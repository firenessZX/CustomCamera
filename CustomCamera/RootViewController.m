//
//  RootViewController.m
//  CustomCameraDemo
//
//  Created by sucheng on 2018/8/15.
//  Copyright © 2018年 速成. All rights reserved.
//

#import "RootViewController.h"
#import "CCameraViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    takePhotoBtn.frame = CGRectMake(40, 350, self.view.frame.size.width - 80, 40);
    
    [takePhotoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    
    [takePhotoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    takePhotoBtn.layer.borderColor = [UIColor blueColor].CGColor;
    
    takePhotoBtn.layer.borderWidth = 2;
    
    [takePhotoBtn addTarget:self action:@selector(takePhotoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:takePhotoBtn];
    
}

- (void)takePhotoBtnClick:(UIButton*)sender {

    CCameraViewController * cameraVC = [[CCameraViewController alloc]init];
    [self presentViewController:cameraVC animated:YES completion:nil];
    
}



@end
