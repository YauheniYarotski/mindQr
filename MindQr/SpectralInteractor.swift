//
//  SpectralInteractor.swift
//  MindQr
//
//  Created by Yauheni Yarotski on 6/11/17.
//  Copyright © 2017 Yauheni Yarotski. All rights reserved.
//

import Foundation

class SpectralInteractor {
	
	fileprivate struct Constants {
		static let failToLoadDataString = "fail to load data from JSON"
		static let sampleRate: Int = 256
	}
	
	var spectralVС: SpectralVС?
	
	fileprivate var count: Int = 0
	fileprivate var timer: Timer?
	fileprivate var chanels = [[Float]]()
	
	init() {
		loadSampleDataFromJson()
		let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateVC), userInfo: nil, repeats: true)
		RunLoop.main.add(timer, forMode: .commonModes)
		self.timer = timer
	}
}

private typealias SpectralInteractorPrivate = SpectralInteractor
private extension SpectralInteractorPrivate {
	func loadSampleDataFromJson() {
		if let path = Bundle.main.path(forResource: "sample", ofType: "json") {
			do {
				let jsonData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
				do {
					let jsonResult: [String:[[Float]]] = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:[[Float]]]
					if let chanels = jsonResult["samples"] {
						self.chanels = chanels
					} else {
						print(Constants.failToLoadDataString)
					}
				} catch {
					print(Constants.failToLoadDataString)}
			} catch {
				print(Constants.failToLoadDataString)}
		}
	}
	
	func fft(from frame: [Float]) -> TempiFFT {
		let fft = TempiFFT(withSize: frame.count, sampleRate: Float(Constants.sampleRate))
		fft.windowType = TempiFFTWindowType.hanning
		fft.fftForward(frame)
		fft.calculateLinearBands(minFrequency: 0, maxFrequency: 49, numberOfBands: 49)
		return fft
	}
	
	@objc func updateVC() {
		var ffts = [TempiFFT]()
		for chanel in chanels {
			let firstSample = self.count * Constants.sampleRate
			let lastSample = firstSample + Constants.sampleRate
			let frame = Array(chanel[firstSample..<lastSample])
			let ttf = fft(from: frame)
			ffts.append(ttf)
		}
		spectralVС?.update(with: ffts)
		self.count = self.count + 1
		if self.count == chanels.first!.count/Constants.sampleRate {
			self.count = 0
		}
		
	}
}
