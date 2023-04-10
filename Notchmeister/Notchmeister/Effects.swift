//
//	Effects.swift
//  Notchmeister
//
//  Created by Craig Hockenberry on 11/30/21.
//

import AppKit
import QuartzCore

enum Effects: Int, CaseIterable {
	case glow
	case cylon
	case plasma
	case festive
	case radar
#if DEBUG
	case portal
#endif
	case expando

	func displayName() -> String {
		switch self {
		case .glow:
			return "Glow"
		case .cylon:
			return "Cylon"
		case .plasma:
			return "Plasma Leak"
		case .festive:
			return "Festive"
		case .radar:
			return "Nano Radar"
#if DEBUG
		case .portal:
			return "Portal"
#endif
		case .expando:
			return "Expando"
		}
	}
	
	func displayDescription() -> String {
		switch self {
		case .glow:
			return "A cursor will light your way.\n\n⚠️ Works best in Dark Mode."
		case .cylon:
			return "By your command.\n\nAnd don‘t get too close."
		case .plasma:
			return "WARNING: Your mouse can break down the magnetic containment field that keeps Apple Silicon's power in check!"
		case .festive:
			return "Let your Mac celebrate the holidays the best way it can—in binary.\n\n01101100 01101111 01101100"
		case .radar:
			return "Notchmeister’s patented Nano Radar lets you know exactly where your mouse has gone."
#if DEBUG
		case .portal:
			return "Activate Macintosh Interdimensional Computation Extension (MICE)."
#endif
		case .expando:
			return "Bigger is better, right?"
		}
	}

	func notchEffect(with parentLayer: CALayer, in parentView: NSView) -> NotchEffect {
		switch self {
		case .glow:
			return GlowEffect(with: parentLayer, in: parentView)
		case .cylon:
			return CylonEffect(with: parentLayer, in: parentView)
		case .plasma:
			return PlasmaEffect(with: parentLayer, in: parentView)
		case .festive:
			return FestiveEffect(with: parentLayer, in: parentView)
		case .radar:
			return RadarEffect(with: parentLayer, in: parentView)
#if DEBUG
		case .portal:
			return PortalEffect(with: parentLayer, in: parentView)
#endif
		case .expando:
			return ExpandoEffect(with: parentLayer, in: parentView)
		}
	}
	
}
