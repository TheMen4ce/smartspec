//
//  Extensions.swift
//  spectrometer
//
//  Created by Dennis Briner on 11.11.21.
//

import CoreMedia

extension UserDefaults {
    func cmtime(forKey key: String) -> CMTime? {
        if let timescale = object(forKey: key + ".timescale") as? NSNumber {
            let seconds = double(forKey: key + ".seconds")
            return CMTime(seconds: seconds, preferredTimescale: timescale.int32Value)
        } else {
            return nil
        }
    }

    func set(_ cmtime: CMTime, forKey key: String) {
        let seconds = cmtime.seconds
        let timescale = cmtime.timescale

        set(seconds, forKey: key + ".seconds")
        set(NSNumber(value: timescale), forKey: key + ".timescale")
    }
}
