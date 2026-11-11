//
//  CYLSearchController.m
//  CYLSearchViewController
//
//  Copyright (c) 2014 ChenYilong. All rights reserved.
//

#import "CYLSearchController.h"

@interface CYLSearchController ()
@property (nonatomic, strong, readwrite) CYLSearchResultsViewController *resultsViewController;
@property (nonatomic, weak) UINavigationController *overlayNavigationController;
@property (nonatomic, assign, getter=isPresented) BOOL presented;
@property (nonatomic, assign) BOOL dismissing;
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *dismissCompletions;
@end

@implementation CYLSearchController

- (instancetype)initWithSearchDataSource:(id<CYLSearchResultsDataSource>)dataSource
{
    NSParameterAssert(dataSource);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _resultsViewController = [[CYLSearchResultsViewController alloc] initWithSearchDataSource:dataSource];
        _dismissCompletions = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // The view starts below the navigation bar and its search bar: the search bar never covers this view.
    self.edgesForExtendedLayout &= ~UIRectEdgeTop;
    [self addChildViewController:self.resultsViewController];
    UIView *resultsView = self.resultsViewController.view;
    resultsView.frame = self.view.bounds;
    resultsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:resultsView];
    [self.resultsViewController didMoveToParentViewController:self];
    self.resultsViewController.navigationItem.searchController = nil;
    self.navigationItem.searchController = self.resultsViewController.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cyl_cancelSearch)];
}

- (void)showInViewController:(UIViewController *)controller
{
    NSParameterAssert(controller);
    if (self.isPresented || self.dismissing) return;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [self loadViewIfNeeded];
    self.overlayNavigationController = navigationController;
    self.presented = YES;
    [controller addChildViewController:navigationController];
    navigationController.view.frame = controller.view.bounds;
    navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    navigationController.view.transform = CGAffineTransformMakeTranslation(0, 44);
    navigationController.view.alpha = 0;
    [controller.view addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:controller];
    [UIView animateWithDuration:0.25 animations:^{
        navigationController.view.transform = CGAffineTransformIdentity;
        navigationController.view.alpha = 1;
    }];
}

- (void)hide:(void (^)(void))completion
{
    if (completion) [self.dismissCompletions addObject:[completion copy]];
    if (self.dismissing) return;
    UINavigationController *navigationController = self.overlayNavigationController;
    if (!navigationController || !self.isPresented) {
        [self cyl_completeDismissal];
        return;
    }
    self.dismissing = YES;
    [self.resultsViewController.searchController setActive:NO];
    [navigationController willMoveToParentViewController:nil];
    [UIView animateWithDuration:0.25 animations:^{
        navigationController.view.transform = CGAffineTransformMakeTranslation(0, 44);
        navigationController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [navigationController.view removeFromSuperview];
        [navigationController removeFromParentViewController];
        self.overlayNavigationController = nil;
        self.presented = NO;
        self.dismissing = NO;
        [self cyl_completeDismissal];
    }];
}

- (void)cyl_completeDismissal
{
    NSArray<void (^)(void)> *completions = [self.dismissCompletions copy];
    [self.dismissCompletions removeAllObjects];
    for (void (^completion)(void) in completions) completion();
}

- (void)cyl_cancelSearch
{
    [self hide:^{
        if ([self.delegate respondsToSelector:@selector(searchControllerDidCancel:)]) {
            [self.delegate searchControllerDidCancel:self];
        }
    }];
}

@end
