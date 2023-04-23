//
//  FestiveEffect.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/16/21.
//

import AppKit

class FestiveEffect: NotchEffect {

	var bulbLayers: [CALayer]
	var timer: Timer?
	
	let bulbCount = 8
	let padding: CGFloat = 20

	let bulbBounds = CGRect(origin: .zero, size: CGSize(width: 15, height: 55))

	private func bulbImage(named name: String) -> CGImage? {
		let image = NSImage(named: name)!
		var proposedRect = bulbBounds
		return image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
	}
	
	lazy var purpleOffImage: CGImage? = {
		return bulbImage(named: "bulb-purple-off")
	}()

	lazy var purpleOnImage: CGImage? = {
		return bulbImage(named: "bulb-purple-on")
	}()

	lazy var blueOffImage: CGImage? = {
		return bulbImage(named: "bulb-blue-off")
	}()

	lazy var blueOnImage: CGImage? = {
		return bulbImage(named: "bulb-blue-on")
	}()

	required init (with parentLayer: CALayer, in parentView: NSView, of parentWindow: NSWindow) {
		self.bulbLayers = []
		
		super.init(with: parentLayer, in: parentView, of: parentWindow)

		configureSublayers()
	}
	
	deinit {
		self.bulbLayers.removeAll()
	}
	
	var patternAddress = 0b0000_0000_0000_0000
	
	static let patternRom = [
		// scan left then right
		0b0000_0001,
		0b0000_0010,
		0b0000_0100,
		0b0000_1000,
		0b0001_0000,
		0b0010_0000,
		0b0100_0000,
		0b1000_0000,
		0b0100_0000,
		0b0010_0000,
		0b0001_0000,
		0b0000_1000,
		0b0000_0100,
		0b0000_0010,
		0b0000_0001,

		// alternating every other
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,
		0b1010_1010,
		0b0101_0101,

		// intersecting
		0b0000_0000,
		0b1000_0001,
		0b0100_0010,
		0b0010_0100,
		0b0001_1000,
		0b0000_0000,
		0b0001_1000,
		0b0010_0100,
		0b0100_0010,
		0b1000_0001,
		0b0100_0010,
		0b0010_0100,
		0b0001_1000,
		0b0000_0000,
		0b0001_1000,
		0b0010_0100,
		0b0100_0010,
		0b1000_0001,
		0b0000_0000,

		// alternating every other pair
		0b1100_1100,
		0b1100_1100,
		0b0011_0011,
		0b0011_0011,
		0b1100_1100,
		0b1100_1100,
		0b0011_0011,
		0b0011_0011,
		0b1100_1100,
		0b1100_1100,
		0b0011_0011,
		0b0011_0011,
		0b1100_1100,
		0b1100_1100,
		0b0011_0011,
		0b0011_0011,
		
		// scan left then right (inverted)
		0b1111_1110,
		0b1111_1101,
		0b1111_1011,
		0b1111_0111,
		0b1110_1111,
		0b1101_1111,
		0b1011_1111,
		0b0111_1111,
		0b1011_1111,
		0b1101_1111,
		0b1110_1111,
		0b1111_0111,
		0b1111_1011,
		0b1111_1101,
		0b1111_1110,

		// why would your notch send a distress signal?
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b1111_1111,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b1111_1111,
		0b0000_0000,
		0b0000_0000,

		// and now a word from our sponsor (that's why)
		0b0_0000000,
		0b11_111111,
		0b000_00000,
		0b1111_1111,
		0b00000_000,
		0b010000_11,
		0b0100100_0,
		0b0_1001111,
		0b01_000011,
		0b010_01011,
		0b0000_0000,
		0b01010_111,
		0b010000_01,
		0b0101001_1,
		0b0_0000000,
		0b01_001000,
		0b010_00101,
		0b0101_0010,
		0b01000_101,
		0b000000_00,
		0b0100010_0,
		0b0_1010101,
		0b01_001000,
		0b000_00000,
		0b1111_1111,
		0b00000_000,
		0b111111_11,
		0b0000000_0,
	]
	+ Array(repeating: 0b0000_0000, count: 4)
	+ Array(0b0000_0000...0b1111_1111) // doing what computers do best
	+ Array(repeating: 0b0000_0000, count: 8)
	
	private func configureSublayers() {
		guard let parentLayer = parentLayer else { return }

		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(bulbCount - 1)
		let yOffset = -bulbBounds.height

		for index in 0..<bulbCount {
			let bulbLayer = CALayer()
			
			bulbLayer.contentsScale = parentLayer.contentsScale

			bulbLayer.bounds = bulbBounds
			bulbLayer.contents = (index % 2 == 0 ? purpleOffImage : blueOffImage)
			
			bulbLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
			
			let xOffset = padding + (bulbSpacing * CGFloat(index))
			bulbLayer.position = CGPoint(x: xOffset, y: yOffset)
			
			parentLayer.addSublayer(bulbLayer)
			
			bulbLayers.append(bulbLayer)
		}
	}
	
