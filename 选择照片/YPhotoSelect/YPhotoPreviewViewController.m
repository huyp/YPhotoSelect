//
//  YPhotoPreviewViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/25.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoPreviewViewController.h"
#import "YPhotoGlobalVar.h"

@interface YPhotoPreviewViewController ()

@property (strong , nonatomic) UIScrollView * imageScrollViewA;
@property (strong , nonatomic) UIScrollView * imageScrollViewB;
@property (strong , nonatomic) UIScrollView * imageScrollViewC;

@property (strong , nonatomic) __block UIImage * leftImage;  //初始左边
@property (strong , nonatomic) __block UIImage * rightImage;  //初始右边

@property (strong,nonatomic) UIScrollView * scrollView;
@property (strong,nonatomic) UIToolbar * toolBar;
@property (strong,nonatomic) UIBarButtonItem * doneItem;

@property (assign,nonatomic) int pastIndexPathRow;
@property (strong,nonatomic) ALAssetRepresentation * representation;
@property (strong,nonatomic) YPhotoGlobalVar * globalVar;

@property (strong,nonatomic) CAKeyframeAnimation * animation;
@end

@implementation YPhotoPreviewViewController

- (void)cancel {
    _globalVar.selectedThumbnails = nil;
    _globalVar.selectedImgs = nil;
    _globalVar.currentNum = 0;
    _globalVar.animation = nil;
    
    _globalVar.indexPaths = nil;
    _globalVar.reloadIndexPaths = nil;
    _globalVar.selectedAlassets = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done {
    
    UIActivityIndicatorView * activityIV = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIV.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/3);
    [self.view addSubview:activityIV];
    [activityIV startAnimating];
    
    UIImage * fullScreenImg;
    for (int i = 0; i < _globalVar.selectedAlassets.count; i++) {
        _representation = [_globalVar.selectedAlassets[i] defaultRepresentation];
        
        fullScreenImg = [UIImage imageWithCGImage:[_representation fullScreenImage]] ;
        fullScreenImg = [self compressionImage:fullScreenImg WithScale:_globalVar.targetImageScale];
        [_globalVar.selectedImgs addObject:fullScreenImg];
        
        UIImage * thumbnail = [UIImage imageWithCGImage:((ALAsset *)_globalVar.selectedAlassets[i]).thumbnail];
        [_globalVar.selectedThumbnails addObject:thumbnail];
    }
    
    [activityIV stopAnimating];
    [activityIV removeFromSuperview];
    
    _globalVar.indexPaths = nil;
    _globalVar.reloadIndexPaths = nil;
    _globalVar.selectedAlassets = nil;
    _globalVar.animation = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIImage *)compressionImage:(UIImage *)image WithScale:(CGFloat)scale {
    /* 按给定尺寸 按比例缩放的方法
     实现等比例缩放
     double hfactor = image.size.width / targetSize.width;
     double vfactor = image.size.height / targetSize.height;
     double factor = fmax(hfactor, vfactor);
     绘制画布
     double newWith = image.size.width / factor;
     double newHeight = image.size.height / factor;
     CGSize newSize = CGSizeMake(newWith, newHeight);
     */
    /*
     按照给定缩放比例缩放
     */
    double newWith = image.size.width * scale;
    double newHeight = image.size.height * scale;
    CGSize newSize = CGSizeMake(newWith, newHeight);
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newWith, newHeight)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //按照jpg格式进行了压缩,如果需要png格式就把这个换成 : UIImagePNGRepresentation(newImage);
    NSData * data;
    if (_globalVar.png == YES) {
        data = UIImagePNGRepresentation(newImage);
    }
    else {
        data = UIImageJPEGRepresentation(newImage, 0.5);//二次压缩
    }
    
    newImage = [UIImage imageWithData:data];
    
    return newImage;
}

