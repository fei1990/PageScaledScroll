//
//  ScaledViewProtocal.swift
//  PageScaledScrollView
//
//  Created by wangfei on 16/6/23.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import Foundation
import UIKit
@objc
protocol ScaledViewDataSource:NSObjectProtocol {
    
    func numbersOfPageInScaledView(scaledScrollView:ScaledScrollView) -> Int
    func pageViewInScrollView(scaledScrollView:ScaledScrollView, pageIndex:Int) -> UIView

}

@objc
protocol ScaledViewDelegate:NSObjectProtocol {
    
    optional
    func didSelectPageView(scaledScrollView:ScaledScrollView, pageIndex:Int)
    
}