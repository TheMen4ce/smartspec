//
//  CameraSettingsVC.swift
//  spectrometer
//
//  Created by Dennis Briner on 10.11.21.
//

import Foundation

class CameraSettingsViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    private var unsubscribeFromImageProcessor: () -> Void = { }

    // MARK: OUTLETS
    
    @IBOutlet weak var isoView: UIView!
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    @IBOutlet weak var currentIsoLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentFocusLabel: UILabel!
    @IBOutlet weak var isoPlusButton: UIButton!
    @IBOutlet weak var isoMinusButton: UIButton!
    @IBOutlet weak var timePlusButton: UIButton!
    @IBOutlet weak var timeMinusButton: UIButton!
    @IBOutlet weak var focusPlusButton: UIButton!
    @IBOutlet weak var focusMinusButton: UIButton!
    
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
    
    @IBAction func moreFocusTapped(_ sender: Any) {
        CaptureManager.shared.increaseFocus()
    }
    
    @IBAction func lessFocusTapped(_ sender: Any) {
        CaptureManager.shared.decreaseFocus()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: LIFECYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCameraSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        unsubscribeFromImageProcessor = ImageProcessor.shared.subscribe(subscriber: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromImageProcessor()
    }
    
    private func updateCameraSettings() {
        currentIsoLabel.text = String(format: "%.0f", CaptureManager.shared.device!.iso)
        currentTimeLabel.text = String(format: "%.3f", CaptureManager.shared.device!.exposureDuration.seconds)
        currentFocusLabel.text = String(format: "%.2f", CaptureManager.shared.device!.lensPosition)
        
        isoPlusButton.isHidden = CaptureManager.shared.isIsoAtMax
        isoMinusButton.isHidden = CaptureManager.shared.isIsoAtMin
        timePlusButton.isHidden = CaptureManager.shared.isTimeAtMax
        timeMinusButton.isHidden = CaptureManager.shared.isTimeAtMin
        focusPlusButton.isHidden = CaptureManager.shared.isFocusAtMax
        focusMinusButton.isHidden = CaptureManager.shared.isFocusAtMin
    }
}

extension CameraSettingsViewController: ImageProcessorSubscriber {
    
    func newImageAvailable() {
        updateCameraSettings()
    }
}
