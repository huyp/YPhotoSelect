//
//  YPhotoNavViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/21.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoNavViewController.h"
#import "YPhotoAblumTableViewController.h"
#import "YPhotoGlobalVar.h"

@interface YPhotoNavViewController ()
@property (strong ,nonatomic) YPhotoGlobalVar * globalVar;
@end

@implementation YPhotoNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * bgImage = [self createImageWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
    [self.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.barTintColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]; //这个导航栏透明度为1(不透明);
    
    self.navigationBar.translucent = YES;
    self.navigationBar.alpha = 0.5;
    [self.navigationBar setShadowImage:[UIImage new]];
    //设置统一的颜色
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    self.interactivePopGestureRecognizer.delegate = self;
    
    _globalVar = [YPhotoGlobalVar shareGlobalVar];
    _globalVar.currentNum = 0;
    _globalVar.selectedImgs = [NSMutableArray new];
    _globalVar.selectedAlassets = [NSMutableArray new];
    _globalVar.indexPaths = [NSMutableArray new];
    _globalVar.selectedThumbnails = [NSMutableArray new];
    _globalVar.reloadIndexPaths = [NSMutableArray new];
    //不合理的值或默认状态下 缩放比例为1
    if (_globalVar.targetImageScale <= 0.0 ||_globalVar.targetImageScale > 1.0) {
        _globalVar.targetImageScale = 1.0;
    }
    _globalVar.yesImg = [[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_yes"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _globalVar.noImg = [[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_no"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//锁定转向
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
