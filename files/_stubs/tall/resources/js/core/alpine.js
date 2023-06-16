import Alpine from 'alpinejs';
import Mask from '@alpinejs/mask';
import Intersect from '@alpinejs/intersect';
import Persist from '@alpinejs/persist';
import Focus from '@alpinejs/focus';
import Collapse from '@alpinejs/collapse';
import Morph from '@alpinejs/morph';
import Hooks from '@ryangjchandler/alpine-hooks';

Alpine.plugin(Mask);
Alpine.plugin(Intersect);
Alpine.plugin(Persist);
Alpine.plugin(Focus);
Alpine.plugin(Collapse);
Alpine.plugin(Morph);
Alpine.plugin(Hooks);

window.Alpine = Alpine;
