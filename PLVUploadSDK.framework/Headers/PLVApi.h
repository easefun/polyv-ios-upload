//
//  PLVApi.h
//  PolyvUploadSDK
//
//  Created by FT on 16/6/12.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVApi : NSObject

/**
*  初始化上传(代码块回调在异步线程中)
*
*  @param writeToken      用户的writeToken
*  @param userid          用户的id
*  @param cataid          分类id
*  @param title           视频标题
*  @param tag             标签(多个标签用逗号分隔)
*  @param luping          视频课件优化处理：0/1
*  @param filepath        文件路径
*  @param fileSize        请求成功后回调的block
*  @param completionBlock 请求成功后回调的block
*  @param failureBlock    请求失败回调的block
*/
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

/**
 *  上传文件(代码块回调部分在主线程中)
 *
 *  @param uploadToken   上传token
 *  @param taskTag       上传任务标记,配合cancelUploadInTaskTag:使用
 *  @param progressBlock 上传中回调的block
 *  @param successBlock  上传成功回调的block
 *  @param failureblock  上传失败回调的block
 */
+ (void)startUploadWithUploadToken:(NSString *)uploadToken
                           taskTag:(NSUInteger)taskTag
                    progressBlocak:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
                      successBlock:(void(^)(NSDictionary *responseDict))successBlock
                      failureBlock:(void(^)(NSDictionary *errorMeg))failureblock;

/** 取消taskTag标记的上传任务*/
+ (void)cancelUploadingOperationInTag:(NSUInteger)taskTag;

@end
