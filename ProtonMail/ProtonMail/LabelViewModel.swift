//
//  LabelViewModel.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 8/17/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation
import CoreData

class LabelMessageModel {
    public var label : Label!
    public var totalMessages : [Message] = []
    public var originalSelected : [Message] = []
    public var origStatus : Int = 0
    public var currentStatus : Int = 0
}

class LabelViewModel {
    
    public typealias OkBlock = () -> Void
    public typealias ErrorBlock = (_ code : Int, _ errorMessage : String) -> Void
    
    public init() {
        
    }
    
    func getFetchType() -> LabelFetchType {
        fatalError("This method must be overridden")
    }
    
    func apply (archiveMessage : Bool) -> Bool {
        fatalError("This method must be overridden")
    }
    
    func cancel () {
        fatalError("This method must be overridden")
    }
    
    func getLabelMessage(_ label : Label!) -> LabelMessageModel! {
        fatalError("This method must be overridden")
    }
    
    func cellClicked(_ label : Label!) {
        fatalError("This method must be overridden")
    }
    
    func singleSelectLabel() {
        
    }
    
    func getTitle() -> String {
        fatalError("This method must be overridden")
    }
    
    func showArchiveOption() -> Bool {
        fatalError("This method must be overridden")
    }
    
    func getApplyButtonText() -> String {
        fatalError("This method must be overridden")
    }
    
    func getCancelButtonText() -> String {
        fatalError("This method must be overridden")
    }
    
    func fetchController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        fatalError("This method must be overridden")
    }
}

