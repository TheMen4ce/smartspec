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
    
    // MARK: PROPERTIES
    
    var device: AVCaptureDevice?
    private var session = AVCaptureSession()
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
    private(set) var isFocusAtMin = false
    private(set) var isFocusAtMax = false
    
    private var newExposureApplied = false
    private var exposureString = ""
    private var isoToApply: Float = 0
    private var timeToApply = CMTimeMake(value: 1, timescale: 1)
    private var isoBeforeApply: Float = 0
    private var timeBeforeApply = CMTimeMake(value: 1, timescale: 1)
    private var exposureToApply = ""
    
    // MARK: CAM SESSION HANDLING
    
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
                
                try device!.lockForConfiguration() // and never unlock
                device!.automaticallyAdjustsVideoHDREnabled = false // HDR may impact our measurements
                
                // To stop auto WB (but i think we want it on auto)
                // let wbg = AVCaptureDevice.WhiteBalanceGains(redGain: 1, greenGain: 1, blueGain: 1) // WB will result in wrong colors
                // device!.setWhiteBalanceModeLocked(with: wbg, completionHandler: nil)
                
                // To restrict frame rate (but i think we want it on auto)
                // device?.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20)
                // device?.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 20)
                
                setFocusAt(factor: 0.8)
                
                // Note: Time will be set to 1/30 regardless of what is set here. Weird, but true!
                let initialIso = 600 > device!.activeFormat.maxISO ? device!.activeFormat.maxISO : 600
                self.device!.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 20), iso: initialIso) { _ in
                    print("ℹ️ Init exposure set!")
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
    
    private func hasInputs() -> Bool {
        return session.inputs.count > 0
    }
    
    // MARK: FOCUS HANDLING
    
    func increaseFocus() {
        setFocusAt(factor: device!.lensPosition + 0.05)
    }
    
    func decreaseFocus() {
        setFocusAt(factor: device!.lensPosition - 0.05)
    }
    
    private func setFocusAt(factor: Float) {
        isFocusAtMin = false
        isFocusAtMax = false
        
        var lensPosition = Float(String(format: "%.2f", factor))!
        if lensPosition < 0 {
            lensPosition = 0
            isFocusAtMin = true
        }
        if lensPosition > 1 {
            lensPosition = 1
            isFocusAtMax = true
        }
        
        if device!.isFocusModeSupported(.locked) {
            device?.setFocusModeLocked(lensPosition: lensPosition) { _ in
                print("👁 Focus set to:", lensPosition)
            }
        } else {
            print("❌ Adjusting focus is not supported! ❌")
        }
    }
    
    // MARK: EXPOSURE HANDLING
    
    func increaseIso() {
        exposureToApply = "⬆️🎞"
        applyNewExposure(newIso: getNewIso(current: device!.iso, factor: 1.1), newTime: device!.exposureDuration)
    }
    
    func decreaseIso() {
        exposureToApply = "⬇️🎞"
        applyNewExposure(newIso: getNewIso(current: device!.iso, factor: 0.9), newTime: device!.exposureDuration)
    }
    
    func increaseTime() {
        exposureToApply = "⬆️⏱"
        applyNewExposure(newIso: device!.iso, newTime: getNewTime(current: device!.exposureDuration, factor: 1.1))
    }
    
    func decreaseTime() {
        exposureToApply = "⬇️⏱"
        applyNewExposure(newIso: device!.iso, newTime: getNewTime(current: device!.exposureDuration, factor: 0.9))
    }
    
    
    private func getNewIso(current: Float, factor: Float) -> Float {
        var newIso = current * factor
        if newIso < device!.activeFormat.minISO {
            newIso = device!.activeFormat.minISO
        } else if newIso > device!.activeFormat.maxISO {
            newIso = device!.activeFormat.maxISO
        }
        return newIso
    }
    
    private func getNewTime(current: CMTime, factor: Float) -> CMTime {
        let newValue = Int64(Float(current.value) * factor)
        var newTime = CMTimeMake(value: newValue, timescale: device!.exposureDuration.timescale)
        
        if newTime < device!.activeFormat.minExposureDuration {
            newTime = device!.activeFormat.minExposureDuration

        } else if newTime > device!.activeFormat.maxExposureDuration {
            newTime = device!.activeFormat.maxExposureDuration
        }
        return newTime
    }
    
    private func applyNewExposure(newIso: Float, newTime: CMTime) {
        print(exposureString)
        print("Apply new exposure | time:", String(format: "%.8f", newTime.seconds), "iso:", String(format: "%.6f", newIso))
        
        timeToApply = newTime
        isoToApply = newIso
        timeBeforeApply = device!.exposureDuration
        isoBeforeApply = device!.iso
        
        isTimeAtMax = newTime == device!.activeFormat.maxExposureDuration
        isTimeAtMin = newTime == device!.activeFormat.minExposureDuration
        
        isIsoAtMax = newIso == device!.activeFormat.maxISO
        isIsoAtMin = newIso == device!.activeFormat.minISO
        
        device!.setExposureModeCustom(duration: newTime, iso: newIso) {_ in
            self.newExposureApplied = true
        }
    }
    
    private func reapplyExposure() {
        print("🔄 reapplying exposure!", exposureToApply)
        switch exposureToApply {
        case "⬇️⏱":
            applyNewExposure(newIso: isoToApply, newTime: getNewTime(current: timeToApply, factor: 0.995))
        case "⬆️⏱":
            applyNewExposure(newIso: isoToApply, newTime: getNewTime(current: timeToApply, factor: 1.005))
        case "⬇️🎞":
            applyNewExposure(newIso: getNewIso(current: isoToApply, factor: 0.999), newTime: timeToApply)
        case "⬆️🎞":
            applyNewExposure(newIso: getNewIso(current: isoToApply, factor: 1.001), newTime: timeToApply)
        default:
            print("❌ No such exposure to apply exists ❌", exposureToApply)
        }
    }
    
    // MARK: IMAGE PROCESSING
    
    private func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("❌ Couldn't aquire sample buffer! ❌")
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            print("❌ Couldn't create context from base address! ❌")
            return nil
        }
        guard let cgImage = context.makeImage() else {
            print("❌ Couldn't make image from context! ❌")
            return nil
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
}

extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if newExposureApplied {
            newExposureApplied = false
            if device!.iso != isoBeforeApply || device!.exposureDuration != timeBeforeApply {
                print("✅ Exposure has actually changed!")
            } else {
                reapplyExposure()
            }
        }
        
        
        if let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
            ImageProcessor.shared.process(image: outputImage)
        }
    }
}
