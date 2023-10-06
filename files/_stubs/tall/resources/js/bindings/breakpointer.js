document.addEventListener('alpine:init', () => {
    Alpine.bind('Breakpointer', () => ({
        'x-breakpoint'() {
            if (this.$isBreakpoint('2xl')) {
                this.at2xl = true;
                this.atXl = false;
                this.atLg = false;
                this.atMd = false;
                this.atSm = false;
                this.atMobile = false;
            } else if (this.$isBreakpoint('xl')) {
                this.at2xl = false;
                this.atXl = true;
                this.atLg = false;
                this.atMd = false;
                this.atSm = false;
                this.atMobile = false;
            } else if (this.$isBreakpoint('lg')) {
                this.at2xl = false;
                this.atXl = false;
                this.atLg = true;
                this.atMd = false;
                this.atSm = false;
                this.atMobile = false;
            } else if (this.$isBreakpoint('md')) {
                this.at2xl = false;
                this.atXl = false;
                this.atLg = false;
                this.atMd = true;
                this.atSm = false;
                this.atMobile = false;
            } else if (this.$isBreakpoint('sm')) {
                this.at2xl = false;
                this.atXl = false;
                this.atLg = false;
                this.atMd = false;
                this.atSm = true;
                this.atMobile = false;
            } else {
                this.at2xl = false;
                this.atXl = false;
                this.atLg = false;
                this.atMd = false;
                this.atSm = false;
                this.atMobile = true;
            }
        },
    }));
});
