//
//  Legend.swift
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

#if !os(OSX)
    import UIKit
#endif

public struct Legend {
    public enum Form {
        /// Avoid drawing a form
        case none
        
        /// Do not draw the a form, but leave space for it
        case empty
        
        /// Use default (default dataset's form to the legend's form)
        case `default`
        
        /// Draw a square
        case square
        
        /// Draw a circle
        case circle
        
        /// Draw a horizontal line
        case line
    }
    
    public enum HorizontalAlignment {
        case left
        case center
        case right
    }
    
    public enum VerticalAlignment {
        case top
        case center
        case bottom
    }
    
    public enum Orientation {
        case horizontal
        case vertical
    }
    
    public enum Direction {
        case leftToRight
        case rightToLeft
    }
    
    /// The legend entries array
    public var entries = [LegendEntry]()
    
    /// Entries that will be appended to the end of the auto calculated entries after calculating the legend.
    /// (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
    public var extraEntries = [LegendEntry]()
    
    /// Are the legend labels/colors a custom value or auto calculated? If false, then it's auto, if true, then custom.
    /// 
    /// **default**: false (automatic legend)
    public private(set) var isLegendCustom = false
    
    /// The horizontal alignment of the legend
    public var horizontalAlignment: HorizontalAlignment = .left
    
    /// The vertical alignment of the legend
    public var verticalAlignment: VerticalAlignment = .bottom
    
    /// The orientation of the legend
    public var orientation: Orientation = .horizontal
    
    /// Flag indicating whether the legend will draw inside the chart or outside
    public var drawInside = false
    
    /// The text direction of the legend
    public var direction: Direction = .leftToRight

    public var font: Font = .systemFont(ofSize: 10.0)
    public var textColor = Color.black

    /// The form/shape of the legend forms
    public var form = Form.square
    
    /// The size of the legend forms
    public var formSize = CGFloat(8.0)
    
    /// The line width for forms that consist of lines
    public var formLineWidth = CGFloat(3.0)
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is how much (in pixels) into the dash pattern are we starting from.
    public var formLineDashPhase: CGFloat = 0.0
    
    /// Line dash configuration for shapes that consist of lines.
    ///
    /// This is the actual dash pattern.
    /// I.e. [2, 3] will paint [--   --   ]
    /// [1, 3, 4, 2] will paint [-   ----  -   ----  ]
    public var formLineDashLengths: [CGFloat]?
    
    public var xEntrySpace = CGFloat(6.0)
    public var yEntrySpace = CGFloat(0.0)
    public var formToTextSpace = CGFloat(5.0)
    public var stackSpace = CGFloat(3.0)
    
    public var calculatedLabelSizes = [CGSize]()
    public var calculatedLabelBreakPoints = [Bool]()
    public var calculatedLineSizes = [CGSize]()
    
    public init() {
        self.xOffset = 5.0
        self.yOffset = 3.0
    }
    
    public init(entries: [LegendEntry]) {
        self.entries = entries
    }
    
    public func getMaximumEntrySize(withFont font: Font) -> CGSize {
        var maxW = CGFloat(0.0)
        var maxH = CGFloat(0.0)
        
        var maxFormSize: CGFloat = 0.0

        for entry in entries {
            let formSize = entry.formSize.isNaN ? self.formSize : entry.formSize
            if formSize > maxFormSize {
                maxFormSize = formSize
            }
            
            guard let label = entry.label
                else { continue }
            
            let size = (label as NSString!).size(withAttributes: [NSAttributedStringKey.font: font])
            
            if size.width > maxW {
                maxW = size.width
            }
            if size.height > maxH {
                maxH = size.height
            }
        }
        
        return CGSize(
            width: maxW + maxFormSize + formToTextSpace,
            height: maxH
        )
    }

    public var neededWidth = CGFloat(0.0)
    public var neededHeight = CGFloat(0.0)
    public var textWidthMax = CGFloat(0.0)
    public var textHeightMax = CGFloat(0.0)
    
    /// flag that indicates if word wrapping is enabled
    /// this is currently supported only for `orientation == Horizontal`.
    /// you may want to set maxSizePercent when word wrapping, to set the point where the text wraps.
    /// 
    /// **default**: true
    /// if this is set, then word wrapping the legend is enabled.
    public var isWordWrapEnabled = true

    /// The maximum relative size out of the whole chart view in percent.
    /// If the legend is to the right/left of the chart, then this affects the width of the legend.
    /// If the legend is to the top/bottom of the chart, then this affects the height of the legend.
    /// 
    /// **default**: 0.95 (95%)
    public var maxSizePercent: CGFloat = 0.95
    
