//
//  YPhotothumbnailsViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/20.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoThumbnailsViewController.h"
#import "YPhotoPreviewViewController.h"
#import "YPhotoGlobalVar.h"

#import "YPhotoAblumTableViewController.h"

@interface YPhotoThumbnailsViewController ()
@property (strong,nonatomic) UICollectionView * collectionView;
@property (strong,nonatomic) UIToolbar * toolBar;
@property (assign,nonatomic) BOOL isMaxNum;
@property (strong,nonatomic) NSMutableDictionary * selectedFullScreenImages;
@property (strong,nonatomic) NSMutableArray * aLAssets;
@property (strong,nonatomic) UIBarButtonItem * selectBtn;
@property (strong,nonatomic) UILabel * selectNumLabel;
@property (strong,nonatomic) ALAssetRepresentation * representation;
@property (strong,nonatomic) UIBarButtonItem * previewBtn;
@property (strong,nonatomic) YPhotoGlobalVar * globalVar;
@end

@implementation YPhotoThumbnailsViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSString *)getZH_CN:(NSString *)name {
    if ([name isEqualToString:@"Favorites"]) {
        return @"个人收藏";
    }
    else if ([name isEqualToString:@"Panoramas"]) {
        return @"全景照片";
    }
    else if ([name isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }
    else if ([name isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    }
    else if ([name isEqualToString:@"Bursts"]) {
        return @"连拍快照";
    }
    else if ([name isEqualToString:@"Selfies"]) {
        return @"自拍";
    }
    else if ([name isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    }
    else {
        return name;
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel {
    _globalVar.currentNum = 0;
    _globalVar.indexPaths = nil;
    _globalVar.selectedThumbnails = nil;
    _globalVar.selectedImgs = nil;
    _globalVar.selectedAlassets = nil;
    _globalVar.reloadIndexPaths = nil;
    _globalVar.animation = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadNavgationBar {
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [backItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backItem;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    
    self.title = [self getZH_CN:[_album valueForProperty:ALAssetsGroupPropertyName]];
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
    UIImage * bgImage = [self createImageWithColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [_toolBar setBackgroundImage:bgImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:_toolBar];
    
    NSArray * h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolBar]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"toolBar":_toolBar}];
    //NSArray * v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolBar(44)]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"toolBar":_toolBar}];
    
    _previewBtn = [[UIBarButtonItem alloc]initWithTitle:@"预览" style:UIBarButtonItemStylePlain target:self action:@selector(presentTap)];
    [_previewBtn setTintColor:[UIColor grayColor]];
    _previewBtn.enabled = NO;
    
    UIBarButtonItem * flexibleBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    _selectBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneTap)];
    [_selectBtn setTintColor:[UIColor greenColor]];
    _selectBtn.enabled = NO;
    
    _selectNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    _selectNumLabel.layer.masksToBounds = YES;
    _selectNumLabel.layer.cornerRadius = 10;
    _selectNumLabel.backgroundColor = [UIColor greenColor];
    _selectNumLabel.textAlignment = NSTextAlignmentCenter;
    _selectNumLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem * label = [[UIBarButtonItem alloc]initWithCustomView:_selectNumLabel];
    
    _toolBar.items = @[_previewBtn,flexibleBarBtn,label,_selectBtn];
    
    [self.view addConstraints:h];
    //[self.view addConstraints:v];
    
    NSArray * toolBar_collention = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[collectionView]-0-[toolBar(44)]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"collectionView":_collectionView,@"toolBar":_toolBar}];
    [self.view addConstraints:toolBar_collention];
}


- (void)loadAlAsset {
    _aLAssets = [NSMutableArray array];
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用想访问您的相册" message:@"请设置应用的相册访问权限" delegate:self cancelButtonTitle:@"不允许" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
    else {
        [_album enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [_aLAssets addObject:result];
            }
        }];
    }
}

