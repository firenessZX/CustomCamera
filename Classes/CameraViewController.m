//
//  CameraViewController.m
//  CustomCameraDemo
//
//  Created by sucheng on 2018/8/15.
//  Copyright © 2018年 速成. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+saveToAlbum.h"
#import <Photos/Photos.h>
#import "BrowseViewController.h"
#import "UIImage+TintColor.h"
@interface CameraViewController ()<AVCapturePhotoCaptureDelegate>

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic) AVCaptureDevice * captureDevice;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic) AVCaptureDeviceInput * inputDevice;

//照片输出
@property (nonatomic) AVCapturePhotoOutput *photoOutput;

/*session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）*/
@property (nonatomic,strong) AVCaptureSession *captureSession;

//图像预览层，实时显示捕获的图像
@property(nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

// ------------- UI --------------
//拍照按钮
@property (nonatomic) UIButton *takePhotoButton;
//闪光灯按钮
@property (nonatomic) UIButton *flashButton;
//聚焦
@property (nonatomic) CALayer *focusBox;

/***/
@property (nonatomic,strong) CALayer *exposeBox;

//是否开启闪光灯
@property (nonatomic) BOOL isflashOn;

//切换前置后置摄像头按钮
@property (nonatomic) UIButton *switchCameraButton;

/**关闭按钮*/
@property (nonatomic,strong) UIButton *closeButton;

/**照库按钮*/
@property (nonatomic,strong) UIButton *photoLibraryButton;

/**照片数组*/
@property (nonatomic,strong) NSArray *photoArray;

/** 闪光灯模式*/
@property (nonatomic,assign) AVCaptureFlashMode  flashMode;

/**摄像头n模式*/
@property (nonatomic,assign) AVCaptureDevicePosition position;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configCamera];
    //添加一些按钮
    [self.view addSubview:self.flashButton];
    [self.view addSubview:self.switchCameraButton];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.takePhotoButton];
    [self.view addSubview:self.photoLibraryButton];
    //添加聚焦
    [self.view.layer addSublayer:self.focusBox];
    
    [self.view.layer addSublayer:self.exposeBox];
    
    
    self.photoArray = [UIImage fetchImageFromPhotoAlbum];
    
    [self.photoLibraryButton setImage:self.photoArray.firstObject forState:UIControlStateNormal];
    
}

