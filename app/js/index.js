document.addEventListener('DOMContentLoaded', function () {
    const maxValueInput = document.getElementById("max-value-input");
    let maxRandomValue = 10

    function refreshTitle() {
        document.getElementById("title-header").innerHTML = "Random value between 0 and " + maxRandomValue
    }

    function generateRandom() {
        document.getElementById("random-number").innerHTML = (Math.random() * maxRandomValue) | 0
    }

    function ajax(url, method, success, failure) {
        const xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                const jsondata = JSON.parse(this.responseText);
                success(jsondata.message)
            } else if(this.readyState === 4 && failure) {
                failure()
            }
        };
        xhttp.open(method, url, true);
        xhttp.send();
    }

    function postCall(event) {
        event.preventDefault()
        const apiUrl = document.getElementById("url-input").value
        ajax(apiUrl, "POST", (message) => {
            document.getElementById("result-container").innerHTML = message;
        }, () => {
            document.getElementById("result-container").innerHTML = "Error";
        })
    }

    function getCall(event) {
        event.preventDefault()
        const apiUrl = document.getElementById("url-input").value
        ajax(apiUrl, "GET", (message) => {
            document.getElementById("result-container").innerHTML = message;
        }, () => {
            document.getElementById("result-container").innerHTML = "Error";
        })
    }

    document.getElementById("get-btn").addEventListener("click", getCall, false);
    document.getElementById("post-btn").addEventListener("click", postCall, false);


    document.getElementById("register-btn").addEventListener("click", registerUser, false);
    document.getElementById("log-in-btn").addEventListener("click", login, false);
    document.getElementById("verify-btn").addEventListener("click", verifyCode, false);


    // document.getElementById("log-in-btn").addEventListener("click", () => {
    //     const email = (document.getElementById("email-input").value || "").trim()
    //     if(typeof window.appData !== 'undefined' && email.length > 0) {
    //         window.appData.login(email,
    //             function signinSuccess() {
    //                 console.log('Successfully Logged In');
    //                 document.getElementById("result-container").innerHTML = 'Successfully Logged In'
    //             },
    //             function signinError(err) {
    //                 alert(err);
    //             }
    //         )
    //     } else {
    //         document.getElementById("result-container").innerHTML = "Error";
    //     }
    // }, false);
}, false);