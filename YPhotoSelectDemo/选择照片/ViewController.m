//
//  ViewController.m
//  选择照片
//
//  Created by 彦鹏 on 16/7/20.
//  Copyright © 2016年 Huyp. All rights reserved.
//

#import "ViewController.h"
#import "YPhotoAblumTableViewController.h"
#import "YPhotoNavViewController.h"
#import "YPhotoGlobalVar.h"


@interface ViewController ()

{
    UICollectionView * collection;
}

@property (strong,nonatomic) YPhotoGlobalVar * globalVar;  //全局变量
@property (strong,nonatomic) NSMutableArray * thumbnails;  //接收返回的缩略图
@property (strong,nonatomic) NSMutableArray * imgs;  //接收返回的图片
@end

@implementation ViewController

/*
 必须要导入的头文件 :
 #import "YPhotoAblumTableViewController.h"
 #import "YPhotoNavViewController.h"
 #import "YPhotoGlobalVar.h"
 
 present 和 viewDidAppear 中的方法是必须要实现的
 
 viewDidLoad中的变量有默认值,如果默认满足需求可不设置
 
 如果使用了collectionView方式展示图片 Item的数量 使用 接收到的缩略图.count
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    _thumbnails = [NSMutableArray new];
    _imgs = [NSMutableArray new];
    //设置全局变量
    _globalVar = [YPhotoGlobalVar shareGlobalVar];
    
    //图片的尺寸缩放值  照相机拍摄 default is {758, 1136} or {1136, 758} scale 0..1
    _globalVar.targetImageScale = 0.5;
    //设置图片类型 png jpg  default is jpg
    _globalVar.png = YES;
    
    [self setView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //以下这几部是必须的
    
    //添加图片
    if (_globalVar.selectedThumbnails.count >0) {
        [_thumbnails addObjectsFromArray:_globalVar.selectedThumbnails];
        [_imgs addObject:_globalVar.selectedImgs];
    }
    //设置还能选择的最大图片数量 第一个数字是最大数量
    _globalVar.maxNum = 3 - (int)_thumbnails.count;
    
    [collection reloadData];
}
//点击按钮进入相册的方法
- (void)present {
    //以下这几步是必须的
    YPhotoAblumTableViewController * y = [YPhotoAblumTableViewController new];
    YPhotoNavViewController * n = [[YPhotoNavViewController alloc]initWithRootViewController:y];
    //必须是present方式进入照片选择器;
    [self presentViewController:n animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _thumbnails.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cell";
    
    TestCollectionViewCell * cell = (TestCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    //如果使用了collectionView方式展示图片 使用接收到的缩略图
    cell.imageView.image = _thumbnails[indexPath.row];
    
    return cell;
}

- (void)setView {
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(80, 80, 80, 80)];
    [button setTitle:@"add" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(present) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:button];
    
    UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-200) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor yellowColor];
    collection.delegate = self;
    collection.dataSource = self;
    [collection registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:collection];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"memoryWarning");
    // Dispose of any resources that can be recreated.
}

@end
