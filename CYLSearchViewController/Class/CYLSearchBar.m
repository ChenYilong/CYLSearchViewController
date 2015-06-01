//
//  CYLSearchBar.m
//  CYLSearchViewController
//
//  Created by   http://weibo.com/luohanchenyilong/  on 15/5/29.
//  Copyright (c) 2015年  https://github.com/ChenYilong/CYLSearchViewController . All rights reserved.
//

#import "CYLSearchBar.h"

@implementation CYLSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)initWithCoder: (NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self = [self sharedInit];
    }
    return self;
}

- (id)sharedInit {
    self.backgroundColor = TEXTFIELD_BACKGROUNDC0LOR;
    self.placeholder = @"搜索";
    self.keyboardType = UIKeyboardTypeDefault;
    self.showsCancelButton = NO;
    // 删除UISearchBar中的UISearchBarBackground
    [self setBackgroundImage:[[UIImage alloc] init]];
    self.tintColor = APP_TINT_COLOR;
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@"取消"];
    return self;
}

@end
