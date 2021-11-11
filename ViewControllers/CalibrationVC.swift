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
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
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
        let lowerNm = Float(sender.text!) ?? 0
        if lowerNm > 0 {
            ImageProcessor.shared.setLowerNm(newLowerNm: lowerNm)
        } else {
            lowerNmTextField.text = String(format: "%.0f", ImageProcessor.shared.lowerNm)
        }
    }
    
    @IBAction func upperNmChanged(_ sender: UITextField) {
        let upperNm = Float(sender.text!) ?? 0
        if upperNm > 0 {
            ImageProcessor.shared.setUpperNm(newUpperNm: upperNm)
        } else {
            upperNmTextField.text = String(format: "%.0f", ImageProcessor.shared.upperNm)
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
        
        lowerNmTextField.delegate = self
        upperNmTextField.delegate = self
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

extension CalibrationViewController: UITextFieldDelegate {
    
    // used to slide up the content when showing keyboard
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewBottomConstraint.constant = -200
        })
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewBottomConstraint.constant = 0
        })
    }

}