    mutating func calculateDimensions(labelFont: Font, viewPortHandler: ViewPortHandler) {
        let maxEntrySize = getMaximumEntrySize(withFont: labelFont)
        let defaultFormSize = self.formSize
        let stackSpace = self.stackSpace
        let formToTextSpace = self.formToTextSpace
        let xEntrySpace = self.xEntrySpace
        let yEntrySpace = self.yEntrySpace
        let wordWrapEnabled = self.isWordWrapEnabled
        let entries = self.entries
        let entryCount = entries.count
        
        textWidthMax = maxEntrySize.width
        textHeightMax = maxEntrySize.height
        
        switch orientation {
        case .vertical:
            
            var maxWidth = CGFloat(0.0)
            var width = CGFloat(0.0)
            var maxHeight = CGFloat(0.0)
            let labelLineHeight = labelFont.lineHeight
            
            var wasStacked = false
            
            for (i,e) in entries.enumerated() {
                let drawingForm = e.form != .none
                let formSize = e.formSize.isNaN ? defaultFormSize : e.formSize
                let label = e.label
                
                if !wasStacked {
                    width = 0.0
                }
                
                if drawingForm {
                    if wasStacked {
                        width += stackSpace
                    }
                    width += formSize
                }
                
                if let label = label as NSString? {
                    let size = label.size(withAttributes: [NSAttributedStringKey.font: labelFont])
                    
                    if drawingForm && !wasStacked {
                        width += formToTextSpace
                    }
                    else if wasStacked {
                        maxWidth = max(maxWidth, width)
                        maxHeight += labelLineHeight + yEntrySpace
                        width = 0.0
                        wasStacked = false
                    }
                    
                    width += size.width
                    
                    if i < entryCount - 1 {
                        maxHeight += labelLineHeight + yEntrySpace
                    }
                }
                else {
                    wasStacked = true
                    width += formSize
                    
                    if i < entryCount - 1 {
                        width += stackSpace
                    }
                }
                
                maxWidth = max(maxWidth, width)
            }
            
            neededWidth = maxWidth
            neededHeight = maxHeight
            
        case .horizontal:
            
            let labelLineHeight = labelFont.lineHeight
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth * maxSizePercent
            
            // Prepare arrays for calculated layout
            if calculatedLabelSizes.count != entryCount {
                calculatedLabelSizes = [CGSize](repeating: CGSize(), count: entryCount)
            }
            
            if calculatedLabelBreakPoints.count != entryCount {
                calculatedLabelBreakPoints = [Bool](repeating: false, count: entryCount)
            }
            
            calculatedLineSizes.removeAll(keepingCapacity: true)
            
            // Start calculating layout
            
            let labelAttrs = [NSAttributedStringKey.font: labelFont]
            var maxLineWidth: CGFloat = 0.0
            var currentLineWidth: CGFloat = 0.0
            var requiredWidth: CGFloat = 0.0
            var stackedStartIndex: Int = -1
            
            for (i,e) in entries.enumerated() {
                let drawingForm = e.form != .none
                let label = e.label
                
                calculatedLabelBreakPoints[i] = false
                
                if stackedStartIndex == -1 {
                    // we are not stacking, so required width is for this label only
                    requiredWidth = 0.0
                }
                else {
                    // add the spacing appropriate for stacked labels/forms
                    requiredWidth += stackSpace
                }
                
                // grouped forms have null labels
                if label != nil {
                    calculatedLabelSizes[i] = (label as NSString!).size(withAttributes: labelAttrs)
                    requiredWidth += drawingForm ? formToTextSpace + formSize : 0.0
                    requiredWidth += calculatedLabelSizes[i].width
                }
                else {
                    calculatedLabelSizes[i] = CGSize()
                    requiredWidth += drawingForm ? formSize : 0.0
                    
                    if stackedStartIndex == -1 {
                        // mark this index as we might want to break here later
                        stackedStartIndex = i
                    }
                }
                
                if label != nil || i == entryCount - 1 {
                    let requiredSpacing = currentLineWidth == 0.0 ? 0.0 : xEntrySpace
                    
                    if (!wordWrapEnabled || // No word wrapping, it must fit.
                        currentLineWidth == 0.0 || // The line is empty, it must fit.
                        (contentWidth - currentLineWidth >= requiredSpacing + requiredWidth)) // It simply fits
                    {
                        // Expand current line
                        currentLineWidth += requiredSpacing + requiredWidth
                    }
                    else { // It doesn't fit, we need to wrap a line
                        
                        // Add current line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                        
                        // Start a new line
                        calculatedLabelBreakPoints[stackedStartIndex > -1 ? stackedStartIndex : i] = true
                        currentLineWidth = requiredWidth
                    }
                    
                    if i == entryCount - 1 { // Add last line size to array
                        calculatedLineSizes.append(CGSize(width: currentLineWidth, height: labelLineHeight))
                        maxLineWidth = max(maxLineWidth, currentLineWidth)
                    }
                }
                
                stackedStartIndex = label != nil ? -1 : stackedStartIndex
            }
            
            neededWidth = maxLineWidth
            neededHeight = labelLineHeight * CGFloat(calculatedLineSizes.count) +
                yEntrySpace * CGFloat(calculatedLineSizes.count == 0 ? 0 : (calculatedLineSizes.count - 1))
        }
        
        neededWidth += xOffset
        neededHeight += yOffset
    }
    
    /// MARK: - Custom legend
    
    /// Sets a custom legend's entries array.
    /// * A nil label will start a group.
    /// This will disable the feature that automatically calculates the legend entries from the datasets.
    /// Call `resetCustom(...)` to re-enable automatic calculation (and then `notifyDataSetChanged()` is needed).
    public mutating func setCustom(entries: [LegendEntry]) {
        self.entries = entries
        isLegendCustom = true
    }
    
    /// Calling this will disable the custom legend entries (set by `setLegend(...)`). Instead, the entries will again be calculated automatically (after `notifyDataSetChanged()` is called).
    public mutating func resetCustom() {
        isLegendCustom = false
    }
    
    /// flag that indicates if this component is enabled or not
    public var isEnabled = true
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0
    public var xOffset = CGFloat(5.0)
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    public var yOffset = CGFloat(5.0)
}
