//
//  APIService+SettingsExtension.swift
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

/// Settings extension
extension APIService {
    
    func settingUpdateDisplayName(displayName: String, completion: CompletionBlock) {
        let path = "/setting/display"
        let parameters = ["DisplayName" : displayName]
        
        PUT(path, parameters: parameters, completion: completion)
    }

    func settingUpdateMailboxPassword(newPassword: String, completion: CompletionBlock) {
        let path = "/setting/keypwd"
        // TODO: Add parameters for update mailbox password when defined in API
        let parameters = [:]

        PUT(path, parameters: parameters, completion: completion)
    }
    
    func settingUpdateNotificationEmail(notificationEmail: String, completion: CompletionBlock) {
        let path = "/setting/noticeemail"
        let parameters = ["NotificationEmail" : notificationEmail]

        PUT(path, parameters: parameters, completion: completion)
    }
    
    func settingUpdatePassword(newPassword: String, completion: CompletionBlock) {
        let path = "/setting/password"
        let parameters = [
            "username" : sharedUserDataService.username ?? "",
            "password" : newPassword,
            "client_id" : "demoapp",
            "response_type" : "password"]
        let success: (AnyObject? -> Void) = { response in
            if let response = response as? NSDictionary {
                if let data = response["data"] as? NSDictionary {
                    completion(nil)
                    return
                }
            }
            
            completion(APIError.unableToParseResponse.asNSError())
        }
        
        PUT(path, parameters: parameters, success: success, failure: completion)
    }
    
    func settingUpdateSignature(signature: String, completion: CompletionBlock) {
        let path = "/setting/signature"
        let parameters = ["Signature" : signature]
        
        PUT(path, parameters: parameters, completion: completion)
    }
}