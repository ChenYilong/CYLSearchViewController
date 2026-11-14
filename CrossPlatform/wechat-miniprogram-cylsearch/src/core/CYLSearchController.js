"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CYLSearchController = exports.CYLSearchControllerDelegate = void 0;
const { animateTo, Curve } = require("./CYLSearchPlatform");
const CYLSearchResultsViewController_1 = require("./CYLSearchResultsViewController");
/**
 * Events of a `CYLSearchController` (iOS `CYLSearchControllerDelegate`).
 */
class CYLSearchControllerDelegate {
    constructor() {
        /**
         * Cancel was tapped and the overlay is gone. Optional.
         */
        this.searchControllerDidCancel = undefined;
    }
}
exports.CYLSearchControllerDelegate = CYLSearchControllerDelegate;
/**
 * An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController` (iOS
 * `CYLSearchController`). This class is the state and API; `CYLSearchOverlayComponent` draws it over its host.
 */
class CYLSearchController {
    /**
     * Creates the overlay with the data source of its results (iOS `-initWithSearchDataSource:`).
     */
    constructor(searchDataSource) {
        var _a;
        /**
         * Receives the cancel event.
         */
        this.delegate = undefined;
        /**
         * The length of the show and hide animations, in seconds. 0.25 by default.
         */
        this.animationDuration = 0.25;
        this.shown = false;
        this.resultsViewController = new CYLSearchResultsViewController_1.CYLSearchResultsViewController(searchDataSource);
        const bar = this.resultsViewController.searchController;
        bar.showsCancelButton = true;
        const textChanged = (_a = bar.delegate) === null || _a === void 0 ? void 0 : _a.searchBarViewTextDidChange;
        bar.delegate = {
            searchBarViewTextDidChange: textChanged,
            searchBarViewCancelButtonClicked: () => {
                this.hide(() => {
                    var _a, _b;
                    (_b = (_a = this.delegate) === null || _a === void 0 ? void 0 : _a.searchControllerDidCancel) === null || _b === void 0 ? void 0 : _b.call(_a, this);
                });
            }
        };
    }
    /**
     * True while the overlay is on screen or animating in (iOS `presented`).
     */
    get isPresented() {
        return this.shown;
    }
    /**
     * Animates the overlay into view over the host that holds its `CYLSearchOverlayComponent`, and starts editing
     * (iOS `-showInViewController:`).
     */
    showInViewController() {
        if (this.shown) {
            return;
        }
        animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseOut }, () => {
            this.shown = true;
        });
        setTimeout(() => {
            this.resultsViewController.searchController.showKeyboard();
        }, this.animationDuration * 1000);
    }
    /**
     * Hides the overlay; the completion is called after it is removed, including when it was not presented.
     */
    hide(completion) {
        if (!this.shown) {
            completion === null || completion === void 0 ? void 0 : completion();
            return;
        }
        this.resultsViewController.searchController.hideKeyboard();
        animateTo({
            duration: this.animationDuration * 1000,
            curve: Curve.EaseIn,
            onFinish: () => {
                completion === null || completion === void 0 ? void 0 : completion();
            }
        }, () => {
            this.shown = false;
        });
    }
}
exports.CYLSearchController = CYLSearchController;
