# polyv-ios-upload
>本项目演示使用PLVUploadSDK.framework静态库上传视频文件，polyvUploadSDK实现了文件的续传和加速上传等特性。

>polyvUploadSDK会将待上传的视频文件切成大小相同块(块在这里为服务端的数据存储单位)，再把每一块切成大小相等的片。上传过程就是把一片片的数据片上传至服务器，如果当前块未传输完毕(手动取消或者断网等情况造成传输终止)，再次上传时需要重新传输该文件块。如果视频总文件较小，则会较明显看到进度从之前某个位置开始。

主要特性：

- 通过分片上传技术实现文件的断点续传
- 使用CDN服务器实现文件的加速上传

说明：

- 拍摄上传功能需在真机上测试
- 此版本的上传程序在退出后暂不支持续传
- 项目中对视频文件或拍摄的视频进行压缩处理等操作如不需要可自行修改源码

## 更新说明

2016-9-2

- 修复demo中iOS8.4系统下压缩视频文件时崩溃问题，以及压缩时产生声音的问题
- demo中使用到新的类添加版本判断和说明，提醒低版本上的兼容问题
- 更新上传API接口文件，取消旧的API

2016-8-23

- 原上传接口不可用，更新使用新的接口
- 更新PLVApi.h接口文件，修改出现的文字和语法错误等

## PLVUploadSDK.framework
    
- 接口文件：PLVApi.h
- 支持iOS7.0以上系统版本编译及armv7、 arm64(真机)、i386、x86_64(模拟器)架构cpu
  
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

  **现POLYV上传SDK已全面支持ATS(App Transport Security)，所有的网络访问均使用HTTPS，无需在info.plist中配置ATS。**

5. 导入PLVApi.h头文件

```objective-c
#import<PLVUploadSDK/PLVApi.h>
```
  **使用此头文件时如果Xcode提示"file not found"错误,可尝试直接拷贝此行代码,Xcode7.3编译器有时没有感应**

## 上传接口及使用

1. PLVApi.h接口文件

 - 获取上传token等信息

	```objective-c
/**
 *  获取上传token等信息
 *
 *  @param writeToken      用户的writeToken
 *  @param userid          用户的id
 *  @param cataid          分类id
 *  @param title           视频标题
 *  @param tag             标签(多个标签用逗号分隔)
 *  @param luping          视频课件优化处理：0/1
 *  @param filepath        文件路径
 *  @param completionBlock 获取成功后回调的block,
            uploadToken:    上传token(有效期为两个小时)
            vid:            待上传文件vid
            fileInfo:       待上传文件其他信息
 *  @param failureBlock    获取失败回调的block
 */
+ (void)getUploadInfoWithWritetoken:(NSString *)writeToken
                             userid:(NSString *)userid
                             cataid:(NSString *)cataid
                              titlt:(NSString *)title
                                tag:(NSString *)tag
                             luping:(NSString *)luping
                           filepath:(NSString *)filepath
                    completionBlock:(void(^)(NSString *uploadToken, NSString *vid, NSDictionary *fileInfo))completionBlock
                       failureBlock:(void(^)(NSDictionary *errorMsg))failureBlock;
```   
**获取到的上传uploadToken值有效期为两个小时**

 - 上传文件

	```objective-c
/**
 *  上传文件(代码块回调部分在主线程中)
 *
 *  @param filePath      待上传文件路径(和获取上传token的方法中路径须一致)
 *  @param uploadToken   上传token
 *  @param taskTag       上传任务标记,配合cancelUploadInTaskTag:使用
 *  @param progressBlock 上传中回调的block
 *  @param successBlock  上传成功回调的block
 *  @param failureblock  上传失败回调的block
 */
+ (void)startUploadWithFile:(NSString *)filePath
                uploadToken:(NSString *)uploadToken
                    taskTag:(NSUInteger)taskTag
             progressBlocak:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
               successBlock:(void(^)(NSDictionary *responseDict))successBlock
               failureBlock:(void(^)(NSDictionary *errorMeg))failureblock;
```     
 - 取消taskTag标记的上传任务

	```objective-c
+ (void)cancelUploadingOperationInTag:(NSUInteger)taskTag;
```

2. 上传

	```objective-c
	// 获取上传token
    [PLVApi getUploadInfoWithWritetoken:_writetoken userid:_userid cataid:_cataid titlt:_fileTitle tag:_tag luping:_luping filepath:_filePath completionBlock:^(NSString *uploadToken, NSString *vid, NSDictionary *fileInfo) {
        ++ _taskTag;		// 设置一个记录当前上传任务的taskTag变量
        
        // 上传文件
        [PLVApi startUploadWithFile:_filePath uploadToken:uploadToken taskTag:_taskTag progressBlocak:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            self.statusLabel.text = @"uploading...";                                              // 上传中操作，多次调用
            float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
            self.progressView.progress = percent;
            self.progressLabel.text = [NSString stringWithFormat:@"progress:%.1f%%",percent > 1 ? 100.0 : percent*100]; // 结果可能超过百分百
            
        } successBlock:^(NSDictionary *responseDict) {
            NSLog(@"slice upload success : %@", responseDict);                                  // 上传文件成功回调
            self.statusLabel.text = @"slice upload success";
            
            [self clearlocalVideoUploadCaches];         // 清空视频缓存(可选)
        } failureBlock:^(NSDictionary *errorMsg) {
            NSLog(@"failured : %@", errorMsg);                                                  // 上传文件失败或终止回调
            
            NSObject *messages = [errorMsg[@"messages"] firstObject];
            NSString *status = [NSString new];
            
            if ([messages isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)messages;
                status = dict[@"message"];
            }else {
                status = (NSString *)messages;
            }
            self.statusLabel.text = status;
        }];
    } failureBlock:^(NSDictionary *errorMsg) {
        NSLog(@"get file info failure:%@",errorMsg);   // 初始化失败
    }];
}
```

## DEMO 项目说明

本工程使用POLYV 上传SDK进行文件的上传演示。项目代码可供参考，使用中需要注意接口文件的说明。

- 清空视频缓存，视频上传成功后可以清空视频文件缓存，在demo中已默认取消，如有需要可参考`[self clearlocalVideoUploadCaches]`方法（解注释）。
- 视频压缩，demo中默认会压缩视频（建议压缩）。

## FAQ

1. 客户端打印错误信息

```
failured : {
    messages =     (
                {
            code = 401;
            message = "File Name Invalid";
        }
    );
}
```
文件名无效，同一视频文件上传成功后不能重复上传


