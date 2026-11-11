#import "CYLSearchResultsViewController.h"

@interface CYLSearchResultsViewController () <UISearchResultsUpdating>

@property (nonatomic, strong, readwrite) id<CYLSearchResultsDataSource> searchDataSource;
@property (nonatomic, strong, readwrite) UISearchController *searchController;
@property (nonatomic, copy, readwrite) NSArray *searchResults;

@end

@implementation CYLSearchResultsViewController

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)searchDataSource
{
    NSParameterAssert(searchDataSource);
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _searchDataSource = searchDataSource;
        _searchResults = @[];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.obscuresBackgroundDuringPresentation = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // The view starts below the navigation bar and its search bar: the search bar never covers this view.
    self.edgesForExtendedLayout &= ~UIRectEdgeTop;
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    // The search bar stays in the navigation bar, under the title. On iOS 26 an iPhone would otherwise float it at
    // the bottom of the screen, over the list: a search bar never covers a view.
    if (@available(iOS 16.0, *)) {
        self.navigationItem.preferredSearchBarPlacement = UINavigationItemSearchBarPlacementStacked;
    }
    if (@available(iOS 26.0, *)) {
        self.navigationItem.searchBarPlacementAllowsToolbarIntegration = NO;
    }
    self.definesPresentationContext = YES;
    [self reloadSearchResults];
}

- (void)reloadSearchResults
{
    NSString *query = self.searchController.searchBar.text ?: @"";
    self.searchResults = [self.searchDataSource searchResultsViewController:self resultsForQuery:query];
    [self reloadResultsTableView];
}

- (void)reloadResultsTableView
{
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self reloadSearchResults];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CYLSearchCellIdentifier = @"CYLSearchResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLSearchCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CYLSearchCellIdentifier];
    }
    [self.searchDataSource searchResultsViewController:self configureCell:cell withResult:self.searchResults[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.searchDataSource respondsToSelector:@selector(searchResultsViewController:didSelectResult:)]) {
        [self.searchDataSource searchResultsViewController:self didSelectResult:self.searchResults[indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
