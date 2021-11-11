//
//  MainViewController.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//

import UIKit
import Charts

class MainViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    private var unsubscribeFromImageProcessor: () -> Void = { }
    
    // MARK: OUTLETS
    
    @IBOutlet weak var noCameraAccessView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var croppedImage: UIImageView!
    @IBOutlet weak var cameraSettingsButton: UIButton!
    @IBOutlet weak var cropSettingsButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var freezeButton: UIButton!
    
    @IBAction func cropSettingButtonTapped(_ sender: Any) {
        if let controller = UIStoryboard(name: "CropSettings", bundle: nil).instantiateViewController(withIdentifier: "CropSettingsViewController") as? CropSettingsViewController {
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraSettingsButtonTapped(_ sender: Any) {
        if let controller = UIStoryboard(name: "CameraSettings", bundle: nil).instantiateViewController(withIdentifier: "CameraSettingsViewController") as? CameraSettingsViewController {
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func calibrationButtonTapped(_ sender: Any) {
        if let controller = UIStoryboard(name: "Calibration", bundle: nil).instantiateViewController(withIdentifier: "CalibrationViewController") as? CalibrationViewController {
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func freezeButtonTapped(_ sender: UIButton) {
        ImageProcessor.shared.freeze = !ImageProcessor.shared.freeze
        
        if ImageProcessor.shared.freeze {
            UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromRight, animations: {
                sender.setImage(UIImage(named: "play"), for: .normal)
            })
        } else {
            UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                sender.setImage(UIImage(named: "pause"), for: .normal)
            })

        }
        
    }
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        hideAccordingToCamPermissions()
        noCameraAccessView.isHidden = true // prevents flashing at startupa
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: PRIVATE
    
    private func updateNoCameraAccessLabel() {
        DispatchQueue.main.async {
            self.hideAccordingToCamPermissions()
        }
    }
    
    private func hideAccordingToCamPermissions() {
        noCameraAccessView.isHidden = CaptureManager.shared.cameraAccessGranted
        chartView.isHidden = !CaptureManager.shared.cameraAccessGranted
        cameraSettingsButton.isHidden = !CaptureManager.shared.cameraAccessGranted
        cropSettingsButton.isHidden = !CaptureManager.shared.cameraAccessGranted
        calibrationButton.isHidden = !CaptureManager.shared.cameraAccessGranted
        freezeButton.isHidden = !CaptureManager.shared.cameraAccessGranted
    }
    
    private func getInfoText() -> String {
        let dev = CaptureManager.shared.device!
        return "ISO " + String(format: "%.1f", dev.iso) + "\nTime " + String(format: "%.6f", dev.exposureDuration.seconds)
    }
    
    // MARK: CHART
    
    private func updateGraph() {
        let numberOfMeasurements = ImageProcessor.shared.hist.count
        if numberOfMeasurements < 1 {
            return
        }
        
        var lineChartEntry = [ChartDataEntry]()
        
        // calculate shift in perspective
        let nmDiff = ImageProcessor.shared.upperNm - ImageProcessor.shared.lowerNm
        let posDiff = ImageProcessor.shared.upperNmPosition - ImageProcessor.shared.lowerNmPosition
        
        // calculate the range of the x-axis
        let leftNm = ImageProcessor.shared.lowerNm - nmDiff / posDiff * ImageProcessor.shared.lowerNmPosition
        let rightNm = ImageProcessor.shared.upperNm + nmDiff / posDiff * (1 - ImageProcessor.shared.upperNmPosition)
        let xRange = rightNm - leftNm
        
        let highestValue = ImageProcessor.shared.hist.value(forKeyPath: "@max.self") as! Double
        
        // interpolate values from measurement array into the x-axis
        let arraySize = Float(numberOfMeasurements - 1)
        for i in 0..<numberOfMeasurements {
            let x = leftNm + Float(i) / arraySize * xRange
            
            let value = ChartDataEntry(x: Double(x), y: ImageProcessor.shared.hist[i] as! Double / highestValue)
            lineChartEntry.append(value)
        }
        
        let dataSet = LineChartDataSet(entries: lineChartEntry, label: "")
        dataSet.colors = [NSUIColor.black]
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        dataSet.drawHorizontalHighlightIndicatorEnabled = false // disable cross hairs
        dataSet.drawVerticalHighlightIndicatorEnabled = false // disable cross hairs
        
        let chartData = LineChartData()
        chartData.addDataSet(dataSet)
        chartData.setDrawValues(false) // don't show values when zooming in

        if ImageProcessor.shared.isCalibrating {
            chartData.addDataSet(getVerticalLine(color: NSUIColor.blue, x: Double(ImageProcessor.shared.lowerNm)))
            chartData.addDataSet(getVerticalLine(color: NSUIColor.red, x: Double(ImageProcessor.shared.upperNm)))
        }
        
        chartView.data = chartData
        
        chartView.backgroundColor = UIColor.white
        chartView.xAxis.labelPosition = .bottom // X-axis should be at the bottom
        chartView.leftAxis.axisMinimum = 0 // Y-axis should start at 0
        chartView.rightAxis.labelTextColor = UIColor.black // override since it would become white in dark mode
        chartView.leftAxis.labelTextColor = UIColor.black // override since it would become white in dark mode
        chartView.xAxis.labelTextColor = UIColor.black // override since it would become white in dark mode
        chartView.rightAxis.axisMinimum = 0 // Y-axis should start at 0
        chartView.legend.enabled = false // disable extra legend for each data set
        // chartView.xAxis.avoidFirstLastClippingEnabled = true // doesn't work
        // chartView.xAxis.setLabelCount(6, force: true) // to limit labels. leave this to auto for now
        
    }
    
    // Hacky way to draw a vertical line in a chart
    private func getVerticalLine(color: NSUIColor, x: Double) -> LineChartDataSet {
        var chartDataEntry = [ChartDataEntry]()
        chartDataEntry.append(ChartDataEntry(x: x, y: 0))
        chartDataEntry.append(ChartDataEntry(x: x, y: 1))
        
        let dataSet = LineChartDataSet(entries: chartDataEntry, label: "")
        dataSet.colors = [color]
        dataSet.drawCirclesEnabled = false
        
        return dataSet
    }
}

// MARK: EXTENSIONS

extension MainViewController: ImageProcessorSubscriber {
    
    func newImageAvailable() {
        cameraImage.image = ImageProcessor.shared.image
        croppedImage.image = ImageProcessor.shared.croppedImage
        updateGraph()
    }
    
}
