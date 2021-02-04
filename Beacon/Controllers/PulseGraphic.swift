//
//  PulseGraphic.swift
//  Beacon
//
//  Based on Pulsator by Shuichi Tsutsumi, Tokyo Japan

import UIKit
    
class PulseGraphic: CAReplicatorLayer {
    
    let pulse = CALayer()
  
    override var backgroundColor: CGColor? {
        didSet {
            pulse.backgroundColor = backgroundColor
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
    private var animationGroup      : CAAnimationGroup!
    private weak var prevSuperlayer : CALayer?
    private var prevLayerIndex      : Int?
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        setupPulse()
        backgroundColor = UIColor(named : K.defaultColor)?.cgColor
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(save),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resume),
                                               name: UIApplication.willEnterForegroundNotification,
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
        instanceDelay       = K.instanceDelay
        repeatCount         = K.repeatMax
        instanceCount       = K.numPulse
        pulse.contentsScale = UIScreen.main.scale
        pulse.opacity       = 0
        addSublayer(pulse)
        updatePulse()
    }
    
    private func setupAnimationGroup() {
        let scaleAnimation = CABasicAnimation(keyPath: K.scaleXY)
        scaleAnimation.fromValue = K.scaleAnimationFrom
        scaleAnimation.toValue   = K.scaleAnimationTo
        scaleAnimation.duration  = K.animationDuration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: K.opacity)
        opacityAnimation.duration = K.animationDuration
        opacityAnimation.values   = [K.alpha, K.alpha * 0.5, 0.0]
        opacityAnimation.keyTimes = K.keyValues
        
        animationGroup = CAAnimationGroup()
        animationGroup.animations     = [scaleAnimation, opacityAnimation]
        animationGroup.duration       = K.animationDuration
        animationGroup.repeatCount    = repeatCount
        animationGroup.timingFunction = CAMediaTimingFunction(name : .default)
        animationGroup.delegate       = self
    }
    
    private func updatePulse() {
        let diameter: CGFloat = K.radius * 2
        pulse.bounds          = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        pulse.cornerRadius    = K.radius
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
