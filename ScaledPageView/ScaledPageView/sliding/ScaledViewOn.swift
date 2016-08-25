//
//  ScaledViewOn.swift
//  PageScaledScrollView
//
//  Created by wangfei on 16/6/23.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit

class ScaledViewOn: UIView {

    var scaledScrollView:ScaledScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.redColor()
        scaledScrollView = ScaledScrollView(frame: CGRectMake(0,0,270,140))
        scaledScrollView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2)
        self.addSubview(scaledScrollView)
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if point.y >= 0 && point.y <=  CGRectGetHeight(self.frame) {
            if !CGRectContainsPoint(scaledScrollView.frame, point) {
                return scaledScrollView
            }
        }
        return super.hitTest(point, withEvent: event)
    }

}
