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
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    private var cameraAccessGranted = false
    
    private let colorSpace = CGColorSpace.init(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)

    override init() {
        super.init()
        session = AVCaptureSession()
    }

    func stopSession() {
        if hasInputs() {
            session?.stopRunning()
        }
    }

    func startSession(onRequestCompleted: @escaping () -> ()) {
        if hasInputs() {
            session?.startRunning()
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
        
        if session?.isRunning == true {
            print("❌ Already running... please check why I'm called! ❌")
            return
        }
                
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        if device != nil {
            do {
                let input = try AVCaptureDeviceInput(device: device!)
                session?.addInput(input)
                session?.sessionPreset = AVCaptureSession.Preset.hd1920x1080
                
                try device?.lockForConfiguration()
                device?.automaticallyAdjustsVideoHDREnabled = false // no need for HDR
                let wbg = AVCaptureDevice.WhiteBalanceGains(redGain: 2, greenGain: 1, blueGain: 2) // WB will result in wrong colors
                device?.setWhiteBalanceModeLocked(with: wbg, completionHandler: nil)
            } catch {
                print("❌ Configuration Error! ❌")
                return
            }

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session?.addOutput(output)
        } else {
            print("❌ No camera found? ❌")
        }

        if hasInputs() {
            session?.startRunning()
        }
    }

    func hasInputs() -> Bool {
        return session?.inputs.count ?? 0 > 0
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

extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let outputImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
            ImageProcessor.shared.process(image: outputImage)
        }
    }
}
