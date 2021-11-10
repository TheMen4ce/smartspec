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


+ (UIImage *)displayCrop:(UIImage *)image height:(float)height width:(float)width;
+ (UIImage *)extractCrop:(UIImage *)image height:(float)height width:(float)width;
+ (NSMutableArray *)histogram:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
