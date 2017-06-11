//
//  SpectralVС.swift
//  MindQr
//
//  Created by Yauheni Yarotski on 6/11/17.
//  Copyright © 2017 Yauheni Yarotski. All rights reserved.
//


import UIKit

class SpectralVС: UIViewController {
	
	let interactor = SpectralInteractor()
	
	private let spectralViews = [SpectralView(), SpectralView(), SpectralView(), SpectralView(), SpectralView(), SpectralView(), SpectralView(), SpectralView()]
	private let stackView: UIStackView = UIStackView()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		interactor.spectralVС = self
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .firstBaseline
		stackView.distribution = .fillEqually
		view.addSubview(stackView)
		stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
		stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		
		
		for spectralView in spectralViews {
			spectralView.translatesAutoresizingMaskIntoConstraints = false
			spectralView.backgroundColor = UIColor.black
			stackView.addArrangedSubview(spectralView)
			spectralView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
			spectralView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	func update(with ffts: [TempiFFT]) {
		for (i, fft) in ffts.enumerated() {
			let specView = spectralViews[i]
			DispatchQueue.main.async {
				specView.fft = fft
				specView.setNeedsDisplay()
			}
		}
	}
	
}

