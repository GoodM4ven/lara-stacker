<div
    id="tall-fader"
    class="fixed inset-0 z-[99] bg-white transition-opacity duration-1000 pointer-events-none"
></div>

@push('scripts')
    <script>
        document.fonts.ready.then(() => {
            setTimeout(() => {
                const fader = document.getElementById('tall-fader');

                fader.classList.add('opacity-0');
                setTimeout(() => fader.remove(), 500);
            }, 500);
        });
    </script>
@endpush
