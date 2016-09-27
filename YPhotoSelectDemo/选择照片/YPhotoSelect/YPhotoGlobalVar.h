//
//  YPhotoGlobalVar.h
//  选择照片
//
//  Created by 彦鹏 on 16/8/23.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YPhotoGlobalVar : NSObject<NSCopying>
/*!
设置的最大照片数和返回的全屏图和缩略图在这里.
 */
@property (assign,nonatomic) int maxNum;
@property (assign,nonatomic) int currentNum;
@property (strong,nonatomic) NSMutableArray * selectedImgs;
@property (strong,nonatomic) NSMutableArray * selectedThumbnails;
@property (strong,nonatomic) NSMutableArray * selectedAlassets;
@property (strong,nonatomic) NSMutableArray * indexPaths;
@property (strong,nonatomic) NSMutableArray * reloadIndexPaths;
@property (strong,nonatomic) CAKeyframeAnimation * animation;
@property (assign,nonatomic) CGFloat targetImageScale;
@property (assign,nonatomic) BOOL png;  //default is NO; imgStyle is jpg
/*!
 每次读取的时候直接从内存提取,不用再每次根据名字读图片了;
 */
@property (strong,nonatomic) UIImage * yesImg;
@property (strong,nonatomic) UIImage * noImg;

+ (instancetype)shareGlobalVar;

@end
