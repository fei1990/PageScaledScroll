//
//  ScaledScrollView.swift
//  PageScaledScrollView
//
//  Created by wangfei on 16/6/23.
//  Copyright © 2016年 fei.wang. All rights reserved.
//

import UIKit

let MAXSCALE_FACTOR = CGFloat(1.2)

class ScaledScrollView: UIScrollView {
    
    internal var scrollViewDataSource:ScaledViewDataSource!
    internal var scrollViewDelegate:ScaledViewDelegate!
    private var numsOfItems:Int = 0
    private var pageView:UIView!
    private var pageViewArr:Array<UIView>!
    private var currentPageView:UIView?  //当前屏幕中间显示的pageView
    private var nextSlidePageView:UIView? //下一个滑入屏幕中间的pageView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = UIColor.cyanColor()
        self.clipsToBounds = false
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceHorizontal = false
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.delegate = self
        self.addGestureRecognizer(self.tapGesture())
        pageViewArr = Array()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func reloadData() {
        
        numsOfItems = (scrollViewDataSource?.numbersOfPageInScaledView(self))!
        assert(numsOfItems > 0, "pageView的数量必须大于零")
        
        for i in 0...numsOfItems {
            
            if i == numsOfItems {
                pageView = scrollViewDataSource?.pageViewInScrollView(self, pageIndex: 0)
            }else {
                pageView = scrollViewDataSource?.pageViewInScrollView(self, pageIndex: i)
            }
            setPageViewFrameAndCenter(pageView: pageView, withIndex: i)
            pageViewArr.append(pageView)
            self.addSubview(pageView!)
        }
        
        pageView = scrollViewDataSource?.pageViewInScrollView(self, pageIndex: numsOfItems - 1)
        pageViewArr.insert(pageView, atIndex: 0)
        setPageViewFrameAndCenter(pageView: pageView, withIndex: -1)
        self.addSubview(pageView)
        self.contentSize = CGSize(width: scrollViewWidth * CGFloat(numsOfItems + 2), height: scrollViewHeight)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { 
            self.contentOffset = CGPointMake(self.scrollViewWidth, 0)
        }
        
    }

    func tapGesture() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ScaledScrollView.tappedAction(_:)))
        tap.numberOfTapsRequired = 1;
        return tap
    }

    func tappedAction(tap:UITapGestureRecognizer) {
        let point = tap.locationInView(tap.view)
        let convertPoint = tap.view?.convertPoint(point, toView: self.superview)  //转换point点

        let touchIndex:Int = touchPageViewIndexOfPoint(point.x)
        if selectedCenterPageViewOfConvertPoint(convertPoint!) {  //点击中间的cell
            let indexPath:Int = pageViewIndexOfPoint(touchPVIndex: CGFloat(touchIndex))
            scrollViewDelegate?.didSelectPageView?(self, pageIndex: indexPath)
        }
        
        if selectedLeftRightPageViewOfPoint(point, index: touchIndex) {  //点击两侧的cell
            self.setContentOffset(CGPointMake(scrollViewWidth * CGFloat(touchIndex), 0), animated: true)
        }

    }
    
    private func touchPageViewIndexOfPoint(pointX:CGFloat) ->Int {
        return Int(pointX / (pageViewWidth + leftRightMargin * 2))
    }
    
    private func pageViewIndexOfPoint(touchPVIndex tIndex:CGFloat) -> Int {
        let index = tIndex - 1
        if index < 0 {
            return numsOfItems - 1
        }
        if index == CGFloat(numsOfItems) {
            return 0
        }
        return Int(index)
    }
    
    private func selectedCenterPageViewOfConvertPoint(convertPoint:CGPoint) -> Bool {
        return (convertPoint.x >= (leftRightMargin + scrollViewX) && convertPoint.x <= (pageViewWidth + leftRightMargin + scrollViewX)) && (convertPoint.y >= (topBottomMargin + scrollViewY) && convertPoint.y <= (pageVieweHeight + topBottomMargin + scrollViewY))
    }
    
    private func selectedLeftRightPageViewOfPoint(point:CGPoint, index:Int) ->Bool {
        return point.x >= leftRightMargin + scrollViewWidth * CGFloat(index) && point.y >= topBottomMargin && point.y <= (topBottomMargin + pageVieweHeight)
    }
    
    private func setPageViewFrameAndCenter(pageView pageView:UIView, withIndex index:Int) {
        pageView.frame = CGRectMake(0, 0, 230, 100)
        pageView.center = CGPointMake(scrollViewWidth * (0.5 + CGFloat(index + 1)), scrollViewHeight/2)
        pageView.setNeedsUpdateConstraints()
    }
    
}


extension ScaledScrollView {
    
    private var pageViewWidth:CGFloat {
        get{
            return CGRectGetWidth(pageView.frame)
        }
    }
    
    private var pageVieweHeight:CGFloat {
        get{
            return CGRectGetHeight(pageView.frame)
        }
    }
    
    private var leftRightMargin:CGFloat {
        get{
            return (CGRectGetWidth(self.frame) - CGRectGetWidth(pageView.frame))/2
        }
    }
    private var topBottomMargin:CGFloat {
        get {
            return (CGRectGetHeight(self.frame) - CGRectGetHeight(pageView.frame))/2
        }
    }
    private var scrollViewWidth:CGFloat {
        get{
            return CGRectGetWidth(self.frame)
        }
    }
    private var scrollViewHeight:CGFloat {
        return CGRectGetHeight(self.frame)
    }
    private var scrollViewX:CGFloat {
        get{
            return CGRectGetMinX(self.frame)
        }
    }
    private var scrollViewY:CGFloat {
        get{
            return CGRectGetMinY(self.frame)
        }
    }
    
}

extension ScaledScrollView:UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        currentPageView?.transform = CGAffineTransformIdentity    //相当重要
        nextSlidePageView?.transform = CGAffineTransformIdentity  //相当重要
        
        let scale = scrollView.contentOffset.x/scrollViewWidth   //滑动时的缩放比例
        let indexOfPage = Int(scale)
        if Int(scrollView.contentOffset.x/scrollViewWidth) == numsOfItems + 1 {  //滑到最后一个
            scrollView.setContentOffset(CGPointMake(scrollViewWidth, 0), animated: false)
            nextSlidePageView = self.pageViewArr.first
            nextSlidePageView?.transform = CGAffineTransformIdentity
            return
        }
        if CGFloat(scrollView.contentOffset.x/scrollViewWidth) <= 0 {  //滑到第一个
            scrollView.setContentOffset(CGPointMake(scrollViewWidth * CGFloat(numsOfItems), 0), animated: false)
            nextSlidePageView = self.pageViewArr.last
            nextSlidePageView?.transform = CGAffineTransformIdentity
            return
        }
        
        if indexOfPage < self.pageViewArr.count - 1 {
            currentPageView = self.pageViewArr[indexOfPage]
            if indexOfPage < self.pageViewArr.count - 1 {
                nextSlidePageView = self.pageViewArr[indexOfPage + 1]
            }else {
                nextSlidePageView = self.pageViewArr[1]
            }
            
            currentPageView?.transform = CGAffineTransformMakeScale(MAXSCALE_FACTOR - (CGFloat(scale) - CGFloat(indexOfPage))/5, MAXSCALE_FACTOR - (CGFloat(scale) - CGFloat(indexOfPage))/5)
            nextSlidePageView?.transform = CGAffineTransformMakeScale(1 + (CGFloat(scale) - CGFloat(indexOfPage))/5, 1 + (CGFloat(scale) - CGFloat(indexOfPage))/5)
            
        }
        
    }
    
}
