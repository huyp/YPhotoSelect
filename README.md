## YPhotoSelect

* 模仿微信的照片选择器
* 获取图片的缩略图和高清图
* 保证浏览图片时的内存循环利用,浏览图片时内存稳定,内存占用很小.和微信一致.
* 可以自定义图片数量
* 可以自定义高清图片的尺寸
 
### <a id="图片"></a>图片

![](http://images2015.cnblogs.com/blog/881202/201609/881202-20160927161002360-46403511.png)
![](http://images2015.cnblogs.com/blog/881202/201609/881202-20160927161005453-795690702.png)
![](http://images2015.cnblogs.com/blog/881202/201609/881202-20160927161009750-1488094518.png)

### <a id="使用"></a>使用

##### 加载:
```
 必须要导入的头文件 :
 #import "YPhotoAblumTableViewController.h"
 #import "YPhotoNavViewController.h"
 #import "YPhotoGlobalVar.h"
```

```
需要的属性 :
@property (strong,nonatomic) YPhotoGlobalVar * globalVar;  //全局变量
@property (strong,nonatomic) NSMutableArray * thumbnails;  //接收返回的缩略图
@property (strong,nonatomic) NSMutableArray * imgs;  //接收返回的图片

```

```
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
    
    //这是自定义页面
    [self setView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //以下这几步是必须的
    //添加图片
    if (_globalVar.selectedThumbnails.count >0) {
        [_thumbnails addObjectsFromArray:_globalVar.selectedThumbnails];
        [_imgs addObject:_globalVar.selectedImgs];
    }
    //设置还能选择的最大图片数量 第一个数字是最大数量
    _globalVar.maxNum = 3 - (int)_thumbnails.count;
    
    [collection reloadData];
}
```
```
//点击按钮进入相册的方法
- (void)present {
    //以下这几步是必须的
    YPhotoAblumTableViewController * y = [YPhotoAblumTableViewController new];
    YPhotoNavViewController * n = [[YPhotoNavViewController alloc]initWithRootViewController:y];
    //必须是present方式进入照片选择器;
    [self presentViewController:n animated:YES completion:nil];
}
```
```
//如果采用了collectionView展示图片缩略图 数量这么设置
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _thumbnails.count;
}

```

### 提醒
* 本框架纯ARC，兼容的系统>=iOS6.0、iPhone竖屏 不支持iPad
* 图片浏览器已经把方向锁定在竖屏,但是不影响application的横竖屏切换

* 如果在使用过程中遇到BUG，希望你能告诉我，谢谢. 我的email : huyanpeng_ios@126.com
* 如果在使用过程中发现功能不够用，您可以自定义添加功能 , 也可以告诉我，我非常想为这个框架增加更多好用的功能 ，我也同样期待您的加入一起完善这个框架 谢谢
* 如果您喜欢,劳烦您点个`star`! thank you !

