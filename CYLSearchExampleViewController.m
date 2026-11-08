#import "CYLSearchExampleViewController.h"
#import <CYLSearchViewController/CYLSearchController.h>
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
            [items addObject:[NSString stringWithFormat:@"Sample result %lu", (unsigned long)index]];
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
    self.title = @"Search";
    self.searchController.searchBar.placeholder = @"Filter results";
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Repro: OFF"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(cyl_toggleReproduction)];
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier = @"CYLIssueReproductionToggle";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Overlay"
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
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Refresh Failed"
                                                                                   message:error.localizedDescription
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
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
    self.navigationItem.rightBarButtonItem.title = enabled ? @"Repro: ON" : @"Repro: OFF";
}

- (void)reloadResultsTableView
{
    [self.tableView cyl_reloadData];
}

- (UIView *)makePlaceHolderView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"No matching results";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.grayColor;
    label.accessibilityIdentifier = @"CYLSearchEmptyState";
    return label;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing
{
    return YES;
}

@end
