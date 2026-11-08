#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CYLSearchResultsViewController;

@protocol CYLSearchResultsDataSource <NSObject>

- (NSArray *)searchResultsViewController:(CYLSearchResultsViewController *)controller
                         resultsForQuery:(NSString *)query;
- (void)searchResultsViewController:(CYLSearchResultsViewController *)controller
                     configureCell:(UITableViewCell *)cell
                        withResult:(id)result;

@optional
- (void)searchResultsViewController:(CYLSearchResultsViewController *)controller
                   didSelectResult:(id)result;

@end

@interface CYLSearchResultsViewController : UITableViewController

@property (nonatomic, strong, readonly) id<CYLSearchResultsDataSource> searchDataSource;
@property (nonatomic, strong, readonly) UISearchController *searchController;
@property (nonatomic, copy, readonly) NSArray *searchResults;

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)searchDataSource NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// Requeries the data source using the current search text and reloads the table.
- (void)reloadSearchResults;

/// Override to integrate a custom table reload, such as an empty-state provider.
- (void)reloadResultsTableView;

@end

NS_ASSUME_NONNULL_END
