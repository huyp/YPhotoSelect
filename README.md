## YPhotoSelect

* 模仿微信的照片选择器
 
### <a id="图片"></a>图片
- 
- 它可以是一个小窗口,也可以是一个全屏的窗口
- 支持方向识别,横屏时自动最大化

![](http://images2015.cnblogs.com/blog/881202/201604/881202-20160411110636207-1067249997.gif)

### <a id="使用"></a>使用

#### 加载:
```
导入头文件
#import "YVideoPlayerView.h"
```

```
yVideoPlayerView = [YVideoPlayerView initWithVideoName:@"视频名称1" frame:CGRectMake(0,20,200,150) path:@"http://videoPath" onViewControll:self];

初始化方法
+ (instancetype)initWithVideoName:(NSString *)name frame:(CGRect)frame path:(NSString *)path onViewControll:(UIViewController *)OnViewController;

name : 视频名称
frame : 视频位置
path : 视频路径
onViewController : 加载视频所在的ViewController -> 一般写self
```

#### 更新:
```
yVideoPlayerView = [yVideoPlayerView updateVideoWithName:@"视频名称2" path:@"http://videoPath2" onViewController:self];

注意 : 这是一个对象方法
- (instancetype)updateVideoWithName:(NSString *)name path:(NSString *)path onViewController :(UIViewController *)OnViewController;

name : 视频名称
path : 视频路径
onViewController : 加载视频所在的ViewController -> 一般写self

这里不用重写frame -- 参照了初始化时
```

### 提醒
* 本框架纯ARC，兼容的系统>=iOS6.0、iPhone\iPad横竖屏
* 横竖屏需要手机关闭横竖排方向锁定
* App至少要开启`LandScape Left` 或 `LandScape Right`其中的一项. 如App其他页面不能转屏,用代码锁定!
	* 在其他不需要转屏的根视图里写如下代码:
	
	```
	- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	    return UIInterfaceOrientationMaskPortrait;
	}
	```

	* 在加载YVideoPlayerView的ViewController里写如下代码:

	```
	//只让这个页面转动
	- (BOOL)shouldAutorotate {
	    return YES;
	}
	- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	    if (yVideoPlayerView.canOrientationChange == YES) {  //刚进入页面是竖屏
	        return UIInterfaceOrientationMaskAllButUpsideDown;
	    }
	    return UIInterfaceOrientationMaskPortrait;
	}
```

### 期待
* 如果在使用过程中遇到BUG，希望你能告诉我，谢谢. 我的email : huyanpeng_ios@126.com
* 如果在使用过程中发现功能不够用，您可以自定义添加功能 , 也可以告诉我，我非常想为这个框架增加更多好用的功能 ，我也同样期待您的加入一起完善这个框架 谢谢
* 如果您喜欢,劳烦您点个`star`! thank you !

