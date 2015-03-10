//
//  FullHeightWebView.swift
//  ProtonMail
//
//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import Foundation

class FullHeightWebView: UIWebView {
    
    private var kvoContext = 0
    private let scrollViewContentSizeKeyPath = "scrollView.contentSize"

    override init() {
        super.init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.scrollEnabled = true
        scrollView.alwaysBounceVertical = false
        
        addObserver(self, forKeyPath: scrollViewContentSizeKeyPath, options: .New, context: &kvoContext)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(self, forKeyPath: scrollViewContentSizeKeyPath, context: &kvoContext)
    }

    override func updateConstraints() {
        mas_updateConstraints { (make) -> Void in
            make.height.equalTo()(self.scrollView.contentSize.height)
            return
        }
        
        super.updateConstraints()
    }

    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &kvoContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        } else if object as FullHeightWebView == self && keyPath == scrollViewContentSizeKeyPath {
            setNeedsUpdateConstraints()
            layoutIfNeeded()
        }
    }
}
