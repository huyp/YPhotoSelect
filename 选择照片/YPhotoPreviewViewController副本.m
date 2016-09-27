//
//  YPhotoPreviewViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/25.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoPreviewViewController.h"

@interface YPhotoPreviewViewController ()

{
    BOOL isTwoImage;
}

@property (strong , nonatomic) UIImageView * imageViewA;  //初始左边
@property (strong , nonatomic) UIImageView * imageViewB;  //初始中间
@property (strong , nonatomic) UIImageView * imageViewC;  //初始右边

@property (strong , nonatomic) __block UIImage * leftImage;  //初始左边
@property (strong , nonatomic) __block UIImage * rightImage;  //初始右边

@end

@implementation YPhotoPreviewViewController

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)selectOrDisSelect {
    NSLog(@"select");
}

- (void)setNavgation {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"＜" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"YPhoto.bundle/y_icon_image_no"] style:UIBarButtonItemStylePlain target:self action:@selector(selectOrDisSelect)];
}

- (void)setToolBar {
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    
    UIBarButtonItem * flexibleBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [rightItem setTintColor:[UIColor greenColor]];
    toolBar.items = @[flexibleBarBtn,rightItem];
    
    [self.view addSubview:toolBar];
}

- (void)setScrollView {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用想访问您的相册" message:@"请设置应用的相册访问权限" delegate:self cancelButtonTitle:@"不允许" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
    else {
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(-3, 0, [UIScreen mainScreen].bounds.size.width + 6, [UIScreen mainScreen].bounds.size.height)];
        scrollView.delegate = self;
        [self.view addSubview:scrollView];
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.contentMode = UIViewContentModeCenter;
        scrollView.contentSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width + 6) * _ALAssets.count, 0);
        scrollView.contentOffset = CGPointMake(([UIScreen mainScreen].bounds.size.width + 6) * _indexPath.row, 0);
        
        _imageViewA = [self showThumbnailImageViewAtIndexPath:_indexPath.row - 1];
        _imageViewB = [self showThumbnailImageViewAtIndexPath:_indexPath.row];
        _imageViewC = [self showThumbnailImageViewAtIndexPath:_indexPath.row + 1];
        
        [scrollView addSubview:_imageViewA];
        [scrollView addSubview:_imageViewB];
        [scrollView addSubview:_imageViewC];
        
        //异步获取fullscreen图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetRepresentation * representation = [_ALAssets[_indexPath.row] defaultRepresentation];
            UIImage * image = [UIImage imageWithCGImage:[representation fullResolutionImage]] ;
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageViewB.image = image;
                NSLog(@"scrollView=%@",scrollView.subviews);
            });
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavgation];
    
    [self setScrollView];
    
    [self setToolBar];
}

- (UIImageView *)showThumbnailImageViewAtIndexPath:(NSInteger)indexPathRow{

    if ((indexPathRow < 0)||(indexPathRow > _ALAssets.count - 1)) {
        return nil;
    }
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[self thumbnailImage:indexPathRow]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * indexPathRow, -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return imageView;
}

- (UIImage *)thumbnailImage:(NSInteger)indexPathRow {
    if ((indexPathRow < 0)||(indexPathRow > _ALAssets.count-1)) {
        return nil;
    }
    return [UIImage imageWithCGImage:[_ALAssets[indexPathRow] aspectRatioThumbnail]];
}

- (UIImageView *)showFullscreenImageViewAtIndexPath:(NSInteger)indexPathRow{
    
    if ((indexPathRow < 0)||(indexPathRow > _ALAssets.count)) {
        return nil;
    }
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[self fullscreenImage:indexPathRow]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * indexPathRow, -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    return imageView;
}

- (UIImage *)fullscreenImage :(NSInteger)indexPathRow {
    if ((indexPathRow < 0)||(indexPathRow > _ALAssets.count)) {
        return nil;
    }
    ALAssetRepresentation * representation = [_ALAssets[indexPathRow] defaultRepresentation];
    return [UIImage imageWithCGImage:[representation fullResolutionImage]];
}

