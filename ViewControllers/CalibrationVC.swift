//
//  CalibrationVC.swift
//  spectrometer
//
//  Created by Dennis Briner on 11.11.21.
//

import Foundation

class CalibrationViewController: UIViewController {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var lowerNmPositionSlider: UISlider!
    @IBOutlet weak var upperNmPositionSlider: UISlider!
    @IBOutlet weak var lowerNmTextField: UITextField!
    @IBOutlet weak var upperNmTextField: UITextField!
    
    // MARK: ACTIONS
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func lowerNmPositionChanged(_ sender: UISlider) {
        print("ℹ️ lower nm position:", sender.value)
        ImageProcessor.shared.setLowerNmPosition(newLowerNmPosition: sender.value)
    }
    
    @IBAction func upperNmPositionChanged(_ sender: UISlider) {
        ImageProcessor.shared.setUpperNmPosition(newUpperNmPosition: sender.value)
    }
    
    @IBAction func lowerNmChanged(_ sender: UITextField) {
        if let lowerNm = Float(sender.text!) {
            ImageProcessor.shared.setLowerNm(newLowerNm:  lowerNm)
        }
    }
    
    @IBAction func upperNmChanged(_ sender: UITextField) {
        if let upperNm = Float(sender.text!) {
            ImageProcessor.shared.setUpperNm(newUpperNm: upperNm)
        }
    }
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
              
        let tapAnywhere = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapAnywhere)
        
        lowerNmTextField.text = String(format: "%.0f", ImageProcessor.shared.lowerNm)
        upperNmTextField.text = String(format: "%.0f", ImageProcessor.shared.upperNm)
        lowerNmPositionSlider.value = ImageProcessor.shared.lowerNmPosition
        upperNmPositionSlider.value = ImageProcessor.shared.upperNmPosition
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ImageProcessor.shared.isCalibrating = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ImageProcessor.shared.isCalibrating = false
    }
    
    // MARK: PRIVATE

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
