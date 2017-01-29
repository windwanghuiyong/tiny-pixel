//
//  TinyPixDocument.m
//  TinyPix
//
//  Created by wanghuiyong on 28/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "TinyPixDocument.h"

@interface TinyPixDocument ()

@property (strong, nonatomic) NSMutableData *bitmap; // 8*8的位图, 共占用8字节, 强引用

@end

@implementation TinyPixDocument

#pragma mark - Initializer

- (id)initWithFileURL:(NSURL *)url {
    self = [super initWithFileURL:url];
    
    // 初始化位图属性为一个对角线图案
    if (self) {
        unsigned char startPattern[] = {
            0x01, 0x02, 0x04, 0x08, 
            0x10, 0x20, 0x40, 0x80
    	};
    	self.bitmap = [NSMutableData dataWithBytes:startPattern length:8];	// 8字节数据, 自动释放内存
    }
    return self;	// 返回文档类
}

#pragma mark - Accesser

// 读取指定像素的值
- (BOOL)stateAtRow:(NSUInteger)row column:(NSUInteger)column {
    const char *bitmapBytes = [self.bitmap bytes];	// 常量引用, 按字节排列
    char rowByte = bitmapBytes[row];					// 指定行的8个字节数据
    char result = (1 << column) & rowByte;
    if (result != 0) {
        return YES;
    } else {
        return NO;
    }
}

// 设置指定像素的值
- (void)setState:(BOOL)state atRow:(NSUInteger)row column:(NSUInteger)column {
    char *bitmapBytes = [self.bitmap mutableBytes];	// 变量引用
    char *rowByte = &bitmapBytes[row];		 // 至少按行操作
    
    if (state) {
        *rowByte = *rowByte | (1 << column);
    } else {
        *rowByte = *rowByte & ~(1 << column);
    }
}

// 切换指定像素的值
- (void)toggleStateAtRow:(NSUInteger)row column:(NSUInteger)column {
    BOOL state = [self stateAtRow:row column:column];	// 先读取
    [self setState:!state atRow:row column:column];		// 再按相反状态设置
}

#pragma mark - Document Methods

// 写入: 将文档的数据结构转换成 NSData 对象, 以便存储到文档
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"saving document to URL %@", self.fileURL);		// 文档类操作 URL, 不需要直接处理文件
    return [self.bitmap copy];	// 返回位图的不可变副本给文档
}

// 读取: 获取最近加载的 NSData 对象, 从中取出对象的数据结构, 提供给文档类实例
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    NSLog(@"loading document from URL %@", self.fileURL);
    self.bitmap = [contents mutableCopy];	// 获取传递给该方法的数据的可变副本
    return true;
}

@end
