//
//  QuestionSearchController.m
//  PiFuKeYiSheng
//
//  Created by 喻平 on 14-5-20.
//  Copyright (c) 2014年 com.pifukeyisheng. All rights reserved.
//

#define kAppWordColor  [UIColor colorWithRed:0/255.f green:150/255.f blue:136/255.f alpha:.8f]
#define BACKGROUND_COLOR [UIColor colorWithRed:229/255.f green:238/255.f blue:235/255.f alpha:1.f] // 浅绿色背景
#define TABLE_LINE_COLOR [UIColor colorWithRed:200/255.f green:199/255.f blue:204/255.f alpha:1.f].CGColor // 列表分割线颜色

#define udQuestionSearchHistory @"udQuestionSearchHistory"



#define udServerList @"udServerList"

#import "QuestionSearchController.h"
//#import "Constant.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
//#import "SVPullToRefresh.h"
//#import "QuestionPatientCell.h"
//#import "Question.h"
//#import "QuestionDetailController.h"
//#import "QuestDetailController.h"
//#import "QuestionCell.h"
//#import "MBProgressHUD+MJ.h"
//#import "AFNetworking.h"
//#import "QuestionModel.h"
//#import "QuestionFrameModel.h"
#import "AppDelegate.h"
#import "CYLSearchResultViewController.h"

@interface QuestionSearchController ()
<
UITextFieldDelegate,
UITableViewDelegate,
UITableViewDataSource
>

{
    BOOL _showQuestions; // 判断列表的显示内容是搜索记录，还是问题
    UIView *_searchBgView; // 搜索框
    UIViewController *_inController; // 此界面被显示在哪个View Controller
    UIButton *_clearButton;
}

@property (nonatomic, strong) IBOutlet UIView *searchBarView;
@property (nonatomic, strong) IBOutlet UITextField *searchField;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray *searchHistories;
@property (nonatomic, strong) NSMutableArray *questionDataSource;
@property (nonatomic, strong) UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QuestionSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"返回";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    [self initTableViewDataSource];
    //仅修改_searchBarView的宽度,xyh值不变
    _searchBarView.frame = CGRectMake(_searchBarView.frame.origin.x, _searchBarView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, _searchBarView.frame.size.height);
    //    [self.tableView registerNibName:@"QuestionPatientCell"];
    self.searchHistories = [NSMutableArray array];
    
    [self.navigationController.navigationBar addSubview:_searchBarView];
    [self.navigationController.navigationBar setNeedsLayout];
    
    //仅修改_cancelButton的x,ywh值不变
    _cancelButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, _cancelButton.frame.origin.y, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
    [UIView animateWithDuration:0.25f animations:^{
        //仅修改_cancelButton的x,ywh值不变
        _cancelButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - _cancelButton.frame.size.width - 10, _cancelButton.frame.origin.y, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
        //仅修改_searchField的宽度,xyh值不变
        _searchField.frame = CGRectMake(_searchField.frame.origin.x, _searchField.frame.origin.y, _cancelButton.frame.origin.x - 6, _searchField.frame.size.height);
        
    }];
    _searchField.layer.borderWidth = 0.5f;
    _searchField.layer.borderColor = [UIColor colorWithRed:241/255.f green:241/255.f blue:241/255.f alpha:1.f].CGColor;
    _searchField.layer.cornerRadius = 5;
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 44)];
    searchIcon.contentMode = UIViewContentModeCenter;
    searchIcon.image = [UIImage imageNamed:@"icon_question_search"];
    _searchField.leftViewMode = UITextFieldViewModeAlways;
    _searchField.leftView = searchIcon;
    _showQuestions = NO;
    // 初始化清除按钮
    _clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _clearButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    [_clearButton setTitle:@"清除搜索记录" forState:UIControlStateNormal];
    [_clearButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_clearButton setBackgroundColor:[UIColor whiteColor]];
    [_clearButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:217/255.f green:217/255.f blue:217/255.f alpha:1.f]] forState:UIControlStateHighlighted];
    [_clearButton addBottomFillLineWithColor:[UIColor colorWithRed:198/255.f green:200/255.f blue:199/255.f alpha:1.f].CGColor];
    [_clearButton addTarget:self action:@selector(clearHistoriesButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _clearButton.clipsToBounds = YES;
    //仅修改_clearButton的高度,xyw值不变
    _clearButton.frame = CGRectMake(_clearButton.frame.origin.x,
                                    _clearButton.frame.origin.y,
                                    _clearButton.frame.size.width,
                                    0);
    [self.view addSubview:_clearButton];
    //
    //    [self.tableView addInfiniteScrollingWithActionHandler:^{
    //        Question *question = [tableViewDataSource lastObject];
    //        [self getQuestionList:question.qid];
    //    }];
    //    self.tableView.infiniteScrollingView.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _searchBarView.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0/255.f green:165/255.f blue:154/255.f alpha:.33f]] forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:51/255.f green:171/255.f blue:160/255.f alpha:1.f]
                                                                 ] forBarMetrics:UIBarMetricsDefault];
    
}
/**
 *  懒加载_titleLbl
 *
 *  @return UILabel
 */
