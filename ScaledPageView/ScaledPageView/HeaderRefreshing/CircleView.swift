
//
//  CircleView.swift
//  HeaderRefreshing
//
//  Created by wangfei on 16/7/5.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit


class CircleView: UIView {
    
    var progress:CGFloat = 0 {
        willSet {
            self.progress = newValue
            self.setNeedsDisplay()
        }
    }
        /// 线宽颜色需要和tableView的背景色一致
    var lineColor:UIColor!
    
    private var lineWidth:CGFloat!
    
    private var startAngle:CGFloat!
    
    deinit {
        print("\(#function) in \(#file)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.lineWidth = 5.0
        self.startAngle = 1.5 * CGFloat(M_PI)
//        self.lineColor = UIColor.init(colorLiteralRed: 249.0/255, green: 249.0/255, blue: 249.0/255, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context!, self.lineWidth);
        CGContextSetLineCap(context!, .Butt);
        
        CGContextSetStrokeColorWithColor(context!, self.lineColor.CGColor);
        let step = self.progress * CGFloat(M_PI)
        CGContextAddArc(context!, rect.size.width/2, rect.size.height/2, rect.size.width/2 - 2, startAngle, startAngle + 2 * CGFloat(M_PI) - step, 0);
        
        CGContextStrokePath(context!);
        
    }
}
