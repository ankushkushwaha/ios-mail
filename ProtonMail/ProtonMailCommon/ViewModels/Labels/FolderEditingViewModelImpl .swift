//
//  FolderEditingViewModelImpl .swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 4/6/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import Foundation
// folder editing
final public class FolderEditingViewModelImple : LabelEditViewModel {
    var currentLabel : Label
    
    required public init(label : Label) {
        self.currentLabel = label
    }
    
     override public func title() -> String {
        return LocalString._labels_edit_folder_title
    }
    
    override public func placeHolder() -> String {
        return LocalString._labels_folder_name_text
    }
    
    override public func rightButtonText() -> String {
        return LocalString._general_update_action
    }
    
    override public func name() -> String {
        return currentLabel.name
    }
    
    override public func seletedIndex() -> IndexPath {
        let currentColor = currentLabel.color
        if let index = colors.index(of: currentColor) {
            return IndexPath(row: index, section: 0)
        } else {
            return super.seletedIndex()
        }
    }
    
    override public func apply(withName name: String, color: String, error: @escaping LabelEditViewModel.ErrorBlock, complete: @escaping LabelEditViewModel.OkBlock) {
        let api = UpdateLabelRequest<CreateLabelRequestResponse>(id: currentLabel.labelID, name: name, color: color)
        api.call { (task, response, hasError) -> Void in
            if hasError {
                error(response?.code ?? 1000, response?.errorMessage ?? "");
            } else {
                self.currentLabel.name = name
                self.currentLabel.color = color
                if let context = self.currentLabel.managedObjectContext {
                    context.perform {
                        let _ = context.saveUpstreamIfNeeded()
                    }
                }
                complete()
            }
        }
    }
}