//
//  BubbleChartData.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class BubbleChartData: BarLineScatterCandleBubbleChartData {    
    /// Sets the width of the circle that surrounds the bubble when highlighted for all DataSet objects this data object contains
    public func setHighlightCircleWidth(_ width: CGFloat) {
        for set in (_dataSets as? [BubbleChartDataSet])! {
            set.highlightCircleWidth = width
        }
    }
}