- (void)loadCollectionView {
    
    UICollectionViewFlowLayout * pickImageCollectionLayout =  [UICollectionViewFlowLayout new];
    pickImageCollectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    pickImageCollectionLayout.minimumInteritemSpacing = 2;
    pickImageCollectionLayout.minimumLineSpacing = 2;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44) collectionViewLayout:pickImageCollectionLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"YPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"YPhotoCollectionCellID"];
    [self.view addSubview:_collectionView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _globalVar = [YPhotoGlobalVar shareGlobalVar];
    
    [self loadNavgationBar];
    [self loadAlAsset];
    [self loadCollectionView];
    [self setToolBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    //NSLog(@"_globalVar.indexPaths=%@",_globalVar.indexPaths);
    if ( _globalVar.reloadIndexPaths.count > 0) {
        [_collectionView reloadItemsAtIndexPaths:_globalVar.reloadIndexPaths];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_globalVar.selectedAlassets.count > 0) {
        _previewBtn.enabled = YES;
        _selectBtn.enabled = YES;
        
        _selectNumLabel.hidden = NO;
        _selectNumLabel.text = [NSString stringWithFormat:@"%d",_globalVar.currentNum];
    } else {
        _previewBtn.enabled =  NO;
        _selectBtn.enabled = NO;
        
        _selectNumLabel.hidden = YES;
    }
}

- (void)presentTap {
    if (_globalVar.currentNum <= 0) {
        return;
    }
    
    UIImage * centerImage = [UIImage imageWithCGImage:[_globalVar.selectedAlassets[0] thumbnail]] ;
    YPhotoPreviewViewController * previewVC = [YPhotoPreviewViewController new];
    previewVC.centerImage = centerImage;
    NSIndexPath * indepath = [NSIndexPath indexPathForRow:0 inSection:1];
    previewVC.indexPath = indepath;
    previewVC.aLAssets = _globalVar.selectedAlassets;
    previewVC.lib = _lib;
    previewVC.isPresent = YES;
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)doneTap {
    
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
    
    _globalVar.indexPaths = nil;
    _globalVar.reloadIndexPaths = nil;
    _globalVar.selectedAlassets = nil;
    _globalVar.animation = nil;
    
    [activityIV stopAnimating];
    [activityIV removeFromSuperview];
    
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _aLAssets.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellID = @"YPhotoCollectionCellID";
    __weak YPhotoCollectionViewCell * cell = (YPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    if ([_globalVar.indexPaths containsObject:indexPath]) {
        cell.isPicked = YES;
        [cell.button setImage:_globalVar.yesImg forState:UIControlStateNormal];
    } else {
        cell.isPicked = NO;
        [cell.button setImage:_globalVar.noImg forState:UIControlStateNormal];
    }
    
    cell.selectBlock = ^(BOOL isSelect) {
        if (isSelect == YES) {
            
            _globalVar.currentNum ++;
            if (_globalVar.currentNum  > 0) {
                _previewBtn.enabled = YES;
                _selectBtn.enabled = YES;
                
                _selectNumLabel.hidden = NO;
            }
            _selectNumLabel.text = [NSString stringWithFormat:@"%d",_globalVar.currentNum];
            [self selectCompressionImageWithIndexPath:(NSIndexPath *)indexPath];
        }
        else if (isSelect == NO) {
            _globalVar.currentNum --;
            if (_globalVar.currentNum  == 0) {
                _previewBtn.enabled = NO;
                _selectBtn.enabled = NO;
                
                _selectNumLabel.hidden = YES;
            }
            if (_globalVar.currentNum  >= 0) {
                _selectNumLabel.text = [NSString stringWithFormat:@"%d",_globalVar.currentNum];
                [self deleteCompressionImageIndexPath:(NSIndexPath *)indexPath];
            }
        }
    };
    cell.imageView.image = [UIImage imageWithCGImage:((ALAsset *)_aLAssets[indexPath.row]).thumbnail];
    
    return cell;
}

- (void)selectCompressionImageWithIndexPath:(NSIndexPath *)indexPath {

    [_globalVar.selectedAlassets addObject:_aLAssets[indexPath.row]];
    [_globalVar.indexPaths addObject:indexPath];
}

- (void)deleteCompressionImageIndexPath:(NSIndexPath *)indexPath {
    [_globalVar.selectedAlassets removeObject:_aLAssets[indexPath.row]];
    [_globalVar.indexPaths removeObject:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage * centerImage = [UIImage imageWithCGImage:((ALAsset *)_aLAssets[indexPath.row]).thumbnail];
    YPhotoPreviewViewController * previewVC = [YPhotoPreviewViewController new];
    previewVC.centerImage = centerImage;
    previewVC.indexPath = indexPath;
    previewVC.aLAssets = _aLAssets;
    previewVC.lib = _lib;
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWH = ([UIScreen mainScreen].bounds.size.width - 10) / 4;
    CGSize cellSize = CGSizeMake(cellWH, cellWH);
    return cellSize;
}

//MARK: - alertViewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    //NSLog(@"thumbnail dealloc");
}

@end
