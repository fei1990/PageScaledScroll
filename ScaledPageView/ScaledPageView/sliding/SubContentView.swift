//
//  SubContentView.swift
//  PageScaledScrollView
//
//  Created by wangfei on 16/6/27.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit
import SnapKit

class SubContentView: UIView {

    var label:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        label?.backgroundColor = UIColor.yellowColor()
        label!.textAlignment = .Center
        self.addSubview(label!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
         super.updateConstraints()
        
        label?.snp_makeConstraints(closure: { (make) in
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.center.equalTo(CGPointMake(CGRectGetWidth(self.frame) * self.transform.tx/2, CGRectGetHeight(self.frame) * self.transform.ty/2))
//            make.center.equalTo(self.snp_center)
        })
        
    }

}
