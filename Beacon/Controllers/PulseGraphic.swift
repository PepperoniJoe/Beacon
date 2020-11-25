//
//  PulseGraphic.swift
//  Beacon
//
//  Created by Marcy Vernon on 11/21/20.
//  Copyright © 2020 Marcy Vernon. All rights reserved.
//

import UIKit
import QuartzCore
    
class PulseGraphic: CAReplicatorLayer {
    
    let pulse = CALayer()
    var animationGroup: CAAnimationGroup!
    var alpha: CGFloat = 0.45
    
    private let screenScale = UIScreen.main.scale
    private let applicationWillBecomeActiveNotfication = UIApplication.willEnterForegroundNotification
    private let applicationDidResignActiveNotification = UIApplication.didEnterBackgroundNotification
    /// private properties for resuming
    private weak var prevSuperlayer: CALayer?
    private var prevLayerIndex: Int?

    override var backgroundColor: CGColor? {
        didSet {
            pulse.backgroundColor = backgroundColor
            guard let backgroundColor = backgroundColor else {return}
            let oldAlpha = alpha
            alpha = backgroundColor.alpha
            if alpha != oldAlpha {
                recreate()
            }
        }
    }
    
    
    override var repeatCount: Float {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.repeatCount = repeatCount
            }
        }
    }
    
    
    var animationCompletionBlock: (()->Void)?
    
    /// The number of pulse.
    var numPulse: Int = 1 {
        didSet {
            if numPulse < 1 {
                numPulse = 1
            }
            instanceCount = numPulse
            updateInstanceDelay()
        }
    }
    
    ///    The radius of pulse.
    var radius: CGFloat = 60 {
        didSet {
            updatePulse()
        }
    }
    
    /// The animation duration in seconds.
    var animationDuration: TimeInterval = 3 {
        didSet {
            updateInstanceDelay()
        }
    }
    
    /// If this property is `true`, the instanse will be automatically removed
    /// from the superview, when it finishes the animation.
    var autoRemove = false
    
    /// fromValue for radius
    /// It must be smaller than 1.0
    var fromValueForRadius: Float = 0.0 {
        didSet {
            if fromValueForRadius >= 1.0 {
                fromValueForRadius = 0.0
            }
            recreate()
        }
    }
    
    /// The value of this property should be ranging from @c 0 to @c 1 (exclusive).
    var keyTimeForHalfOpacity: Float = 0.2 {
        didSet {
            recreate()
        }
    }
    
    /// The animation interval in seconds.
    var pulseInterval: TimeInterval = 0
    
    /// A function describing a timing curve of the animation.
    var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .default) {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.timingFunction = timingFunction
            }
        }
    }
    
    
    /// The value of this property showed a pulse is started
    var isPulsating: Bool {
        guard let keys = pulse.animationKeys() else { return false }
        return keys.count > 0
    }
    
    
    // MARK: - Initializer
    override init() {
        super.init()
        
        setupPulse()
        
        instanceDelay = 1
        repeatCount = MAXFLOAT
        backgroundColor = K.backgroundColor
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(save),
                                               name: applicationDidResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resume),
                                               name: applicationWillBecomeActiveNotfication,
                                               object: nil)
    }
    
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func save() {
        prevSuperlayer = superlayer
        prevLayerIndex = prevSuperlayer?.sublayers?.firstIndex(where: {$0 === self})
    }

    
    @objc func resume() {
        
        if let prevSuperlayer = prevSuperlayer, let prevLayerIndex = prevLayerIndex {
            prevSuperlayer.insertSublayer(self, at: UInt32(prevLayerIndex))
        }
        
        if pulse.superlayer == nil {
            addSublayer(pulse)
        }
        
//        let isAnimating = pulse.animation(forKey: K.pulseAnimationKey) != nil

        if let animationGroup = animationGroup, pulse.isAnimating() == false {
            pulse.add(animationGroup, forKey: K.pulseAnimationKey)
        }
    }
    
    
    /// Start the animation.
    func start() {
        
        guard pulse.isAnimating() == false else { return }
        
        setupPulse()
        setupAnimationGroup()
        pulse.add(animationGroup, forKey: K.pulseAnimationKey)
    }
    
    
    /// Stop the animation.
    func stop() {
        pulse.removeAllAnimations()
        animationGroup = nil
    }
    
    
    // MARK: - Private Methods
    private func setupPulse() {
        pulse.contentsScale = screenScale
        pulse.opacity = 0
        addSublayer(pulse)
        updatePulse()
    }
    
    
    private func setupAnimationGroup() {
        let scaleAnimation = CABasicAnimation(keyPath: K.scaleXY)
        scaleAnimation.fromValue = fromValueForRadius
        scaleAnimation.toValue   = 1.0
        scaleAnimation.duration  = animationDuration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: K.opacity)
        opacityAnimation.duration = animationDuration
        opacityAnimation.values   = [alpha, alpha * 0.5, 0.0]
        opacityAnimation.keyTimes = [0.0, NSNumber(value: keyTimeForHalfOpacity), 1.0]
        
        animationGroup = CAAnimationGroup()
        animationGroup.animations  = [scaleAnimation, opacityAnimation]
        animationGroup.duration    = animationDuration + pulseInterval
        animationGroup.repeatCount = repeatCount
        if let timingFunction = timingFunction {
            animationGroup.timingFunction = timingFunction
        }
        animationGroup.delegate = self
    }
    
    
    private func updatePulse() {
        
        let diameter: CGFloat = radius * 2
       
        pulse.bounds = CGRect(
            origin: CGPoint.zero,
            size: CGSize(width: diameter, height: diameter))
        pulse.cornerRadius = radius
        pulse.backgroundColor = backgroundColor
    }
    
    
    private func updateInstanceDelay() {
        guard numPulse >= 1 else { fatalError() }
        instanceDelay = (animationDuration + pulseInterval) / Double(numPulse)
    }
    
    
    private func recreate() {
        guard animationGroup != nil else { return }
        
        stop()
        
        let when = DispatchTime.now() + Double(Int64(0.2 * double_t(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: when) { () -> Void in
            self.start()
        }
    }


    
} // end of PulseGraphic


extension PulseGraphic: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let keys = pulse.animationKeys(), keys.count > 0 {
            pulse.removeAllAnimations()
        }
        
        pulse.removeFromSuperlayer()
        
        if autoRemove {
            removeFromSuperlayer()
        }
        
        animationCompletionBlock?()
    }
}
