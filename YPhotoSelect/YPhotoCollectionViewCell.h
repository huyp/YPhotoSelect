//
//  YPhotoCollectionViewCell.h
//  选择照片
//
//  Created by 彦鹏 on 16/7/21.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPhotoCollectionViewCell : UICollectionViewCell

@property (assign,nonatomic) BOOL isPicked;

typedef void (^SelectBlock)(BOOL isSelect);
@property (strong,nonatomic) SelectBlock selectBlock;

typedef void (^TapBlock)();
@property (strong,nonatomic) TapBlock tapBlock;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end
