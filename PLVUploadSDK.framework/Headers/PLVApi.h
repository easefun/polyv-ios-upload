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
+ (void)getUploadInfoWithWritetoken:( NSString * _Nonnull )writeToken
                             userId:( NSString * _Nonnull )userId
                             cataId:( NSString * _Nonnull )cataId
                              titlt:( NSString * _Nonnull )title
                                tag:( NSString * _Nonnull )tag
                             luping:( NSString * _Nonnull )luping
                           filePath:( NSString * _Nonnull )filePath
                    completionBlock:( void(^ _Nullable )(NSString * _Nonnull uploadToken, NSString * _Nonnull vid, NSDictionary * _Nonnull fileInfo))completionBlock
                       failureBlock:( void(^ _Nullable )(NSDictionary * _Nullable errorMsg))failureBlock;

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
+ (void)startUploadWithFile:( NSString * _Nonnull )filePath
                uploadToken:( NSString * _Nonnull )uploadToken
                    taskTag:( NSUInteger )taskTag
             progressBlocak:(void(^ _Nullable )(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
               successBlock:(void(^ _Nullable )(NSDictionary * _Nullable responseDict))successBlock
               failureBlock:(void(^ _Nullable )(NSDictionary * _Nullable errorMeg))failureBlock;

/** 取消taskTag标记的上传任务*/
+ (void)cancelUploadingOperationInTag:(NSUInteger)taskTag;


@end
