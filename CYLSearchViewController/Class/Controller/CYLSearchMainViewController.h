//
//  CYLSearchMainViewController.h
//  CYLSearchViewController
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/29.
//  Copyright (c) 2015年 https://github.com/ChenYilong/CYLSearchViewController . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CYLSearchReloadCompletion)(NSError * _Nullable error);

@protocol CYLSearchDataProviding <NSObject>

- (NSArray<NSString *> *)searchResultsForQuery:(NSString *)query;
- (void)reloadSearchResultsWithCompletion:(CYLSearchReloadCompletion)completion;

@end

@interface CYLSearchMainViewController : UITableViewController

- (instancetype)initWithDataProvider:(id<CYLSearchDataProviding>)dataProvider NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString * _Nullable)nibNameOrNil
                         bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
