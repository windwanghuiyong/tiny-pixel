//
//  TinyPixView.h
//  TinyPix
//
//  Created by wanghuiyong on 29/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TinyPixDocument;

@interface TinyPixView : UIView

@property (strong, nonatomic) TinyPixDocument *document;		// 对文档的强引用

@end
