//
//  TYTiledLayer.swift
//  oc2swiftDemo
//
//  Created by zhaotaoyuan on 2017/5/26.
//  Copyright © 2017年 DoMobile21. All rights reserved.
//

import CoreFoundation
import QuartzCore

private let kDefaultFadeDuration: CFTimeInterval = 0.08

class TYTiledLayer:  CATiledLayer{
    override class func fadeDuration() -> CFTimeInterval {
        return kDefaultFadeDuration
    }
}
