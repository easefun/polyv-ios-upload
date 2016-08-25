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

#define WRITETOKEN  @""             // 填写你的writetoken
#define USERID      @""             // 你的userid


@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSString    *_filePath;             // 待上传文件的路径
    NSUInteger  _taskTag;               // 上传任务的标记
}

@property (nonatomic, copy) NSString *writetoken;       // 用户的writeToken
@property (nonatomic, copy) NSString *userid;           // 用户id
@property (nonatomic, copy) NSString *cataid;           // 分类id
@property (nonatomic, copy) NSString *fileTitle;        // 视频标题
@property (nonatomic, copy) NSString *tag;              // 标签，逗号分隔
@property (nonatomic, copy) NSString *luping;           // 视频课件优化处理：0/1

@property (strong, nonatomic) UIImagePickerController   *videoPicker;
@property (assign, nonatomic) BOOL                      isVideoPicker;  // 是否录像

@property (weak, nonatomic) IBOutlet UILabel            *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView        *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView     *progressView;
@property (weak, nonatomic) IBOutlet UILabel            *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton           *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton           *cancelbutton;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];            // 配置UI
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
    self.writetoken = WRITETOKEN;
    self.userid = USERID;
    self.cataid = @"1";
    self.fileTitle = @"中文--标题+*1";
    self.tag = @"keyword1, 标签2";
    self.luping = @"0";
    @try {
        if (!self.writetoken.length||!self.userid.length)
            @throw [NSException exceptionWithName:@"configuration error" reason:@"writetoken和userid不能为空" userInfo:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

#pragma mark - 点击事件

- (IBAction)uploadFileButton:(id)sender {
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        NSLog(@"file not found");
        return;
    }
    // 获取上传token
    [PLVApi getUploadInfoWithWritetoken:_writetoken userid:_userid cataid:_cataid titlt:_fileTitle tag:_tag luping:_luping filepath:_filePath completionBlock:^(NSString *uploadToken, NSString *vid, NSDictionary *fileInfo) {
        NSLog(@"vid:%@",vid);
        ++ _taskTag;
        
        // 上传文件
        [PLVApi startUploadWithFile:_filePath uploadToken:uploadToken taskTag:_taskTag progressBlocak:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            self.statusLabel.text = @"uploading...";                                              // 上传中操作，多次调用
            float percent = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
            self.progressView.progress = percent;
            self.progressLabel.text = [NSString stringWithFormat:@"progress:%.1f%%",percent > 1 ? 100.0 : percent*100]; // 结果可能超过百分百
            
        } successBlock:^(NSDictionary *responseDict) {
            NSLog(@"slice upload success : %@", responseDict);                                  // 上传文件成功回调
            self.statusLabel.text = @"slice upload success";
            
            [self clearlocalVideoUploadCaches];         // 清空视频缓存
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

// cancel按钮点击事件
- (IBAction)canceluploadFile:(id)sender {
    [PLVApi cancelUploadingOperationInTag:_taskTag];    // 取消上传
}

#pragma mark -

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
    [imagePicker setMediaTypes:@[(__bridge NSString *)kUTTypeMovie]];   // 设置媒体类型为movie
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)takeVideo {
    _isVideoPicker = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:self.videoPicker animated:YES completion:nil];
    }else {
        NSLog(@"无可用摄像头设备");
    }
}


#pragma mark - UIImagePickerControllerDelegate

// 此代理方法在拍摄完成和选取视频文件完成都会被调用，所以里面须有相应的逻辑判断作为区分，此处使用_isVideoPicker标记
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 获取视频的url,当选中某个文件时该文件会被读取到沙盒的temp路径下
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];      // video path
    
    NSString *originalFileSize = [NSString new];
    
    if (_isVideoPicker) {       // 拍摄视频上传
        NSString *videoPath = [videoURL path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);    // save video to album
            originalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil ] objectForKey:NSFileSize];
        }
    }else {      // 选取视频文件
        NSString *originalFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoURL.lastPathComponent];  // 文件会被读取到沙盒的temp文件夹中
        originalFileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:originalFilePath error:nil ] objectForKey:NSFileSize];
    }
    NSLog(@"original file size:%@",originalFileSize);      // 原始文件大小
    
    self.statusLabel.text =     @"压缩中...";
    self.progressLabel.text =   @"progress:0%";
    self.uploadButton.enabled = NO;
    
    // 获取视频缩略图
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.imageView.image = [player thumbnailImageAtTime:0.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    _filePath =[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    
    // 视频压缩
    [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:[NSURL fileURLWithPath:_filePath] handler:^(AVAssetExportSession *exportSession) {
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{         // 子线程，UI更新等操作需在主线程代码中执行
                self.statusLabel.text = @"压缩完成";
            });
        }else {
            printf("error\n");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.uploadButton.enabled = YES;
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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


// empty video cache
- (void)clearlocalVideoUploadCaches {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileArr = [fileManager subpathsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for (NSString *fileName in fileArr) {
        [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName] error:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
