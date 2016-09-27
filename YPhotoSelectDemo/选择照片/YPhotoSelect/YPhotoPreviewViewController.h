//
//  YPhotoPreviewViewController.h
//  选择照片
//
//  Created by 彦鹏 on 16/7/25.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface YPhotoPreviewViewController : UIViewController<UIAlertViewDelegate,UIScrollViewDelegate>
@property (strong,nonatomic) __block UIImage * centerImage;
@property (strong,nonatomic) ALAssetsLibrary * lib; //防止过期
@property (strong,nonatomic) NSMutableArray * aLAssets;
@property (strong,nonatomic) NSIndexPath * indexPath;
@property (assign,nonatomic) BOOL isPresent;
@property (copy,nonatomic) NSMutableArray * presentIndexParhs;
//@property (copy,nonatomic) NSMutableArray * presentAssets;

@end
