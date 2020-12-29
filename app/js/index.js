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
                console.log(jsondata)
                success(jsondata.message)
                // document.getElementById("result-container").innerHTML = jsondata.message;
            } else if(failure) {
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
        })
    }

    function getCall(event) {
        event.preventDefault()
        const apiUrl = document.getElementById("url-input").value
        ajax(apiUrl, "GET", (message) => {
            document.getElementById("result-container").innerHTML = message;
        })
    }

    function ajaxCall2(event) {
        const method = document.querySelector("input[name=call-method]:checked").value
        console.log(method)
    }
    function ajaxCall2(event) {
        event.preventDefault()
        const apiUrl = document.getElementById("url-input").value
        if(apiUrl === "") {
            console.error("Please set api url")
            return;
        }
        $.ajax({
            type: 'POST',
            //crossDomain: true,
            // dataType: 'jsonp',
            // responseType:'application/json',
            url: apiUrl,
            contentType: 'application/json',
            success: function(jsondata){
                console.log(jsondata)
                document.getElementById("result-container").innerHTML = jsondata.message;
            },
            error: function (e) {
                console.log(e)
            }
        })
        // const xhttp = new XMLHttpRequest();
        // xhttp.onreadystatechange = function() {
        //     console.log(this.status)
        //     if (this.readyState === 4 && this.status === 200) {
        //         console.log(this.responseText)
        //         document.getElementById("demo").innerHTML = this.responseText;
        //     } else {
        //         console.log(this)
        //     }
        // };
        // xhttp.open("GET", apiUrl, true);
        // xhttp.send();
    }

    document.getElementById("run-btn").addEventListener("click", generateRandom, false);
    document.getElementById("call-btn").addEventListener("click", postCall, false);

    maxValueInput.addEventListener('input', (event) => {
        maxRandomValue = maxValueInput.value
        refreshTitle()
    });

    generateRandom()
    refreshTitle()
}, false);