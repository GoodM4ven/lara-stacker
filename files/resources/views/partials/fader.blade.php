<div
    id="tall-stacker-fader"
    class="fixed inset-0 z-[99] bg-white transition-opacity duration-1000"
></div>

@push('scripts')
    <script>
        document.fonts.ready.then(() => {
            setTimeout(() => {
                document.getElementById('tall-stacker-fader').classList.add('opacity-0');
            }, 500);
        });
    </script>
@endpush
