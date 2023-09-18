<div
    class="fixed inset-0 z-50 bg-white dark:bg-black transition-opacity duration-700"
    x-data="{ shown: true }"
    x-show="shown"
    x-transition:enter="transition ease-out duration-[400ms]"
    x-transition:enter-start="opacity-0"
    x-transition:enter-end="opacity-100"
    x-transition:leave="transition ease-in duration-[400ms]"
    x-transition:leave-start="opacity-100"
    x-transition:leave-end="opacity-0"
    x-init='
        () => {
            if ("fonts" in document) {
                document.fonts.load("1em {{ is_ar() ? "Noto Sans Arabic" : "Ubuntu" }}").then(() => {
                    shown = false;
                });
            } else {
                setTimeout(() => shown = false, 100);
            }

            let anchors = document.querySelectorAll("a.show-fader");
            anchors.forEach(anchor => {
                anchor.addEventListener("click", (e) => shown = true);
            });
        }
    '
></div>
