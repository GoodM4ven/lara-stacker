import { Livewire, Alpine } from '../../../vendor/livewire/livewire/dist/livewire.esm';

import Mask from '@alpinejs/mask';
import Intersect from '@alpinejs/intersect';
import Focus from '@alpinejs/focus';
import Collapse from '@alpinejs/collapse';
import Morph from '@alpinejs/morph';
import Hooks from '@ryangjchandler/alpine-hooks';

Alpine.plugin(Mask);
Alpine.plugin(Intersect);
Alpine.plugin(Focus);
Alpine.plugin(Collapse);
Alpine.plugin(Morph);
Alpine.plugin(Hooks);

window.Alpine = Alpine;
window.Livewire = Livewire;
