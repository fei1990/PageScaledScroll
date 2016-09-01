//
//  RefreshTableBkgView.swift
//  zolShop
//
//  Created by wangfei on 16/7/5.
//  Copyright © 2016年 zol. All rights reserved.
//

import UIKit

private let subImageViewSize:CGFloat = 13.0
private let circleViewSize:CGFloat = 30.0
private let stateLblSize:CGFloat = 12.0
let circleViewTopY:CGFloat = 10.0
private let stateLblTopY:CGFloat = 11.0
public extension CGFloat {
    
    public func toRadians() -> CGFloat {
        return (self * CGFloat(M_PI)) / 180.0
    }
    
    public func toDegrees() -> CGFloat {
        return self * 180.0 / CGFloat(M_PI)
    }
    
}

class RefreshTableBkgView: UIView {
    
    lazy var identityTransform: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(0.0).toRadians(), 0.0, 0.0, 1.0)
        return transform
    }()
    
    var circleView:CircleView!
    
        /// circle image
    var imgView:UIImageView!
    
        /// 不做动画的image
    private var subImgView:UIImageView!
    
        /// 用于遮盖loading图和显示文字
    internal let bkgTopView:UIView = {
        let view = UIView()
        view.hidden = false
        return view
    }()
    
    private let stateLbl:UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12.0)
        label.textColor = UIColor(colorLiteralRed: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0)
        label.backgroundColor = UIColor.clearColor()
        return label
    }()
    
        /// 下拉到最大偏移量后更改提示语
    var refreshingMsg:String = "" {
        willSet {
            self.stateLbl.text = "\(newValue)"
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        imgView = UIImageView(image: UIImage(named: NSBundle.mainBundle().pathForResource("HeaderLoadingBundle.bundle/Resources/loading_counterclockwise", ofType: "tiff")!))
        subImgView = UIImageView(image: UIImage(named: NSBundle.mainBundle().pathForResource("HeaderLoadingBundle.bundle/Resources/zol_icon", ofType: "tiff")!))
        circleView = CircleView()
        self.addSubview(imgView)
        self.addSubview(circleView)
        self.addSubview(stateLbl)
        self.addSubview(subImgView)
        addSubview(bkgTopView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RefreshTableBkgView.enterForegroundNotification(_:)), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RefreshTableBkgView.enterBackgroundNotification(_:)), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     根据tableview的默认insetTop 设置本身及其subView的frame
     
     - parameter top: tableView的默认insetTop
     */
    internal func resetFrame(withContentInsetTop top:CGFloat) {
        self.frame = CGRectMake(0, top, CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds))
        
        bkgTopView.frame = CGRectMake(0, top, CGRectGetWidth(UIScreen.mainScreen().bounds), 200)
        
        circleView.frame = CGRectMake(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - circleViewSize/2, top + circleViewTopY, circleViewSize, circleViewSize)
        
        imgView.frame = circleView.frame
        
        subImgView.frame = CGRectMake(0, 0, subImageViewSize, subImageViewSize)
        subImgView.center = imgView.center
        
        stateLbl.frame = CGRectMake(0, CGRectGetMaxY(circleView.frame) + stateLblTopY, CGRectGetWidth(UIScreen.mainScreen().bounds), stateLblSize)
    }
    
    /**
     绘制完整个image时 继续拖动时  随着拖动转
     
     - parameter rotate: 旋转的比例
     */
    internal func circleViewRotate(rotate:CGFloat) {
        let degree = -abs((rotate - 2))
        self.imgView.layer.transform = CATransform3DRotate(identityTransform, degree*CGFloat(M_PI), 0.0, 0.0, 1.0)
    }
    
    private func currentDegree() -> CGFloat {
        return self.imgView.layer.valueForKeyPath("transform.rotation.z") as! CGFloat
    }
    
    /**
     启动动画
     */
    func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = currentDegree()
        animation.toValue = CGFloat(2.0 * M_PI) + currentDegree()
        animation.duration = 0.5
        animation.repeatCount = MAXFLOAT//Float.infinity
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.imgView.layer.addAnimation(animation, forKey: "circleImgAnimationKey")
        
    }
    
    /**
     结束动画
     */
    func endAnimation() {
        self.imgView.layer.removeAnimationForKey("circleImgAnimationKey")
        self.imgView.layer.transform = CATransform3DIdentity
        self.circleView.hidden = false
        self.bkgTopView.hidden = false
    }
    
    private func pauseLayer(layer: CALayer) {
        let pausedTime =  layer.convertTime(CACurrentMediaTime(), fromLayer: nil)// [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    private func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime;
        layer.beginTime = timeSincePause;
    }
    
    
    func enterForegroundNotification(notification:NSNotification) {
//        resumeLayer(self.imgView.layer)
    }
    
    func enterBackgroundNotification(notifcation:NSNotification) {
//        pauseLayer(self.imgView.layer)
    }
    
}
