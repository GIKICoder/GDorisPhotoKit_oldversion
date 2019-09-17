//
//  GDorisTiledImageBuilder.h
//  GDorisPhotoKitExample
//
//  Created by GIKI on 2019/9/7.
//  Copyright © 2019 GIKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PhotoScrollerCommon.h"
NS_ASSUME_NONNULL_BEGIN

@interface GDorisTiledImageBuilder : NSObject
///  CGImageSourceCopyPropertiesAtIndex() -> image properties
@property (nonatomic, strong, readonly) NSDictionary *properties;
/// image orientation
@property (nonatomic, assign) NSInteger orientation;
///
@property (nonatomic, assign) NSUInteger zoomLevels;
/// decoding startTime
@property (nonatomic, assign) uint64_t startTime;
/// decoding finishTime
@property (nonatomic, assign) uint64_t finishTime;
/// elapsed time
@property (nonatomic, assign) uint32_t milliSeconds;
/// UBC threshold above which outstanding writes are flushed to the file system (dynamic default)
@property (nonatomic, assign) int32_t ubc_threshold;
@property (nonatomic, assign, readonly) BOOL failed;
// default is 0.5 - Image disk cache can use half of the available free memory pool
+ (void)setUbcThreshold:(float)val;

- (instancetype)initWithImage:(CGImageRef)image size:(CGSize)sz orientation:(NSInteger)orientation;
- (instancetype)initWithImagePath:(NSString *)path withDecode:(ImageDecoder)decoder size:(CGSize)sz orientation:(NSInteger)orientation;
- (instancetype)initForNetworkDownloadWithDecoder:(ImageDecoder)dec size:(CGSize)sz orientation:(NSInteger)orientation;

- (void)writeToImageFile:(NSData *)data;
- (void)dataFinished;
- (CGSize)imageSize;
@end

@interface GDorisTiledImageBuilder (CGImage)
- (CGImageRef)newImageForScale:(CGFloat)scale location:(CGPoint)pt box:(CGRect)box;
// used when doing drawRect, but now for getImageColor
- (UIImage *)tileForScale:(CGFloat)scale location:(CGPoint)pt;
- (CGAffineTransform)transformForRect:(CGRect)box; 
- (CGPoint)translateTileForScale:(CGFloat)scale location:(CGPoint)origPt;
@end

@interface GDorisTiledImageBuilder (TurboJpeg)
- (BOOL)jpegAdvance:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
