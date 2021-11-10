//
//  CropSettingsVC.swift
//  spectrometer
//
//  Created by Dennis Briner on 10.11.21.
//

import Foundation


class CropSettingsViewController: UIViewController {
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    
    @IBAction func widthValueChanged(_ sender: UISlider) {
        print("ℹ️ got new width:", sender.value)
        ImageProcessor.shared.setCropWidth(newWidth: sender.value)
    }
    
    @IBAction func heightValueChanged(_ sender: UISlider) {
        print("ℹ️ got new height:", sender.value)
        ImageProcessor.shared.setCropHeight(newHeight: sender.value)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        widthSlider.value = ImageProcessor.shared.cropWidth
        heightSlider.value = ImageProcessor.shared.cropHeight
    }
}
