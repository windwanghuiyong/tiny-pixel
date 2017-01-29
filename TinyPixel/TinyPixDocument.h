//
//  TinyPixDocument.h
//  TinyPix
//
//  Created by wanghuiyong on 28/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TinyPixDocument : UIDocument		// 数据模型类

// row and column range from 0 to 7
- (BOOL)stateAtRow:(NSUInteger)row column:(NSUInteger)column;					// 读取指定像素的值
- (void)setState:(BOOL)state atRow:(NSUInteger)row column:(NSUInteger)column;	// 设置指定像素的值
- (void)toggleStateAtRow:(NSUInteger)row column:(NSUInteger)column;				// 切换指定像素的值

@end
