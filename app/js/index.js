document.addEventListener('DOMContentLoaded', function () {
    const maxValueInput = document.getElementById("max-value-input");
    let maxRandomValue = 10

    function refreshTitle() {
        document.getElementById("title-header").innerHTML = "Random value between 0 and " + maxRandomValue
    }

    function generateRandom() {
        document.getElementById("random-number").innerHTML = (Math.random() * maxRandomValue) | 0
    }

    document.getElementById("run-btn").addEventListener("click", generateRandom, false);

    maxValueInput.addEventListener('input', (event) => {
        maxRandomValue = maxValueInput.value
        refreshTitle()
    });

    generateRandom()
    refreshTitle()
}, false);