- (void)selectOrDisSelect {
    
    
    if (_isPresent == YES) {
        //因为这部分是后补的,和其他的方法有些不同----懒得改一致了,写的时候发现了这个问题,我也挺郁闷的,原因是一开始对于逻辑没想周全.
        _globalVar.reloadIndexPaths = _presentIndexParhs;
        
        if (self.navigationItem.rightBarButtonItem.image == _globalVar.noImg) {
            if (_globalVar.maxNum == _globalVar.currentNum) {
                NSString * title = [NSString stringWithFormat:@"您最多只能选择%d张图片",_globalVar.maxNum];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            if (![_globalVar.reloadIndexPaths containsObject:_presentIndexParhs[_indexPath.row]]) {
                [_globalVar.reloadIndexPaths addObject:_presentIndexParhs[_indexPath.row]];
            }
            
            _globalVar.currentNum++;
            [_globalVar.indexPaths addObject:_presentIndexParhs[_indexPath.row]];
            [_globalVar.selectedAlassets addObject:_aLAssets[_indexPath.row]];
            self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
        }
        else {
            _globalVar.currentNum--;
            [_globalVar.indexPaths removeObject:_presentIndexParhs[_indexPath.row]];
            [_globalVar.selectedAlassets removeObject:_aLAssets[_indexPath.row]];
            self.navigationItem.rightBarButtonItem.image = _globalVar.noImg;
        }
    }
    else {
        
        if (![_globalVar.reloadIndexPaths containsObject:_indexPath]) {
            [_globalVar.reloadIndexPaths addObject:_indexPath];
        }
        
        if ([_globalVar.indexPaths containsObject:_indexPath]) {
            _globalVar.currentNum--;
            self.navigationItem.rightBarButtonItem.image = _globalVar.noImg;
            [_globalVar.indexPaths removeObject:_indexPath];
            [_globalVar.selectedAlassets removeObject:_aLAssets[_indexPath.row]];
        }
        else {
            if (_globalVar.maxNum == _globalVar.currentNum) {
                NSString * title = [NSString stringWithFormat:@"你最多只能选择%d张图片",_globalVar.maxNum];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }

            _globalVar.currentNum++;
            self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
            [_globalVar.indexPaths addObject:_indexPath];
            [_globalVar.selectedAlassets addObject:_aLAssets[_indexPath.row]];
        }
    }
    
    if (_globalVar.currentNum == 0) {
        _doneItem.enabled = NO;
    }else {
        _doneItem.enabled = YES;
    }
    
}

- (void)setNavgation {
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [backItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    //self.navigationItem.leftBarButtonItem = backItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:self action:@selector(selectOrDisSelect)];
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

- (void)setToolBar {
    _toolBar = [UIToolbar new];
    
    _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage * bgImage = [self createImageWithColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7]];
    [_toolBar setBackgroundImage:bgImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:_toolBar];

    NSArray * h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"toolBar":_toolBar}];
    NSArray * v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar(44)]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"toolBar":_toolBar}];
    
    UIBarButtonItem * flexibleBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    _doneItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    [_doneItem setTintColor:[UIColor greenColor]];
    _toolBar.items = @[flexibleBarBtn,_doneItem];
    if (_globalVar.currentNum == 0) {
        _doneItem.enabled = NO;
    }
    
    [self.view addConstraints:h];
    [self.view addConstraints:v];
}

- (void)setScrollView {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用想访问您的相册" message:@"请设置应用的相册访问权限" delegate:self cancelButtonTitle:@"不允许" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
    else {
        _scrollView = [UIScrollView new];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        NSArray * h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-3)-[scrollView]-(-3)-|" options:NSLayoutFormatDirectionLeftToRight metrics:nil views:@{@"scrollView":_scrollView}];
        NSArray * v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"scrollView":_scrollView}];
        [self.view addConstraints:h];
        [self.view addConstraints:v];
        
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.contentMode = UIViewContentModeCenter;
        _scrollView.contentSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width + 6) * _aLAssets.count, 0);
        _scrollView.contentOffset = CGPointMake(([UIScreen mainScreen].bounds.size.width + 6) * _indexPath.row, 0);
        
        _imageScrollViewA = [self showThumbnailImageScrollViewAtIndexPath:_indexPath.row - 1];
        _imageScrollViewA.delegate = self;
        _imageScrollViewB = [self showThumbnailImageScrollViewAtIndexPath:_indexPath.row];
        _imageScrollViewB.delegate = self;
        _imageScrollViewC = [self showThumbnailImageScrollViewAtIndexPath:_indexPath.row + 1];
        _imageScrollViewC.delegate = self;
        
        [_scrollView addSubview:_imageScrollViewA];
        [_scrollView addSubview:_imageScrollViewB];
        [_scrollView addSubview:_imageScrollViewC];
        
        _scrollView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageHiddenNavAndToolBar:)];
        [_scrollView addGestureRecognizer:tap];
        
        if (_isPresent == YES) {
            self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
        }
        else {
            if ([_globalVar.indexPaths containsObject:_indexPath]) {
                self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
            }
            else {
                self.navigationItem.rightBarButtonItem.image = _globalVar.noImg;
            }
        }

        //异步获取fullscreen图片
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetRepresentation * representation = [_aLAssets[_indexPath.row] defaultRepresentation];
            _centerImage = [UIImage imageWithCGImage:[representation fullScreenImage]] ;
            dispatch_async(dispatch_get_main_queue(), ^{
                ((UIImageView *)(((UIScrollView *)(_scrollView.subviews[1])).subviews.firstObject)).image = _centerImage;
            });
        });
    }
}

