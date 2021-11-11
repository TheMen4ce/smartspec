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
    
    // MARK: PROPERTIES
    
    static let shared = ImageProcessor()

    private var subscribers = Dictionary<String, ImageProcessorSubscriber>()
    
    private var originalImage = UIImage()
    private(set) var image = UIImage()
    private(set) var croppedImage = UIImage()
    private(set) var hist: NSMutableArray = []
    
    private let DEFAULT_CROP_WIDTH: Float = 0.05
    private let DEFAULT_CROP_HEIGHT: Float = 0.2
    private let DEFAULT_LOWER_NM: Float = 437 // mercury
    private let DEFAULT_UPPER_NM: Float = 612 // europium
    private let DEFAULT_LOWER_NM_POSITION: Float = 0.2
    private let DEFAULT_UPPER_NM_POSITION: Float = 0.8
    
    private(set) var cropWidth: Float = 0
    private(set) var cropHeight: Float = 0
    
    var isCalibrating = false
    var freeze = false
    private(set) var lowerNm: Float = 0
    private(set) var upperNm: Float = 0
    private(set) var lowerNmPosition: Float = 0
    private(set) var upperNmPosition: Float = 0
    
    private var count = 0
    
    // MARK: PUBLIC
    
    func process(newImage: UIImage) {
        if !freeze {
            originalImage = newImage
        }
        
        image = OpenCVWrapper.displayCrop(originalImage, height: cropHeight, width: cropWidth)
        
        // Sample rate. Spare CPU by only analyzing every 10th frame
        if count % 10 == 0 {
            croppedImage = OpenCVWrapper.extractCrop(originalImage, height: cropHeight, width: cropWidth)
            hist = OpenCVWrapper.histogram(croppedImage)
            
            if isCalibrating && (lowerNmPosition > 0 || upperNmPosition > 0) {
                croppedImage = OpenCVWrapper.displayCalibration(croppedImage, lowerNmPosition: lowerNmPosition, upperNmPosition: upperNmPosition)
            }
            
            croppedImage = OpenCVWrapper.redBorder(croppedImage)
            
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
    
    func setLowerNm(newLowerNm: Float) {
        lowerNm = newLowerNm
        UserDefaults.standard.set(lowerNm, forKey: "LowerNm")
    }
    
    func setUpperNm(newUpperNm: Float) {
        upperNm = newUpperNm
        UserDefaults.standard.set(upperNm, forKey: "UpperNm")
    }
    
    func setLowerNmPosition(newLowerNmPosition: Float) {
        lowerNmPosition = newLowerNmPosition
        UserDefaults.standard.set(lowerNmPosition, forKey: "LowerNmPosition")
    }
    
    func setUpperNmPosition(newUpperNmPosition: Float) {
        upperNmPosition = newUpperNmPosition
        UserDefaults.standard.set(upperNmPosition, forKey: "UpperNmPosition")
    }
    
    // MARK: PRIVATE
    
    private init() {
        let storedCropWidth = UserDefaults.standard.float(forKey: "CropWidth")
        let storedCropHeight = UserDefaults.standard.float(forKey: "CropHeight")
        cropWidth = storedCropWidth > 0.01 ? storedCropWidth : DEFAULT_CROP_WIDTH
        cropHeight = storedCropHeight > 0.1 ? storedCropHeight : DEFAULT_CROP_HEIGHT
        
        let storedLowerNm = UserDefaults.standard.float(forKey: "LowerNm")
        lowerNm = storedLowerNm > 0 ? storedLowerNm : DEFAULT_LOWER_NM
        let storedUpperNm = UserDefaults.standard.float(forKey: "UpperNm")
        upperNm = storedUpperNm > 0 ? storedUpperNm : DEFAULT_UPPER_NM
        
        let storedLowerNmPosition = UserDefaults.standard.float(forKey: "LowerNmPosition")
        lowerNmPosition = storedLowerNmPosition > 0 ? storedLowerNmPosition : DEFAULT_LOWER_NM_POSITION
        let storedUpperNmPosition = UserDefaults.standard.float(forKey: "UpperNmPosition")
        upperNmPosition = storedUpperNmPosition > 0 ? storedUpperNmPosition : DEFAULT_UPPER_NM_POSITION
    }

    private func publish() {
        for (_, subscriber) in subscribers {
            subscriber.newImageAvailable()
        }
    }
}
