//
//  CYLSearchController.m
//  http://cnblogs.com/http://weibo.com/luohanchenyilong//
//
//  Created by   http://weibo.com/luohanchenyilong/  on 14-5-20.
//  Copyright (c) 2014年 https://github.com/ChenYilong/CYLSearchViewController . All rights reserved.
//
@import Foundation;

#define BACKGROUND_COLOR [UIColor colorWithRed:229/255.f green:238/255.f blue:235/255.f alpha:1.f] // 浅绿色背景
#define TABLE_LINE_COLOR [UIColor colorWithRed:200/255.f green:199/255.f blue:204/255.f alpha:1.f].CGColor // 列表分割线颜色

static NSString *const kSearchHistory = @"kSearchHistory";
static float const kHeightForFooterInSection = 64;
static float const kMinTableViewHeight = 0.01f;
enum { kMostNumberOfSearchHistories = 15 };

//Frameworks
@import QuartzCore;
//View Controllers
#import "CYLSearchController.h"
#import "CYLSearchResultViewController.h"
//Views
#import "CYLSearchBar.h"
//Others
#import "AppDelegate.h"

@interface CYLSearchController ()
<
UITextFieldDelegate,
UITableViewDelegate,
UITableViewDataSource,
UISearchBarDelegate
>

@property (nonatomic, strong) NSMutableArray *searchHistories;
@property (nonatomic, strong) NSMutableArray *questionDataSource;
@property (nonatomic, strong) UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CYLSearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBackgroundView;
/**
 *  判断列表的显示内容是搜索记录，还是问题
 */
@property (assign, getter=isShowQuestions) BOOL showQuestions;

@end

@implementation CYLSearchController

#pragma mark - 💤 LazyLoad Method

/**
 *  懒加载_searchBgVie
 *
 *  @return UIView
 */
- (UIView *)searchBackgroundView
{
    if (_searchBackgroundView == nil) {
        _searchBackgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //仅修改_searchBackgroundView的y,xwh值不变
        _searchBackgroundView.frame = CGRectMake(_searchBackgroundView.frame.origin.x, 44, _searchBackgroundView.frame.size.width, _searchBackgroundView.frame.size.height);
        _searchBackgroundView.backgroundColor = [UIColor blackColor];
        _searchBackgroundView.alpha = 0;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSerchBarWhenTapBackground:)];
        [_searchBackgroundView addGestureRecognizer:recognizer];
    }
    return _searchBackgroundView;
}

/**
 *  懒加载_titleLabel
 *
 *  @return UILabel
 */
- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 16)];
        _titleLabel.textColor = APP_TINT_COLOR;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

/**
 *  懒加载_searchBar
 *
 *  @return UISearchBar
 */
- (CYLSearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[CYLSearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        // 删除UISearchBar中的UISearchBarBackground
        [_searchBar setShowsCancelButton:YES animated:YES];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

/**
 *  懒加载_questionDataSource
 *
 *  @return NSMutableArray
 */
- (NSMutableArray *)questionDataSource
{
    if (_questionDataSource == nil) {
        _questionDataSource = [[NSMutableArray alloc] init];
    }
    return _questionDataSource;
}

#pragma mark - ♻️ LifeCycle Method

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"initWithNibName:bundle%@", self.view);
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        //仅修改self.tableView的高度,xyw值不变
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          0);
        self.searchHistories = [NSMutableArray array];
        self.showQuestions = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage
                                                                 imageWithColor:TEXTFIELD_BACKGROUNDC0LOR]
                                                  forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage
                                                                 imageWithColor:APP_TINT_COLOR
                                                                 ]
                                                  forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"返回";
    self.navigationItem.titleView = self.searchBar;
    [self.navigationController.navigationBar setNeedsLayout];
    //仅修改self.navigationController.view的高度,xyw值不变
    self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                      self.navigationController.view.frame.origin.y,
                                                      self.navigationController.view.frame.size.width,
                                                      44);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hide:nil];
}

#pragma mark - 🆑 CYL Custom Method

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/**
 *  显示搜索界面
 */
- (void)showInViewController:(UIViewController *)controller
{
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [delegate.navigationController.view addSubview:self.searchBackgroundView];
    [delegate.navigationController.view addSubview:self.navigationController.view];
    
    //仅修改self.navigationController.view的y,xwh值不变
    self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                      44,
                                                      self.navigationController.view.frame.size.width,
                                                      self.navigationController.view.frame.size.height
                                                      );
    [delegate.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        //仅修改self.navigationController.view的y,xwh值不变
        self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                          0,
                                                          self.navigationController.view.frame.size.width,
                                                          self.navigationController.view.frame.size.height
                                                          );
        self.searchBackgroundView.alpha = 0.4f;
    } completion:^(BOOL finished) {
        NSArray *histories = [[NSUserDefaults standardUserDefaults] objectForKey:kSearchHistory];
        [self.searchHistories addObjectsFromArray:histories];
        [self reloadViewLayouts];
        [self.searchBar becomeFirstResponder];
    }];
}

