//
//  MainQueueHandler.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import Groot
import ProtonCore_Keymaker
import ProtonCore_Networking
import ProtonCore_Services

final class MainQueueHandler: QueueHandler {
    let userID: String
    private let cacheService: CacheService
    private let coreDataService: CoreDataService
    private let apiService: APIService
    private let messageDataService: MessageDataService
    private let conversationDataService: ConversationProvider
    private let labelDataService: LabelsDataService
    private let localNotificationService: LocalNotificationService
    private weak var user: UserManager?
    
    init(cacheService: CacheService,
         coreDataService: CoreDataService,
         apiService: APIService,
         messageDataService: MessageDataService,
         conversationDataService: ConversationProvider,
         labelDataService: LabelsDataService,
         localNotificationService: LocalNotificationService,
         user: UserManager) {
        self.userID = user.userinfo.userId
        self.cacheService = cacheService
        self.coreDataService = coreDataService
        self.apiService = apiService
        self.messageDataService = messageDataService
        self.conversationDataService = conversationDataService
        self.labelDataService = labelDataService
        self.localNotificationService = localNotificationService
        self.user = user
    }

    func handleTask(_ task: QueueManager.Task, completion: @escaping (QueueManager.Task, QueueManager.TaskResult) -> Void) {
        let completeHandler = handleTaskCompletion(task, notifyQueueManager: completion)
        let action = task.action
        
        let UID = task.userID
        let uuid = task.uuid
        let isConversation = task.isConversation
        
        if isConversation {
            //TODO: - v4 refactor conversation method
            switch action {
            case .saveDraft, .uploadAtt, .uploadPubkey, .deleteAtt, .send,
                 .updateLabel, .createLabel, .deleteLabel, .signout, .signin,
                 .fetchMessageDetail, .updateAttKeyPacket:
                fatalError()
            case .emptyTrash, .emptySpam:   // keep this as legacy option for 2-3 releases after 1.11.12
                fatalError()
            case .empty(let labelID):
                self.empty(labelId: labelID, UID: UID, completion: completeHandler)
            case .unread(let currentLabelID, let itemIDs, _):
                self.unreadConversations(itemIDs, labelID: currentLabelID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .read(let itemIDs, _):
                self.readConversations(itemIDs, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .delete(let currentLabelID, let itemIDs):
                self.deleteConversations(itemIDs, labelID: currentLabelID ?? "", writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .label(let currentLabelID, _, let itemIDs, _):
                self.labelConversations(itemIDs, labelID: currentLabelID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .unlabel(let currentLabelID, _, let itemIDs, _):
                self.unlabelConversations(itemIDs, labelID: currentLabelID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .folder(let nextLabelID, _, let itemIDs, _):
                self.labelConversations(itemIDs, labelID: nextLabelID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            }
        } else {
            switch action {
            case .saveDraft(let messageObjectID):
                self.draft(save: messageObjectID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .uploadAtt(let attachmentObjectID):
                self.uploadAttachmentWithAttachmentID(attachmentObjectID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .uploadPubkey(let attachmentObjectID):
                self.uploadPubKey(attachmentObjectID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .deleteAtt(let attachmentObjectID):
                self.deleteAttachmentWithAttachmentID(attachmentObjectID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .updateAttKeyPacket(let messageObjectID, let addressID):
                self.updateAttachmentKeyPacket(messageObjectID: messageObjectID, addressID: addressID, completion: completeHandler)
            case .send(let messageObjectID):
                messageDataService.send(byID: messageObjectID, writeQueueUUID: uuid, UID: UID, completion: completeHandler)
            case .emptyTrash:   // keep this as legacy option for 2-3 releases after 1.11.12
                self.empty(at: .trash, UID: UID, completion: completeHandler)
            case .emptySpam:    // keep this as legacy option for 2-3 releases after 1.11.12
                self.empty(at: .spam, UID: UID, completion: completeHandler)
            case .empty(let currentLabelID):
                self.empty(labelId: currentLabelID, UID: UID, completion: completeHandler)
            case .read(_, let objectIDs):
                self.messageAction(objectIDs, writeQueueUUID: uuid, action: action.rawValue, UID: UID, completion: completeHandler)
            case .unread(_, _, let objectIDs):
                self.messageAction(objectIDs, writeQueueUUID: uuid, action: action.rawValue, UID: UID, completion: completeHandler)
            case .delete(_, let itemIDs):
                self.messageDelete(itemIDs, writeQueueUUID: uuid, action: action.rawValue, UID: UID, completion: completeHandler)
            case .label(let currentLabelID, let shouldFetch, let itemIDs, _):
                self.labelMessage(currentLabelID, messageIDs: itemIDs, UID: UID, shouldFetchEvent: shouldFetch ?? false, completion: completeHandler)
            case .unlabel(let currentLabelID, let shouldFetch, let itemIDs, _):
                self.unLabelMessage(currentLabelID, messageIDs: itemIDs, UID: UID, shouldFetchEvent: shouldFetch ?? false, completion: completeHandler)
            case .folder(let nextLabelID, let shouldFetch, let itemIDs, _):
                self.labelMessage(nextLabelID, messageIDs: itemIDs, UID: UID, shouldFetchEvent: shouldFetch ?? false, completion: completeHandler)
            case .updateLabel(let labelID, let name, let color):
                self.updateLabel(labelID: labelID, name: name, color: color, completion: completeHandler)
            case .createLabel(let name, let color, let isFolder):
                self.createLabel(name: name, color: color, isFolder: isFolder, completion: completeHandler)
            case .deleteLabel(let labelID):
                self.deleteLabel(labelID: labelID, completion: completeHandler)
            case .signout:
                self.signout(completion: completeHandler)
            case .signin:
                break
            case .fetchMessageDetail:
                self.fetchMessageDetail(messageID: task.messageID, completion: completeHandler)
            }
        }
    }
    
    private func handleTaskCompletion(_ queueTask: QueueManager.Task, notifyQueueManager: @escaping (QueueManager.Task, QueueManager.TaskResult) -> Void) -> CompletionBlock {
        return { task, response, error in
            var taskResult = QueueManager.TaskResult()
            
            guard let error = error else {
                if case .delete = queueTask.action {
                    _ = self.cacheService.deleteMessage(by: queueTask.messageID)
                }
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            PMLog.D("Handle queue task error: \(String(describing: error))")
            Analytics.shared.error(message: .queueError, error: error, user: nil)
            
            var statusCode = 200
            let errorCode = error.code
            var isInternetIssue = false
            let errorUserInfo = error.userInfo
            
            if let detail = errorUserInfo["com.alamofire.serialization.response.error.response"] as? HTTPURLResponse {
                statusCode = detail.statusCode
            } else {
                if error.domain == NSURLErrorDomain {
                    switch error.code {
                    case NSURLErrorTimedOut,
                         NSURLErrorCannotConnectToHost,
                         NSURLErrorCannotFindHost,
                         NSURLErrorDNSLookupFailed,
                         NSURLErrorNotConnectedToInternet,
                         NSURLErrorSecureConnectionFailed,
                         NSURLErrorDataNotAllowed,
                         NSURLErrorCannotFindHost:
                        isInternetIssue = true
                    default:
                        break
                    }
                } else if error.domain == NSPOSIXErrorDomain && error.code == 100 {
                    //Network protocol error
                    isInternetIssue = true
                } else {
                    let status = Reachability.forInternetConnection()?.currentReachabilityStatus()
                    switch status {
                    case .NotReachable:
                        isInternetIssue = true
                    default: break
                    }
                }
                
                // Show timeout error banner or not reachable banner in mailbox
                if errorCode == NSURLErrorTimedOut {
                    NotificationCenter.default.post(Notification(name: NSNotification.Name.reachabilityChanged, object: 0, userInfo: nil))
                } else if isInternetIssue {
                    NotificationCenter.default.post(Notification(name: NSNotification.Name.reachabilityChanged, object: 1, userInfo: nil))
                }
            }
            
            guard !isInternetIssue else {
                taskResult.action = .connectionIssue
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            if (statusCode == .notFound) {
                taskResult.action = .removeRelated
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            //need add try times and check internet status
            if statusCode == .internalServerError && !isInternetIssue {
                if taskResult.retry < 3 {
                    taskResult.action = .retry
                    taskResult.retry += 1
                } else {
                    taskResult.action = .removeRelated
                }
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            if statusCode == .ok && errorCode == APIErrorCode.HUMAN_VERIFICATION_REQUIRED {
                
            } else if statusCode == .ok && errorCode > 1000 {
                taskResult.action = .removeRelated
                notifyQueueManager(queueTask, taskResult)
                return
            } else if statusCode == .ok && errorCode < 200 && !isInternetIssue {
                taskResult.action = .removeRelated
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            if statusCode != .ok && statusCode != .notFound && statusCode != .internalServerError && !isInternetIssue {
                //show error
                Analytics.shared.error(message: .queueError,
                                       error: error.localizedDescription,
                                       user: nil)
                taskResult.action = .removeRelated
                notifyQueueManager(queueTask, taskResult)
                return
            }
            
            
            if !isInternetIssue &&
                errorCode != APIErrorCode.AuthErrorCode.authCacheLocked {
                taskResult.action = .removeRelated
                notifyQueueManager(queueTask, taskResult)
            } else {
                taskResult.action = .checkReadQueue
                notifyQueueManager(queueTask, taskResult)
            }
            
        }
    }
}

//MARK: shared queue actions
extension MainQueueHandler {
    func empty(labelId: String, UID: String, completion: CompletionBlock?) {
        if let location = Message.Location(rawValue: labelId) {
            self.empty(at: location, UID: UID, completion: completion)
        } else {
            self.empty(labelID: labelId, completion: completion)
        }
    }
    
    private func empty(at location: Message.Location, UID: String, completion: CompletionBlock?) {
        //TODO:: check is label valid
        if location != .spam && location != .trash && location != .draft {
            completion?(nil, nil, nil)
            return
        }
        
        guard user?.userinfo.userId == UID else {
            completion?(nil, nil, NSError.userLoggedOut())
            return
        }
        
        let api = EmptyMessage(labelID: location.rawValue)
        self.apiService.exec(route: api) { (task, response: Response) in
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    private func empty(labelID: String, completion: CompletionBlock?) {
        let api = EmptyMessage(labelID: labelID)
        self.apiService.exec(route: api) { (task, response: Response) in
            completion?(task, nil, response.error?.toNSError)
        }
    }
}

// MARK: queue actions for single message
extension MainQueueHandler {
    fileprivate func draft(save messageID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        var isAttachmentKeyChanged = false
        self.coreDataService.enqueue(context: context) { (context) in
            guard let objectID = self.coreDataService.managedObjectIDForURIRepresentation(messageID) else {
                // error: while trying to get objectID
                completion?(nil, nil, NSError.badParameter(messageID))
                return
            }
            
            guard self.user?.userinfo.userId == UID else {
                completion?(nil, nil, NSError.userLoggedOut())
                return
            }
            
            do {
                guard let message = try context.existingObject(with: objectID) as? Message else {
                    // error: object is not a Message
                    completion?(nil, nil, NSError.badParameter(messageID))
                    return
                }
                
                let completionWrapper: CompletionBlock = { task, response, error in
                    guard let mess = response else {
                        if let err = error {
                            Analytics.shared.error(message: .saveDraftError, error: err, user: self.user)
                            DispatchQueue.main.async {
                                NSError.alertSavingDraftError(details: err.localizedDescription)
                            }
                        }
                        // error: response nil
                        completion?(task, nil, error)
                        return
                    }
                    
                    guard let messageID = mess["ID"] as? String else {
                        // error: not ID field in response
                        let keys = Array(mess.keys)
                        let messageIDError = NSError.badParameter("messageID")
                        Analytics.shared.error(message: .saveDraftError,
                                               error: messageIDError,
                                               extra: ["dicKeys": keys],
                                               user: self.user)
                        // The error is messageID missing from the response
                        // But this is meanless to users
                        // I think parse error is more understandable
                        let parseError = NSError.unableToParseResponse("messageID")
                        NSError.alertSavingDraftError(details: parseError.localizedDescription)
                        completion?(task, nil, error)
                        return
                    }
                    
                    PMLog.D("SendAttachmentDebug == finish save draft!")
                    if message.messageID != messageID {
                        // Cancel scheduled local notification and re-schedule
                        self.localNotificationService
                            .rescheduleMessage(oldID: message.messageID, details: .init(messageID: messageID, subtitle: message.title))
                    }
                    message.messageID = messageID
                    message.isDetailDownloaded = true

                    if let conversationID = mess["ConversationID"] as? String {
                        message.conversationID = conversationID
                    }
                
                    var hasTemp = false
                    let attachments = message.mutableSetValue(forKey: "attachments")
                    for att in attachments {
                        if let att = att as? Attachment {
                            if att.isTemp {
                                hasTemp = true
                                context.delete(att)
                            }
                            // Prevent flag being overide if current call do not change the key
                            if isAttachmentKeyChanged {
                                att.keyChanged = false
                            }
                        }
                    }
                
                
                    if let subject = mess["Subject"] as? String {
                        message.title = subject
                    }
                    if let timeValue = mess["Time"] {
                        if let timeString = timeValue as? NSString {
                            let time = timeString.doubleValue as TimeInterval
                            if time != 0 {
                                message.time = time.asDate()
                            }
                        } else if let dateNumber = timeValue as? NSNumber {
                            let time = dateNumber.doubleValue as TimeInterval
                            if time != 0 {
                                message.time = time.asDate()
                            }
                        }
                    }
                
                    if let error = context.saveUpstreamIfNeeded() {
                        PMLog.D(" error: \(error)")
                    }
                
                    if hasTemp {
                        do {
                            try GRTJSONSerialization.object(withEntityName: Message.Attributes.entityName, fromJSONDictionary: mess, in: context)
                            if let save_error = context.saveUpstreamIfNeeded() {
                                PMLog.D(" error: \(save_error)")
                            }
                        } catch let exc as NSError {
                            Analytics.shared.error(message: .grtJSONSerialization, error: exc, user: self.user)
                            completion?(task, response, exc)
                            return
                        }
                    }
                    completion?(task, response, error)
                }
                
                PMLog.D("SendAttachmentDebug == start save draft!")
                
                if let atts = message.attachments.allObjects as? [Attachment] {
                    for att in atts {
                        if att.keyChanged {
                            isAttachmentKeyChanged = true
                        }
                    }
                }
                
                if message.isDetailDownloaded && UUID(uuidString: message.messageID) == nil {
                    let addr = self.messageDataService.fromAddress(message) ?? message.cachedAddress ?? self.messageDataService.defaultAddress(message)
                    let api = UpdateDraft(message: message, fromAddr: addr, authCredential: message.cachedAuthCredential)
                    self.apiService.exec(route: api) { (task, response: UpdateDraftResponse) in
                        context.perform {
                            if let err = response.error {
                                completionWrapper(task, nil, err.toNSError)
                            } else {
                                completionWrapper(task, response.responseDict, nil)
                            }
                        }
                    }
                } else {
                    let addr = self.messageDataService.fromAddress(message) ?? message.cachedAddress ?? self.messageDataService.defaultAddress(message)
                    let api = CreateDraft(message: message, fromAddr: addr)
                    self.apiService.exec(route: api) { (task, response: UpdateDraftResponse) in
                        context.perform {
                            if let err = response.error {
                                completionWrapper(task, nil, err.toNSError)
                            } else {
                                completionWrapper(task, response.responseDict, nil)
                            }
                        }
                    }
                }
            } catch let ex as NSError {
                // error: context thrown trying to get Message
                Analytics.shared.error(message: .saveDraftError, error: ex, user: self.user)
                completion?(nil, nil, ex)
                return
            }
        }
    }
    
    fileprivate func uploadPubKey(_ managedObjectID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        guard let objectID = self.coreDataService.managedObjectIDForURIRepresentation(managedObjectID),
            let managedObject = try? context.existingObject(with: objectID),
            let _ = managedObject as? Attachment else
        {
            completion?(nil, nil, NSError.badParameter(managedObjectID))
            return
        }
        
        self.uploadAttachmentWithAttachmentID(managedObjectID, writeQueueUUID: writeQueueUUID, UID: UID, completion: completion)
        return
    }
    
    private func uploadAttachmentWithAttachmentID (_ managedObjectID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        self.coreDataService.enqueue(context: context) { (context) in
            guard let objectID = self.coreDataService.managedObjectIDForURIRepresentation(managedObjectID),
                  let managedObject = try? context.existingObject(with: objectID),
                  let attachment = managedObject as? Attachment else
            {
                completion?(nil, nil, NSError.badParameter(managedObjectID))
                return
            }
            
            guard self.user?.userinfo.userId == UID else {
                completion?(nil, nil, NSError.userLoggedOut())
                return
            }
            
            guard let attachments = attachment.message.attachments.allObjects as? [Attachment] else {
                return
            }
            if let _ = attachments
                .first(where: { $0.contentID() == attachment.contentID() &&
                        $0.attachmentID != "0" }) {
                // This upload is duplicated
                context.delete(attachment)
                if let error = context.saveUpstreamIfNeeded() {
                    PMLog.D(" error: \(error)")
                }
                completion?(nil, nil, nil)
                return
            }
            
            let params = [
                "Filename": attachment.fileName,
                "MIMEType": attachment.mimeType,
                "MessageID": attachment.message.messageID,
                "ContentID": attachment.contentID() ?? attachment.fileName,
                "Disposition": attachment.disposition()
            ]

            let addressID = attachment.message.cachedAddress?.addressID ?? self.messageDataService.getAddressID(attachment.message)
            guard
                let key = attachment.message.cachedAddress?.keys.first ?? self.user?.getAddressKey(address_id: addressID),
                let passphrase = attachment.message.cachedPassphrase ?? self.user?.mailboxPassword,
                let userKeys = attachment.message.cachedUser?.userPrivateKeysArray ?? self.user?.userPrivateKeys else {
                completion?(nil, nil, NSError.encryptionError())
                return
            }
            
            autoreleasepool(){
                guard
                    let (kP, dP) = attachment.encrypt(byKey: key, mailbox_pwd: passphrase),
                    let keyPacket = kP,
                    let dataPacket = dP
                else
                {
                    completion?(nil, nil, NSError.encryptionError())
                    return
                }
                Crypto().freeGolangMem()
                let signed = attachment.sign(byKey: key,
                                             userKeys: userKeys,
                                             passphrase: passphrase)
                let completionWrapper: CompletionBlock = { task, response, error in
                    PMLog.D("SendAttachmentDebug == finish upload att!")
                    if error == nil,
                       let attDict = response?["Attachment"] as? [String : Any],
                       let id = attDict["ID"] as? String
                    {
                        self.coreDataService.enqueue(context: context) { (context) in
                            attachment.attachmentID = id
                            attachment.keyPacket = keyPacket.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                            attachment.fileData = nil // encrypted attachment is successfully uploaded -> no longer need it cleartext
                            
                            // proper headers from BE - important for inline attachments
                            if let headerInfoDict = attDict["Headers"] as? Dictionary<String, String> {
                                attachment.headerInfo = "{" + headerInfoDict.compactMap { " \"\($0)\":\"\($1)\" " }.joined(separator: ",") + "}"
                            }
                            
                            if let fileUrl = attachment.localURL,
                               let _ = try? FileManager.default.removeItem(at: fileUrl)
                            {
                                attachment.localURL = nil
                            }
                            
                            if let error = context.saveUpstreamIfNeeded() {
                                PMLog.D(" error: \(error)")
                            }
                            NotificationCenter
                                .default
                                .post(name: .attachmentUploaded,
                                      object: nil,
                                      userInfo: ["objectID": attachment.objectID.uriRepresentation().absoluteString,
                                                 "attachmentID": attachment.attachmentID])
                            completion?(task, response, error)
                        }
                    } else {
                        if let err = error {
                            Analytics.shared.error(message: .uploadAttachmentError, error: err, user: self.user)
                        }
                        completion?(task, response, error)
                    }
                }
                
                PMLog.D("SendAttachmentDebug == start upload att!")
                ///sharedAPIService.upload( byPath: Constants.App.API_PATH + "/attachments",
                self.user?.apiService.upload(byPath: "/attachments",
                                             parameters: params,
                                             keyPackets: keyPacket,
                                             dataPacket: dataPacket as Data,
                                             signature: signed,
                                             headers: [HTTPHeader.apiVersion: 3],
                                             authenticated: true,
                                             customAuthCredential: attachment.message.cachedAuthCredential,
                                             completion: completionWrapper)
            }
        }
        
    }
    
    fileprivate func deleteAttachmentWithAttachmentID (_ deleteObject: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        self.coreDataService.enqueue(context: context) { (context) in
            var authCredential: AuthCredential?
            var att: Attachment?
            if let objectID = self.coreDataService.managedObjectIDForURIRepresentation(deleteObject),
                let managedObject = try? context.existingObject(with: objectID),
                let attachment = managedObject as? Attachment
            {
                authCredential = attachment.message.cachedAuthCredential
                att = attachment
            }
            
            guard self.user?.userinfo.userId == UID else {
                completion?(nil, nil, NSError.userLoggedOut())
                return
            }
            
            let api = DeleteAttachment(attID: att?.attachmentID ?? "0", authCredential: authCredential)
            self.apiService.exec(route: api) { (task, response: Response) in
                completion!(task, nil, response.error?.toNSError)
            }
        }
    }
    
    private func updateAttachmentKeyPacket(messageObjectID: String, addressID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        self.coreDataService.enqueue(context: context) { [weak self] (context) in
            guard let self = self,
                  let objectID = self.coreDataService
                    .managedObjectIDForURIRepresentation(messageObjectID) else {
                // error: while trying to get objectID
                completion?(nil, nil, NSError.badParameter(messageObjectID))
                return
            }
            
            guard let user = self.user else {
                completion?(nil, nil, NSError.userLoggedOut())
                return
            }

            do {
                guard let message = try context
                        .existingObject(with: objectID) as? Message,
                      let attachments = message.attachments.allObjects as? [Attachment] else {
                    // error: object is not a Message
                    completion?(nil, nil, NSError.badParameter(messageObjectID))
                    return
                }

                guard let address = user.userinfo.userAddresses.address(byID: addressID),
                      let key = address.keys.first else {
                    completion?(nil, nil, NSError.badParameter("Address ID"))
                    return
                }

                for att in attachments where !att.isSoftDeleted && att.attachmentID != "0" {
                    guard let sessionPack = user.newSchema ?
                            try att.getSession(userKey: user.userPrivateKeys,
                                               keys: user.addressKeys,
                                               mailboxPassword: user.mailboxPassword) :
                            try att.getSession(keys: user.addressPrivateKeys,
                                               mailboxPassword: user.mailboxPassword) else { //DONE
                        continue
                    }
                    guard let newKeyPack = try sessionPack.key?.getKeyPackage(publicKey: key.publicKey, algo: sessionPack.algo)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) else {
                        continue
                    }
                    context.performAndWait {
                        att.keyPacket = newKeyPack
                        att.keyChanged = true
                    }
                }
                guard let decryptedBody = try self.messageDataService
                    .decryptBodyIfNeeded(message: message) else {
                        // error: object is not a Message
                        completion?(nil, nil, NSError.badParameter("decrypted body"))
                        return
                    }
                context.performAndWait { [weak self] in
                    message.addressID = addressID
                    if message.nextAddressID == addressID {
                        message.nextAddressID = nil
                    }
                    let mailbox_pwd = user.mailboxPassword
                    self?.messageDataService.encryptBody(message, clearBody: decryptedBody, mailbox_pwd: mailbox_pwd, error: nil)
                }
                self.messageDataService.saveDraft(message)
                completion?(nil, nil, nil)
            } catch let ex as NSError {
                // error: context thrown trying to get Message
                Analytics.shared.error(message: .updateAddressIDError, error: ex, user: self.user)
                completion?(nil, nil, ex)
                return
            }
        }
    }
    
    fileprivate func messageAction(_ managedObjectIds: [String], writeQueueUUID: UUID, action: String, UID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        context.performAndWait {
            let messages = managedObjectIds.compactMap { (id: String) -> Message? in
                if let objectID = self.coreDataService.managedObjectIDForURIRepresentation(id),
                    let managedObject = try? context.existingObject(with: objectID)
                {
                    return managedObject as? Message
                }
                return nil
            }
            
            guard self.user?.userinfo.userId == UID else {
                completion!(nil, nil, NSError.userLoggedOut())
                return
            }
            
            let messageIds = messages.map { $0.messageID }
            guard messageIds.count > 0 else {
                Analytics.shared.debug(message: .coredataIssue,
                                       extra: [
                                        "API": "Message action",
                                        "ObjectCounts": managedObjectIds.count
                                       ])
                completion!(nil, nil, nil)
                return
            }
            let api = MessageActionRequest(action: action, ids: messageIds)
            self.apiService.exec(route: api) { (task, response: Response) in
                completion!(task, nil, response.error?.toNSError)
            }
        }
    }
    
    /// delete a message
    ///
    /// - Parameters:
    ///   - messageIDs: must be the real message id. becuase the message is deleted before this triggered
    ///   - writeQueueUUID: queue UID
    ///   - action: action type. should .delete here
    ///   - completion: call back
    fileprivate func messageDelete(_ messageIDs: [String], writeQueueUUID: UUID, action: String, UID: String, completion: CompletionBlock?) {
        guard user?.userinfo.userId == UID else {
            completion!(nil, nil, NSError.userLoggedOut())
            return
        }
        
        let api = MessageActionRequest(action: action, ids: messageIDs)
        self.apiService.exec(route: api) { (task, response: Response) in
            completion!(task, nil, response.error?.toNSError)
        }
    }
    
    fileprivate func labelMessage(_ labelID: String, messageIDs: [String], UID: String, shouldFetchEvent: Bool, completion: CompletionBlock?) {
        guard user?.userinfo.userId == UID else {
            completion!(nil, nil, NSError.userLoggedOut())
            return
        }
        
        let api = ApplyLabelToMessages(labelID: labelID, messages: messageIDs)
        // rebase TODO: need review
        self.apiService.exec(route: api) { [weak self](task, response: Response) in
            if shouldFetchEvent {
                self?.user?.eventsService.fetchEvents(labelID: labelID)
            }
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    fileprivate func unLabelMessage(_ labelID: String, messageIDs: [String], UID: String, shouldFetchEvent: Bool, completion: CompletionBlock?) {
        guard user?.userinfo.userId == UID else {
            completion!(nil, nil, NSError.userLoggedOut())
            return
        }
        
        let api = RemoveLabelFromMessages(labelID: labelID, messages: messageIDs)
        // rebase TODO: need review
        self.apiService.exec(route: api) { [weak self] (task, response: Response) in
            if shouldFetchEvent {
                self?.user?.eventsService.fetchEvents(labelID: labelID)
            }
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    private func createLabel(name: String, color: String, isFolder: Bool, parentID: String? = nil, notify: Bool = true, expanded: Bool = true, completion: CompletionBlock?) {
         
        let type: PMLabelType = isFolder ? .folder: .label
        let api = CreateLabelRequest(name: name, color: color, type: type, parentID: parentID, notify: notify, expanded: expanded)
        self.apiService.exec(route: api) { (task, response: CreateLabelRequestResponse) in
            guard response.error == nil else {
                completion?(nil, nil, response.error?.toNSError)
                return
            }
            self.labelDataService.addNewLabel(response.label)
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    private func updateLabel(labelID: String, name: String, color: String, completion: CompletionBlock?) {
        let api = UpdateLabelRequest(id: labelID, name: name, color: color)
        self.apiService.exec(route: api) { [weak self] (task, response: Response) in
            self?.user?.eventsService.fetchEvents(labelID: labelID)
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    private func deleteLabel(labelID: String, completion: CompletionBlock?) {
        let api = DeleteLabelRequest(lable_id: labelID)
        self.apiService.exec(route: api) { (task, response: Response) in
            completion?(task, nil, response.error?.toNSError)
        }
    }
    
    private func signout(completion: CompletionBlock?) {
        let api = AuthDeleteRequest()
        self.apiService.exec(route: api) { (task: URLSessionDataTask?, response: Response) in
            completion?(task, nil, response.error?.toNSError)
            // probably we want to notify user the session will seem active on website in case of error
        }
    }
    
    private func fetchMessageDetail(messageID: String, completion: CompletionBlock?) {
        let context = self.coreDataService.operationContext
        self.coreDataService.enqueue(context: context) { [weak self] (context) in
            guard let message = Message
                    .messageForMessageID(messageID, inManagedObjectContext: context) else {
                completion?(nil, nil, nil)
                return
            }
            self?.messageDataService.ForcefetchDetailForMessage(message, runInQueue: false, completion: { _, _, _, error in
                guard error == nil else {
                    completion?(nil, nil, error)
                    return
                }
                completion?(nil, nil, nil)
            })
        }
    }
}

// MARK: queue actions for conversation
extension MainQueueHandler {
    fileprivate func unreadConversations(_ conversationIds: [String], labelID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        conversationDataService.markAsUnread(conversationIDs: conversationIds, labelID: labelID) { result in
            completion?(nil, nil, result.nsError)
        }
    }
    
    fileprivate func readConversations(_ conversationIds: [String], writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        conversationDataService.markAsRead(conversationIDs: conversationIds, labelID: "") { result in
            completion?(nil, nil, result.nsError)
        }
    }
    
    fileprivate func deleteConversations(_ conversationIds: [String], labelID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        conversationDataService.deleteConversations(with: conversationIds, labelID: labelID) { result in
            completion?(nil, nil, result.nsError)
        }
    }
    
    fileprivate func labelConversations(_ conversationIds: [String], labelID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        conversationDataService.label(conversationIDs: conversationIds, as: labelID) { result in
            completion?(nil, nil, result.nsError)
        }
    }
    
    fileprivate func unlabelConversations(_ conversationIds: [String], labelID: String, writeQueueUUID: UUID, UID: String, completion: CompletionBlock?) {
        conversationDataService.unlabel(conversationIDs: conversationIds, as: labelID) { result in
            completion?(nil, nil, result.nsError)
        }
    }
}