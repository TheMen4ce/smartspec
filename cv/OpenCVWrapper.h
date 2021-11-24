//
//  bridging-header.h
//  spectrometer
//
//  Created by Dennis Briner on 03.11.21.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject


+ (UIImage *)redBorder:(UIImage *)image;
+ (UIImage *)displayCrop:(UIImage *)image x_offset:(float)x_offset y_offset:(float)y_offset width:(float)width height:(float)height;
+ (UIImage *)extractCrop:(UIImage *)image x_offset:(float)x_offset y_offset:(float)y_offset width:(float)width height:(float)height;
+ (UIImage *)displayCalibration:(UIImage *)image lowerNmPosition:(float)lowerNmPosition upperNmPosition:(float)upperNmPosition;
+ (NSMutableArray *)histogram:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
