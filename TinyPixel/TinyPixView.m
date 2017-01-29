//
//  TinyPixView.m
//  TinyPix
//
//  Created by wanghuiyong on 29/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "TinyPixView.h"
#import "TinyPixDocument.h"

typedef struct {
    NSUInteger row;
    NSUInteger column;
} GridIndex;

// 类扩展
@interface TinyPixView ()

@property (assign, nonatomic) CGRect		gridRect;			// 表格的位置和尺寸
@property (assign, nonatomic) CGSize		blockSize;			// 单元格尺寸
@property (assign, nonatomic) CGSize		lastSize;			// 视图尺寸
@property (assign, nonatomic) CGFloat	gap;					// 间隙长度
@property (assign, nonatomic) GridIndex	selectedBlockIndex;	// 单元格索引

@end

@implementation TinyPixView

// 默认的初始化方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

// 从 storyboard 中加载的初始化方法
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

// 初始化属性
- (void)commonInit {
    [self calculateGridForSize:self.bounds.size];
    _selectedBlockIndex.row = NSNotFound;
    _selectedBlockIndex.column = NSNotFound;
}

// 根据视图尺寸计算网格尺寸
- (void)calculateGridForSize:(CGSize)size {
    CGFloat space = MIN(size.width, size.height);	// 取视图的短边, 以适应设备旋转时视图的尺寸变化
    _gap = space/57;								// 单元格之间的间距, 8个单元9格空隙, 单元大小是间隙的6被, 6*8+9=57
    CGFloat cellSide = 6 * _gap;						// 单元格边长
    _blockSize = CGSizeMake(cellSide, cellSide);		// 单元格尺寸
    _gridRect = CGRectMake((size.width - space)/2, (size.height - space)/2, space, space);
}

// 重写自定义绘图
- (void)drawRect:(CGRect)rect {
    // 文档必须存在
    if (!_document) return;
    
    // 首次绘制, 设备旋转, 更换不同尺寸设备时, 根据新尺寸重新定义网格尺寸
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, self.lastSize)) {
        self.lastSize = size;
        [self calculateGridForSize:size];
    }
    
    // 绘制网格中每个单元格
    for (NSUInteger row = 0; row < 8; row++) {
        for (NSUInteger column = 0; column < 8; column++) {
            [self drawBlockAtRow:row column:column];
        }
    }
}

// 绘制指定行列的单元格
- (void)drawBlockAtRow:(NSUInteger)row column:(NSUInteger)column {
    
    // 单元格的位置和大小
    CGFloat startX = _gridRect.origin.x + _gap + (_blockSize.width + _gap) * (7 - column) + 1;	// 从右向左
    CGFloat startY = _gridRect.origin.y + _gap + (_blockSize.height + _gap) * row + 1;			// 从上到下
    CGRect blockFrame = CGRectMake(startX, startY, _blockSize.width, _blockSize.height);
    
    // 单元格的填充颜色
    UIColor *color = [_document stateAtRow:row column:column] ? [UIColor blackColor] : [UIColor whiteColor];
    [color setFill];
    
    // 单元格高亮颜色
    [self.tintColor setStroke];
    
    // 绘制单元格
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:blockFrame];
    [path fill];
    [path stroke];
}

// 触摸事件
- (GridIndex)touchedGridIndexFromTouches:(NSSet *)touches {
    GridIndex result;
    result.row = -1;
    result.column = -1;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(_gridRect, location)) {
        location.x -= _gridRect.origin.x;
        location.y -= _gridRect.origin.y;
        result.column = 8 - (location.x * 8.0 / _gridRect.size.width);
        result.row = location.y * 8.0 / _gridRect.size.height;
    }
    return result;
}

- (void)toggleSelectedBlock {
    if (_selectedBlockIndex.row != -1 && _selectedBlockIndex.column != -1) {
        
        // 改变触摸单元格的值
        [_document toggleStateAtRow:_selectedBlockIndex.row column:_selectedBlockIndex.column];
        
        // 撤销和重做功能: 记录用户操作, 维护在撤销站栈中, 回溯文档状态
        [[_document.undoManager prepareWithInvocationTarget:_document] toggleStateAtRow:_selectedBlockIndex.row column:_selectedBlockIndex.column];
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selectedBlockIndex = [self touchedGridIndexFromTouches:touches];
    [self toggleSelectedBlock];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    GridIndex touched = [self touchedGridIndexFromTouches:touches];
    if (touched.row != _selectedBlockIndex.row
        || touched.column != _selectedBlockIndex.column) {
        _selectedBlockIndex = touched;
        [self toggleSelectedBlock];
    }
}

@end
