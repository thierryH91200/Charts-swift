//
//  PiePolylineChartViewController.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import UIKit
import Charts

class PiePolylineChartViewController: DemoBaseViewController {

    @IBOutlet var chartView: PieChartView!
    @IBOutlet var sliderX: UISlider!
    @IBOutlet var sliderY: UISlider!
    @IBOutlet var sliderTextX: UITextField!
    @IBOutlet var sliderTextY: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Pie Bar Chart"
        
        self.options = [Option(key: .toggleValues, label: "Toggle Y-Values"),
                        Option(key: .toggleXValues, label: "Toggle X-Values"),
                        Option(key: .togglePercent, label: "Toggle Percent"),
                        Option(key: .toggleHole, label: "Toggle Hole"),
                        Option(key: .animateX, label: "Animate X"),
                        Option(key: .animateY, label: "Animate Y"),
                        Option(key: .animateXY, label: "Animate XY"),
                        Option(key: .spin, label: "Spin"),
                        Option(key: .drawCenter, label: "Draw CenterText"),
                        Option(key: .saveToGallery, label: "Save to Camera Roll"),
                        Option(key: .toggleData, label: "Toggle Data")
        ]
        
        self.setup(pieChartView: chartView)
        
        chartView.delegate = self
        
        chartView.legend.isEnabled = false
        chartView.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        
        sliderX.value = 40
        sliderY.value = 100
        self.slidersValueChanged(nil)
        
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    override func updateChartData() {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        
        self.setDataCount(Int(sliderX.value), range: UInt32(sliderY.value))
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5),
                                     label: parties[i % parties.count])
        }
        
        let set = PieChartDataSet(values: entries, label: "Election Results")
        set.sliceSpace = 2
        
        
        set.colors = ChartColorTemplates.vordiplom
            + ChartColorTemplates.joyful
            + ChartColorTemplates.colorful
            + ChartColorTemplates.liberty
            + ChartColorTemplates.pastel
            + [UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)]
        
        set.valueLinePart1OffsetPercentage = 0.8
        set.valueLinePart1Length = 0.2
        set.valueLinePart2Length = 0.4
        //set.xValuePosition = .outsideSlice
        set.yValuePosition = .outsideSlice
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    override func optionTapped(key: Option.Key) {
        switch key {
        case .toggleXValues:
            chartView.isDrawEntryLabelsEnabled = !chartView.isDrawEntryLabelsEnabled
            chartView.setNeedsDisplay()
            
        case .togglePercent:
            chartView.usePercentValues = !chartView.usePercentValues
            chartView.setNeedsDisplay()
            
        case .toggleHole:
            chartView.isDrawHoleEnabled = !chartView.isDrawHoleEnabled
            chartView.setNeedsDisplay()
            
        case .drawCenter:
            chartView.isDrawCenterTextEnabled = !chartView.isDrawCenterTextEnabled
            chartView.setNeedsDisplay()
            
        case .animateX:
            chartView.animate(xAxisDuration: 1.4)
            
        case .animateY:
            chartView.animate(yAxisDuration: 1.4)
            
        case .animateXY:
            chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4)
            
        case .spin:
            chartView.spin(duration: 2,
                           fromAngle: chartView.rotationAngle,
                           toAngle: chartView.rotationAngle + 360,
                           easingOption: .easeInCubic)
            
        default:
            handleOption(key: key, forChartView: chartView)
        }
    }
    
    // MARK: - Actions
    @IBAction func slidersValueChanged(_ sender: Any?) {
        let startYear = 1980
        let endYear = startYear + Int(sliderX.value)
        
        sliderTextX.text = "\(Int(sliderX.value))"
        sliderTextY.text = "\(Int(sliderY.value))"
        
        self.updateChartData()
    }
}
