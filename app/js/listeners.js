const registerUser = () => {
    const email = (document.getElementById("email-input").value || "").trim()

    const onSuccess = function registerSuccess(result) {
        const cognitoUser = result.user;
        console.log('user name is ' + cognitoUser.getUsername());
        const confirmation = ('Registration successful. Please check your email inbox or spam folder for your verification code.');
        if (confirmation) {
            document.getElementById("result-container").innerHTML = confirmation
        }
    };

    const onFailure = function registerFailure(err) {
        alert(err);
    };

    if(typeof window.appData !== 'undefined' && email.length > 0) {
        window.appData.register(email, onSuccess, onFailure)
    } else {
        const message = "Error windows.app " + window.appData
        document.getElementById("result-container").innerHTML = message;
    }
}

const login = () => {
    const email = (document.getElementById("email-input").value || "").trim()
    if(typeof window.appData !== 'undefined' && email.length > 0) {
        window.appData.login(email,
            function signinSuccess() {
                console.log('Successfully Logged In');
                document.getElementById("result-container").innerHTML = 'Successfully Logged In'
            },
            function signinError(err) {
                alert(err);
            }
        )
    } else {
        document.getElementById("result-container").innerHTML = "Error";
    }
}

const verifyCode = () => {
    const email = (document.getElementById("email-input").value || "").trim()
    const code = (document.getElementById("code-input").value || "").trim()
    if(typeof window.appData !== 'undefined' && code.length > 0) {
        window.appData.verifyCode(email, code,
            function verifySuccess(result) {
                console.log('call result: ' + result);
                console.log('Successfully verified');
                alert('Verification successful. You will now be redirected to the login page.');
            },
            function verifyError(err) {
                alert(err);
            }
        )
    } else {
        document.getElementById("result-container").innerHTML = "Error";
    }
}