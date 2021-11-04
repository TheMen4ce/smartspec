//
//  ViewController.swift
//  spectrometer
//
//  Created by Dennis Briner on 28.10.21.
//

import UIKit
import Charts

class ViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    private var unsubscribeFromImageProcessor: () -> Void = { }
    
    private let MIN_NM = 380.0
    private let MAX_NM = 780.0
    
    // MARK: OUTLETS
    
    @IBOutlet weak var noCameraAccessView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var croppedImage: UIImageView!
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    private func updateGraph(){
        if ImageProcessor.shared.hist.count < 1 {
            return
        }
        
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<ImageProcessor.shared.hist.count {
            let entries = Double(ImageProcessor.shared.hist.count - 1)
            let x = MIN_NM + Double(i) / entries * (MAX_NM - MIN_NM)
            
            let value = ChartDataEntry(x: x, y: ImageProcessor.shared.hist[i] as! Double)
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
        
        chartView.data = chartData
        
        chartView.backgroundColor = UIColor.white // ugly but better readability
        chartView.xAxis.labelPosition = .bottom // X-axis should be at the bottom
        chartView.leftAxis.axisMinimum = 0 // Y-axis should start at 0
        chartView.rightAxis.axisMinimum = 0 // Y-axis should start at 0
        chartView.legend.enabled = false // disable extra legend for each data set
        // chartView.xAxis.avoidFirstLastClippingEnabled = true // doesn't work
        chartView.xAxis.setLabelCount(6, force: true) // to have MIN_NM to the left and MAX_NM to the right
    }
}

// MARK: EXTENSIONS

extension ViewController: ImageProcessorSubscriber {
    
    func newImageAvailable() {
        cameraImage.image = ImageProcessor.shared.image
        croppedImage.image = ImageProcessor.shared.croppedImage
        updateGraph()
        
        currentIsoLabel.text = String(format: "%.0f", CaptureManager.shared.device!.iso)
        currentTimeLabel.text = String(format: "%.3f", CaptureManager.shared.device!.exposureDuration.seconds)
        
        isoPlusButton.isHidden = CaptureManager.shared.isIsoAtMax
        isoMinusButton.isHidden = CaptureManager.shared.isIsoAtMin
        timePlusButton.isHidden = CaptureManager.shared.isTimeAtMax
        timeMinusButton.isHidden = CaptureManager.shared.isTimeAtMin
    }
    
}
