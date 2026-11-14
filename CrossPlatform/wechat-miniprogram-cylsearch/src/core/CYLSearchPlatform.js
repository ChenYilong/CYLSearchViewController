"use strict";
// The ArkUI names the models were written against (animateTo, Curve, TextInputController, focusControl, InputType,
// EnterKeyType, TextOverflow), for the mini program: plain values the components read.
Object.defineProperty(exports, "__esModule", { value: true });
exports.Curve = exports.animateTo = void 0;
/**
 * The animation curves the models name (ArkUI `Curve`); the components map them to CSS timing functions.
 */
exports.Curve = Object.freeze({ EaseIn: 'ease-in', EaseOut: 'ease-out', EaseInOut: 'ease-in-out', Linear: 'linear' });
/**
 * Applies `changes` at once (the components animate the result with CSS transitions of `options.duration` ms) and
 * calls `options.onFinish` when that time is over, like ArkUI `animateTo`.
 */
function animateTo(options, changes) {
    changes();
    if (options && typeof options.onFinish === 'function') {
        setTimeout(options.onFinish, Math.max(0, options.duration || 0));
    }
}
exports.animateTo = animateTo;
/**
 * The text field's controller (ArkUI `TextInputController`): the component reads `focused` into the `<input>`'s
 * `focus` and the caret into its `cursor`.
 */
class TextInputController {
    constructor() {
        this.focused = false;
        this.caret = -1;
    }
    caretPosition(value) {
        this.caret = value;
    }
    stopEditing() {
        this.focused = false;
    }
}
exports.TextInputController = TextInputController;
/**
 * Moves the focus to a field by its id (ArkUI `focusControl`); a component registers its field's controller here.
 */
exports.focusControl = {
    fields: {},
    requestFocus(id) {
        const field = exports.focusControl.fields[id];
        if (field) {
            field.focused = true;
        }
        return field !== undefined;
    },
};
/**
 * The `<input>` type of the field (ArkUI `InputType`): the component maps it to the `type` attribute.
 */
exports.InputType = Object.freeze({ Normal: 'text', Number: 'number', PhoneNumber: 'number', Email: 'text', Password: 'safe-password' });
/**
 * The return key (ArkUI `EnterKeyType`): the component maps it to `confirm-type`.
 */
exports.EnterKeyType = Object.freeze({ Search: 'search', Done: 'done', Go: 'go', Next: 'next', Send: 'send' });
/**
 * How a long title ends (ArkUI `TextOverflow`): the component maps it to `text-overflow`.
 */
exports.TextOverflow = Object.freeze({ None: 'clip', Clip: 'clip', Ellipsis: 'ellipsis', MARQUEE: 'clip' });
