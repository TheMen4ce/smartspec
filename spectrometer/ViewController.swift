//
//  ViewController.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    private var unsubscribeFromImageProcessor: () -> Void = { }
    
    // MARK: OUTLETS
    
    @IBOutlet weak var noCameraAccessView: UIView!
    @IBOutlet weak var cameraImage: UIImageView!
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noCameraAccessView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CaptureManager.shared.startSession(onRequestCompleted: updateNoCameraAccessLabel)
        unsubscribeFromImageProcessor = ImageProcessor.shared.subscribe(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CaptureManager.shared.stopSession()
        unsubscribeFromImageProcessor()
    }
    
    // MARK: PRIVATE
    
    private func updateNoCameraAccessLabel() {
        DispatchQueue.main.async {
            self.noCameraAccessView.isHidden = CaptureManager.shared.hasCameraAccess()
        }
    }

}

// MARK: EXTENSIONS

extension ViewController: ImageProcessorSubscriber {
    
    func newImageAvailable() {
        cameraImage.image = ImageProcessor.shared.image
    }
    
}
