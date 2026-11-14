"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchPlaceholderView = exports.CYLSearchPlaceholderMessage = exports.CYLSearchPlaceholderStyle = exports.CYLSearchPlaceholderKind = void 0;
const { $r } = require("./CYLSearchResourceReference");
const CYLSearchResources_1 = require("./CYLSearchResources");
/**
 * The common placeholder kinds: an empty list, no search results, or an error (iOS `CYLSearchPlaceholderKind`).
 */
var CYLSearchPlaceholderKind;
(function (CYLSearchPlaceholderKind) {
    /**
     * Nothing to show yet.
     */
    CYLSearchPlaceholderKind[CYLSearchPlaceholderKind["empty"] = 0] = "empty";
    /**
     * The search found nothing.
     */
    CYLSearchPlaceholderKind[CYLSearchPlaceholderKind["noResults"] = 1] = "noResults";
    /**
     * Loading failed.
     */
    CYLSearchPlaceholderKind[CYLSearchPlaceholderKind["error"] = 2] = "error";
})(CYLSearchPlaceholderKind || (exports.CYLSearchPlaceholderKind = CYLSearchPlaceholderKind = {}));
/**
 * The image of a placeholder (iOS `CYLSearchPlaceholderStyle`); each style has a system symbol on HarmonyOS.
 */
var CYLSearchPlaceholderStyle;
(function (CYLSearchPlaceholderStyle) {
    /**
     * The `empty` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["empty"] = 0] = "empty";
    /**
     * The `noResults` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["noResults"] = 1] = "noResults";
    /**
     * The `error` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["error"] = 2] = "error";
    /**
     * The `wifiOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["wifiOff"] = 3] = "wifiOff";
    /**
     * The `signalWifiOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["signalWifiOff"] = 4] = "signalWifiOff";
    /**
     * The `noInternet` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["noInternet"] = 5] = "noInternet";
    /**
     * The `cloudOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["cloudOff"] = 6] = "cloudOff";
    /**
     * The `syncProblem` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["syncProblem"] = 7] = "syncProblem";
    /**
     * The `syncDisabled` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["syncDisabled"] = 8] = "syncDisabled";
    /**
     * The `networkLocked` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["networkLocked"] = 9] = "networkLocked";
    /**
     * The `bluetoothDisabled` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["bluetoothDisabled"] = 10] = "bluetoothDisabled";
    /**
     * The `locationOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["locationOff"] = 11] = "locationOff";
    /**
     * The `publicOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["publicOff"] = 12] = "publicOff";
    /**
     * The `errorOutline` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["errorOutline"] = 13] = "errorOutline";
    /**
     * The `warning` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["warning"] = 14] = "warning";
    /**
     * The `reportProblem` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["reportProblem"] = 15] = "reportProblem";
    /**
     * The `blocked` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["blocked"] = 16] = "blocked";
    /**
     * The `help` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["help"] = 17] = "help";
    /**
     * The `hourglass` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["hourglass"] = 18] = "hourglass";
    /**
     * The `locked` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["locked"] = 19] = "locked";
    /**
     * The `visibilityOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["visibilityOff"] = 20] = "visibilityOff";
    /**
     * The `searchOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["searchOff"] = 21] = "searchOff";
    /**
     * The `folderOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["folderOff"] = 22] = "folderOff";
    /**
     * The `folderOpen` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["folderOpen"] = 23] = "folderOpen";
    /**
     * The `downloadOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["downloadOff"] = 24] = "downloadOff";
    /**
     * The `uploadOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["uploadOff"] = 25] = "uploadOff";
    /**
     * The `inbox` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["inbox"] = 26] = "inbox";
    /**
     * The `brokenImage` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["brokenImage"] = 27] = "brokenImage";
    /**
     * The `imageUnavailable` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["imageUnavailable"] = 28] = "imageUnavailable";
    /**
     * The `photoLibrary` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["photoLibrary"] = 29] = "photoLibrary";
    /**
     * The `musicOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["musicOff"] = 30] = "musicOff";
    /**
     * The `videoOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["videoOff"] = 31] = "videoOff";
    /**
     * The `personOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["personOff"] = 32] = "personOff";
    /**
     * The `groupOff` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["groupOff"] = 33] = "groupOff";
    /**
     * The `eventBusy` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["eventBusy"] = 34] = "eventBusy";
    /**
     * The `emptyCart` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["emptyCart"] = 35] = "emptyCart";
    /**
     * The `favorite` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["favorite"] = 36] = "favorite";
    /**
     * The `batteryAlert` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["batteryAlert"] = 37] = "batteryAlert";
    /**
     * The `unknownDevice` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["unknownDevice"] = 38] = "unknownDevice";
    /**
     * The `phoneDisabled` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["phoneDisabled"] = 39] = "phoneDisabled";
    /**
     * The `wrongLocation` image.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["wrongLocation"] = 40] = "wrongLocation";
    /**
     * The number of styles.
     */
    CYLSearchPlaceholderStyle[CYLSearchPlaceholderStyle["count"] = 41] = "count";
})(CYLSearchPlaceholderStyle || (exports.CYLSearchPlaceholderStyle = CYLSearchPlaceholderStyle = {}));
/**
 * The localized message of a placeholder (iOS `CYLSearchPlaceholderMessage`).
 */
