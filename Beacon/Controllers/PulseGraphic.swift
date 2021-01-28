//
//  PulseGraphic.swift
//  Beacon
//
//  Based on Pulsator by Shuichi Tsutsumi, Tokyo Japan

import UIKit
    
class PulseGraphic: CAReplicatorLayer {
    
    let pulse = CALayer()
    
    var numPulse: Int = 1 {
        didSet {
            numPulse = numPulse < 1 ? 1 : numPulse
            instanceCount = numPulse
        }
    }
    
    var radius: CGFloat = 60
    var animationDuration: TimeInterval = 5
    
    override var backgroundColor: CGColor? {
        didSet {
            pulse.backgroundColor = backgroundColor
            guard let backgroundColor = backgroundColor else {return}
            alpha = backgroundColor.alpha
        }
    }
    
    override var repeatCount: Float {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.repeatCount = repeatCount
            }
        }
    }
    
    //MARK: - Private Properties
    private let pulseInterval: TimeInterval = 0
    private var animationGroup: CAAnimationGroup!
    private var alpha: CGFloat = 0.45
    private let screenScale = UIScreen.main.scale
    private let applicationWillBecomeActiveNotfication = UIApplication.willEnterForegroundNotification
    private let applicationDidResignActiveNotification = UIApplication.didEnterBackgroundNotification
    private weak var prevSuperlayer: CALayer?
    private var prevLayerIndex: Int?
    
    /// A function describing a timing curve of the animation.
//    private var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .default) {
//        didSet {
//            if let animationGroup = animationGroup {
//                animationGroup.timingFunction = timingFunction
//            }
//        }
//    }
    
    /// The value of this property showed a pulse is started
//    private var isPulsating: Bool {
//        guard let keys = pulse.animationKeys() else { return false }
//        return keys.count > 0
//    }
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        setupPulse()
        instanceDelay = 1
        repeatCount = MAXFLOAT
        
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
       super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func removeFromSuperlayer() {
        super.removeFromSuperlayer()
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func save() {
        prevSuperlayer = superlayer
        prevLayerIndex = prevSuperlayer?.sublayers?.firstIndex(where: { $0 === self })
    }

    
    @objc func resume() {

        if let prevSuperlayer = prevSuperlayer, let prevLayerIndex = prevLayerIndex {
            prevSuperlayer.insertSublayer(self, at: UInt32(prevLayerIndex))
        }
        
        if pulse.superlayer == nil {
            addSublayer(pulse)
        }

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
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue   = 1.0
        scaleAnimation.duration  = animationDuration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: K.opacity)
        opacityAnimation.duration = animationDuration
        opacityAnimation.values   = [alpha, alpha * 0.5, 0.0]
        opacityAnimation.keyTimes = [0.0, NSNumber(value: 0.1), 1.0]
        
        animationGroup = CAAnimationGroup()
        animationGroup.animations     = [scaleAnimation, opacityAnimation]
        animationGroup.duration       = animationDuration
        animationGroup.repeatCount    = repeatCount
        animationGroup.timingFunction = CAMediaTimingFunction(name : .default)
        
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
    
} // end of PulseGraphic


extension PulseGraphic: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if let keys = pulse.animationKeys(), keys.count > 0 {
            pulse.removeAllAnimations()
        }
        
        pulse.removeFromSuperlayer()
    }
}
