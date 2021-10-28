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
    @IBOutlet weak var debugInfoLabel: UILabel!
    
    @IBOutlet weak var currentIsoLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var isoPlusButton: UIButton!
    @IBOutlet weak var isoMinusButton: UIButton!
    @IBOutlet weak var timePlusButton: UIButton!
    @IBOutlet weak var timeMinusButton: UIButton!
    
    // MARK: ACTIONS
    
    @IBAction func moreIsoButtonTapped(_ sender: Any) {
        CaptureManager.shared.increaseIso()
    }
    
    @IBAction func lessIsoButtonTapped(_ sender: Any) {
        CaptureManager.shared.decreaseIso()
    }
    
    @IBAction func moreTimeButtonTapped(_ sender: Any) {
        CaptureManager.shared.increaseTime()
    }
    
    @IBAction func lessTimeButtonTapped(_ sender: Any) {
        CaptureManager.shared.decreaseTime()
    }

    
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
    
    private func getInfoText() -> String {
        let dev = CaptureManager.shared.device!
        return "ISO " + String(format: "%.1f", dev.iso) + "\nTime " + String(format: "%.6f", dev.exposureDuration.seconds)
    }

}

// MARK: EXTENSIONS

extension ViewController: ImageProcessorSubscriber {
    
    func newImageAvailable() {
        cameraImage.image = ImageProcessor.shared.image
        currentIsoLabel.text = String(format: "%.0f", CaptureManager.shared.device!.iso)
        currentTimeLabel.text = String(format: "%.3f", CaptureManager.shared.device!.exposureDuration.seconds)
        
        isoPlusButton.isHidden = CaptureManager.shared.isIsoAtMax
        isoMinusButton.isHidden = CaptureManager.shared.isIsoAtMin
        timePlusButton.isHidden = CaptureManager.shared.isTimeAtMax
        timeMinusButton.isHidden = CaptureManager.shared.isTimeAtMin
    }
    
}