var CYLSearchPlaceholderMessage;
(function (CYLSearchPlaceholderMessage) {
    /**
     * "No data".
     */
    CYLSearchPlaceholderMessage[CYLSearchPlaceholderMessage["empty"] = 0] = "empty";
    /**
     * "No matching results".
     */
    CYLSearchPlaceholderMessage[CYLSearchPlaceholderMessage["noResults"] = 1] = "noResults";
    /**
     * "Something went wrong".
     */
    CYLSearchPlaceholderMessage[CYLSearchPlaceholderMessage["error"] = 2] = "error";
    /**
     * "Check your internet connection".
     */
    CYLSearchPlaceholderMessage[CYLSearchPlaceholderMessage["network"] = 3] = "network";
})(CYLSearchPlaceholderMessage || (exports.CYLSearchPlaceholderMessage = CYLSearchPlaceholderMessage = {}));
const STYLE_NAMES = [
    'Empty',
    'NoResults',
    'Error',
    'WifiOff',
    'SignalWifiOff',
    'NoInternet',
    'CloudOff',
    'SyncProblem',
    'SyncDisabled',
    'NetworkLocked',
    'BluetoothDisabled',
    'LocationOff',
    'PublicOff',
    'ErrorOutline',
    'Warning',
    'ReportProblem',
    'Blocked',
    'Help',
    'Hourglass',
    'Locked',
    'VisibilityOff',
    'SearchOff',
    'FolderOff',
    'FolderOpen',
    'DownloadOff',
    'UploadOff',
    'Inbox',
    'BrokenImage',
    'ImageUnavailable',
    'PhotoLibrary',
    'MusicOff',
    'VideoOff',
    'PersonOff',
    'GroupOff',
    'EventBusy',
    'EmptyCart',
    'Favorite',
    'BatteryAlert',
    'UnknownDevice',
    'PhoneDisabled',
    'WrongLocation'
];
/**
 * An image above a message, centered: the empty, no-result and error states of a list (iOS
 * `CYLSearchPlaceholderView`). This class is the placeholder's content; `CYLSearchPlaceholderComponent` draws it.
 */
