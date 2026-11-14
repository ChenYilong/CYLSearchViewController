"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.$r = void 0;
const { CYLSearchResources } = require("./CYLSearchResources");
// System symbols of the HarmonyOS models -> the package's images (src/images).
const SYMBOLS = {
    magnifyingglass: 'search', mic: 'mic', camera: 'camera', chevron_backward: 'back', xmark_circle_fill: 'clear',
    arrow_right: 'submit', trash: 'trash', archivebox: 'empty', exclamationmark_circle: 'error',
    exclamationmark_triangle: 'error', wifi_slash: 'network', icloud_slash: 'network', bluetooth_slash: 'network',
    map_slash: 'network', nosign: 'error', lock: 'error', eye_slash: 'error', questionmark_circle: 'error',
};
// System colors -> CSS colors (light appearance; the components follow the page's colors).
const COLORS = { comp_divider: '#e5e5ea', comp_background_primary: '#ffffff' };
/**
 * Resolves a resource reference of the HarmonyOS models (ArkUI `$r`): `app.string.cyl_x` gives the localized
 * string, `sys.symbol.x` an image path of this package (a generic icon when it has none), `sys.color.x` a CSS color.
 */
function $r(reference) {
    const [scope, kind, name] = String(reference).split('.');
    if (kind === 'string') {
        return CYLSearchResources.localizedString(undefined, name.replace(/^cyl_/, '').replace(/_/g, '.'));
    }
    if (kind === 'symbol') {
        return `${CYLSearchResources.imageRoot}/${SYMBOLS[name] || 'empty'}.svg`;
    }
    if (kind === 'color') {
        return COLORS[name] || '#8e8e93';
    }
    return scope === 'app' ? name : undefined;
}
exports.$r = $r;
