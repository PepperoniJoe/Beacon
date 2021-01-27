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
            instanceCount = numPulse
            updateInstanceDelay()
        }
    }
    
    var radius: CGFloat = 60
    var animationDuration: TimeInterval = K.animationDuration
    
    //MARK: - Private Properties
    private var animationGroup: CAAnimationGroup!
    private var alpha: CGFloat = 0.45
    private let screenScale = UIScreen.main.scale
    private let applicationWillBecomeActiveNotfication = UIApplication.willEnterForegroundNotification
    private let applicationDidResignActiveNotification = UIApplication.didEnterBackgroundNotification
    private weak var prevSuperlayer: CALayer?
    private var prevLayerIndex: Int?
    private var animationCompletionBlock: (() -> ())?
    
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
    

    /// If this property is `true`, the instance will be automatically removed
    /// from the superview, when it finishes the animation.
    private var autoRemove = true
    
    /// fromValue for radius
    /// It must be smaller than 1.0
    private var fromValueForRadius: Float = 0.0 {
        didSet {
            if fromValueForRadius >= 1.0 {
                fromValueForRadius = 0.0
            }
          //  recreate()
        }
    }
    
    private var keyTimeForHalfOpacity: Float = 0.2
    private var pulseInterval: TimeInterval = 0
    
    /// A function describing a timing curve of the animation.
    private var timingFunction: CAMediaTimingFunction? = CAMediaTimingFunction(name: .default) {
        didSet {
            if let animationGroup = animationGroup {
                animationGroup.timingFunction = timingFunction
            }
        }
    }
    
    
    /// The value of this property showed a pulse is started
    private var isPulsating: Bool {
        guard let keys = pulse.animationKeys() else { return false }
        return keys.count > 0
    }
    
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        
        setupPulse()
        
        instanceDelay = 1
        repeatCount = MAXFLOAT
        backgroundColor = UIColor(named: K.defaultColor)?.cgColor
        
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
        prevLayerIndex = prevSuperlayer?.sublayers?.firstIndex(where: {$0 === self})
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
        /// division-by-zero check
        guard numPulse >= 1 else { fatalError() }
        instanceDelay = (animationDuration + pulseInterval) / Double(numPulse)
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
