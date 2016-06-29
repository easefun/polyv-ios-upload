//
//  ViewController.m
//  polyvUploadSDK
//
//  Created by ftao on 16/6/21.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <PLVUploadSDK/PLVApi.h>


@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSString *_originalFileSize;        // 原始文件大小 :bytes
    NSString *_newFileSize;             // 压缩后的文件大小 :bytes
    NSUInteger _taskTag;                // 上传任务的标记
    NSString *_filePath;
}

@property (nonatomic, copy) NSString *writetoken;       // 用户的writeToken
@property (nonatomic, copy) NSString *userid;           // 用户id
@property (nonatomic, copy) NSString *cataid;           // 分类id
@property (nonatomic, copy) NSString *fileTitle;        // 视频标题
@property (nonatomic, copy) NSString *tag;              // 标签，逗号分隔
@property (nonatomic, copy) NSString *luping;           // 视频课件优化处理：0/1


@property (weak, nonatomic) IBOutlet UILabel            *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView        *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView     *progressView;
@property (weak, nonatomic) IBOutlet UILabel            *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton           *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton           *cancelbutton;


@property (strong, nonatomic) UIImagePickerController   *videoPicker;
@property (assign, nonatomic) BOOL                      isVideoPicker;      // 是否拍摄


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];            // UI配置
    [self initializeData];     // 初始化数据
}


- (void)setupUI {
    UIBarButtonItem *rightBarButtonitem = [[UIBarButtonItem alloc] initWithTitle:@"选取" style:UIBarButtonItemStyleDone target:self action:@selector(showSheetAlert)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"断点续传"];
    [navigationItem setRightBarButtonItem:rightBarButtonitem];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
    [self.view addSubview:navigationBar];
    navigationBar.items = @[navigationItem];
}


- (void)initializeData {

    // 示例数据
    self.writetoken = @"Y07Q4yopIVXN83n-MPoIlirBKmrMPJu0";      // 你的writetoken
    self.userid = @"sl8da4jjbx";                                // 你的userid
    self.cataid = @"1";
    self.fileTitle = @"中文--标题+*1";
    self.tag = @"keyword1, 标签2";
    self.luping = @"0";
    
    // 文件在退出程序时可以保存文件路径，再次进入时读取文件的地址。示例(仅参考)
    //     _filePath =[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
    //        _newFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] objectForKey:NSFileSize];
    //        // 获取视频缩略图
    //        MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_filePath]];
    //        self.imageView.image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    //    }
}


- (void)showSheetAlert {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *selectFileAction = [UIAlertAction actionWithTitle:@"文件上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self selectVideoFile];     // 文件上传
    }];
    UIAlertAction *takeVideoAction = [UIAlertAction actionWithTitle:@"拍摄上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takeVideo];           // 拍摄上传
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:selectFileAction];
    [alertController addAction:takeVideoAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)selectVideoFile {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [imagePicker setMediaTypes:@[(__bridge NSString *)kUTTypeMovie]];           // 设置媒体类型为movie
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)takeVideo {
    
    _isVideoPicker = YES;
    [self presentViewController:self.videoPicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

// 此代理方法在拍摄完成和选取视频文件完成都会被调用，所以里面须有相应的逻辑判断作为区分，此处使用_isVideoPicker作为区分
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 获取视频的url,当选中某个文件时该文价会被读取到沙盒的temp路径下
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];      // video path
    
    if (_isVideoPicker) {       // 拍摄视频上传
        
        NSString *videoPath = [videoURL path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);    // save video to album
            _originalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil ] objectForKey:NSFileSize];
        }
    }else {                    // 选取视频文件
        
        NSString *originalFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoURL.lastPathComponent];        // 文件会被读取到沙盒的temp文件夹中
        _originalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:originalFilePath error:nil ] objectForKey:NSFileSize];
    }
    
    NSLog(@"original file size:%@",_originalFileSize);      // 原始文件大小
    self.statusLabel.text =     @"压缩中...";
    self.progressLabel.text =   @"progress:0%";
    self.uploadButton.enabled = NO;
    
    // 获取视频缩略图
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.imageView.image = [player thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    _filePath =[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    
    // 视频压缩
    [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:[NSURL fileURLWithPath:_filePath] handler:^(AVAssetExportSession *exportSession) {
       
        // 非主线程，如有UI更新等操作需在主线程代码中执行
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"压缩完成";
            });
            _newFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:_filePath error:nil] objectForKey:NSFileSize];
            NSLog(@"compressed file size:%@",_newFileSize);     //  压缩后的文件大小
        }else {
            printf("error\n");
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadButton.enabled = YES;
        });
    }];
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    //deselected file
//}


/** 压缩视频大小*/
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession *exportSession))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

// 保存到相册成功的回调方法，如不回调，设置UISaveVideoAtPathToSavedPhotosAlbum方法第二个和第三个参数为nil即可
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"save failure:%@",error.localizedDescription);
    }else {
        NSLog(@"video save success");
    }
}

#pragma mark - 用户交互事件

// upload点击事件
- (IBAction)uploadFileButton:(id)sender {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {                // 判断
        NSLog(@"no file can be found");
        return;
    }
    
    // 初始化上传
    [[PLVApi alloc] initUploadWithWritetoken:self.writetoken userid:self.userid cataid:self.cataid titlt:self.fileTitle tag:self.tag luping:self.luping filepath:_filePath fileSize:_newFileSize completionBlock:^(NSDictionary *responseDict, NSString *vid) {
        
        NSString *uploadToken = responseDict[@"uploadToken"];       // 获取uploadToken等信息，可打印responseDict查看
        //NSString *bucketName = responseDict[@"bucketName"];
        //NSString *fileKey = responseDict[@"fileKey"];
        NSLog(@"file vid:%@",vid);

        ++ _taskTag;
        
        // 初始化成功 调用PLVApi接口开始上传
        [PLVApi startUploadWithToken:uploadToken taskTag:_taskTag progressBlocak:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            self.statusLabel.text = @"uploading...";                                              // 上传中操作，多次调用
            float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
            self.progressView.progress = percent;
            self.progressLabel.text = [NSString stringWithFormat:@"progress:%.1f%%",percent > 1 ? 100.0 : percent*100]; // 解决可能出现超过百分百的问题
            
        } successBlock:^(NSDictionary *responseDict) {
            NSLog(@"slice upload success : %@", responseDict);                                  // 上传文件成功回调
            // 目前sdk中处理缓存部分是在文件上传成功后清空沙盒中Temp缓存的所有文件，包括视频源文件，压缩后的文件，上传成功和之前上传失败的文件。如有问题可联系我们做进一步的完善
            
            self.statusLabel.text = @"slice upload success";
            
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
        NSLog(@"init upload failed:%@",errorMsg);                                              // 初始化失败
    }];
}


// cancel按钮点击事件
- (IBAction)canceluploadFile:(id)sender {
    
    [PLVApi cancelUploadInTaskTag:_taskTag];        // 取消上传
}


#pragma mark - 重写方法

- (UIImagePickerController *)videoPicker {
    if (!_videoPicker) {
        _videoPicker = [[UIImagePickerController alloc] init];
        [_videoPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [_videoPicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
        [_videoPicker setVideoQuality:UIImagePickerControllerQualityTypeIFrame1280x720];
        [_videoPicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo]; // 摄像头模式
        
        _videoPicker.delegate = self;
        _videoPicker.editing = YES;     // 允许编辑
    }
    return _videoPicker;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
