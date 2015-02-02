//
//  NSManagedObjectContextExtension.swift
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

import CoreData
import Foundation

extension NSManagedObjectContext {
    func saveAndSaveParents(error: NSErrorPointer) -> Bool {
        var result = save(error)
        
        if result {
            if let parentContext = parentContext {
                parentContext.performBlockAndWait() { () -> Void in
                    result = parentContext.saveAndSaveParents(error)
                }
            }
        }
        
        return result
    }
}