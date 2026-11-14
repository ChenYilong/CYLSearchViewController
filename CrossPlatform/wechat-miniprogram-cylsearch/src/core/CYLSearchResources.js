"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchResources = void 0;
const STRINGS = require('./CYLSearchStrings');

/**
 * The package's images and localized strings (iOS `CYLSearchResources`, the resource bundle of the pod).
 */
class CYLSearchResources {
    /**
     * The path of a bundled image ("camera", "mic", "search", "back", "clear", "submit", "trash"), or undefined
     * (iOS `+imageNamed:`), relative to a component folder of this package.
     */
    static imageNamed(name) {
        return CYLSearchResources.imageNames.indexOf(name) >= 0 ? `${CYLSearchResources.imageRoot}/${name}.svg` : undefined;
    }
    /**
     * The string for `key` ("search.placeholder") in `language` ("zh-Hans", "ja"…), the system language by default,
     * else English, else the key (iOS `+localizedString:`). The first argument keeps the HarmonyOS signature.
     */
    static localizedString(context, key, language) {
        const name = 'cyl_' + key.replace(/\./g, '_');
        const table = STRINGS[CYLSearchResources.languageFor(language)] || {};
        if (table[name] !== undefined) {
            return table[name];
        }
        return (STRINGS.en || {})[name] !== undefined ? STRINGS.en[name] : key;
    }
    /**
     * The table name for a language tag: "zh_CN", "zh-Hans-CN" give "zh-Hans"; "zh_TW", "zh-HK" give "zh-Hant".
     */
    static languageFor(language) {
        let tag = language;
        if (!tag) {
            try {
                tag = wx.getAppBaseInfo ? wx.getAppBaseInfo().language : wx.getSystemInfoSync().language;
            }
            catch (error) {
                tag = 'en';
            }
        }
        tag = String(tag || 'en').replace(/_/g, '-');
        if (/^zh-(Hant|TW|HK|MO)/i.test(tag)) {
            return 'zh-Hant';
        }
        if (/^zh/i.test(tag)) {
            return 'zh-Hans';
        }
        return tag.split('-')[0];
    }
}
exports.CYLSearchResources = CYLSearchResources;
/**
 * The bundle name (iOS `resourceBundle`).
 */
CYLSearchResources.resourceBundle = 'cylsearch';
/**
 * Where the images are, from a component folder of this package.
 */
CYLSearchResources.imageRoot = '../images';
/**
 * The names `imageNamed` knows.
 */
CYLSearchResources.imageNames = ['camera', 'mic', 'search', 'back', 'clear', 'submit', 'trash'];