/**
 *  关闭搜索界面
 *
 *  @param completion 操作执行完成后执行
 */
- (void)hide:(void(^)(void))completion
{
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [delegate.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        //仅修改self.navigationController.view的y,xwh值不变
        self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                          44,
                                                          self.navigationController.view.frame.size.width,
                                                          self.navigationController.view.frame.size.height
                                                          );
        self.searchBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.searchBackgroundView removeFromSuperview];
        self.searchBackgroundView = nil;
        [UIView animateWithDuration:0.2f animations:^{
            self.navigationController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.navigationController.view removeFromSuperview];
        }];
    }];
    completion ? completion() : nil;
}

- (void)hideSerchBarWhenTapBackground:(id)sender {
    [self hide:nil];
}

/**
 *  刷新界面控件，取代reloadData方法,作用在于在reloadData之前，先修改self.view、self.tableView、self.navigationController.view三者的高度
 只要需要reloadData的地方，都需要发送本方法
 *  ⓵点击搜索框开始编辑时调⓶点击搜索后调⓷显示本搜索controller时⓸清除搜索历史后
 */
- (void)reloadViewLayouts
{
    if (self.isShowQuestions) {
        // 用户点击搜索，搜索出问题时，显示问题列表
        //仅修改self.view的高度,xyw值不变
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y,
                                     self.view.frame.size.width,
                                     [UIScreen mainScreen].bounds.size.height - 64
                                     );
        //仅修改self.tableView的高度,xyw值不变
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          self.view.frame.size.height
                                          );
        //仅修改self.navigationController.view的高度,xyw值不变
        self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                          self.navigationController.view.frame.origin.y,
                                                          self.navigationController.view.frame.size.width,
                                                          [UIScreen mainScreen].bounds.size.height);
    } else {
        // 显示搜索记录
        //仅修改self.tableView的高度,xyw值不变
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          MIN(self.searchHistories.count * 44 + (self.searchHistories.count > 0 ? kHeightForFooterInSection : 0), [UIScreen mainScreen].bounds.size.height - 64));
        if (self.searchHistories.count == 0) {
            // 没有搜索记录
            //仅修改self.view的高度,xyw值不变
            self.view.frame = CGRectMake(self.view.frame.origin.x,
                                         self.view.frame.origin.y,
                                         self.view.frame.size.width,
                                         CGRectGetMaxY(self.tableView.frame));
            //仅修改self.navigationController.view的高度,xyw值不变
            self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                              self.navigationController.view.frame.origin.y,
                                                              self.navigationController.view.frame.size.width,
                                                              self.view.frame.size.height + 64);
        } else {
            // 有搜索记录
            //仅修改self.view的高度,xyw值不变
            self.view.frame = CGRectMake(self.view.frame.origin.x,
                                         self.view.frame.origin.y,
                                         self.view.frame.size.width,
                                         [UIScreen mainScreen].bounds.size.height - 64);
            //仅修改self.navigationController.view的高度,xyw值不变
            self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                              self.navigationController.view.frame.origin.y,
                                                              self.navigationController.view.frame.size.width,
                                                              [UIScreen mainScreen].bounds.size.height);
        }
    }
    [self.tableView reloadData];
}

/**
 *  清除搜索记录
 */
- (void)clearHistoriesButtonClicked:(id)sender
{
    [self.searchHistories removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:self.searchHistories forKey:kSearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadViewLayouts];
}

- (void)getQuestionList:(NSNumber *)startQid
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //构造元素需要使用两个空格来进行缩进，右括号]或者}写在新的一行，并且与调用语法糖那行代码的第一个非空字符对齐：
    NSArray *array = @[
                       @"@iOS程序犭袁 🆑测试1",
                       @"@iOS程序犭袁 🆑测试2",
                       @"@iOS程序犭袁 🆑测试3",
                       @"@iOS程序犭袁 🆑测试4"
    ];
    self.questionDataSource = [NSMutableArray arrayWithArray:array];
    self.showQuestions = YES;
    [self reloadViewLayouts];
}

/**
 * 删除某个历史搜索关键词
 */
- (void)rightBtnDidClicked:(UIButton *)rightBtn
{
    [self.searchHistories removeObject:self.searchHistories[rightBtn.tag]];
    [[NSUserDefaults standardUserDefaults] setObject:self.searchHistories forKey:kSearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadViewLayouts];
}

