//
//  CYLSearchHeaderView.h
//  http://cnblogs.com/http://weibo.com/luohanchenyilong//
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/6.
//  Copyright (c) 2015年 com.http://cnblogs.com/http://weibo.com/luohanchenyilong//. All rights reserved.
//
@class CYLSearchHeaderView;
@protocol CYLSearchHeaderViewDelegate <NSObject>

@required
-(void)searchHeaderViewClicked:(id)sender;

@end
#import <UIKit/UIKit.h>

@interface CYLSearchHeaderView : UIViewController
//@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIImageView *searchFieldImageView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, weak) id <CYLSearchHeaderViewDelegate> delegate;
@end
