//
//  TYTiledScrollView.swift
//  oc2swiftDemo
//
//  Created by zhaotaoyuan on 2017/5/26.
//  Copyright © 2017年 DoMobile21. All rights reserved.
//


import CoreGraphics
import UIKit

protocol TYTileSource: NSObjectProtocol {
    func tiledScrollView(_ scrollView: TYTiledScrollView, imageForRow row: Int, column: Int, scale: Int) -> UIImage
}

protocol TYTiledScrollViewDelegate: NSObjectProtocol {
    func tiledScrollViewDidZoom(_ scrollView: TYTiledScrollView)
    
    func tiledScrollViewDidScroll(_ scrollView: TYTiledScrollView)
}

class TYTiledScrollView: UIView,UIScrollViewDelegate,TYTiledViewDelegate{
    //Delegates
    
    weak var tiledScrollViewDelegate: TYTiledScrollViewDelegate?
    weak var dataSource: TYTileSource?
    //internals
    var tiledView: TYTiledView
    var scrollView: UIScrollView
    class func tiledLayerClass() -> AnyClass {
        return TYTiledView.self
    }
    var levelsOfZoom: size_t
    
    
    init(frame: CGRect, contentSize: CGSize) {
        self.scrollView = UIScrollView(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.scrollView.backgroundColor = UIColor.white
        self.scrollView.contentSize = contentSize
        self.scrollView.bouncesZoom = true
        self.scrollView.bounces = true
        self.scrollView.minimumZoomScale = 1.0
        self.levelsOfZoom = 2
        self.tiledView = TYTiledView.init(frame: CGRect.zero)
        super.init(frame: frame)

        self.tiledView.delegate = self as TYTiledViewDelegate
        self.scrollView.delegate = self
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.scrollView.addSubview(tiledView)
        addSubview(scrollView)
        scrollView.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIScrolViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         return tiledView
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //设置TileView的中心始终在scrollview中心
        var xcenter: CGFloat = scrollView.center.x
        var ycenter: CGFloat = scrollView.center.y
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width / 2 : xcenter
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height / 2 : ycenter
        tiledView.center = CGPoint(x: xcenter, y: ycenter)
        if tiledScrollViewDelegate == nil {
            return
        }
        if (tiledScrollViewDelegate?.responds(to: #selector(self.scrollViewDidZoom)))! {
            tiledScrollViewDelegate?.tiledScrollViewDidZoom(self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tiledScrollViewDelegate == nil
        {
            return
        }
        if (tiledScrollViewDelegate?.responds(to: #selector(self.scrollViewDidScroll)))! {
            tiledScrollViewDelegate?.tiledScrollViewDidScroll(self)
        }
    }
    
    // MARK: - TYTiledScrollView
    var zoomScale: Float {
        get {
            return self.zoomScale
        }
        set {
            setZoomScale(newValue, animated: false)
        }
    }
    
//    func zoomScale() -> Float {
//        return Float(scrollView.zoomScale)
//    }
//    
//    func setZoomScale(_ zoomScale: Float) {
//        setZoomScale(zoomScale, animated: false)
//    }
    
    
//    func setLevelsOfZoom(_ levelsOfZoom: size_t) {
//        self.levelsOfZoom = levelsOfZoom
//        scrollView.maximumZoomScale = Float(powf(2.0, max(0.0, levelsOfZoom)))
//    }
    
    
    func pushLevelsOfZoom(levels:size_t) {
        levelsOfZoom = levels
        scrollView.maximumZoomScale = CGFloat(Float(powf(2.0, Float(max(0.0, Double(levels))))))
    }
    
    
    
    func setZoomScale(_ zoomScale: Float, animated: Bool) {
        scrollView.setZoomScale(CGFloat(zoomScale), animated: animated)
    }
    
    func setLevelsOfDetail(_ levelsOfDetail: size_t) {
        tiledView.numberOfZoomLevels = levelsOfDetail
    }
    
    func setContentCenter(_ center: CGPoint, animated: Bool) {
        var new_contentOffset: CGPoint = scrollView.contentOffset
        if scrollView.contentSize.width > scrollView.bounds.size.width {
            new_contentOffset.x = max(0.0, (center.x * scrollView.zoomScale) - (scrollView.bounds.size.width / 2.0))
            new_contentOffset.x = min(new_contentOffset.x, (scrollView.contentSize.width - scrollView.bounds.size.width))
        }
        if scrollView.contentSize.height > scrollView.bounds.size.height {
            new_contentOffset.y = max(0.0, (center.y * scrollView.zoomScale) - (scrollView.bounds.size.height / 2.0))
            new_contentOffset.y = min(new_contentOffset.y, (scrollView.contentSize.height - scrollView.bounds.size.height))
        }
        scrollView.setContentOffset(new_contentOffset, animated: animated)
    }
    
    // MARK: - TYTileSource
    func tiledView(_ tiledView: TYTiledView, imageForRow row: Int, column: Int, scale: Int) -> UIImage {
        return dataSource!.tiledScrollView(self, imageForRow: row, column: column, scale: scale)
    }
    
}

//#define kStandardUIScrollViewAnimationTime (int64_t)0.10
