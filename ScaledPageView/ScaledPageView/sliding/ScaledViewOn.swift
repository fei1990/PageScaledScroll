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
        self.backgroundColor = UIColor.whiteColor()
        scaledScrollView = ScaledScrollView(frame: CGRectZero)
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
    
    override func updateConstraints() {
        self.scaledScrollView.snp_makeConstraints { (make) in
            make.left.equalTo(self.snp_left).offset(60)
            make.top.equalTo(self.snp_top).offset(0)
            make.bottom.equalTo(self.snp_bottom).offset(0)
            make.right.equalTo(self.snp_right).offset(-60)
        }
        
        super.updateConstraints()
    }

    override func layoutSubviews() {
        scaledScrollView.frame = CGRectMake(60, 0, CGRectGetWidth(self.frame) - 120, CGRectGetHeight(self.frame))
        scaledScrollView.reloadData()
        super.layoutSubviews()
    }
    
}
