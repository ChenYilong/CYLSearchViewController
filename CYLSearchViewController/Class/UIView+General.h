//
//  UIView+UIViewEXT.h CanXinTong
//
//  Created by https://github.com/ChenYilong/CYLSearchViewController on 13-2-28.
//  Copyright (c) 2013年 https://github.com/ChenYilong/CYLSearchViewController. All rights reserved.
//

@import UIKit;

@interface UIView (General)

- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;

- (void)setSize:(CGSize)size;

- (CGFloat)height;
- (CGFloat)width;
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)maxY;
- (CGFloat)maxX;
- (void)horizontalCenterWithWidth:(CGFloat)width;
- (void)verticalCenterWithHeight:(CGFloat)height;
- (void)verticalCenterInSuperView;
- (void)horizontalCenterInSuperView;

- (void)setBoarderWith:(CGFloat)width color:(CGColorRef)color;
- (void)setCornerRadius:(CGFloat)radius;

- (CALayer *)addSubLayerWithFrame:(CGRect)frame color:(CGColorRef)colorRef;


- (void)setTarget:(id)target action:(SEL)action;

- (UIImage *)capture;

@end
