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
    private init(){ }
    
    static let shared = ImageProcessor()

    private var subscribers = Dictionary<String, ImageProcessorSubscriber>()
    
    private(set) var image = UIImage()
    private(set) var croppedImage = UIImage()
    
    private var count = 0
    
    func process(image: UIImage) {
        self.image = image
        
        if count % 10 == 0 {
            croppedImage = OpenCVWrapper.extractCrop(image)
            let hist = OpenCVWrapper.histogram(croppedImage)
//            print(hist)
            count = 0
        }
        count += 1
        
        publish()
    }

    func subscribe(subscriber: ImageProcessorSubscriber) -> () -> Void {
        subscribers["\(subscriber)"] = subscriber
        subscriber.newImageAvailable()
        
        return {
            self.unsubscribe(subscriber: subscriber)
        }
    }

    func unsubscribe(subscriber: ImageProcessorSubscriber) {
        subscribers["\(subscriber)"] = nil
    }

    private func publish() {
        for (_, subscriber) in subscribers {
            subscriber.newImageAvailable()
        }
    }
}