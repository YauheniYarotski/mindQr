//
//  SpectralView.swift
//  MindQr
//
//  Created by Yauheni Yarotski on 6/11/17.
//  Copyright © 2017 Yauheni Yarotski. All rights reserved.
//


import UIKit

class SpectralView: UIView {
	
	var fft: TempiFFT!
	// Draw the spectrum.
	let maxDB: Float = 15.0
	let minDB: Float = 0.0
	static let colors = [UIColor.red.cgColor, UIColor.yellow.cgColor, UIColor.green.cgColor, UIColor.blue.cgColor, UIColor.purple.cgColor]
	let gradient = CGGradient(
		colorsSpace: nil, // generic color space
		colors: colors as CFArray,
		locations: [0.015, 0.125, 0.2, 0.45, 0.7])
	
	override func draw(_ rect: CGRect) {
		
		if fft == nil {
			return
		}
		
		let context = UIGraphicsGetCurrentContext()
		
		self.drawSpectrum(context: context!)
		
		// We're drawing static labels every time through our drawRect() which is a waste.
		// If this were more than a demo we'd take care to only draw them once.
		self.drawLabels(context: context!)
	}
	
	private func drawSpectrum(context: CGContext) {
		let viewWidth = self.bounds.size.width
		let viewHeight = self.bounds.size.height
		let plotYStart: CGFloat = 0
		
		context.saveGState()
		context.scaleBy(x: 1, y: -1)
		context.translateBy(x: 0, y: -viewHeight)
		
		var x: CGFloat = 0.0
		
		let count = fft.numberOfBands
		
		let headroom = maxDB - minDB
		let colWidth = viewWidth / CGFloat(count)
		
		for band in 0..<count {
			let magnitude = fft.magnitudeAtBand(band)
			
			// Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
			var magnitudeDB = TempiFFT.toDB(magnitude)
			
			// Normalize the incoming magnitude so that -Inf = 0
			magnitudeDB = max(0, magnitudeDB + abs(minDB))
			
			let dbRatio = min(1.0, magnitudeDB / headroom)
			let magnitudeNorm = CGFloat(dbRatio) * viewHeight
			
			let colRect: CGRect = CGRect(x: x, y: plotYStart, width: colWidth, height: magnitudeNorm)
			
			let startPoint = CGPoint(x: 0, y: viewHeight)
			let endPoint = CGPoint(x: viewWidth, y: viewHeight)
			
			context.saveGState()
			context.clip(to: colRect)
			context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
			context.restoreGState()
			
			x += colWidth
		}
		
		context.restoreGState()
	}
	
	private func drawLabels(context: CGContext) {
		let viewWidth = self.bounds.size.width
		let viewHeight = self.bounds.size.height
		
		context.saveGState()
		context.translateBy(x: 0, y: viewHeight);
		
		let pointSize: CGFloat = 8.0
		let font = UIFont.systemFont(ofSize: pointSize, weight: UIFontWeightRegular)
		
		var labelStrings: [String] = []
		let labelValues: [CGFloat] = [1,5,8,14,30,49]
		for val in labelValues {
			labelStrings.append(Int(val).description)
		}
		let samplesPerPixel: CGFloat = 50 / viewWidth
		for i in 0..<labelStrings.count {
			let str = labelStrings[i]
			let freq = labelValues[i]
			
			let attrStr = NSMutableAttributedString(string: str)
			attrStr.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, str.characters.count))
			attrStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.yellow, range: NSMakeRange(0, str.characters.count))
			
			let x = freq / samplesPerPixel - pointSize / 2.0
			attrStr.draw(at: CGPoint(x: x, y: -10))
		}
		let str = fft.magnitudeAtBand(0).description
		let attrStrXMax = NSMutableAttributedString(string: str)
		attrStrXMax.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, str.characters.count))
		attrStrXMax.addAttribute(NSForegroundColorAttributeName, value: UIColor.yellow, range: NSMakeRange(0, str.characters.count))
		
		attrStrXMax.draw(at: CGPoint(x: 2, y: -viewHeight+5))
		
		context.restoreGState()
	}
	
//	func bandColor(for band: Int) -> CGColor {
//		var color: CGColor?
//		switch band {
//		case 0..<5:
//			color = UIColor.red.cgColor
//		case 5..<8:
//			color = UIColor.yellow.cgColor
//		case 8..<14:
//			color = UIColor.green.cgColor
//		case 14..<30:
//			color = UIColor.blue.cgColor
//		case 30...49:
//			color = UIColor.purple.cgColor
//		default:
//			color = UIColor.black.cgColor
//			print("band out of color range")
//		}
//		return color ?? UIColor.black.cgColor
//	}
}
