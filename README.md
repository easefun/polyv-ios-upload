# polyv-ios-upload
>此工程使用PLVUploadSDK.framework静态库演示文件上传的demo，polyvUploadSDK实现了断点续传和后台上传。其断点续传的原理是将待上传的文件切成大小相同块，块是服务端的永久数据存储单位，块中也是一系列特定大小的数据片。上传过程就是上传一片一片的数据片，如果当前块未传输完毕(手动取消或者断网等情况造成传输终止)，再次上传时则会重新传输该块，上传进度上也就会看到进度回到之前某一点开始上传。

>程序退出后不可以续传，因为续传信息在内存中保存，但是可以将待传文件信息(名称、路径等)保存下来，再次进入应用时读取待传文件

本工程上传文件时会对选取的视频文件或拍摄的视频进行压缩处理，如果不需要压缩，简单修改一下代码即可(压缩视频的代码在demo中)

## 更新说明

2016-8-23

- 原上传接口不可用，先更新新的接口

## PLVUploadSDK.framework
  接口文件为PLVApi.h，支持IOS7.0以上系统版本的编译以及armv7 armv7s arm64(真机)、 i386 x86_64(模拟器) 架构的cpu
  
## 使用前的准备
1. 导入PLVUploadSDK

 将PLVUploadSDK.framework静态包拖入到工程中，选中”Copy items if needed”，如下图。或者先将该framework拷贝至工程目录下，选中项目的TARGETS->Build Phases下的Link binary With Libraries中添加PLVUploadSDK.framework
![](https://raw.githubusercontent.com/easefun/polyv-ios-upload/master/images/1.png)

2. 导入liz.tbd库文件

   Xcode project->TARGETS->Build Phases下的Link binary With Libraries中查找并导入liz.tbd库文件
     
3. 设置Other Linker Flags的标志 -ObjC

  因为PLVUploadSDK.framework中使用了category，所以在使用该库文件时需要将静态库中所有的和对象相关的文件都加载进来。具体操作如下：在Xcode project->TARGETS->Build Settings的Other Linker Flags下添加 -ObjC 标志。
  如果依旧出现selector not recognized 可尝试添加-all_load 标志  加载静态库中所有文件。
    
4. 配置info.plist文件，允许http连接访问

  iOS9.0中开发要求App内访问的网络必须使用HTTPS协议，为了解决这个问题。我们可以在Info.plist文件中添加NSAppTransportSecurity条目，此条目下再添加NSAllowsArbitraryLoads，并设值为YES
![](https://raw.githubusercontent.com/easefun/polyv-ios-upload/master/images/2.png)
 非测试文件中的Info.plist

5. 导入PLVApi.h头文件

```objective-c
#import<PLVUploadSDK/PLVApi.h>
```

## PLVApi.h接口文件
* 初始化上传

```objective-c
- (void)initUploadWithWritetoken:(NSString *)writetoken userid:(NSString *)userid
                          cataid:(NSString *)cataid
                           titlt:(NSString *)title
                             tag:(NSString *)tag
                          luping:(NSString *)luping
                        filepath:(NSString *)filepath
                        fileSize:(NSString *)fileSize
                 completionBlock:(void(^)(NSDictionary *responseDict, NSString *vid))completionBlock
                    failureBlock:(void(^)(NSDictionary *errorMsg))failureBlock;
```   
* 上传文件

```objective-c
+ (void)startUploadWithToken:(NSString *)uploadToken
                     taskTag:(NSUInteger)taskTag
              progressBlocak:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
                successBlock:(void(^)(NSDictionary *responseDict))successBlock
                failureBlock:(void(^)(NSDictionary *errorMeg))failureblock; 
```     
* 取消上传文件

```objective-c
  + (void)cancelUploadInTaskTag:(NSUInteger)taskTag;
```

#### 注意: 需在真机上测试拍摄上传的功能  获取的writeToken值有效期为两个小时
