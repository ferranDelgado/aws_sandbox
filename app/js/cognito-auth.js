window.appData = window.appData || {}
const appData = window.appData

window.onload = function () {
    console.log("windows loaded")
    const poolData = {
        UserPoolId: 'eu-west-1_DopT4TPns',
        ClientId: '5bk18ktmagv5vgfeit8q98ivma'
    };

    const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

    if (typeof AWSCognito !== 'undefined') {
        AWSCognito.config.region = "eu-west-1";
    } else {
        console.log(AWSCognito)
    }


    appData.signOut = function signOut() {
        userPool.getCurrentUser().signOut();
    };

    appData.authToken = new Promise(function fetchCurrentAuthToken(resolve, reject) {
        const cognitoUser = userPool.getCurrentUser();

        if (cognitoUser) {
            cognitoUser.getSession(function sessionCallback(err, session) {
                if (err) {
                    reject(err);
                } else if (!session.isValid()) {
                    resolve(null);
                } else {
                    resolve(session.getIdToken().getJwtToken());
                }
            });
        } else {
            resolve(null);
        }
    });

    appData.authToken.then(function setAuthToken(token) {
        if (token) {
            console.log("Token " + token)
        } else {
            console.log("not log in")
            // window.location.href = '/signin.html';
        }
    }).catch(function handleTokenError(error) {
        alert(error);
        //window.location.href = '/signin.html';
    });

    const password = "Static-Password-123"

    appData.register = function (email, onSuccess, onFailure) {
        console.log("Registering " + email)
        const dataEmail = {
            Name: 'email',
            Value: email
        };
        const attributeEmail = new AmazonCognitoIdentity.CognitoUserAttribute(dataEmail);

        userPool.signUp(toUsername(email), password, [attributeEmail], null,
            function signUpCallback(err, result) {
                if (!err) {
                    onSuccess(result);
                } else {
                    onFailure(err);
                }
            }
        );
    }

    appData.verifyCode = function (email, code, onSuccess, onFailure) {
        createCognitoUser(email).confirmRegistration(code, true, function confirmCallback(err, result) {
            if (!err) {
                onSuccess(result);
            } else {
                onFailure(err);
            }
        });
    }

    appData.login = function(email, onSuccess, onFailure) {
        console.log("Log in with " + email)
        const authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails({
            Username: toUsername(email),
            Password: password
        });

        const cognitoUser = createCognitoUser(email);
        cognitoUser.authenticateUser(authenticationDetails, {
            onSuccess: onSuccess,
            onFailure: onFailure
        });
    }

    function createCognitoUser(email) {
        return new AmazonCognitoIdentity.CognitoUser({
            Username: toUsername(email),
            Pool: userPool
        });
    }

    function toUsername(email) {
        return email.replace('@', '-at-');
    }

}