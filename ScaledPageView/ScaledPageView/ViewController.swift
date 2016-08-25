//
//  ViewController.swift
//  ScaledPageView
//
//  Created by wangfei on 16/8/25.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController,ScaledViewDelegate,ScaledViewDataSource {
    
    
    var scrollViewOn:ScaledViewOn!
    var label:UILabel!
    var view1:UIView!
    var pageViewIndex:Int = 0 {
        willSet {
            label.text = "您选择了第\(newValue)个pageView"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        scrollViewOn = ScaledViewOn(frame: CGRect(x: 0, y: 100, width: CGRectGetWidth(self.view.frame), height: 150))
        scrollViewOn.scaledScrollView.scrollViewDataSource = self
        scrollViewOn.scaledScrollView.scrollViewDelegate = self
        self.view.addSubview(scrollViewOn)
        scrollViewOn.scaledScrollView.reloadData()
        
        subViewInit()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - ScaledViewDataSource
    func numbersOfPageInScaledView(scaledScrollView: ScaledScrollView) -> Int {
        return 16
    }
    func pageViewInScrollView(scaledScrollView: ScaledScrollView, pageIndex: Int) -> UIView {
        
        let view = SubContentView()
        view.backgroundColor = UIColor.greenColor()
        
        //        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        //        label.center = CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(view.frame)/2)
        //        label.textAlignment = .Center
        view.label!.text = "\(pageIndex)"
        //        view.addSubview(label)
        
        return view
    }
    
    //MARK: - ScaledViewDelegate
    func didSelectPageView(scaledScrollView: ScaledScrollView, pageIndex: Int) {
        print("pageIndex : \(pageIndex)")
        
        self.pageViewIndex = pageIndex
        
    }
    
    func subViewInit() {
        
        view1 = UIView()
        view1.backgroundColor = UIColor.blueColor()
        self.view.addSubview(view1)
        
        label = UILabel()
        label.backgroundColor = UIColor.cyanColor()
        label.textAlignment = .Center
        view1.addSubview(label)
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        view1.snp_makeConstraints { (make) in
            
            make.top.equalTo(scrollViewOn.snp_bottom).offset(10)
            make.left.equalTo(self.view.snp_left).offset(10)
            make.height.equalTo(50)
            make.right.equalTo(self.view.snp_right).offset(-10.0)
            
            
        }
        
        
        label.snp_makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(35)
            make.center.equalTo(CGPointMake(CGRectGetWidth(view1.frame)/2, CGRectGetHeight(view1.frame)/2))
        }
        
    }
    
}

