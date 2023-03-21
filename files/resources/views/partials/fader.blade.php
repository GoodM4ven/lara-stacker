<div
    x-data="{ show: true }"
    x-show="show"
    x-transition:enter="transition ease-out duration-1000"
    x-transition:enter-start="opacity-0"
    x-transition:enter-end="opacity-100"
    x-transition:leave="transition ease-in duration-1000"
    x-transition:leave-start="opacity-100"
    x-transition:leave-end="opacity-0"
    x-init="$nextTick(() => show = false)"
    class="fixed inset-0 bg-white z-[99]"
></div>
