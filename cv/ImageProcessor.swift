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
        cropWidth = UserDefaults.standard.float(forKey: "CropWidth")
        cropHeight = UserDefaults.standard.float(forKey: "CropHeight")
    }
    
    static let shared = ImageProcessor()

    private var subscribers = Dictionary<String, ImageProcessorSubscriber>()
    
    private(set) var image = UIImage()
    private(set) var croppedImage = UIImage()
    private(set) var hist: NSMutableArray = []
    
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
