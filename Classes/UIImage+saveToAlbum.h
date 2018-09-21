//
//  UIImage+saveToAlbum.h
//  ImageSaveToPhotosDemo
//
//  Created by 尚東 on 2017/5/1.
//  Copyright © 2017年 tear. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PhotoSaveStatusCode){
    ////保存图片到相机胶卷状态码
    
    /** 保存图片到胶卷失败*/
    PhotoSaveToAlbumFail=100,          //保存图片到胶卷失败
    /** 保存图片到胶卷成功*/
     PhotoSaveToAlbumSuccess=101,       //保存图片到胶卷成功
    
    ////创建相册状态码
    
    /** 创建相册失败*/
     PhotoAlbumCollectionCreatedFail=200,//创建相册失败
    /** 创建相册成功*/
     PhotoAlbumCollectionCreatedSuccess=201, //创建相册成功
    
    
    ////保存图片到相册状态码
    
    /** 保存图片到相册失败*/
    PhotoSaveToAlbumCollectionFail=300,          //保存图片到相册失败
    /** 保存图片到相册成功*/
   PhotoSaveToAlbumCollectoinSuccess=302,    //保存图片到相册成功
    /** 相册访问权限未授权*/
   PhotoAccessPhotoLibraryUnauthorized=400
    
};

typedef void(^PhotoSaveStatusCodeBlock)(PhotoSaveStatusCode saveCode);

@interface UIImage (saveToAlbum)


/**
 保存照片到相簿

 @param codeBlock 状态码
 */
- (void)savePhotoToAlbumWithStatusCodeBlock:(PhotoSaveStatusCodeBlock)codeBlock;


/**
 根据APP名称从相簿获取照片

 @param AppName App名称
 @return 图片数组
 */
+ (NSArray*)fetchImageFromPhotoAlbum;


@end
