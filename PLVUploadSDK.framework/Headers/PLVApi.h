//
//  PLVApi.h
//  PolyvUploadSDK
//
//  Created by FT on 16/6/12.
//  Copyright © 2016年 Polyv. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Polyv分片上传API */
@interface PLVApi : NSObject


/**
 *  初始化上传
 *  代码块回调在异步线程中
 *  @param writetoken      用户的writetoken值
 *  @param userid          用户的id
 *  @param cataid          分类id
 *  @param title           视频标题
 *  @param tag             视频标签
 *  @param luping          课件优化处理：0/1
 *  @param filepath        文件路径
 *  @param completionBlock 请求成功后回调的block
 *  @param failureBlock    请求失败回调的block
 */
- (void)initUploadWithWritetoken:(NSString *)writetoken
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
 *  上传文件
 *  代码块回调部分在主线程中
 *  @param taskTag       上传任务的tag，配合cancelUploadInTaskTag:使用
 *  @param progressBlock 上传进度
 *  @param successBlock  上传成功回调的block
 *  @param failureblock  上传失败回调的block
 */
+ (void)startUploadWithToken:(NSString *)uploadToken
                     taskTag:(NSUInteger)taskTag
              progressBlocak:(void(^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
                successBlock:(void(^)(NSDictionary *responseDict))successBlock
                failureBlock:(void(^)(NSDictionary *errorMeg))failureblock;

/** 取消上传*/
+ (void)cancelUploadInTaskTag:(NSUInteger)taskTag;


@end
