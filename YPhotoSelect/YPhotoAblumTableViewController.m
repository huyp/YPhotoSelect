//
//  ViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/20.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "YPhotoAblumTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "YPhotothumbnailsViewController.h"

@interface YPhotoAblumTableViewController ()
@property (strong,nonatomic) NSMutableArray * albums;
@property (strong,nonatomic) NSMutableArray * thumbnails;
@property (strong,nonatomic) NSMutableArray * names;
@property (strong,nonatomic) NSMutableArray * amounts;
@property (strong,nonatomic) ALAssetsLibrary * assetsLibrary;

@end
@implementation YPhotoAblumTableViewController



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @"相册";
    [backItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backItem;
    
    _albums = [[NSMutableArray alloc] init];
    _thumbnails = [[NSMutableArray alloc] init];
    _names = [[NSMutableArray alloc] init];
    _amounts = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self loadAlbum];
}

- (void)loadAlbum {
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (status == ALAuthorizationStatusRestricted || status == ALAuthorizationStatusDenied) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用想访问您的相册" message:@"请设置应用的相册访问权限" delegate:self cancelButtonTitle:@"不允许" otherButtonTitles:@"去设置", nil];
        [alert show];
    }
    else {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group) {
                if (group.numberOfAssets > 0) {
                    // 把相册储存到数组中，方便后面展示相册时使用
                    [_albums addObject:group];
                    [_names addObject:[self getZH_CN:[group valueForProperty:ALAssetsGroupPropertyName]]];
                    [_amounts addObject:[NSString stringWithFormat:@"%ld",(long)[group numberOfAssets]]];
                    [_thumbnails addObject:[UIImage imageWithCGImage:[group posterImage]]];
                }
            }
            else {
                [self.tableView reloadData];
            }
        }
        failureBlock:^(NSError *error) {
            NSLog(@"Asset group not found!");
        }];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_albums == nil) {
        return 0;
    }
    else {
        return _albums.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"album";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    cell.imageView.image = _thumbnails[indexPath.row];
    cell.textLabel.text = _names[indexPath.row];
    cell.detailTextLabel.text = _amounts[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UIScreen mainScreen].bounds.size.height/9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YPhotoThumbnailsViewController * photoThumbnailVC = [YPhotoThumbnailsViewController new];
    photoThumbnailVC.album = _albums[indexPath.row];
    photoThumbnailVC.lib = _assetsLibrary;
    [self.navigationController pushViewController:photoThumbnailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)dealloc {
    //NSLog(@"ablum dealloc");
}

//MARK: - alertViewdelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
