//
//  AnotherBarChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class AnotherBarChartViewController: DemoBaseViewController {
    
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.options = [Option(key: .toggleValues, label: "Toggle Values"),
                        Option(key: .toggleHighlight, label: "Toggle Highlight"),
                        Option(key: .animateX, label: "Animate X"),
                        Option(key: .animateY, label: "Animate Y"),
                        Option(key: .animateXY, label: "Animate XY"),
                        Option(key: .saveToGallery, label: "Save to Camera Roll"),
                        Option(key: .togglePinchZoom, label: "Toggle PinchZoom"),
                        Option(key: .toggleData, label: "Toggle Data"),
                        Option(key: .toggleBarBorders, label: "Toggle Bar Borders")
        ]
        
        chartView.delegate = self
        
        chartView.chartDescription?.isEnabled = false
        chartView.maxVisibleCount = 60
        chartView.isPinchZoomEnabled = false
        chartView.isDrawBarShadowEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
                
        chartView.legend.isEnabled = false
        
        sliderX.value = 10
        sliderY.value = 100
        self.slidersValueChanged(nil)
    }
    
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value) + 1, range: Double(sliderY.value))
    }
    
    func setDataCount(_ count: Int, range: Double) {
        let yVals = (0..<count).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(UInt32(mult))) + mult/3
            return BarChartDataEntry(x: Double(i), y: val)
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1?.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "Data Set")
            set1.colors = ChartColorTemplates.vordiplom
            set1.isDrawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            chartView.data = data
            chartView.fitBars = true
        }
        
        chartView.setNeedsDisplay()
    }
    
    override func optionTapped(key: Option.Key) {
        super.handleOption(key: key, forChartView: chartView)
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }
}
