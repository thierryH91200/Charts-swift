//
//  RadarChartData.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public class RadarChartData: ChartData {
    public var highlightColor = Color(red: 255.0/255.0, green: 187.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    public var highlightLineWidth = CGFloat(1.0)
    public var highlightLineDashPhase = CGFloat(0.0)
    public var highlightLineDashLengths: [CGFloat]?
    
    /// Sets labels that should be drawn around the RadarChart at the end of each web line.
    public var labels = [String]()
    
    /// Sets the labels that should be drawn around the RadarChart at the end of each web line.
    public func setLabels(_ labels: String...) {
        self.labels = labels
    }

    public override func entryForHighlight(_ highlight: Highlight) -> ChartDataEntry? {
        return getDataSetByIndex(highlight.dataSetIndex)?[Int(highlight.x)]
    }
}
