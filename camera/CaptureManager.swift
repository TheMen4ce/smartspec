//
//  CaptureManager.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//


import UIKit
import AVFoundation

class CaptureManager: NSObject {
    internal static let shared = CaptureManager()
    
    var session = AVCaptureSession()
    var device: AVCaptureDevice?
    private var isExposing = false
    private var cameraAccessGranted = false
    
    private let colorSpace = CGColorSpace.init(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    
    private var desired_iso: Float = 600
    private var desired_time = 0.2
    private(set) var isIsoAtMin = false
    private(set) var isIsoAtMax = false
    private(set) var isTimeAtMin = false
    private(set) var isTimeAtMax = false

    // MARK: PUBLIC

    func stopSession() {
        if hasInputs() {
            session.stopRunning()
        }
    }

    func startSession(onRequestCompleted: @escaping () -> ()) {
        if hasInputs() {
            session.startRunning()
            onRequestCompleted()
        } else {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                camAccessGrantedAndInit(onRequestCompleted: onRequestCompleted)
            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.camAccessGrantedAndInit(onRequestCompleted: onRequestCompleted)
                    } else {
                        self.cameraAccessGranted = false
                        onRequestCompleted()
                    }
                })
            }
        }
    }

    private func camAccessGrantedAndInit(onRequestCompleted: () -> ()) {
        cameraAccessGranted = true
        initCameraSession()
        onRequestCompleted()
    }

    func hasCameraAccess() -> Bool {
        return cameraAccessGranted
    }

    func initCameraSession() {
        
        if session.isRunning == true {
            print("❌ Already running... please check why I'm called! ❌")
            return
        }
                
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        if device != nil {
            do {
                let input = try AVCaptureDeviceInput(device: device!)
                session.addInput(input)
                session.sessionPreset = AVCaptureSession.Preset.high
                
                try device!.lockForConfiguration()
                device!.automaticallyAdjustsVideoHDREnabled = false // no need for HDR
                
                // To stop auto WB (but i think we want it on auto)
                // let wbg = AVCaptureDevice.WhiteBalanceGains(redGain: 1, greenGain: 1, blueGain: 1) // WB will result in wrong colors
                // device!.setWhiteBalanceModeLocked(with: wbg, completionHandler: nil)
                
                // To restrict frame rate (but i think we want it on auto)
                // device?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20)
                // device?.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 20)
                
                // custom exposure (but I think we want it on auto)
                //                self.device!.setExposureModeCustom(duration: self.device!.activeFormat.maxExposureDuration, iso: self.device!.activeFormat.maxISO) { _ in
                //                    print("ℹ️ Init exposure set!")
                //                }
                
                if device!.isFocusModeSupported(.locked) {
                    device?.setFocusModeLocked(lensPosition: 0.8) { _ in // .7-.9 seems to be the best
                        print("ℹ️ Init focus locked!")
                    }
                }
            } catch {
                print("❌ Configuration Error! ❌")
                return
            }

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(output)
        } else {
            print("❌ No camera found? ❌")
        }

        if hasInputs() {
            session.startRunning()
        }
    }
    
    func increaseIso() {
        setDesiredIso(newIso: desired_iso + 50)
    }
    
    func decreaseIso() {
        setDesiredIso(newIso: desired_iso - 50)
    }
    
    func increaseTime() {
        setDesiredTime(newTime: desired_time + 0.01)
    }
    
    func decreaseTime() {
        setDesiredTime(newTime: desired_time - 0.01)
    }
    
    // MARK: PRIVATE

    private func hasInputs() -> Bool {
        return session.inputs.count > 0
    }
    
    private func setDesiredIso(newIso: Float) {
        isIsoAtMin = false
        isIsoAtMax = false
        if newIso >= device!.activeFormat.maxISO {
            desired_iso = device!.activeFormat.maxISO
            isIsoAtMax = true
        } else if newIso <= device!.activeFormat.minISO {
            desired_iso = device!.activeFormat.minISO
            isIsoAtMin = true
        } else {
            desired_iso = newIso
        }
    }
    
    private func setDesiredTime(newTime: Double) {
        isTimeAtMin = false
        isTimeAtMax = false
        if newTime >= device!.activeFormat.maxExposureDuration.seconds {
            desired_time = device!.activeFormat.maxExposureDuration.seconds
            isTimeAtMax = true
        } else if newTime <= device!.activeFormat.minExposureDuration.seconds {
            desired_time = device!.activeFormat.minExposureDuration.seconds
            isTimeAtMin = true
        } else {
            desired_time = newTime
        }
    }

    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    
}

// MARK: EXTENSION

extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("exposing", isExposing)
//        print("iso round", Util.round(device!.iso, toNearest: 10))
//        print("time round", String(format: "%.2f", device!.exposureDuration.seconds))
        
//        if !isExposing && (Util.round(device!.iso, toNearest: 10) != desired_iso || String(format: "%.2f", device!.exposureDuration.seconds) != String(format: "%.2f", desired_time)) {
//            isExposing = true
//            device?.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: Int32(1/desired_time)), iso: desired_iso) {_ in
//                self.isExposing = false
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.isExposing = false
//            }
//            print("ℹ️ adjusting exposure!")
//            print("current iso: ", device!.iso, "time:", device!.exposureDuration.seconds)
//            print("desired iso: ", desired_iso, "time:", desired_time)
//            print("device POI: ", device!.focusPointOfInterest)
//        }
            
        
        if let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
            ImageProcessor.shared.process(image: outputImage)
        }
    }
}
