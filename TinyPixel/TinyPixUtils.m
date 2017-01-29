//
//  TinyPixUtils.m
//  TinyPix
//
//  Created by wanghuiyong on 28/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "TinyPixUtils.h"

@implementation TinyPixUtils

+ (UIColor *)getTintColorForIndex:(NSUInteger)index {
    UIColor *color = [UIColor redColor];		// 默认颜色
    switch (index) {
        case 0:
            color = [UIColor redColor];
            break;
        case 1:
            color = [UIColor colorWithRed:0 green:0.6 blue:0 alpha:1];
            break;
        case 2:
            color = [UIColor blueColor];
            break;
        default:
            break;
    }
    return color;
}

@end