#pragma mark - 🔌 UITableViewDataSource Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isShowQuestions) {
        self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
        return self.questionDataSource.count;
    } else {
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        return self.searchHistories.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.isShowQuestions) {
        static NSString *searchResultTableView = @"searchResultTableView";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchResultTableView];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            [cell.contentView addSubLayerWithFrame:CGRectMake(0,
                                                              44 - 0.5f,
                                                              [UIScreen mainScreen].bounds.size.width,
                                                              0.5f
                                                              )
                                             color:TABLE_LINE_COLOR];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.text = self.questionDataSource[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    } else {
        static NSString *searchHistoryTableView = @"searchHistoryTableView";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchHistoryTableView];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            [cell.contentView addSubLayerWithFrame:CGRectMake(0,
                                                              44 - 0.5f,
                                                              [UIScreen mainScreen].bounds.size.width,
                                                              0.5f
                                                              )
                                             color:TABLE_LINE_COLOR];
            cell.textLabel.backgroundColor = [UIColor whiteColor];
        }
        cell.imageView.image = [UIImage imageNamed:@"SearchHistory"];
        cell.textLabel.text = self.searchHistories[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44, 0, 44, 44);
        // 监听点击删除按钮
        [rightBtn addTarget:self action:@selector(rightBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setImage:[UIImage imageNamed:@"search_history_delete_icon_normal"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"SearchDeleteSelected"] forState:UIControlStateSelected];
        rightBtn.tag = indexPath.row;
        [cell.contentView addSubview:rightBtn];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowQuestions) {
        return 44;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.isShowQuestions){
        return 44;
    }
    return kMinTableViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (!self.isShowQuestions && self.searchHistories.count > 0) {
        return kHeightForFooterInSection;
    }
    return kMinTableViewHeight;
}

#pragma mark - 🔌 UITableViewDelegatel Method

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (!self.isShowQuestions && self.searchHistories.count>0) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeightForFooterInSection)];
        footerView.backgroundColor = [UIColor whiteColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 160)/2, 18, 160, 30)];
        [footerView addSubview:btn];
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor =[UIColor lightGrayColor].CGColor;
        btn.layer.cornerRadius = 4;
        [btn setTitle:@"清除搜索历史" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"Superclarendon-Light" size:16];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clearHistoriesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return footerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowQuestions) {
        // 点击问题，跳转到问题系那个情
        CYLSearchResultViewController *searchResultViewController =
        [[CYLSearchResultViewController alloc] initWithNibName:[[CYLSearchResultViewController class] description] bundle:nil];
        searchResultViewController.searchResult.titleLabel.text = self.questionDataSource[indexPath.row];
        [self.navigationController pushViewController:searchResultViewController animated:YES];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        self.searchBar.text = self.searchHistories[indexPath.row];
        [self getQuestionList:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    if(self.isShowQuestions)
    {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        header.backgroundColor = [UIColor whiteColor];
        [header addSubview:self.titleLabel];
        self.titleLabel.text = [NSString stringWithFormat:@"与%@有关的搜索结果", self.searchBar.text];
        
        UIView *cureLine = [[UIView alloc] initWithFrame:CGRectMake(12, 43.5, [UIScreen mainScreen].bounds.size.width - 12, 0.5)];
        cureLine.backgroundColor = [UIColor colorWithRed:224/255.f green:224/255.f blue:224/255.f alpha:1.f];
        [header addSubview:cureLine];
    }
    return header;
}

#pragma mark - 🔌 UISearchBarDelegate Method

/**
 *  点击输入框，显示搜索记录
 *
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    if (self.isShowQuestions) {
        self.showQuestions = NO;
        [self reloadViewLayouts];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length == 0) {
        return;
    }
    if ([self.searchHistories containsObject:searchBar.text]) {
        [self.searchHistories removeObject:searchBar.text];
    }
    // 保存搜索记录，最多10条
    [self.searchHistories insertObject:searchBar.text atIndex:0];
    if (self.searchHistories.count > kMostNumberOfSearchHistories) {
        [self.searchHistories removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.searchHistories forKey:kSearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 开始搜索
    [self getQuestionList:nil];
    [self reloadViewLayouts];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (_delegate && [_delegate respondsToSelector:@selector(questionSearchCancelButtonClicked:)]) {
        [_delegate questionSearchCancelButtonClicked:self];
    }
}

#pragma mark - 🔌 UIScrollViewDelegate Method

/**
 *  一旦滑动列表，隐藏键盘
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}

@end



