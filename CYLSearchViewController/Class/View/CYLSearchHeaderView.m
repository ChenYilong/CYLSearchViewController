//
//  CYLSearchHeaderView.m
//  http://cnblogs.com/http://weibo.com/luohanchenyilong//
//
//  Created by http://weibo.com/luohanchenyilong/ on 15/4/6.
//  Copyright (c) 2015年 com.http://cnblogs.com/http://weibo.com/luohanchenyilong//. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CYLSearchHeaderView.h"
//#import "UIView+YPGeneral.h"
@implementation CYLSearchHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {              }
    return self;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"icon_question_search_rect"];
    image = [image stretchableImageWithLeftCapWidth:(NSUInteger)(image.size.width / 2)
                                      topCapHeight:(NSUInteger)(image.size.height / 2)];
    _searchFieldImageView.image = image;
    self.searchButton.titleLabel.textColor = [UIColor colorWithRed:142/255.f green:142/255.f blue:147/255.f alpha:1.f];
    self.searchButton.titleLabel.font = [UIFont systemFontOfSize:12];
}
- (IBAction)searchBarClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(searchHeaderViewClicked:)]) {
        [self.delegate searchHeaderViewClicked:self];
    }
}


@end