class CYLSearchPlaceholderView {
    /**
     * Your own image and text (iOS `-initWithImage:text:`).
     */
    constructor(image, text) {
        /**
         * The image, a system symbol drawn 80 vp high in the secondary text color.
         */
        this.image = undefined;
        /**
         * The message.
         */
        this.text = '';
        this.image = image;
        this.text = text;
    }
    /**
     * A placeholder of a common kind with its built-in image and message (iOS `-initWithKind:`).
     */
    static withKind(kind) {
        if (kind === CYLSearchPlaceholderKind.noResults) {
            return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.noResults, CYLSearchPlaceholderMessage.noResults);
        }
        if (kind === CYLSearchPlaceholderKind.error) {
            return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.error, CYLSearchPlaceholderMessage.error);
        }
        return CYLSearchPlaceholderView.withStyleMessage(CYLSearchPlaceholderStyle.empty, CYLSearchPlaceholderMessage.empty);
    }
    /**
     * A built-in image with a built-in message (iOS `-initWithStyle:message:`).
     */
    static withStyleMessage(style, message) {
        return new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style), CYLSearchPlaceholderView.textForMessage(message));
    }
    /**
     * A built-in image with your own text (iOS `-initWithStyle:text:`).
     */
    static withStyleText(style, text) {
        return new CYLSearchPlaceholderView(CYLSearchPlaceholderView.imageForStyle(style), text);
    }
    /**
     * Your own image with a built-in message (iOS `-initWithImage:message:`).
     */
    static withImageMessage(image, message) {
        return new CYLSearchPlaceholderView(image, CYLSearchPlaceholderView.textForMessage(message));
    }
    /**
     * The name of the image of a style, as on iOS ("CYLSearchNoResults"); (iOS `+imageNameForStyle:`).
     */
    static imageNameForStyle(style) {
        const index = style;
        return index >= 0 && index < STYLE_NAMES.length ? `CYLSearch${STYLE_NAMES[index]}` : 'CYLSearchEmpty';
    }
    /**
     * The system symbol of a style.
     */
    static imageForStyle(style) {
        const symbols = [
            $r('sys.symbol.archivebox'),
            $r('sys.symbol.magnifyingglass'),
            $r('sys.symbol.exclamationmark_circle'),
            $r('sys.symbol.wifi_slash'),
            $r('sys.symbol.wifi_slash'),
            $r('sys.symbol.wifi_slash'),
            $r('sys.symbol.icloud_slash'),
            $r('sys.symbol.exclamationmark_triangle'),
            $r('sys.symbol.nosign'),
            $r('sys.symbol.lock'),
            $r('sys.symbol.bluetooth_slash'),
            $r('sys.symbol.map_slash'),
            $r('sys.symbol.nosign'),
            $r('sys.symbol.exclamationmark_circle'),
            $r('sys.symbol.exclamationmark_triangle'),
            $r('sys.symbol.exclamationmark_triangle'),
            $r('sys.symbol.nosign'),
            $r('sys.symbol.questionmark_circle'),
            $r('sys.symbol.hourglass'),
            $r('sys.symbol.lock'),
            $r('sys.symbol.eye_slash'),
            $r('sys.symbol.magnifyingglass'),
            $r('sys.symbol.folder'),
            $r('sys.symbol.folder'),
            $r('sys.symbol.arrow_down_circle'),
            $r('sys.symbol.arrow_up_circle'),
            $r('sys.symbol.archivebox'),
            $r('sys.symbol.picture'),
            $r('sys.symbol.picture'),
            $r('sys.symbol.picture'),
            $r('sys.symbol.nosign'),
            $r('sys.symbol.video'),
            $r('sys.symbol.person_2'),
            $r('sys.symbol.person_2'),
            $r('sys.symbol.calendar'),
            $r('sys.symbol.cart'),
            $r('sys.symbol.heart'),
            $r('sys.symbol.battery'),
            $r('sys.symbol.questionmark_circle'),
            $r('sys.symbol.phone'),
            $r('sys.symbol.map_slash')
        ];
        const index = style;
        return index >= 0 && index < symbols.length ? symbols[index] : symbols[0];
    }
    /**
     * The text of a built-in message, as a resource that follows the app's language.
     */
    static textForMessage(message) {
        if (message === CYLSearchPlaceholderMessage.noResults) {
            return $r('app.string.cyl_placeholder_search');
        }
        if (message === CYLSearchPlaceholderMessage.error) {
            return $r('app.string.cyl_placeholder_error');
        }
        if (message === CYLSearchPlaceholderMessage.network) {
            return $r('app.string.cyl_placeholder_network');
        }
        return $r('app.string.cyl_placeholder_empty');
    }
    /**
     * The text of a built-in message as a string, in the app's language.
     */
    static localizedTextForMessage(context, message) {
        var _a;
        const keys = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];
        return CYLSearchResources_1.CYLSearchResources.localizedString(context, (_a = keys[message]) !== null && _a !== void 0 ? _a : keys[0]);
    }
}
exports.CYLSearchPlaceholderView = CYLSearchPlaceholderView;
