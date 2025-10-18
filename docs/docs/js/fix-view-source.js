// Fix view source button to use /blob/ instead of /raw/
// issue: https://github.com/squidfunk/mkdocs-material/discussions/6850
"use strict";

window.addEventListener("DOMContentLoaded", function() {
    fixViewSourceButton();
});

function fixViewSourceButton() {
    const buttons = document.querySelectorAll("a.md-content__button");

    buttons.forEach(function(button) {
        if (button.href.includes("/raw/")) {
            button.href = button.href.replace("/raw/", "/blob/");
        }
    });
}
