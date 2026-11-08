#import <UIKit/UIKit.h>
#import "CYLSearchResultsViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchController;

@protocol CYLSearchControllerDelegate <NSObject>
@optional
- (void)searchControllerDidCancel:(CYLSearchController *)controller;
@end

/// An animated search overlay that uses the same injectable result source as
/// CYLSearchResultsViewController. Keep the controller while it is presented.
@interface CYLSearchController : UIViewController

@property (nonatomic, weak, nullable) id<CYLSearchControllerDelegate> delegate;
@property (nonatomic, strong, readonly) CYLSearchResultsViewController *resultsViewController;
@property (nonatomic, readonly, getter=isPresented) BOOL presented;

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)dataSource NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// Adds a child navigation controller to the host and animates it into view.
- (void)showInViewController:(UIViewController *)controller;
/// Completion is called after the overlay is removed, including when not presented.
- (void)hide:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
