let newVoyageBtn = document.getElementById("new-voyage");
let newVoyageDiv = document.getElementById("new-voyage-div");

let notice = document.getElementById("notice");

function showNotice(text) {
    notice.children[0].innerText = text;
    notice.style.display = "unset";
}

globalThis.newVoyage = function () {
    setCameraState(1);
    newVoyageBtn.classList.add("fade-out");
    newVoyageDiv.classList.add("fade-in");
}

document.forms['new-voyage-form'].addEventListener('submit', (event) => {
    event.preventDefault();
    fetch(event.target.action, {
        method: 'POST',
        body: new URLSearchParams(new FormData(event.target))
    }).then((response) => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    }).then((body) => {
        if (body["error"]) {
            showNotice("Error: " + body["error"]);
            return;
        }
        showNotice("Success!" + JSON.stringify(body));
    }).catch((error) => {
        showNotice("Error: Not success :(");
    });
});