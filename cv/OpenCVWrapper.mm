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

+ (UIImage *)extractCrop:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    float heightMargin = 0.82;
    float widthMargin = 0.94;

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
        NSNumber *num = [NSNumber numberWithDouble:col_sum.at<uchar>(1,i)];
        [array addObject:num];
    }
    
//    cout << "ARRAY" << endl << array << endl;
//    cout << "MAT" << endl << col_sum << endl;
    
    
    return array;
}

@end
