//
//  YPhotoCollectionViewCell.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/21.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoCollectionViewCell.h"
#import "YPhotoGlobalVar.h"

@interface YPhotoCollectionViewCell()

@property (strong,nonatomic) YPhotoGlobalVar * globalVar;

@end

@implementation YPhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [_button addTarget:self action:@selector(selectOrDeselect) forControlEvents:UIControlEventTouchUpInside];
    [_button setImage:[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_no"] forState:UIControlStateNormal];
    
    _globalVar = [YPhotoGlobalVar shareGlobalVar];
}

- (void)selectOrDeselect {
    
    if (_isPicked == NO) {
        if (_globalVar.maxNum == _globalVar.currentNum) {
            NSString * title = [NSString stringWithFormat:@"您最多只能选择%d张图片",_globalVar.maxNum];
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        if (_globalVar.animation == nil) {
            _globalVar.animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            //    CAKeyframeAnimation(keyPath: "transform.scale");
            _globalVar.animation.duration = 0.15;
            _globalVar.animation.autoreverses = false;
            _globalVar.animation.values = @[@1.0,@1.2,@1.0];
            _globalVar.animation.fillMode = kCAFillModeBackwards;
        }

        _isPicked = YES;
        if (_selectBlock) {
            self.selectBlock(_isPicked);
        }
        [_button setImage:[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_yes"] forState:UIControlStateNormal];
        [_button.layer removeAnimationForKey:@"transform.scale"];
        [_button.layer addAnimation:_globalVar.animation forKey:@"transform.scale"];
    }
    else if (_isPicked == YES) {
        _isPicked = NO;
        if (_selectBlock) {
            self.selectBlock(_isPicked);
        }
        [_button setImage:[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_no"] forState:UIControlStateNormal];
    }
}

@end