- (void)tapImageHiddenNavAndToolBar:(id)sender {
    if (self.navigationController.navigationBar.isHidden) {
        self.navigationController.navigationBar.hidden = NO;
        [_toolBar setHidden:NO];
    }
    else {
        self.navigationController.navigationBar.hidden = YES;
        [_toolBar setHidden:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _globalVar = [YPhotoGlobalVar shareGlobalVar];
    _globalVar.reloadIndexPaths = [_globalVar.indexPaths mutableCopy];
    
    if (_isPresent == YES) {
        _presentIndexParhs = [_globalVar.indexPaths mutableCopy];
        _aLAssets = [_globalVar.selectedAlassets mutableCopy];
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setNavgation];
    
    [self setScrollView];
    
    [self setToolBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (UIScrollView *)showThumbnailImageScrollViewAtIndexPath:(NSInteger)indexPathRow{

    UIImageView * imageView;
    
    if ((indexPathRow < 0)||(indexPathRow > _aLAssets.count - 1)) {
        imageView = [UIImageView new];
    }
    else {
        imageView = [[UIImageView alloc]initWithImage:[self thumbnailImage:indexPathRow]];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    imageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * indexPathRow, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentMode = UIViewContentModeScaleAspectFill;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 2.0;
    
    [scrollView addSubview:imageView];
    
    return scrollView;
}

- (UIImage *)thumbnailImage:(NSInteger)indexPathRow {
    if ((indexPathRow < 0)||(indexPathRow > _aLAssets.count-1)) {
        return [UIImage new];
    }
    return [UIImage imageWithCGImage:[_aLAssets[indexPathRow] aspectRatioThumbnail]];
}

- (UIImage *)fullscreenImage :(NSInteger)indexPathRow {
    if ((indexPathRow < 0)||(indexPathRow > _aLAssets.count)) {
        return [UIImage new];
    }
    ALAssetRepresentation * representation = [_aLAssets[indexPathRow] defaultRepresentation];
    return [UIImage imageWithCGImage:[representation fullScreenImage]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return;
    }
    
    //使用这个方法控制图片顺序
    @synchronized (self) {

        int indexPathRow = (int)roundf(scrollView.contentOffset.x/([UIScreen mainScreen].bounds.size.width+6));
        
        if (indexPathRow == _indexPath.row) {
            return ;
        }
        else if (indexPathRow < _indexPath.row) {  //向右划 显示左边的图片
            
            _indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
            //_indexPath.row = indexPathRow;

            ((UIImageView *)(((UIScrollView *)(scrollView.subviews.lastObject)).subviews.firstObject)).image = [self thumbnailImage:indexPathRow-1];
        
            (scrollView.subviews.lastObject).frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * (indexPathRow-1), 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
            [scrollView insertSubview:scrollView.subviews.lastObject atIndex:0];

            ((UIImageView *)(((UIScrollView *)(scrollView.subviews.lastObject)).subviews.firstObject)).image = [self thumbnailImage:indexPathRow+1];
        }
        else {  //左滑 显示右边的图片

            _indexPath = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
            
            ((UIImageView *)(((UIScrollView *)(scrollView.subviews.firstObject)).subviews.firstObject)).image = [self thumbnailImage:indexPathRow+1];

            (scrollView.subviews.firstObject).frame = CGRectMake(3 + ([UIScreen mainScreen].bounds.size.width + 6) * (indexPathRow+1), 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            [scrollView insertSubview:scrollView.subviews.firstObject atIndex:2];

            ((UIImageView *)(((UIScrollView *)(scrollView.subviews.firstObject)).subviews.firstObject)).image = [self thumbnailImage:indexPathRow-1];
        }

        if (_isPresent == YES) {
            NSIndexPath * cuttentTrueIndexPath = _presentIndexParhs[indexPathRow];
            if ([_globalVar.indexPaths containsObject:cuttentTrueIndexPath]) {
                self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
            }
            else {
                self.navigationItem.rightBarButtonItem.image = _globalVar.noImg;
            }
            
        }
        else {
            if ([_globalVar.indexPaths containsObject:_indexPath]) {
                self.navigationItem.rightBarButtonItem.image = _globalVar.yesImg;
            }
            else {
                self.navigationItem.rightBarButtonItem.image = _globalVar.noImg;
            }
        }
        
        for ( UIScrollView * v in scrollView.subviews ) {
            [v setZoomScale:1.0];
            for ( UIImageView * iv in v.subviews ) {
                iv.frame = [UIScreen mainScreen].bounds;
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != _scrollView) {
        return;
    }
    //用这个方法改变图片规格
    //获取要显示的图片的index 过半算
    int indexPathRow = (int)roundf(scrollView.contentOffset.x/([UIScreen mainScreen].bounds.size.width+6));

    if (indexPathRow != _aLAssets.count-1 || indexPathRow != 0) {
            _centerImage = [self fullscreenImage:indexPathRow];
        }
        else if (indexPathRow == 0) {
            _centerImage = [self fullscreenImage:indexPathRow];
        }
        else if (indexPathRow == _aLAssets.count-1) {
            _centerImage = [self fullscreenImage:indexPathRow];
        }
    
    ((UIImageView *)_scrollView.subviews[1].subviews.firstObject).image = _centerImage;
}

//当UIScrollView尝试进行缩放的时候调用
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    if (scrollView != _scrollView) {
        return (UIImageView *)_scrollView.subviews[1].subviews.firstObject;
    }
    else {
        return nil;
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {

}
//当缩放完毕的时候调用
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
}

//当正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //NSLog(@"正在缩放 %@",scrollView);
}

//MARK: - alertViewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)dealloc {
    //NSLog(@"present dealloc");
}
@end
