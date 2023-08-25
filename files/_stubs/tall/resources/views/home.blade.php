<x-app>
    <div
        class="flex min-h-screen flex-col justify-center bg-background-1 py-8 transition dark:bg-dark-background-1 sm:py-12 sm:px-6 lg:px-8">
        <div class="flex items-center justify-center">
            <div class="flex flex-col justify-around">
                <div class="space-y-6 flex flex-col items-center">
                    <button
                        type="button"
                        class="w-fit flex ml-auto mr-auto transform"
                        x-init="$animateReset(0)"
                        x-data="{ isAnimating: false }"
                        x-on:mouseenter="
                            if (isAnimating) return;

                            isAnimating = true;
                            $animate(0.7);
                        "
                        x-on:mouseleave="
                            $animateReset(0.7);
                            isAnimating = false;
                        "
                        x-animate="{
                            opacity: '1.0',
                            transform: 'scale(1.0)',
                        }"
                        x-animate.reset="{
                            opacity: '0.7',
                            transform: 'scale(0.9)',
                        }"
                        x-on:click="
                            toggleDarkMode();
                            Alpine.evaluate(document.getElementById('tall-text'), '$animate(0.4)');
                        "
                    >
                        <x-icon
                            name="laravel"
                            class="mx-auto h-16 fill-primary-600 dark:fill-dark-primary-500"
                        />
                    </button>

                    <a
                        href="https://tallstack.dev"
                        target="_blank"
                        class="inline-flex w-min"
                    >
                        <h1
                            class="flex w-fit whitespace-pre-line text-center text-3xl font-extrabold tracking-wider dark:text-background-1 sm:pb-2 sm:text-5xl"
                            id="tall-text"
                            x-init="$animateReset(0)"
                            x-data="{ isAnimating: false }"
                            x-on:mouseenter="
                                if (isAnimating) return;

                                isAnimating = true;
                                $animate(0.4);
                            "
                            x-on:mouseleave="
                                $animateReset(0.4);
                                isAnimating = false;
                            "
                            x-animate="isDarkMode ? {
                                color: '#f3f4f6',
                                transform: 'scale(1.0)',
                            } : {
                                color: '#111827',
                                transform: 'scale(1.0)',
                            }"
                            x-animate.reset="isDarkMode ? {
                                color: '#e5e7eb',
                                transform: 'scale(0.9)',
                            } : {
                                color: '#4b5563',
                                transform: 'scale(0.9)',
                            }"
                        >T
                            A
                            L
                            L

                            S
                            T
                            A
                            C
                            K
                        </h1>
                    </a>

                    <div class="flex flex-col space-y-1 text-center sm:flex-row sm:space-y-0">
                        <x-home.link
                            caption="TailwindCSS"
                            link="https://tailwindcss.com"
                        />
                        <x-home.link
                            caption="Alpine.js"
                            link="https://alpinejs.dev"
                        />
                        <x-home.link
                            caption="Livewire"
                            link="https://livewire.laravel.com"
                        />
                        <x-home.link
                            caption="Laravel"
                            link="https://laravel.com"
                        />
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app>