- (UILabel *)titleLbl
{
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
    }
    return _titleLbl;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    if(_showQuestions)
    {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        header.backgroundColor = [UIColor whiteColor];
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 16)];
        [header addSubview:titleLbl];
        self.titleLbl = titleLbl;
        titleLbl.textColor = kAppWordColor;
        titleLbl.font = [UIFont systemFontOfSize:14];
        titleLbl.text = [NSString stringWithFormat:@"与%@有关的咨询", self.searchField.text];
        
        UIView *cureLine = [[UIView alloc] initWithFrame:CGRectMake(12, 43.5, [UIScreen mainScreen].bounds.size.width - 12, 0.5)];
        cureLine.backgroundColor = [UIColor colorWithRed:224/255.f green:224/255.f blue:224/255.f alpha:1.f];
        [header addSubview:cureLine];
    }
    return header;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_showQuestions){
        return 44;
    }
    return CGFLOAT_MIN;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

// 显示搜索界面
- (void)showInViewController:(UIViewController *)controller
{
    _searchBgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //仅修改_searchBgView的y,xwh值不变
    _searchBgView.frame = CGRectMake(_searchBgView.frame.origin.x, 44, _searchBgView.frame.size.width, _searchBgView.frame.size.height);
    _searchBgView.backgroundColor = [UIColor blackColor];
    _searchBgView.alpha = 0;
    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
    [delegate.navigationController.view addSubview:_searchBgView];
    [delegate.navigationController.view addSubview:self.navigationController.view];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    [_searchBgView addGestureRecognizer:recognizer];
    
    //仅修改self.navigationController.view的y,xwh值不变
    self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x, 44, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    [delegate.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.25f animations:^{
        //仅修改self.navigationController.view的y,xwh值不变
        self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                          0,
                                                          self.navigationController.view.frame.size.width,
                                                          self.navigationController.view.frame.size.height
                                                          );
        _searchBgView.alpha = 0.4f;
    } completion:^(BOOL finished) {
        NSArray *histories = [[NSUserDefaults standardUserDefaults] objectForKey:udQuestionSearchHistory];
        [_searchHistories addObjectsFromArray:histories];
        [self.tableView reloadData];
        _searchField.placeholder = @"输入问题关键字进行检索";
        [_searchField becomeFirstResponder];
    }];
}
// 关闭搜索界面
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
        _searchBgView.alpha = 0;
        //仅修改_searchField的宽度,xyh值不变
        _searchField.frame = CGRectMake(_searchField.frame.origin.x,
                                        _searchField.frame.origin.y,
                                        [UIScreen mainScreen].bounds.size.width - 16,
                                        _searchField.frame.size.height
                                        );
        //仅修改_cancelButton的x,ywh值不变
        _cancelButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width,
                                         _cancelButton.frame.origin.y,
                                         _cancelButton.frame.size.width,
                                         _cancelButton.frame.size.height
                                         );
    } completion:^(BOOL finished) {
        [_searchBgView removeFromSuperview];
        _searchBgView = nil;
        [UIView animateWithDuration:0.2f animations:^{
            self.navigationController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.navigationController.view removeFromSuperview];
        }];
    }];
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

- (void)dealloc
{
    [self removeKeyboardNotification];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(IBAction)rightBarButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(questionSearchCancelButtonClicked:)]) {
        [_delegate questionSearchCancelButtonClicked:self];
    }
}


- (void)keyboardWillShowWithRect:(CGRect)keyboardRect animationDuration:(float)duration
{
    [self reloadViewLayouts];
}

