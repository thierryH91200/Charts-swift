//
//  XAxis.swift
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

public class XAxis: AxisBase {
    public enum LabelPosition {
        case top
        case bottom
        case bothSided
        case topInside
        case bottomInside
    }
    
    /// width of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    public var labelWidth: CGFloat = 1
    
    /// height of the x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    public var labelHeight: CGFloat = 1
    
    /// width of the (rotated) x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    public var labelRotatedWidth: CGFloat = 1
    
    /// height of the (rotated) x-axis labels in pixels - this is automatically calculated by the `computeSize()` methods in the renderers
    public var labelRotatedHeight: CGFloat = 1
    
    /// This is the angle for drawing the X axis labels (in degrees)
    public var labelRotationAngle: CGFloat = 0

    /// if set to true, the chart will avoid that the first and last label entry in the chart "clip" off the edge of the chart
    public var isAvoidFirstLastClippingEnabled = false
    
    /// the position of the x-labels relative to the chart
    public var labelPosition: LabelPosition = .top
    
    /// if set to true, word wrapping the labels will be enabled.
    /// word wrapping is done using `(value width * labelRotatedWidth)`
    ///
    /// - note: currently supports all charts except pie/radar/horizontal-bar*
    /// - returns: `true` if word wrapping the labels is enabled
    public var isWordWrapEnabled = false
    
    /// the width for wrapping the labels, as percentage out of one value width.
    /// used only when isWordWrapEnabled = true.
    /// 
    /// **default**: 1.0
    public var wordWrapWidthPercent: CGFloat = 1
    
    public override init() {
        super.init()
        
        self.yOffset = 4
    }
}
