//
//  TYTiledRender.swift
//  oc2swiftDemo
//
//  Created by zhaotaoyuan on 2017/5/26.
//  Copyright © 2017年 DoMobile21. All rights reserved.
//
import UIKit
import ImageIO
import CoreGraphics

class TYTiledRender: NSObject {
    class func rendImage(withImageSource path: String, show view: UIView) {
        // Do any additional setup after loading the view, typically from a nib.
        let scrollView_frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(view.bounds.size.width), height: CGFloat(view.bounds.size.height))
        //Bitmap
        let scrollView = TYTiledScrollView(frame: scrollView_frame, contentSize: CGSize(width: CGFloat(scrollView_frame.size.width), height: CGFloat(scrollView_frame.size.height)))
        
        //    scrollView.tiledScrollViewDelegate = self;
        scrollView.zoomScale = 1.0
        // totals 4 sets of tiles across all devices, retina devices will miss out on the first 1x set
        //初始化图像数据
        let url = URL(fileURLWithPath: path)
        let imageSource: CGImageSource? = CGImageSourceCreateWithURL((url as CFURL), nil)
        let cgSourceImage: CGImage = CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!
        scrollView.tiledView.cgSourceImage = cgSourceImage
        let imageWidth: Int = cgSourceImage.width
        let imageHeight: Int = cgSourceImage.height
        //向上取整
        let totalRow = Int(ceil(Double(imageHeight / 256)))+1
        let totalCol = Int(ceil(Double(imageWidth / 256)))+1
        //取切片应对用的填充区域的大小
        let blockWidth = Int(view.bounds.size.width / CGFloat(totalCol))
        let blockHeight = Int(view.bounds.size.height / CGFloat(totalRow))
        var minLength: Int = blockWidth < blockHeight ? blockWidth : blockHeight
        //取能被256整除的数字
        while 256%minLength != 0 {
            minLength = minLength-1;
        }
        //计算初始的放大倍数
        let beginScale = Float(Float(view.frame.size.width)/Float(minLength*totalCol))
        let blockSize = CGSize(width: CGFloat(minLength), height: CGFloat(minLength))
        
        //计算应显示的区域大小
        
        
        scrollView.tiledView.frame = CGRect(x: CGFloat((CGFloat(scrollView.bounds.size.width) -  CGFloat(minLength * totalCol)) / 2), y: CGFloat((scrollView.bounds.size.height - CGFloat(minLength * totalRow)) / 2), width: CGFloat(minLength * totalCol), height: CGFloat(minLength * totalRow))
        //计算最大放大倍数
        var renderSize: Int = minLength
        let realSize = 256
        
        var scale: Int = 0
        renderSize = renderSize << 1
        while renderSize < realSize {
            scale += 1
            renderSize = renderSize << 1
        }
        
        scrollView.tiledView.blockSize = blockSize
        scrollView.tiledView.totalCol = totalCol
        scrollView.tiledView.totalRow = totalRow
        scrollView.tiledView.lastColWidth = CGFloat(imageWidth - (totalCol - 1) * 256)
        scrollView.tiledView.lastRowHeight = CGFloat(imageHeight - (totalRow - 1) * 256)
        
        scrollView.pushLevelsOfZoom(levels: scale)
        scrollView.levelsOfZoom = scale
        scrollView.setLevelsOfDetail(scale)
        scrollView.contentMode = .center
        scrollView.backgroundColor = UIColor.black
        view.insertSubview(scrollView, at: 0)
        scrollView.setZoomScale(beginScale, animated: false)
    }
}
