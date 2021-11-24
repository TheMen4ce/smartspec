//
//  CropSettingsVC.swift
//  spectrometer
//
//  Created by Dennis Briner on 10.11.21.
//

import Foundation


class CropSettingsViewController: UIViewController {
    @IBOutlet weak var xSlider: UISlider!
    @IBOutlet weak var ySlider: UISlider!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    
    @IBAction func widthValueChanged(_ sender: UISlider) {
        ImageProcessor.shared.setCropWidth(newWidth: sender.value)
    }
    
    @IBAction func heightValueChanged(_ sender: UISlider) {
        ImageProcessor.shared.setCropHeight(newHeight: sender.value)
    }
    
    @IBAction func xValueChanged(_ sender: UISlider) {
        ImageProcessor.shared.setXOffset(newX: sender.value)
    }
    
    @IBAction func yValueChanged(_ sender: UISlider) {
        ImageProcessor.shared.setYOffset(newY: sender.value)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        widthSlider.value = ImageProcessor.shared.cropWidth
        heightSlider.value = ImageProcessor.shared.cropHeight
        xSlider.value = ImageProcessor.shared.cropXOffset
        ySlider.value = ImageProcessor.shared.cropYOffset
    }
}
