#import "CYLSearchExampleViewController.h"
#import <CYLSearchViewController/CYLSearchController.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLSearchViewController/CYLSearchViewController-Swift.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

@interface CYLSearchExampleDataSource ()
@property (nonatomic, copy) NSArray<NSString *> *items;
@end

@implementation CYLSearchExampleDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray<NSString *> *items = [NSMutableArray array];
        for (NSUInteger index = 1; index <= 40; index++) {
            [items addObject:[NSString stringWithFormat:[CYLSearchResources localizedStringForKey:@"sample.result"], (unsigned long)index]];
        }
        _items = [items copy];
    }
    return self;
}

- (NSArray *)searchResultsViewController:(CYLSearchResultsViewController *)controller resultsForQuery:(NSString *)query
{
    if (query.length == 0) return self.items;
    return [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *item, NSDictionary *bindings) {
        return [item localizedCaseInsensitiveContainsString:query];
    }]];
}

- (void)searchResultsViewController:(CYLSearchResultsViewController *)controller configureCell:(UITableViewCell *)cell withResult:(id)result
{
    cell.textLabel.text = result;
}

- (void)reloadWithCompletion:(void (^)(NSError *error))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(nil);
    });
}

@end

@interface CYLSearchExampleViewController () <CYLTableViewPlaceHolderDelegate>
@property (nonatomic, strong) id<CYLSearchExampleRefreshing> refreshProvider;
@property (nonatomic, strong) CYLSearchController *overlaySearchController;
@end

@implementation CYLSearchExampleViewController

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)searchDataSource
                        refreshProvider:(id<CYLSearchExampleRefreshing>)refreshProvider
{
    NSParameterAssert(refreshProvider);
    self = [super initWithSearchDataSource:searchDataSource];
    if (self) {
        _refreshProvider = refreshProvider;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // navigationItem.title, not title: a view controller's title also renames its tab item, whose title comes from
    // CYLTabBarConfiguration.json.
    self.navigationItem.title = [CYLSearchResources localizedStringForKey:@"search.title"];
    self.searchController.searchBar.placeholder = [CYLSearchResources localizedStringForKey:@"search.placeholder"];
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[CYLSearchResources localizedStringForKey:@"repro.off"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(cyl_toggleReproduction)];
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier = @"CYLIssueReproductionToggle";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[CYLSearchResources localizedStringForKey:@"action.overlay"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(cyl_showOverlay)];

    __weak typeof(self) weakSelf = self;
    self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        CYLSearchExampleViewController *controller = weakSelf;
        if (!controller) return;
        [controller.refreshProvider reloadWithCompletion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CYLSearchExampleViewController *currentController = weakSelf;
                if (!currentController) return;
                [currentController.tableView.cyl_header endRefreshing];
                if (error) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[CYLSearchResources localizedStringForKey:@"refresh.error"]
                                                                                   message:error.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:[CYLSearchResources localizedStringForKey:@"action.ok"] style:UIAlertActionStyleDefault handler:nil]];
                    [currentController presentViewController:alert animated:YES completion:nil];
                } else {
                    [currentController reloadSearchResults];
                }
            });
        }];
    }];
}

- (void)cyl_showOverlay
{
    if (!self.overlaySearchController) {
        self.overlaySearchController = [[CYLSearchController alloc] initWithSearchDataSource:self.searchDataSource];
    }
    [self.overlaySearchController showInViewController:self];
}

- (void)cyl_toggleReproduction
{
    BOOL enabled = !self.navigationItem.hidesSearchBarWhenScrolling;
    self.navigationItem.hidesSearchBarWhenScrolling = enabled;
    self.navigationItem.rightBarButtonItem.title = [CYLSearchResources localizedStringForKey:enabled ? @"repro.on" : @"repro.off"];
}

- (void)reloadResultsTableView
{
    [self.tableView cyl_reloadData];
}

- (UIView *)makePlaceHolderView
{
    CYLSearchPlaceholderView *placeholder = [[CYLSearchPlaceholderView alloc] initWithKind:CYLSearchPlaceholderKindNoResults];
    placeholder.accessibilityIdentifier = @"CYLSearchEmptyState";
    return placeholder;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing
{
    return YES;
}

@end
