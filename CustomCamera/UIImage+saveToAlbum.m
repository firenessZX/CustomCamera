//
//  UIImage+saveToAlbum.m
//  ImageSaveToPhotosDemo
//
//  Created by 尚東 on 2017/5/1.
//  Copyright © 2017年 tear. All rights reserved.
//

#import "UIImage+saveToAlbum.h"
#import <Photos/Photos.h>

@interface UIImage()

/** 获取相册*/
- (PHAssetCollection*)getAPPAssetCollection;

/** 获取图片*/
- (PHFetchResult<PHAsset *> *)getAsset;

@end

@implementation UIImage (saveToAlbum)

- (void)savePhotoToAlbumWithStatusCodeBlock:(PhotoSaveStatusCodeBlock)codeBlock{

[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
   
    if (status==PHAuthorizationStatusAuthorized)
    {
        //获取刚才保存到【相机胶卷】的图片
        PHFetchResult<PHAsset *> *Asset=self.getAsset;
        
        if (Asset==nil){
            codeBlock(PhotoSaveToAlbumFail);
            return;
        }
        
        //assetColleciton为空，创建相册失败
        PHAssetCollection *assetCollection=self.getAPPAssetCollection;
        
        if (assetCollection==nil){
            
            codeBlock(PhotoAlbumCollectionCreatedFail);
            return;
        }
        
        NSError *error=nil;
        
        //添加刚才保存的图片到相册
        [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
            
            PHAssetCollectionChangeRequest *request =[PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            
            [request insertAssets:Asset atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
        } error:&error];//error不为空，保存图片失败
        
        if (error){
            codeBlock(PhotoSaveToAlbumCollectionFail);
            
        }
        else{
            codeBlock(PhotoSaveToAlbumCollectoinSuccess);
        }
        
    }
    else{
    
        codeBlock(PhotoAccessPhotoLibraryUnauthorized);
        
    }
    
}];
    
    
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#pragma mark --- 获取相片
- (PHFetchResult<PHAsset *> *)getAsset{
    
    NSError *error=nil;
    
    __block NSString *assetID=nil;
    
    //保存图片到相机胶卷
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        
        assetID =[PHAssetChangeRequest creationRequestForAssetFromImage:self].placeholderForCreatedAsset.localIdentifier;
        
    } error:&error];//error不为空，保存图片失败
    
    if (error)
    {
        return nil;
    }
    
    //获取相片
    PHFetchResult<PHAsset *> * asset=[PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
    
    return asset;
    
}

#pragma mark --- 获取APP对应的自定义相册
-(PHAssetCollection *)getAPPAssetCollection{
    
    //获取APP名字
    NSString *appName=[NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    //获取所有自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //查找当前APP对应的自定义相册
    for (PHAssetCollection *collection in collections){
        
        if ([collection.localizedTitle isEqualToString:appName]){
            
            return collection;
            
        }
        
    }
    
    /********当前APP对应的自定义相册没有被创建过,那么就创建相册*********/
    
    //获取创建的相册唯一标示
    
    NSError *error=nil;
    
    __block  NSString *assetID=nil;
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        
        NSString *AppName=[NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
        
        //创建一个自定义相册（相册名称就是APP的名字）
        
        //获取创建的相册唯一标示
        assetID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:AppName].placeholderForCreatedAssetCollection.localIdentifier;
        
    } error:&error];
    
    if (error){
        return nil;
    }
    
    //根据相册唯一标识符获得刚才创建的自定义相册
    return  [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetID] options:nil].firstObject;
    
}

#pragma clang diagnostic pop


+ (NSArray *)fetchImageFromPhotoAlbum{
    
    NSMutableArray * imageArray = [NSMutableArray array];
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection*> * assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    NSString *AppName = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    // 遍历所有的自定义相簿
    for (PHAssetCollection * assetCollection in assetCollections) {
        
        if ([assetCollection.localizedTitle isEqualToString: AppName] ) {
            
            PHFetchResult<PHAsset*> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            for (PHAsset * asset in assets) {
                
                CGSize   originSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
                
                PHImageRequestOptions *  option = [[PHImageRequestOptions alloc] init];
                
                option.synchronous= YES;
                
                [[PHImageManager defaultManager]requestImageForAsset:asset targetSize:originSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    [imageArray addObject:result];
                    
                }];
                
            }
        }
        
    }
    return imageArray;
    
}

@end
