//
//  RecordingCircleOverlayView.swift
//  SparkRecordingCircle
//
//  Created by Yichi on 27/02/2015.
//  Copyright (c) 2015 Sam Page. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

class RecordingCircleOverlayView: UIView {
	var duration:CGFloat = 0
	var strokeWidth:CGFloat!
	
	private var progressLayers:[CAShapeLayer] = Array()
	private var circlePath:UIBezierPath!
	
	private var currentProgressLayer:CAShapeLayer?
	private lazy var backgroundLayer:CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.path = self.circlePath.CGPath
		layer.strokeColor = UIColor.lightGrayColor().CGColor
		layer.fillColor = UIColor.clearColor().CGColor
		layer.lineWidth = self.strokeWidth
		return layer
	}()
	
	private var circleComplete = false
	
	// MARK: Init methods
	init(frame:CGRect, strokeWidth:CGFloat, insets:UIEdgeInsets){
		super.init(frame:frame)
		
		self.duration = 45
		self.strokeWidth = strokeWidth
		
		let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
		let radius = bounds.midX - insets.top - insets.bottom
		
		circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(M_PI), endAngle: CGFloat(-M_PI), clockwise: false)
		
		addBackgroundLayer()
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Private methods.
	private func addBackgroundLayer() {
		layer.addSublayer(backgroundLayer)
	}
	
	private func addNewLayer() {
		let progressLayer = CAShapeLayer()
		progressLayer.path = circlePath.CGPath
		progressLayer.strokeColor = randomColor().CGColor
		progressLayer.fillColor = UIColor.clearColor().CGColor
		progressLayer.lineWidth = strokeWidth
		progressLayer.strokeEnd = 0
		
		layer.addSublayer(progressLayer)
		progressLayers.append(progressLayer)
		
		currentProgressLayer = progressLayer
	}
	
	private func randomColor() -> UIColor {
		let randomCGFloat = { () -> CGFloat in
			// random CGFloat value between 0.0 to 1.0
			return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
		}
		let hue = randomCGFloat()
		let saturation = randomCGFloat() * 0.5 + 0.5 // 0.5 to 1.0, away from white
		let brightness = randomCGFloat() * 0.5 + 0.5 // 0.5 to 1.0, away from black
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
	}
	
	private func updateAnimations() {
		let duration = self.duration * (1 - progressLayers.first!.strokeEnd )
		var strokeEndFinal = CGFloat(1)
		
		for progressLayer in progressLayers {
			let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
			strokeEndAnimation.duration = CFTimeInterval( duration )
			strokeEndAnimation.fromValue = progressLayer.strokeEnd
			strokeEndAnimation.toValue = strokeEndFinal
			strokeEndAnimation.autoreverses = false
			strokeEndAnimation.repeatCount = 0
			
			let previousStrokeEnd = progressLayer.strokeEnd
			progressLayer.strokeEnd = strokeEndFinal
			
			progressLayer.addAnimation(strokeEndAnimation, forKey: "strokeEndAnimation")
			
			strokeEndFinal -= (previousStrokeEnd - progressLayer.strokeStart)
			
			if progressLayer != currentProgressLayer {
				let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
				strokeStartAnimation.duration = CFTimeInterval( duration )
				strokeStartAnimation.fromValue = progressLayer.strokeStart
				strokeStartAnimation.toValue = strokeEndFinal
				strokeStartAnimation.autoreverses = false
				strokeStartAnimation.repeatCount = 0
				
				progressLayer.strokeStart = strokeEndFinal
				
				progressLayer.addAnimation(strokeStartAnimation, forKey: "strokeStartAnimation")
			}
		}
		
		let backgroundLayerAnimation = CABasicAnimation(keyPath: "strokeStart")
		backgroundLayerAnimation.duration = CFTimeInterval( duration )
		backgroundLayerAnimation.fromValue = backgroundLayer.strokeStart
		backgroundLayerAnimation.toValue = 1
		backgroundLayerAnimation.autoreverses = false
		backgroundLayerAnimation.repeatCount = 0
		backgroundLayerAnimation.delegate = self
		
		backgroundLayer.strokeStart = 1
		
		backgroundLayer.addAnimation(backgroundLayerAnimation, forKey: "strokeStartAnimation")
	}
	
	private func updateLayerModelsForPresentationState() {
		for progressLayer in progressLayers {
			progressLayer.strokeStart = progressLayer.presentationLayer().strokeStart
			progressLayer.strokeEnd = progressLayer.presentationLayer().strokeEnd
			progressLayer.removeAllAnimations()
		}
		
		backgroundLayer.strokeStart = backgroundLayer.presentationLayer().strokeStart
		backgroundLayer.removeAllAnimations()
	}
	
	// MARK: UIResponder overrides
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		if !circleComplete {
			addNewLayer()
			updateAnimations()
		}
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		if !circleComplete {
			updateLayerModelsForPresentationState()
		}
	}
	
	// MARK: CAAnimation Delegate
	override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
		if !circleComplete && flag {
			circleComplete = flag
		}
	}
}