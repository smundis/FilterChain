//
//  CachedThumbnails.m
//  FilterChain
//
//  Created by Ryan Cumley on 9/20/13.
//  Copyright (c) 2013 Ryan Cumley. All rights reserved.
//

#import "CachedThumbnails.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface CachedThumbnails ()

- (BOOL)thumbnailAlreadyExistsForPath:(NSString*)targetPath;
- (UIImage*)generateNewThumbnailForURL:(NSURL*)targetUrl withPath:(NSString*)path;
- (NSString*)thumbnailPathFromVideoUrl:(NSURL*)videoUrl;
- (NSString*)thumbnailsPath;

@end

@implementation CachedThumbnails



#pragma mark Global Scoped Methods

- (UIImage*)thumbnailForURL:(NSURL*)targetUrl {
    
    NSString* thumbPath= [self thumbnailPathFromVideoUrl:targetUrl];
    UIImage* fetchedImage;
    NSURL* storedThumbUrl;
    
    if ([self thumbnailAlreadyExistsForPath:thumbPath]) {
        //fetch the stored image
        storedThumbUrl = [NSURL fileURLWithPath:thumbPath];
        NSData* fetchedJPG = [NSData dataWithContentsOfURL:storedThumbUrl]; 
        fetchedImage = [UIImage imageWithData:fetchedJPG];
        return fetchedImage;
    }
    else {
        //create this thumbnail from scratch, save it and return it
        UIImage* new = [self generateNewThumbnailForURL:targetUrl withPath:thumbPath];
        return new;
    }
    
    return nil; //failure condition. TODO consider a stock "image not loaded" file here
}

- (void)deleteThumbnailForURL:(NSURL*)targetUrl {
    NSString* thumbPath= [self thumbnailPathFromVideoUrl:targetUrl];
    fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:thumbPath error:&error];
    
}


#pragma mark Class Scoped Methods

- (BOOL)thumbnailAlreadyExistsForPath:(NSString *)targetPath {
    fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:targetPath isDirectory:NO];
    return exists;
}

- (UIImage*)generateNewThumbnailForURL:(NSURL*)targetUrl withPath:(NSString*)path{
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:targetUrl options:nil];
    AVAssetImageGenerator* generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError* err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage* thumb = [[UIImage alloc] initWithCGImage:oneRef];
    return thumb;
}

- (NSString*)thumbnailPathFromVideoUrl:(NSURL*)videoUrl {
    NSString* basePath = [self thumbnailsPath];
    NSString* incoming = [[[videoUrl lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@".jpg"];
    NSString* pathforURL = [[basePath stringByAppendingString:@"/" ] stringByAppendingString:incoming];
    return pathforURL;
}

- (NSString*)thumbnailsPath {
    if (!thumbnailsPath) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        thumbnailsPath = [documentsDirectory stringByAppendingPathComponent:@"/Thumbnails/"];
    }
    
    return thumbnailsPath;
}

@end
