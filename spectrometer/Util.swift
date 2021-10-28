//
//  Extension.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//

import Foundation

class Util {
    
    class func round(_ value: Float, toNearest: Float) -> Float {
        return Darwin.round(value / toNearest) * toNearest
    }
}
