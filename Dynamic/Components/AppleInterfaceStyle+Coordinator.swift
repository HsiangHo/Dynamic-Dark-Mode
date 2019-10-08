//
//  AppleInterfaceStyle+Coordinator.swift
//  Dynamic Dark Mode
//
//  Created by Apollo Zhu on 5/3/19.
//  Copyright © 2019 Dynamic Dark Mode. All rights reserved.
//

import Foundation

extension AppleInterfaceStyle {
    public static let Coordinator = AppleInterfaceStyleCoordinator()
}

/// This class coordinates between scheduler and screen brightness observer.
public class AppleInterfaceStyleCoordinator: NSObject {
    fileprivate override init() { super.init() }
    
    private var appearanceObservation: NSKeyValueObservation? {
        didSet {
            oldValue?.invalidate()
        }
    }
    
    @objc public func toggleInterfaceStyle() {
        AppleInterfaceStyle.toggle()
    }
    
    public func setup() {
        tearDown()
        appearanceObservation = NSApp.observe(\.effectiveAppearance) { _, _ in
            AppleInterfaceStyle.updateWallpaper()
        }
        guard preferences.scheduled else {
            guard preferences.adjustForBrightness else { return }
            // No need for scheduler, only enable brightness observer
            return ScreenBrightnessObserver.shared.startObserving()
        }
        Connectivity.default.scheduleWhenReconnected()
        Scheduler.shared.schedule(startBrightnessObserverOnFailure: true)
    }
    
    public func tearDown(stopAppearanceObservation: Bool = true) {
        Scheduler.shared.cancel()
        Connectivity.default.stopObserving()
        ScreenBrightnessObserver.shared.stopObserving()
        if stopAppearanceObservation {
            appearanceObservation = nil
        }
    }
}
