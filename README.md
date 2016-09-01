# polyv-ios-upload
>本项目演示如何使用PLVUploadSDK.framework静态库上传视频文件，polyvUploadSDK实现了断点续传和后台上传。断点续传原理是将待上传的文件切成大小相同块，块在这里为服务端的数据存储单位，在把每一块切成大小相等的片。上传过程是把一片片的数据片上传至服务器，如果当前块未传输完毕(手动取消或者断网等情况造成传输终止)，再次上传时会重新传输该块(可能退回之前某一进度点继续开始上传)。

>目前iOS版本的上传程序在退出后暂不支持续传

本项目中如对视频文件或拍摄的视频进行压缩处理等操作如不需要可自行修改源码

## 更新说明

2016-8-23

- 原上传接口不可用，更新使用新的接口
- 更新PLVApi.h接口文件，修改出现的文字和语法错误等

## PLVUploadSDK.framework
    
- 接口文件为PLVApi.h
- 支持iOS7.0以上系统版本编译及armv7、 arm64(真机)、i386、x86_64(模拟器) 架构cpu
  
## 使用前准备
1. 导入PLVUploadSDK

 将PLVUploadSDK.framework拖入到工程中，选中”Copy items if needed”，如下图。或先将该framework拷贝至工程目录下，选中项目的TARGETS->Build Phases下的Link binary With Libraries中添加PLVUploadSDK.framework
![](https://raw.githubusercontent.com/easefun/polyv-ios-upload/master/images/1.png)

2. 导入libz.tbd库文件

   Xcode project->TARGETS->Build Phases下的Link binary With Libraries中查找并导入libz.tbd库文件
     
3. 设置Other Linker Flags的标志 -ObjC

  PLVUploadSDK.framework中使用了category，在使用该库文件时需要将静态库中所有的和对象相关的文件都加载进来。具体操作如下：在Xcode project->TARGETS->Build Settings的Other Linker Flags下添加 -ObjC 标志。
  如果继续报错"selector not recognized"可尝试添加"-all_load"标志(加载静态库中所有文件)。
    
4. 配置info.plist文件

  iOS9.0中开发要求App内访问的网络必须使用HTTPS协议，为了解决这个问题。我们可以在Info.plist文件中添加NSAppTransportSecurity条目，此条目下再添加NSAllowsArbitraryLoads，并设值为YES
![](https://raw.githubusercontent.com/easefun/polyv-ios-upload/master/images/2.png)
 非测试文件中的Info.plist

5. 导入PLVApi.h头文件

```objective-c
#import<PLVUploadSDK/PLVApi.h>
```
  **使用此头文件时如果Xcode提示"file not found"错误,可尝试直接拷贝此行代码,因为Xcode7.3编译器有时没有感应**

## PLVApi.h接口文件
* 初始化上传

```objective-c
- (void)initUploadWithWriteToken:(NSString *)writeToken
                          userid:(NSString *)userid
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
+ (void)startUploadWithUploadToken:(NSString *)uploadToken
                           taskTag:(NSUInteger)taskTag
                    progressBlocak:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
                      successBlock:(void(^)(NSDictionary *responseDict))successBlock
                      failureBlock:(void(^)(NSDictionary *errorMeg))failureblock;
```     
* 取消taskTag标记的上传任务

```objective-c
+ (void)cancelUploadingOperationInTag:(NSUInteger)taskTag;
```

#### 注意: 初始化上传后返回的获取的uploadToken值的有效期为两个小时；拍摄上传功能需在真机上测试

commit test

