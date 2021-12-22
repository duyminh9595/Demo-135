'use strict';
const log4js = require('log4js');
const logger = log4js.getLogger('BasicNetwork');
const bodyParser = require('body-parser');
const http = require('http')
const util = require('util');
const express = require('express')
const app = express();
const expressJWT = require('express-jwt');
const jwt = require('jsonwebtoken');
const bearerToken = require('express-bearer-token');
const cors = require('cors');
const constants = require('./config/constants.json')

const host = process.env.HOST || constants.host;
const port = process.env.PORT || constants.port;


const bcrypt = require('bcrypt')

const helper = require('./app/helper')
const invoke = require('./app/invoke')
const register = require('./app/register')
const qscc = require('./app/qscc')
const query = require('./app/query')


const login = require('./app/login')

app.options('*', cors());
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: false
}));
// set secret variable
app.set('secret', 'thisismysecret');
app.use(expressJWT({
    secret: 'thisismysecret'
}).unless({
    path: ['/users', '/users/login', '/register']
}));
app.use(bearerToken());

logger.level = 'debug';


app.use((req, res, next) => {
    logger.debug('New req for %s', req.originalUrl);
    if (req.originalUrl.indexOf('/users') >= 0 || req.originalUrl.indexOf('/login') >= 0 || req.originalUrl.indexOf('/register') >= 0) {
        return next();
    }
    var token = req.token;
    jwt.verify(token, app.get('secret'), (err, decoded) => {
        if (err) {
            console.log(`Error ================:${err}`)
            res.send({
                success: false,
                message: 'Failed to authenticate token. Make sure to include the ' +
                    'token returned from /users call in the authorization header ' +
                    ' as a Bearer token'
            });
            return;
        } else {
            req.username = decoded.username;
            req.orgname = decoded.orgName;
            logger.debug(util.format('Decoded from JWT token: username - %s, orgname - %s', decoded.username, decoded.orgName));
            return next();
        }
    });
});

var server = http.createServer(app).listen(port, function () { console.log(`Server started on ${port}`) });
logger.info('****************** SERVER STARTED ************************');
logger.info('***************  http://%s:%s  ******************', host, port);
server.timeout = 240000;

function getErrorMessage(field) {
    var response = {
        success: false,
        message: field + ' field is missing or Invalid in the request'
    };
    return response;
}

// Register and enroll user
app.post('/users', async function (req, res) {
    var username = req.body.username;
    var orgName = req.body.orgName;
    var password = req.body.password;
    logger.debug('End point : /users');
    logger.debug('User name : ' + username);
    logger.debug('Org name  : ' + orgName);
    logger.debug('Password  : ' + password);
    if (!username) {
        res.json(getErrorMessage('\'username\''));
        return;
    }
    if (!orgName) {
        res.json(getErrorMessage('\'orgName\''));
        return;
    }

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: orgName
    }, app.get('secret'));

    let response = await helper.getRegisteredUser(username, orgName, true);
    var salt = bcrypt.genSaltSync(10)
    var hash = bcrypt.hashSync(req.body.password, salt)
    logger.debug('Password has : ' + hash);
    logger.debug('-- returned from registering the username %s for organization %s', username, "thayson");
    if (response && typeof response !== 'string') {
        logger.debug('Successfully registered the username %s for organization %s', username, "thayson");
        let message = await register.invokeTransaction("mychannel", "thesis", "registerUser", username, hash);
        console.log(`message result is : ${message}`)

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);
    } else {
        logger.debug('Failed to register the username %s for organization %s with::%s', username, orgName, response);
        res.json({ success: false, message: response });
    }

});

// Register and enroll user
app.post('/register', async function (req, res) {
    var username = req.body.username;
    var password = req.body.password;
    logger.debug('End point : /users');
    logger.debug('User name : ' + username);
    logger.debug('Org name  : ' + "Thay Son");
    logger.debug('Password  : ' + password);
    if (!username) {
        res.json(getErrorMessage('\'username\''));
        return;
    }
    if (!orgName) {
        res.json(getErrorMessage('\'orgName\''));
        return;
    }

    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: "Thay Son"
    }, app.get('secret'));

    let response = await helper.getRegisteredUser(username, orgName, true);
    var salt = bcrypt.genSaltSync(10)
    var hash = bcrypt.hashSync(req.body.password, salt)
    logger.debug('Password has : ' + hash);
    logger.debug('-- returned from registering the username %s for organization %s', username, "thayson");
    if (response && typeof response !== 'string') {
        logger.debug('Successfully registered the username %s for organization %s', username, "thayson");
        let message = await register.invokeTransaction("mychannel", "thesis", "registerUser", username, hash);
        console.log(`message result is : ${message}`)

        const response_payload = {
            result: message,
            error: null,
            errorData: null
        }
        res.send(response_payload);
    } else {
        logger.debug('Failed to register the username %s for organization %s with::%s', username, orgName, response);
        res.json({ success: false, message: response });
    }
});

//login
app.post('/login', async function (req, res) {
    var username = req.body.username;
    var password = req.body.password;
    logger.debug('End point : /users');
    logger.debug('User name : ' + username);
    logger.debug('Password  : ' + password);
    var token = jwt.sign({
        exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
        username: username,
        orgName: "Thay Son"
    }, app.get('secret'));
    let isUserRegistered = await helper.isUserRegistered(username, orgName);
    if (isUserRegistered) {
        let message = await login.query("mychannel", "thesis", "queryUser", username, "thayson");
        var salt = bcrypt.genSaltSync(10)
        var check = bcrypt.compareSync(password, message.password);
        console.log(check)
        if (check) {
            var token = jwt.sign({
                exp: Math.floor(Date.now() / 1000) + parseInt(constants.jwt_expiretime),
                username: username,
                orgName: "Thay Son"
            }, app.get('secret'));
            res.status(200).json({
                result: token,
                error: "Thành công"
            })
        }
        else {
            res.status(403).json({
                error: "Sai email or mk"
            })
        }
    } else {
        res.json({ success: false, message: `User with username ${username} is not registered with thay son, Please register first.` });
    }
})