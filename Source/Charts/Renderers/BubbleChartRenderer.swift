//
//  BubbleChartRenderer.swift
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

#if !os(OSX)
    import UIKit
#endif


final class BubbleChartRenderer: BarLineScatterCandleBubbleRenderer {
    var _xBounds: XBounds = XBounds()
    
    let viewPortHandler: ViewPortHandler
    
    var animator: Animator?
    
    weak var dataProvider: BubbleChartDataProvider?
    
    init(dataProvider: BubbleChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler) {
        self.animator = animator
        self.viewPortHandler = viewPortHandler
        self.dataProvider = dataProvider
    }
    
    func initBuffers() { }
    
    func drawData(context: CGContext) {
        guard
            let dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData
            else { return }
        
        for set in bubbleData.dataSets as! [BubbleChartDataSet] {
            if set.isVisible {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private func getShapeSize(
        entrySize: CGFloat,
        maxSize: CGFloat,
        reference: CGFloat,
        normalizeSize: Bool) -> CGFloat {
        let factor: CGFloat = normalizeSize
            ? ((maxSize == 0.0) ? 1.0 : sqrt(entrySize / maxSize))
            : entrySize
        let shapeSize: CGFloat = reference * factor
        return shapeSize
    }
    
    private var _pointBuffer = CGPoint()
    private var _sizeBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    func drawDataSet(context: CGContext, dataSet: BubbleChartDataSet) {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
    
        _sizeBuffer[0].x = 0.0
        _sizeBuffer[0].y = 0.0
        _sizeBuffer[1].x = 1.0
        _sizeBuffer[1].y = 0.0
        
        trans.pointValuesToPixel(&_sizeBuffer)
        
        context.saveGState()
        
        let normalizeSize = dataSet.isNormalizeSizeEnabled
        
        // calcualte the full width of 1 step on the x-axis
        let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
        let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
        let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)
        
        for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
            guard let entry = dataSet[j] as? BubbleChartDataEntry else { continue }
            
            _pointBuffer.x = CGFloat(entry.x)
            _pointBuffer.y = CGFloat(entry.y * phaseY)
            _pointBuffer = _pointBuffer.applying(valueToPixelMatrix)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
            let shapeHalf = shapeSize / 2.0
            
            if !viewPortHandler.isInBoundsTop(_pointBuffer.y + shapeHalf)
                || !viewPortHandler.isInBoundsBottom(_pointBuffer.y - shapeHalf) {
                continue
            }
            
            if !viewPortHandler.isInBoundsLeft(_pointBuffer.x + shapeHalf) {
                continue
            }
            
            if !viewPortHandler.isInBoundsRight(_pointBuffer.x - shapeHalf) {
                break
            }
            
            let color = dataSet.color(atIndex: Int(entry.x))
            
            let rect = CGRect(
                x: _pointBuffer.x - shapeHalf,
                y: _pointBuffer.y - shapeHalf,
                width: shapeSize,
                height: shapeSize
            )

            context.setFillColor(color.cgColor)
            context.fillEllipse(in: rect)
        }
        
        context.restoreGState()
    }
    
    func drawValues(context: CGContext) {
        guard let
            dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData,
            let animator = animator
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider) {
            guard let dataSets = bubbleData.dataSets as? [BubbleChartDataSet] else { return }
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0..<dataSets.count {
                let dataSet = dataSets[i]
                
                if !shouldDrawValues(forDataSet: dataSet) {
                    continue
                }
                
                let alpha = phaseX == 1 ? phaseY : phaseX
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1) {
                    guard let e = dataSet[j] as? BubbleChartDataEntry else { break }
                    
                    let valueTextColor = dataSet.valueTextColorAt(j).withAlphaComponent(CGFloat(alpha))
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x)) {
                        break
                    }
                    
                    if ((!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))) {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        Double(e.size),
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    // Larger font for larger bubbles?
                    let valueFont = dataSet.valueFont
                    let lineHeight = valueFont.lineHeight
                    
                    if dataSet.isDrawValuesEnabled {
                        ChartUtils.drawText(text,
                                            at: CGPoint(x: pt.x,
                                                        y: pt.y - (0.5 * lineHeight)),
                                            align: .center,
                                            attributes: [.font: valueFont,
                                                         .foregroundColor: valueTextColor],
                                            context: context)
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled {
                        ChartUtils.drawImage(icon,
                                             x: pt.x + iconsOffset.x,
                                             y: pt.y + iconsOffset.y,
                                             size: icon.size,
                                             context: context)
                    }
                    
                }
            }
        }
    }
    
    func drawExtras(context: CGContext) { }
    
    func drawHighlighted(context: CGContext, indices: [Highlight]) {
        guard let
            dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData,
            let animator = animator
            else { return }
        
        context.saveGState()
        
        let phaseY = animator.phaseY
        
        for high in indices {
            guard
                let dataSet = bubbleData.getDataSetByIndex(high.dataSetIndex) as? BubbleChartDataSet,
                dataSet.isHighlightEnabled
                else { continue }
                        
            guard let entry = dataSet.entryForXValue(high.x, closestToY: high.y) as? BubbleChartDataEntry else { continue }
            
            if !isInBoundsX(entry: entry, dataSet: dataSet) { continue }
            
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            
            _sizeBuffer[0].x = 0.0
            _sizeBuffer[0].y = 0.0
            _sizeBuffer[1].x = 1.0
            _sizeBuffer[1].y = 0.0
            
            trans.pointValuesToPixel(&_sizeBuffer)
            
            let normalizeSize = dataSet.isNormalizeSizeEnabled
            
            // calcualte the full width of 1 step on the x-axis
            let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
            let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
            let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)
            
            _pointBuffer.x = CGFloat(entry.x)
            _pointBuffer.y = CGFloat(entry.y * phaseY)
            trans.pointValueToPixel(&_pointBuffer)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
            let shapeHalf = shapeSize / 2.0
            
            if !viewPortHandler.isInBoundsTop(_pointBuffer.y + shapeHalf) ||
                !viewPortHandler.isInBoundsBottom(_pointBuffer.y - shapeHalf) {
                continue
            }
            
            if !viewPortHandler.isInBoundsLeft(_pointBuffer.x + shapeHalf) {
                continue
            }
            
            if !viewPortHandler.isInBoundsRight(_pointBuffer.x - shapeHalf) {
                break
            }
            
            let originalColor = dataSet.color(atIndex: Int(entry.x))
            
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            
            originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            
            let color = Color(hue: h, saturation: s, brightness: b * 0.5, alpha: a)
            let rect = CGRect(
                x: _pointBuffer.x - shapeHalf,
                y: _pointBuffer.y - shapeHalf,
                width: shapeSize,
                height: shapeSize)
            
            context.setLineWidth(dataSet.highlightCircleWidth)
            context.setStrokeColor(color.cgColor)
            context.strokeEllipse(in: rect)
            
            high.setDraw(x: _pointBuffer.x, y: _pointBuffer.y)
        }
        
        context.restoreGState()
    }
}