	private func startLights() {
		if timer == nil {
			patternAddress = 0b0000_0000_0000_0000
			timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
				let pattern = Self.patternRom[self.patternAddress]
				
				var shift = pattern
				for index in 0..<self.bulbCount {
					let bulbLayer = self.bulbLayers[index]
					
					let state = shift & 0b1000_0000
					if index % 2 == 0 {
						// purple
						if state == 0b0 {
							bulbLayer.contents = self.purpleOffImage
						}
						else {
							bulbLayer.contents = self.purpleOnImage
						}
					}
					else {
						// blue
						if state == 0b0 {
							bulbLayer.contents = self.blueOffImage
						}
						else {
							bulbLayer.contents = self.blueOnImage
						}
					}
					
					shift = shift << 1
				}
				
				self.patternAddress += 0b0000_0000_0000_0001
				if self.patternAddress >= Self.patternRom.count {
					self.patternAddress = 0b0000_0000_0000_0000
				}
			})
		}
	}

	var lastPoint: CGPoint = .zero

	override func mouseEntered(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let yOffset = parentLayer.bounds.midY

		stopLights()
		
		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.startLights()
		}

		for (index, bulbLayer) in bulbLayers.enumerated() {
			bulbLayer.contents = (index % 2 == 0 ? purpleOnImage : blueOnImage)

			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)
			
			let fromPosition: CGPoint
			if let position = bulbLayer.presentation()?.position {
				fromPosition = position
			}
			else {
				fromPosition = CGPoint(x: bulbLayer.position.x, y: -bulbBounds.height)
			}
			
			let springDownAnimation = CASpringAnimation(keyPath: "position")
			springDownAnimation.fromValue = fromPosition
			springDownAnimation.toValue = CGPoint(x: bulbLayer.position.x, y: yOffset)
			springDownAnimation.duration = 2
			springDownAnimation.damping = 8
			springDownAnimation.mass = 0.5
			bulbLayer.add(springDownAnimation, forKey: "position")
		}
		
		CATransaction.commit()
		
		lastPoint = point
	}
	
	var currentBulbIndex = -1

	override func mouseMoved(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }
			
		let availableWidth = parentLayer.bounds.width - (padding * 2)
		let bulbSpacing = availableWidth / CGFloat(bulbCount - 1)

		if underNotch {
			let bulbInset = padding - (bulbSpacing / 2)
			if point.x > bulbInset {
				let bulbIndex = Int((point.x - bulbInset) / bulbSpacing)
				if bulbIndex >= 0 && bulbIndex < bulbCount {
					if bulbIndex != currentBulbIndex {
						currentBulbIndex = bulbIndex

						let bulbLayer = bulbLayers[bulbIndex]
						
						CATransaction.begin()
						
						let horizontalDirection = point.x - lastPoint.x // negative = moving left, positive - moving right
						let pulse: CGFloat = horizontalDirection > 0 ? -1 : 1
						let springSwayAnimation = CASpringAnimation(keyPath: "transform.rotation")
						springSwayAnimation.fromValue = CGFloat.pi / 16 * pulse
						springSwayAnimation.toValue = 0
						springSwayAnimation.duration = 3
						springSwayAnimation.damping = 2
						springSwayAnimation.fillMode = .forwards
						springSwayAnimation.isAdditive = true
						bulbLayer.add(springSwayAnimation, forKey: "springSway")
						
						CATransaction.commit()
					}
				}
			}
		}
		else {
			currentBulbIndex = -1
		}
		
		lastPoint = point
	}
	
	private func stopLights() {
		timer?.invalidate()
		timer = nil
	}

	override func mouseExited(at point: CGPoint, underNotch: Bool) {
		guard let parentLayer = parentLayer else { return }

		let yOffset = -bulbBounds.height

		CATransaction.begin()
		CATransaction.setCompletionBlock { [weak self] in
			self?.stopLights()
		}
		
		bulbLayers.forEach { bulbLayer in
			bulbLayer.position = CGPoint(x: bulbLayer.position.x, y: yOffset)

			let fromPosition: CGPoint
			if let position = bulbLayer.presentation()?.position {
				fromPosition = position
			}
			else {
				fromPosition = CGPoint(x: bulbLayer.position.x, y: parentLayer.bounds.midY)
			}

			let animation = CABasicAnimation(keyPath: "position")
			animation.fromValue = fromPosition
			animation.toValue = CGPoint(x: bulbLayer.position.x, y: -bulbBounds.height)
			animation.duration = 1
			animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
			bulbLayer.add(animation, forKey: "position")
		}
		
		CATransaction.commit()
	}

}
