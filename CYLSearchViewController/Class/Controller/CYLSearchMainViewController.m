//
//  CYLSearchMainViewController.m
//  CYLSearchViewController
//
//  Created by chenyilong on 15/4/29.
//  Copyright (c) 2015年 chenyilong. All rights reserved.
//

#import "CYLSearchMainViewController.h"
#import "CYLSearchHeaderView.h"
#import "QuestionSearchController.h"

@interface CYLSearchMainViewController ()
<
CYLSearchHeaderViewDelegate,
QuestionSearchControllerDelegate
>
@property (nonatomic, strong)  CYLSearchHeaderView *searchHeaderView;
@property (nonatomic, strong) UINavigationController *searchController;

@end

@implementation CYLSearchMainViewController

/**
 *  懒加载_searchHeaderView
 *
 *  @return CYLSearchHeaderView
 */
- (CYLSearchHeaderView *)searchHeaderView
{
    if (_searchHeaderView == nil) {
        _searchHeaderView = [[CYLSearchHeaderView alloc] initWithNibName:@"CYLSearchHeaderView" bundle:nil];
        _searchHeaderView.delegate = self;
        _searchHeaderView.view.frame =
        CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        [self.view addSubview:_searchHeaderView.view];
    }
    return _searchHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchHeaderView;
    self.title = @"@iOS程序犭袁";
}

#pragma mark - CYLSearchHeaderViewDelegate

- (void)searchHeaderViewClicked:(id)sender {
    QuestionSearchController *controller = [[QuestionSearchController alloc] initWithNibName:@"QuestionSearchController" bundle:nil];
    controller.delegate = self;
    self.searchController = [[UINavigationController alloc] initWithRootViewController:controller];
    [controller showInViewController:self];
}

#pragma mark - QuestionSearchControllerDelegate

- (void)questionSearchCancelButtonClicked:(QuestionSearchController *)controller
{
    [controller hide:^{
        self.searchController = nil;
    }];
}
@end
