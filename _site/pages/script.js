document.addEventListener("DOMContentLoaded", () => {
    const overlay = document.getElementById("popup-overlay");
    const popupCode = document.querySelector("#popup-content code");
    const closeBtn = document.getElementById("popup-close");

    document.querySelectorAll(".code-btn").forEach(btn => {
        btn.addEventListener("click", () => {
            const file = btn.getAttribute("data-file");

            // Load external Lua file
            fetch(`./code/${file}`)
                .then(res => res.text())
                .then(code => {
                    popupCode.textContent = code;
                    Prism.highlightElement(popupCode);
                    overlay.style.display = "flex";
                })
                .catch(err => {
                    popupCode.textContent = "Error loading code file.";
                    overlay.style.display = "flex";
                });
        });
    });

    closeBtn.addEventListener("click", () => overlay.style.display = "none");
    overlay.addEventListener("click", e => {
        if (e.target === overlay) overlay.style.display = "none";
    });
});
