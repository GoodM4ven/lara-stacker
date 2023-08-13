import tippy from 'tippy.js';

Alpine.magic('tippy', (el) => {
    return (content, duration = 400) => {
        return tippy(el, {
            // trigger: 'manual',
            theme: 'material',
            animation: 'shift-toward',
            duration: duration,
            // allowHTML: true,
            content: content,
        });
    };
});

window.Tippy = tippy;
