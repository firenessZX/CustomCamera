//
//  BrowseViewController.m
//  CustomCameraDemo
//
//  Created by sucheng on 2018/9/17.
//  Copyright © 2018年 速成. All rights reserved.
//

#import "BrowseViewController.h"

@interface BrowseViewController ()

@end

@implementation BrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * _sourceArray.count, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    for (NSUInteger i = 0; i<_sourceArray.count; i++) {
        
        UIImageView * imageView = [[UIImageView alloc]initWithImage:[_sourceArray objectAtIndex:i]];
        imageView.frame = CGRectMake(i * scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height);
        [scrollView addSubview:imageView];
    }
    
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(20, self.view.frame.size.height - 60, 40, 40);
    NSString * imagePath = [[NSBundle mainBundle]pathForResource:@"Asset" ofType:@"bundle"];
    imagePath = [imagePath stringByAppendingString:@"/close"];
    [closeBtn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:closeBtn];

    
}

- (void)closeAction:(UIButton*)sender {
 
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
