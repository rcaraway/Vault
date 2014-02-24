//
//  RCTableView.m
//  Valt
//
//  Created by Robert Caraway on 2/5/14.
//  Copyright (c) 2014 Rob Caraway. All rights reserved.
//

#import "RCTableView.h"
#import "RCPasswordManager.h"

@implementation RCTableView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.shouldAllowMovement = YES;
        self.shouldAllowResize = YES;
        self.extendedSize = NO;
    }
    return self;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (self.shouldAllowMovement){
        [super setContentOffset:contentOffset];
    }
}

-(void)setContentSize:(CGSize)contentSize
{
    if (self.shouldAllowMovement && self.shouldAllowResize){
        CGFloat height = [[RCPasswordManager defaultManager] passwords].count * NORMAL_CELL_FINISHING_HEIGHT + 100;
        if (_extendedSize){
            height += 188;
        }
        [super setContentSize:CGSizeMake(self.frame.size.width, height)];
    }
}

-(void)setContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
}

-(void)setExtendedSize:(BOOL)extendedSize
{
    _extendedSize = extendedSize;
    [self setContentSize:CGSizeZero];
}

-(void)setBounds:(CGRect)bounds
{
    if (self.shouldAllowResize){
        [super setBounds:bounds];
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)reloadData
{
    [super reloadData];
}


@end
