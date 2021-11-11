//
//  ImageProcessor.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//

import Foundation
import UIKit

protocol ImageProcessorSubscriber {
    func newImageAvailable()
}

class ImageProcessor {
    private init() {
        let storedCropWidth = UserDefaults.standard.float(forKey: "CropWidth")
        let storedCropHeight = UserDefaults.standard.float(forKey: "CropHeight")
        cropWidth = storedCropWidth > 0.01 ? storedCropWidth : DEFAULT_CROP_WIDTH
        cropHeight = storedCropHeight > 0.1 ? storedCropHeight : DEFAULT_CROP_HEIGHT
    }
    
    static let shared = ImageProcessor()

    private var subscribers = Dictionary<String, ImageProcessorSubscriber>()
    
    private(set) var image = UIImage()
    private(set) var croppedImage = UIImage()
    private(set) var hist: NSMutableArray = []
    
    private let DEFAULT_CROP_WIDTH: Float = 0.05
    private let DEFAULT_CROP_HEIGHT: Float = 0.2
    
    private(set) var cropWidth: Float = 0
    private(set) var cropHeight: Float = 0
    
    private var count = 0 // defines sample rate
    
    func process(image: UIImage) {
        self.image = OpenCVWrapper.displayCrop(image, height: cropHeight, width: cropWidth)
        
        if count % 10 == 0 {
            croppedImage = OpenCVWrapper.extractCrop(image, height: cropHeight, width: cropWidth)
            hist = OpenCVWrapper.histogram(croppedImage)
            
            count = 0
        }
        count += 1
        
        publish()
    }

    func subscribe(subscriber: ImageProcessorSubscriber) -> () -> Void {
        subscribers["\(subscriber)"] = subscriber
        
        return {
            self.unsubscribe(subscriber: subscriber)
        }
    }

    func unsubscribe(subscriber: ImageProcessorSubscriber) {
        subscribers["\(subscriber)"] = nil
    }
    
    func setCropWidth(newWidth: Float) {
        cropWidth = newWidth
        UserDefaults.standard.set(cropWidth, forKey: "CropWidth")
    }
    
    func setCropHeight(newHeight: Float) {
        cropHeight = newHeight
        UserDefaults.standard.set(cropHeight, forKey: "CropHeight")
    }

    private func publish() {
        for (_, subscriber) in subscribers {
            subscriber.newImageAvailable()
        }
    }
}
