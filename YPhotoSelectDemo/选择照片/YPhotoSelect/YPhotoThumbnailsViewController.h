//
//  YPhotothumbnailsViewController.h
//  选择照片
//
//  Created by 彦鹏 on 16/7/20.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YPhotoCollectionViewCell.h"

@interface YPhotoThumbnailsViewController : UIViewController<UIAlertViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong,nonatomic) ALAssetsLibrary * lib; //防止过期
@property (strong,nonatomic) ALAssetsGroup * album;

typedef void (^SelectImageBlock)(NSMutableArray * imgs);

@end