- (void)keyboardWillHideWithRect:(CGRect)keyboardRect animationDuration:(float)duration
{
    
}
// 刷新界面控件
- (void)reloadViewLayouts
{
    if (_showQuestions) {
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
        //仅修改_clearButton的高度,xyw值不变
        _clearButton.frame = CGRectMake(_clearButton.frame.origin.x,
                                        _clearButton.frame.origin.y,
                                        _clearButton.frame.size.width,
                                        0);
    } else {
        // 显示搜索记录
        //仅修改self.tableView的高度,xyw值不变
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          MIN(_searchHistories.count * 44, [UIScreen mainScreen].bounds.size.height - 64 - 44));
        _clearButton.frame = CGRectMake(0, self.tableView.frame.size.height, [UIScreen mainScreen].bounds.size.width, _searchHistories.count > 0 ? 44 : 0);
        if (_searchHistories.count == 0) {
            // 没有搜索记录
            //仅修改self.view的高度,xyw值不变
            self.view.frame = CGRectMake(self.view.frame.origin.x,
                                         self.view.frame.origin.y,
                                         self.view.frame.size.width,
                                         CGRectGetMaxY(_clearButton.frame));
            //仅修改self.navigationController.view的高度,xyw值不变
            self.navigationController.view.frame = CGRectMake(self.navigationController.view.frame.origin.x,
                                                              self.navigationController.view.frame.origin.y,
                                                              self.navigationController.view.frame.size.width,
                                                              self.view.frame.size.height + 64);
        } else {
            // 有搜索记录
            self.view.backgroundColor = [UIColor whiteColor];
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
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_showQuestions) {
        self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
        return self.questionDataSource.count;
    } else {
        self.navigationController.view.backgroundColor = [UIColor clearColor];
        return _searchHistories.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showQuestions) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
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
        cell.textLabel.font = [UIFont systemFontOfSize:14];        // 传入数据
        
        // 返回cell
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
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
        cell.textLabel.text = _searchHistories[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showQuestions) {
        return 44;
    } else {
        return 44;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.01;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showQuestions) {
        // 点击问题，跳转到问题系那个情
        
        CYLSearchResultViewController *searchResultViewController =
        [[CYLSearchResultViewController alloc] initWithNibName:[[CYLSearchResultViewController class] description] bundle:nil];
        searchResultViewController.searchResult.titleLabel.text = self.questionDataSource[indexPath.row];
        //        QuestDetailController *questDetailCtl =
        //        [[QuestDetailController alloc]
        //        init];
        //        questDetailCtl.questionDict = [tableViewDataSource[indexPath.row] infoDict];
                [self.navigationController pushViewController:searchResultViewController animated:YES];
        
        _searchBarView.hidden = YES;
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        _searchField.text = _searchHistories[indexPath.row];
        //        [self showProgressOnWindowWithText:@"请稍候..."];
        [self getQuestionList:nil];
    }
}

// 清除搜索记录
- (IBAction)clearHistoriesButtonClicked:(id)sender
{
    [_searchHistories removeAllObjects];
    [[NSUserDefaults standardUserDefaults] setObject:_searchHistories forKey:udQuestionSearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    [self reloadViewLayouts];
}

- (void)getQuestionList:(NSNumber *)startQid
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    //构造元素需要使用两个空格来进行缩进，右括号]或者}写在新的一行，并且与调用语法糖那行代码的第一个非空字符对齐：
    NSArray *array = @[
                       @"测试1❤️",
                       @"测试2❤️",
                       @"测试3❤️",
                       @"测试4❤️"
                       ];
    self.questionDataSource = [NSMutableArray arrayWithArray:array];
    _showQuestions = YES;
    [self.tableView reloadData];
}

// 点击输入框，显示搜索记录
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_showQuestions) {
        _showQuestions = NO;
//        self.tableView.infiniteScrollingView.enabled = NO;
        [self.tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length == 0) {
        return NO;
    }
    if ([_searchHistories containsObject:textField.text]) {
        [_searchHistories removeObject:textField.text];
    }
    // 保存搜索记录，最多10条
    [_searchHistories insertObject:textField.text atIndex:0];
    if (_searchHistories.count > 10) {
        [_searchHistories removeLastObject];
    }
    [[NSUserDefaults standardUserDefaults] setObject:_searchHistories forKey:udQuestionSearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
    // 刷新views
    [self reloadViewLayouts];
//    [self showProgressOnWindowWithText:@"请稍候..."];
    // 开始搜索
    [self getQuestionList:nil];
    return YES;
}

// 一旦滑动列表，隐藏键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_searchField.isFirstResponder) {
        [_searchField resignFirstResponder];
    }
}

@end



