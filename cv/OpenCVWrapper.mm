//
//  bridging-header.h
//  spectrometer
//
//  Created by Dennis Briner on 03.11.21.
//


#ifdef __cplusplus

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>

#endif

using namespace std;
using namespace cv;

@implementation OpenCVWrapper

+ (UIImage *)displayCrop:(UIImage *)image height:(float)height width:(float)width {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    float heightMargin = 1 - height;
    float widthMargin = 1 - width;

    cv::Rect rect(image.size.height * heightMargin / 2, image.size.width * widthMargin / 2, image.size.height - image.size.height * heightMargin, image.size.width - image.size.width * widthMargin);
    
    cv::Point tr = cv::Point(rect.x + rect.width, rect.y);
    cv::Point bl = cv::Point(rect.x, rect.y + rect.height);
    
    cv::line(mat, rect.tl(), tr, Scalar(255,0,0,255), 5, LINE_AA);
    cv::line(mat, tr, rect.br(), Scalar(255,0,0,255), 5, LINE_AA);
    cv::line(mat, rect.br(), bl, Scalar(255,0,0,255), 5, LINE_AA);
    cv::line(mat, bl, rect.tl(), Scalar(255,0,0,255), 5, LINE_AA);
    
    UIImage *newImage = MatToUIImage(mat);
    
    return [UIImage imageWithCGImage:[newImage CGImage] scale:[image scale] orientation: image.imageOrientation];
}

+ (UIImage *)extractCrop:(UIImage *)image height:(float)height width:(float)width {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    float heightMargin = 1 - height;
    float widthMargin = 1 - width;

    cv::Rect croppedRect(image.size.height * heightMargin / 2, image.size.width * widthMargin / 2, image.size.height - image.size.height * heightMargin, image.size.width - image.size.width * widthMargin);
    
    return MatToUIImage(mat(croppedRect));
}

+ (NSMutableArray *)histogram:(UIImage *)image {
    Mat mat, col_sum;
    UIImageToMat(image, mat);
    cvtColor(mat, mat, COLOR_RGB2GRAY);
    
    reduce(mat, col_sum, 0, REDUCE_AVG, CV_32F);

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i = 0; i < col_sum.cols - 1; i++) {
        NSNumber *num = [NSNumber numberWithFloat:(float)col_sum.at<float>(0,i)];
        [array addObject:num];
    }
    
    return array;
}

@end
