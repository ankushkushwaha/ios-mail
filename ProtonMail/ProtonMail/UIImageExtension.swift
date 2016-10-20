//
//  UIImageExtension.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 8/14/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation


extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillRect(context, rect)
        }//TODO:: need add throw errors when else
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
