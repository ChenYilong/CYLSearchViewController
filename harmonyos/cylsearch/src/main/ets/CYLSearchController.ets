import { CYLSearchResultsComponent, CYLSearchResultsDataSource, CYLSearchResultsViewController } from './CYLSearchResultsViewController';

/**
 * Events of a `CYLSearchController` (iOS `CYLSearchControllerDelegate`).
 */
export interface CYLSearchControllerDelegate {
  /**
   * Cancel was tapped and the overlay is gone. Optional.
   */
  searchControllerDidCancel?: (controller: CYLSearchController) => void;
}

/**
 * An animated search overlay that uses the same injectable result source as `CYLSearchResultsViewController` (iOS
 * `CYLSearchController`). This class is the state and API; `CYLSearchOverlayComponent` draws it over its host.
 */
@ObservedV2
export class CYLSearchController {
  /**
   * Receives the cancel event.
   */
  delegate: CYLSearchControllerDelegate | undefined = undefined;
  /**
   * The results controller shown inside the overlay.
   */
  readonly resultsViewController: CYLSearchResultsViewController;
  /**
   * The length of the show and hide animations, in seconds. 0.25 by default.
   */
  animationDuration: number = 0.25;

  @Trace private shown: boolean = false;

  /**
   * Creates the overlay with the data source of its results (iOS `-initWithSearchDataSource:`).
   */
  constructor(searchDataSource: CYLSearchResultsDataSource) {
    this.resultsViewController = new CYLSearchResultsViewController(searchDataSource);
    const bar = this.resultsViewController.searchController;
    bar.showsCancelButton = true;
    const textChanged = bar.delegate?.searchBarViewTextDidChange;
    bar.delegate = {
      searchBarViewTextDidChange: textChanged,
      searchBarViewCancelButtonClicked: () => {
        this.hide(() => {
          this.delegate?.searchControllerDidCancel?.(this);
        });
      }
    };
  }

  /**
   * True while the overlay is on screen or animating in (iOS `presented`).
   */
  get isPresented(): boolean {
    return this.shown;
  }

  /**
   * Animates the overlay into view over the host that holds its `CYLSearchOverlayComponent`, and starts editing
   * (iOS `-showInViewController:`).
   */
  showInViewController(): void {
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
  hide(completion?: () => void): void {
    if (!this.shown) {
      completion?.();
      return;
    }
    this.resultsViewController.searchController.hideKeyboard();
    animateTo({
      duration: this.animationDuration * 1000,
      curve: Curve.EaseIn,
      onFinish: () => {
        completion?.();
      }
    }, () => {
      this.shown = false;
    });
  }
}

/**
 * Draws a `CYLSearchController` over the page it is placed on: nothing while hidden, the results page while shown.
 */
@ComponentV2
export struct CYLSearchOverlayComponent {
  /**
   * The controller to draw.
   */
  @Require @Param controller: CYLSearchController;

  build() {
    Stack() {
      if (this.controller.isPresented) {
        Column() {
          CYLSearchResultsComponent({ controller: this.controller.resultsViewController })
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_primary'))
        .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 24 })))
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.controller.isPresented ? HitTestMode.Default : HitTestMode.None)
  }
}
