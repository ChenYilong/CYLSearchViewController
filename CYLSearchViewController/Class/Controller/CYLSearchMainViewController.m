//
//  CYLSearchMainViewController.m
//  CYLSearchViewController
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/29.
//  Copyright (c) 2015年 https://github.com/ChenYilong/CYLSearchViewController . All rights reserved.
//

#import "CYLSearchMainViewController.h"

@interface CYLSearchMainViewController () <UISearchResultsUpdating, CYLTableViewPlaceHolderDelegate>

@property (nonatomic, strong) id<CYLSearchDataProviding> dataProvider;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, copy) NSArray<NSString *> *searchResults;

@end

@implementation CYLSearchMainViewController

- (instancetype)initWithDataProvider:(id<CYLSearchDataProviding>)dataProvider
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _dataProvider = dataProvider;
        _searchResults = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Search";
    self.tableView.accessibilityIdentifier = @"CYLSearchResultsTable";
    self.tableView.tableFooterView = [UIView new];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Filter results";
    self.navigationItem.searchController = self.searchController;
//    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Repro: OFF"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(toggleIssueReproduction)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = @"Toggle Issue 1317 reproduction";
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier = @"CYLIssueReproductionToggle";
    self.navigationItem.rightBarButtonItem.accessibilityValue = @"Off";

    [self configureRefreshHeader];
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)configureRefreshHeader
{
    __weak typeof(self) weakSelf = self;
    self.tableView.cyl_header = [CYLRefreshNormalHeader headerWithRefreshingBlock:^{
        CYLSearchMainViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        [strongSelf.dataProvider reloadSearchResultsWithCompletion:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CYLSearchMainViewController *currentSelf = weakSelf;
                if (!currentSelf) {
                    return;
                }

                [currentSelf.tableView.cyl_header endRefreshing];
                if (error) {
                    [currentSelf presentRefreshError:error];
                    return;
                }
                [currentSelf updateSearchResultsForSearchController:currentSelf.searchController];
            });
        }];
    }];
}

- (void)toggleIssueReproduction
{
    BOOL reproducingIssue = !self.navigationItem.hidesSearchBarWhenScrolling;
    self.navigationItem.hidesSearchBarWhenScrolling = reproducingIssue;
    self.navigationItem.rightBarButtonItem.title = reproducingIssue ? @"Repro: ON" : @"Repro: OFF";
    self.navigationItem.rightBarButtonItem.accessibilityValue = reproducingIssue ? @"On" : @"Off";
}

- (void)presentRefreshError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Refresh Failed"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *query = searchController.searchBar.text ?: @"";
    self.searchResults = [self.dataProvider searchResultsForQuery:query];
    [self.tableView cyl_reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const CYLSearchResultCellIdentifier = @"CYLSearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CYLSearchResultCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CYLSearchResultCellIdentifier];
    }

    NSString *result = self.searchResults[indexPath.row];
    cell.textLabel.text = result;
    cell.accessibilityLabel = result;
    cell.accessibilityIdentifier = [NSString stringWithFormat:@"CYLSearchResult-%ld", (long)indexPath.row];
    return cell;
}

#pragma mark - CYLTableViewPlaceHolderDelegate

- (UIView *)makePlaceHolderView
{
    UILabel *label = [[UILabel alloc] init];
    label.text = @"No matching results";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.grayColor;
    label.isAccessibilityElement = YES;
    label.accessibilityLabel = label.text;
    label.accessibilityIdentifier = @"CYLSearchEmptyState";
    return label;
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing
{
    return YES;
}

@end