- (void)done {
    NSLog(@"done");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //获取要显示的图片的index 过半算
        int indexPathRow = (int)roundf(scrollView.contentOffset.x/([UIScreen mainScreen].bounds.size.width+6));
        
        //向右划 显示左边的图片
        if (indexPathRow == _indexPath.row) {
            return ;
        }
        else if (indexPathRow < _indexPath.row) {
            _indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:1];
            if (scrollView.subviews.count == 1) {
                return;
            }
            else if (scrollView.subviews.count == 2) {
                if (_ALAssets.count == 2) { //相册只有2张图片 模糊转走这张
                    return;
                }
                else { //因为是右滑 所以当前肯定是最后一张图片
                    UIImageView * leftImageView = [self showThumbnailImageViewAtIndexPath:indexPathRow-1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [scrollView insertSubview:leftImageView atIndex:0];
                    });
                }
            }
            else {
                if (indexPathRow == 0) { //移动到了第一张
                    [scrollView.subviews.lastObject removeFromSuperview];
                }
                else {
                    ((UIImageView *)scrollView.subviews.lastObject).image = [self thumbnailImage:indexPathRow-1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"1");
                        (scrollView.subviews.lastObject).frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * (indexPathRow-1), -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                        [scrollView insertSubview:scrollView.subviews.lastObject atIndex:0];
                    });
                }
            }
        }
        else {  //左滑 显示右边的图片
            _indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:1];
            if (scrollView.subviews.count == 1) {
                return;
            }
            else if (scrollView.subviews.count == 2) {
                if (_ALAssets.count == 2) { //相册只有2张图片 模糊转走这张
                    return;
                }
                else { //因为是左滑 所以当前肯定是第一张图片
                    UIImageView * rightImageView = [self showThumbnailImageViewAtIndexPath:indexPathRow+1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [scrollView insertSubview:rightImageView atIndex:1];
                    });
                }
            }
            else {
                if (indexPathRow == _ALAssets.count-1) { //移动到了最后一张
                    [scrollView.subviews.firstObject removeFromSuperview];
                }
                else {
                    ((UIImageView *)scrollView.subviews.firstObject).image = [self thumbnailImage:indexPathRow+1];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"1");
                        (scrollView.subviews.firstObject).frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * (indexPathRow-1), -64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                        [scrollView insertSubview:scrollView.subviews.firstObject atIndex:2];
                    });
                }
            }
        }
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //获取要显示的图片的index 过半算
    int indexPathRow = (int)roundf(scrollView.contentOffset.x/([UIScreen mainScreen].bounds.size.width+6));

    NSLog(@"indexPathRow=%d",indexPathRow);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (scrollView.subviews.count == 2) {
            
            if (isTwoImage == NO && _ALAssets.count == 2) {
                UIImage * leftImage = [self fullscreenImage:0];
                UIImage * rightImage = [self fullscreenImage:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ((UIImageView *)scrollView.subviews[0]).image = leftImage;
                    ((UIImageView *)scrollView.subviews[1]).image = rightImage;
                    isTwoImage = YES;
                });
            }
            else if (indexPathRow == 0) {
                UIImage * leftImage = [self fullscreenImage:indexPathRow];
//                UIImage * rightImage = [self thumbnailImage:indexPathRow + 1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ((UIImageView *)scrollView.subviews[0]).image = leftImage;
//                    ((UIImageView *)scrollView.subviews[1]).image = rightImage;
                });
            }
            else if (indexPathRow == _ALAssets.count-1) {
//                UIImage * leftImage = [self thumbnailImage:indexPathRow-1];
                UIImage * rightImage = [self fullscreenImage:indexPathRow];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    ((UIImageView *)scrollView.subviews[0]).image = leftImage;
                    ((UIImageView *)scrollView.subviews[1]).image = rightImage;
                });
            }
        }
        else if(scrollView.subviews.count == 3){
            _centerImage = [self fullscreenImage:indexPathRow];
//            _leftImage = [self thumbnailImage:indexPathRow - 1];
//            _rightImage = [self thumbnailImage:indexPathRow +1];
            dispatch_async(dispatch_get_main_queue(), ^{
//                ((UIImageView *)scrollView.subviews[0]).image = _leftImage;
                ((UIImageView *)scrollView.subviews[1]).image = _centerImage;
//                ((UIImageView *)scrollView.subviews[2]).image = _rightImage;
            });
        }
    });
}



//MARK: - alertViewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)dealloc {
    NSLog(@"dealloc");
}
@end
