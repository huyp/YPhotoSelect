//
//  TestCollectionViewCell.m
//  选择照片
//
//  Created by 彦鹏 on 16/9/23.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "TestCollectionViewCell.h"

@implementation TestCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.imageView = [[UIImageView alloc]init];
        self.imageView.frame = CGRectMake(0, 0, 80, 80);
        [self addSubview:self.imageView];
    }
    
    return self;
}
@end
