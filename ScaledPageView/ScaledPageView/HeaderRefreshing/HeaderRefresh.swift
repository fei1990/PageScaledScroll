//
//  HeaderRefresh.swift
//  HeaderRefreshing
//
//  Created by wangfei on 16/7/5.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import Foundation
import UIKit
enum RefreshState {
    case Normal
    case Pulling
    case Refreshing
}

private let maxPullOffset:CGFloat = 75.0

typealias RefreshCallback = () ->()

public class HeaderRefresh:NSObject {
    
    private var onceToken: dispatch_once_t = 0
    
    private var tableView:UITableView!
    
    private var tableBkgView:RefreshTableBkgView!
    
    private var refreshState:RefreshState = .Normal {
        willSet {
            switch newValue {
            case .Normal,.Pulling:
                self.tableBkgView.refreshingMsg = NSLocalizedString("下拉刷新", comment: "")
            case .Refreshing:
                self.tableBkgView.refreshingMsg = NSLocalizedString("释放开始刷新", comment: "")
            }
        }
    }
    
        /// 是否正在加载
    public var  isLoading:Bool = false
    
    
    /// 是否下拉到规定的最大偏移
    private var isDragingToMaxOffset = false
    
    private var callback:RefreshCallback!
    
    /// 默认top偏移量
    private var defaultTableInsetTop:CGFloat = 0.0
    
    private var defaultTableInsetBottom: CGFloat = 0.0
    
    override init() {
        super.init()
        tableBkgView = RefreshTableBkgView()
    }
    
    deinit {
        self.tableView.removeObserver(self, forKeyPath: "contentOffset")
        self.tableView.removeObserver(self, forKeyPath: "contentInset")
        self.callback = nil
    }
    
    ///根据view反向寻找controller
    func viewController(view:UIView)->UIViewController?{
        var next:UIView? = view
        repeat{
            if let nextResponder = next?.nextResponder() where nextResponder.isKindOfClass(UIViewController.self){
                return (nextResponder as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
    }
    
    /**
     注意 需要传入tableView的bkgColor
     
     - parameter tableView:         刷新控件要添加到的View
     - parameter tableViewBkgColor: tableView的bkgColor
     - parameter callBack:          刷新完成回调
     */
    func handleScrollView(tableView:UITableView, tableViewBkgColor:UIColor, callBack:()->()) {
        
        tableBkgView.circleView.lineColor = tableViewBkgColor
        
        handleScrollView(tableView, callBack: callBack)
    }
    
    /**
     对tableView添加刷新控件
     
     - parameter tableView: 刷新控件要添加到的view
     - parameter callBack:  刷新完成回调
     */
    func handleScrollView(tableView:UITableView, callBack:()->()) {
        
        self.callback = callBack
        
        self.tableView = tableView
        tableBkgView.circleView.lineColor = tableView.backgroundColor
        tableBkgView.bkgTopView.backgroundColor = tableView.backgroundColor
        
        tableBkgView.frame = self.tableView.frame
        self.tableView.backgroundView = tableBkgView
        
        self.tableView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        self.tableView.addObserver(self, forKeyPath: "contentInset", options: .New, context: nil)

    }
    
    /**
     重置一次bkgView的子视图的frame
     
     - parameter top:    默认top inset
     - parameter bottom: 默认bottom inset
     */
    private func resetBkgFrameOnce(top:CGFloat, withInsetBottom bottom: CGFloat) {
//        dispatch_once(&onceToken) {
            self.defaultTableInsetTop = top
            self.defaultTableInsetBottom = bottom
            self.tableBkgView.resetFrame(withContentInsetTop: top)
//        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if keyPath == "contentInset" {
            guard !isDragingToMaxOffset else {
                return
            }
            resetBkgFrameOnce(self.tableView.contentInset.top, withInsetBottom: self.tableView.contentInset.bottom)
        }
        
        let offsetY = -self.tableView.contentOffset.y - self.defaultTableInsetTop
        
        if offsetY >= 1.0 {
            tableBkgView.bkgTopView.hidden = true
        }else if offsetY < 0{
            tableBkgView.bkgTopView.hidden = false
        }
        
        if isLoading {
            return
        }

        if keyPath == "contentOffset" {
            //for test (offsetY - circleViewTopY) / ((self.defaultTableInsetTop - circleViewTopY * 2 - 4))
            let progress =  abs((offsetY - circleViewTopY) / (maxPullOffset - circleViewTopY) * 2)
            if offsetY <= circleViewTopY {   //下拉到开始绘制image的offset之前状态
                self.refreshState = .Normal
            }
            if offsetY > circleViewTopY && offsetY < maxPullOffset {   //下拉绘制loading状态的image
                if self.refreshState == .Refreshing {
                    
                }else {
                    self.refreshState = RefreshState.Pulling
                }
            }else if offsetY >= maxPullOffset {  //下拉到最大偏移量时 转为松手开始刷新
                
                self.refreshState = .Refreshing
            }
            refreshStateChanged(progress, isDraging: self.tableView.dragging)
        }
    }
    
    
    private func refreshStateChanged(progress:CGFloat, isDraging:Bool) {
        
        if self.refreshState == .Normal {
            self.tableView.contentInset.top = self.defaultTableInsetTop
            self.tableView.contentInset.bottom = self.defaultTableInsetBottom
            return
        }else if self.refreshState == .Pulling {
            self.tableBkgView.imgView.layer.transform = CATransform3DIdentity
            self.tableBkgView.circleView.hidden = false
            self.tableBkgView.circleView.progress = progress
        }else if self.refreshState == .Refreshing {
            if isDraging {   //拖动时转动
                isDragingToMaxOffset = true  //不在修改contentinset 的 top
                if progress < 2.0 {
                    self.refreshState = .Pulling
                }else {
                    self.tableBkgView.circleView.hidden = true
                    self.tableBkgView.circleViewRotate(progress)
                }
            }else {   //松手后转动并开始刷新
                UIView.animateWithDuration(0.5, delay: 0, options: .TransitionNone, animations: {
                    self.tableBkgView.refreshingMsg = NSLocalizedString("正在刷新...", comment: "")
                    self.tableBkgView.circleView.hidden = true
                    self.tableView.contentInset = UIEdgeInsetsMake(self.defaultTableInsetTop + maxPullOffset, 0, self.defaultTableInsetBottom, 0)
                    }, completion: { (finished) in
                        if self.isLoading == false {
                            self.startLoading()
                        }
                })
            }
        }
    }
    
    /**
     开始加载
     */
    private func startLoading() {
        self.isLoading = true
        self.tableBkgView.startAnimation()
        callback?()
    }
    
    /**
     结束加载
     */
    func endLoading() {
        self.refreshState = .Normal
        UIView.animateWithDuration(0.5, delay: 0, options: .TransitionNone, animations: {
            var inset = self.tableView.contentInset
            inset = UIEdgeInsetsMake(inset.top - maxPullOffset, 0, self.defaultTableInsetBottom, 0)
            self.tableView.contentInset = inset
            }) { (finished) in
                UIView.animateWithDuration(0, animations: {
                    self.tableBkgView.endAnimation()
                    }, completion: { (finished) in
                        self.isLoading = false
                })
        }
    }
}
