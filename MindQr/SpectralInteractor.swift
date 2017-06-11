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
	
	fileprivate var second: Int = 0
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
	
	func fft(from sample: [Float]) -> TempiFFT {
		let fft = TempiFFT(withSize: sample.count, sampleRate: Float(Constants.sampleRate))
		fft.windowType = TempiFFTWindowType.hanning
		fft.fftForward(sample)
		fft.calculateLinearBands(minFrequency: 0, maxFrequency: 49, numberOfBands: 49)
		return fft
	}
	
	@objc func updateVC() {
		var ffts = [TempiFFT]()
		for chanel in chanels {
			let firstFrameOfSecond = second * Constants.sampleRate
			let frameOfNextSecond = firstFrameOfSecond + Constants.sampleRate
			let sample = Array(chanel[firstFrameOfSecond..<frameOfNextSecond])
			let ttf = fft(from: sample)
			ffts.append(ttf)
		}
		spectralVС?.update(with: ffts)
		self.second = self.second + 1
		if self.second == chanels.first!.count/Constants.sampleRate {
			self.second = 0
		}
		
	}
}