#pragma mark ——————— 配置相机的一些属性 ———————
- (void)configCamera{
    
    self.position = AVCaptureDevicePositionBack;
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
     //使用设备初始化输入
    self.inputDevice = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:nil];
    
    self.photoOutput = [[AVCapturePhotoOutput alloc]init];
    
    //生成会话，用来结合输入输出
    self.captureSession = [[AVCaptureSession alloc]init];
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    if ([self.captureSession canAddInput:self.inputDevice]) {
        [self.captureSession addInput:self.inputDevice];
    }
    
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    
      //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)]];
    
        //开始启动
        [self.captureSession startRunning];
    
    //修改设备的属性，先加锁
    if ([self.captureDevice lockForConfiguration:nil]) {
        //闪光灯自动
        if (self.captureDevice.hasFlash) {
            if (@available(iOS 10.0, *)) {
          
            } else {
                // Fallback on earlier versions
            }
        }
        
        //自动白平衡
        if ([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        //解锁
        [self.captureDevice unlockForConfiguration];
    }

}

#pragma mark <Lazy Loads Methods>

-(UIButton *)flashButton{
    
    if (!_flashButton) {
        
            _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _flashButton.frame = CGRectMake(20, 20, 40, 40);
            _flashButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [_flashButton setImage:[[UIImage imageNamed:@"flash"] tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [_flashButton setImage:[[UIImage imageNamed:@"flash"] tintImageWithColor:[UIColor cyanColor]]forState:UIControlStateSelected];
            [_flashButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _flashButton;
}

-(UIButton *)switchCameraButton{
    
    if (!_switchCameraButton) {
        
       _switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
       _switchCameraButton.frame = CGRectMake(self.view.frame.size.width - 60 , 20, 40, 40);
        [_switchCameraButton setImage:[[UIImage imageNamed:@"flip"]tintImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_switchCameraButton setImage:[[UIImage imageNamed:@"flip"]tintImageWithColor:[UIColor cyanColor]] forState:UIControlStateSelected];
        [_switchCameraButton addTarget:self action:@selector(switchCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

-(UIButton *)closeButton{
    
    if (!_closeButton) {
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(20, self.view.frame.size.height - 60, 40, 40);
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(UIButton *)takePhotoButton{
    
    if (!_takePhotoButton) {
        
        _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _takePhotoButton.frame = CGRectMake(self.view.frame.size.width/2 - 40, self.view.frame.size.height - 80, 80, 80);
        [_takePhotoButton setImage:[UIImage imageNamed:@"trigger"] forState:UIControlStateNormal];
        [_takePhotoButton addTarget:self action:@selector(takePictureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoButton;
}

-(UIButton *)photoLibraryButton{
    
    if (!_photoLibraryButton) {
        
        _photoLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoLibraryButton.frame = CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 70, 60, 60);
        _photoLibraryButton.layer.borderColor = [UIColor blackColor].CGColor;
        _photoLibraryButton.layer.borderWidth = 1;
        [_photoLibraryButton addTarget:self action:@selector(photoLibraryButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _photoLibraryButton;
}


- (CALayer *) focusBox
{
    if ( !_focusBox ) {
        _focusBox = [[CALayer alloc] init];
        [_focusBox setCornerRadius:40.0f];
        [_focusBox setBounds:CGRectMake(0.0f, 0.0f, 80, 80)];
        [_focusBox setBorderWidth:5.f];
        [_focusBox setBorderColor:[UIColor blackColor].CGColor];
        [_focusBox setOpacity:0];
    }
    
    return _focusBox;
}

- (CALayer *) exposeBox
{
    if ( !_exposeBox ) {
        _exposeBox = [[CALayer alloc] init];
        [_exposeBox setCornerRadius:50.0f];
        [_exposeBox setBounds:CGRectMake(0.0f, 0.0f, 100, 100)];
        [_exposeBox setBorderWidth:5.f];
        [_exposeBox setBorderColor:[UIColor cyanColor].CGColor];
        [_exposeBox setOpacity:0];
    }
    
    return _exposeBox;
}

#pragma mark ——————— 执行动画改变焦点位置 ———————
- (void) draw:(CALayer *)layer atPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    if ( remove ){
        [layer removeAllAnimations];
    }
    
    if ( [layer animationForKey:@"transform.scale"] == nil && [layer animationForKey:@"opacity"] == nil ) {
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        [layer setPosition:point];
        [CATransaction commit];
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [scale setFromValue:[NSNumber numberWithFloat:1]];
        [scale setToValue:[NSNumber numberWithFloat:0.7]];
        [scale setDuration:0.8];
        [scale setRemovedOnCompletion:YES];
        
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [opacity setFromValue:[NSNumber numberWithFloat:1]];
        [opacity setToValue:[NSNumber numberWithFloat:0]];
        [opacity setDuration:0.8];
        [opacity setRemovedOnCompletion:YES];
        
        [layer addAnimation:scale forKey:@"transform.scale"];
        [layer addAnimation:opacity forKey:@"opacity"];
    }
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    
    CGPoint point = [gesture locationInView:gesture.view];
    
    [self draw:self.focusBox atPointOfInterest:point andRemove:YES];
    
    [self draw:self.exposeBox atPointOfInterest:point andRemove:YES];
    
}

- (void)focusAtPoint:(CGPoint)point{
    
        CGSize size = self.view.bounds.size;
    
       // focusPoint 函数后面Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间,按这个来但位置就是不对，只能按上面的写法才可以。前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
        CGPoint focusPoint = CGPointMake( point.y /size.height ,1 - point.x/size.width);
    
    if ([self.captureDevice lockForConfiguration:nil]) {
        
        if ([self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            [self.captureDevice setFocusPointOfInterest:focusPoint];
            [self.captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        [self.captureDevice unlockForConfiguration];
    }
    
    
}

- (void)takePictureAction:(UIButton*)sender{
    
    AVCaptureConnection * videoConnection = [self.photoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (videoConnection == nil) {
        return;
        
    }
    
    //图像设置,AVCapturePhotoSettings每拍一张照就需要重新初始化一次，不能重复使用
    AVCapturePhotoSettings * photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecJPEG}];
    
    photoSettings.flashMode = self.flashMode;
    
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
    
}

#pragma mark ——————— 闪光灯 ———————
- (void)flashButtonAction:(UIButton*)sender{
    
    sender.selected = !sender.selected;
    
    if ([self.captureDevice hasFlash]) {
        
        [self.captureDevice lockForConfiguration:nil];
        
        if (self.isflashOn) {

            self.flashMode = AVCaptureFlashModeOff;
                self.isflashOn = NO;
        }else{

                self.flashMode = AVCaptureFlashModeOn;
                self.isflashOn = YES;
      
        }
        
        [self.captureDevice unlockForConfiguration];
    }
    
}

#pragma mark ——————— 切换摄像头 ———————
- (void)switchCameraButtonAction:(UIButton*)sender{
    
    sender.selected = !sender.selected;
    
    if (self.position == AVCaptureDevicePositionBack) {
        self.position = AVCaptureDevicePositionFront;
    }else{
        self.position = AVCaptureDevicePositionBack;
    }
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:self.position];
    
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    
    [self.captureSession beginConfiguration];
    
    [self.captureSession removeInput:self.inputDevice];
    
    if ([self.captureSession canAddInput:input]) {
        [self.captureSession addInput:input];
        self.inputDevice = input;
    }
    
    [self.captureSession commitConfiguration];
    
    //为摄像头的转换加转场动画
    CATransition *animation = [CATransition animation];
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    
    if (self.position == AVCaptureDevicePositionFront) {
        //获取后置摄像头
        animation.subtype = kCATransitionFromLeft;
    }else{
        //获取前置摄像头
        animation.subtype = kCATransitionFromRight;
    }
    
    [self.previewLayer addAnimation:animation forKey:nil];
    
}

-(void)closeButtonAction:(UIButton*)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)photoLibraryButtonAction:(UIButton*)sender{
    
    BrowseViewController * browseVC = [[BrowseViewController alloc]init];
    browseVC.sourceArray = self.photoArray;
    [self presentViewController:browseVC animated:YES completion:nil];
    
}

#pragma mark ——————— 拍摄到照片的代理回调方法 ———————
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error{
    
    NSData * data = [photo fileDataRepresentation];
    
    UIImage * image = [UIImage imageWithData:data];
    
    [image savePhotoToAlbumWithStatusCodeBlock:^(PhotoSaveStatusCode saveCode) {
        
        if(saveCode == PhotoSaveToAlbumCollectoinSuccess){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.photoArray = [UIImage fetchImageFromPhotoAlbum];
                //回到主线程刷新UI
                [self.photoLibraryButton setImage:self.photoArray.firstObject forState:UIControlStateNormal];
                
            });
        }
    }];
    
}


@end
