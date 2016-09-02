//
//  ViewController.swift
//  ScaledPageView
//
//  Created by wangfei on 16/8/25.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ScaledViewDelegate,ScaledViewDataSource {
    
    
    var scrollViewOn:ScaledViewOn!
    lazy private var table: UITableView = UITableView(frame: self.view.frame, style: .Plain)
    private var headerRefresh:HeaderRefresh = HeaderRefresh()
    var pageViewIndex:Int = 0 {
        willSet {
            self.title = "您选择了第\(newValue)个pageView"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "您选择了第0个pageView"
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor.init(colorLiteralRed: 249.0/255, green: 249.0/255, blue: 249.0/255, alpha: 1.0)
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(table)
        
        
        scrollViewOn = ScaledViewOn(frame: CGRect(x: 0, y: 100, width: CGRectGetWidth(self.view.frame), height: 200))
        scrollViewOn.scaledScrollView.scrollViewDataSource = self
        scrollViewOn.scaledScrollView.scrollViewDelegate = self
        table.tableHeaderView = scrollViewOn
        
        headerRefresh.handleScrollView(self.table) { [weak self] _ in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(UInt64(3) * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                self?.title = "您选择了第0个pageView"
                self?.scrollViewOn.scaledScrollView.reloadData()
                self?.headerRefresh.endLoading()
            })
        }
        
        
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
        view.backgroundColor = UIColor.cyanColor()
        view.label!.text = "\(pageIndex)"
        
        return view
    }
    
    //MARK: - ScaledViewDelegate
    func didSelectPageView(scaledScrollView: ScaledScrollView, pageIndex: Int) {
        print("pageIndex : \(pageIndex)")
        
        self.pageViewIndex = pageIndex
        
    }
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let nextVc = NextViewController()
        self.pushVC(nextVc)
    }
}

