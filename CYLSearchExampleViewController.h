#import <CYLSearchViewController/CYLSearchResultsViewController.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CYLSearchExampleRefreshing <NSObject>

- (void)reloadWithCompletion:(void (^)(NSError * _Nullable error))completion;

@end

@interface CYLSearchExampleDataSource : NSObject <CYLSearchResultsDataSource, CYLSearchExampleRefreshing>
@end

@interface CYLSearchExampleViewController : CYLSearchResultsViewController

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)searchDataSource
                        refreshProvider:(id<CYLSearchExampleRefreshing>)refreshProvider;
- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)searchDataSource NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
