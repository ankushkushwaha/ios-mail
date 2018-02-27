//
//  EventAPI.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 6/26/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation

    
// MARK : Get messages part
final class EventCheckRequest<T : ApiResponse> : ApiRequest<T>{
    let eventID : String
    
    init(eventID : String) {
        self.eventID = eventID
    }
    
    override open func path() -> String {
        return EventAPI.Path + "/\(self.eventID)" + AppConstants.DEBUG_OPTION
    }
    
    override func apiVersion() -> Int {
        return EventAPI.V_EventCheckRequest
    }
}


final class EventLatestIDRequest<T : ApiResponse> : ApiRequest<T>{

    override open func path() -> String {
        return EventAPI.Path + "/latest" + AppConstants.DEBUG_OPTION
    }
    
    override func apiVersion() -> Int {
        return EventAPI.V_LatestEventRequest
    }
}

final class EventLatestIDResponse : ApiResponse {
    var eventID : String = ""

    override func ParseResponse(_ response: [String : Any]!) -> Bool {
        
        PMLog.D(response.json(prettyPrinted: true))
        self.eventID = response["EventID"] as? String ?? ""

        return true
    }
}

struct RefreshStatus : OptionSet {
    let rawValue: Int
    //255 means throw out client cache and reload everything from server, 1 is mail, 2 is contacts
    static let ok       = RefreshStatus(rawValue: 0)
    static let mail     = RefreshStatus(rawValue: 1 << 0)
    static let contacts = RefreshStatus(rawValue: 1 << 1)
    static let all      = RefreshStatus(rawValue: 0xFF)
}

final class EventCheckResponse : ApiResponse {
    var eventID : String = ""
    var refresh : RefreshStatus = .ok
    var more : Int = 0
    
    var messages : [[String : Any]]?
    var contacts : [[String : Any]]?
    var userinfo : [String : Any]?
    var unreads : [String : Any]?
    var total : [String : Any]?
    var labels : [[String : Any]]?
    var usedSpace : String?
    var notices : [String]?
    var messageCounts: [[String : Any]]?
    
    override func ParseResponse(_ response: [String : Any]!) -> Bool {

        //PMLog.D(response.JSONStringify(prettyPrinted: true))
        
        self.eventID = response["EventID"] as? String ?? ""
        self.messages =  response["Messages"] as? [[String : Any]]
        self.refresh = RefreshStatus(rawValue: response["Refresh"] as? Int ?? 0)
        self.more = response["More"] as? Int ?? 0
        
        self.userinfo = response["User"] as? [String : Any]
        
        self.unreads = response["Unread"] as? [String : Any]

        self.usedSpace = response["UsedSpace"] as? String
        
        self.total = response["Total"] as? [String : Any]
        
        self.labels =  response["Labels"] as? [[String : Any]]
        
        self.contacts = response["Contacts"] as? [[String : Any]]
        
        self.notices = response["Notices"] as? [String]
        
        self.messageCounts = response["MessageCounts"] as? [[String : Any]]
        
        return true
    }
}

final class MessageEvent {
    
    var Action : Int!
    var ID : String!;
    var message : [String : Any]?
    
    init(event: [String : Any]!) {
        self.Action = event["Action"] as! Int
        self.message =  event["Message"] as? [String : Any]
        self.ID =  event["ID"] as! String
        self.message?["ID"] = self.ID
        self.message?["needsUpdate"] = false
    }
}

final class ContactEvent {
    
    var Action : Int!
    var ID : String!;
    var contact : [String : Any]?
    var contacts : [[String : Any]] = []
    init(event: [String : Any]!) {
        self.Action = event["Action"] as! Int
        self.contact =  event["Contact"] as? [String : Any]
        self.ID =  event["ID"] as! String
        
        if let contact = self.contact {
            if let contactID = contact["ContactID"] as? String, let name = contact["Name"] as? String {
                var found = false
                for (index, var c) in contacts.enumerated() {
                    if let obj = c["ID"] as? String, obj == contactID {
                        found = true
                        if var emails = c["Emails"] as? [[String : Any]] {
                            emails.append(contact)
                            c["Emails"] = emails
                        } else {
                            c["Emails"] = [contact]
                        }
                        contacts[index] = c
                    }
                }
                if !found {
                    let newContact : [String : Any] = [
                        "ID" : contactID,
                        "Name" : name,
                        "Emails" : [contact]
                    ]
                    self.contacts.append(newContact)
                }
            }
        }
    }
}

final class LabelEvent {
    
    var Action : Int!
    var ID : String!;
    var label : [String : Any]?
    
    init(event: [String : Any]!) {
        self.Action = event["Action"] as! Int
        self.label =  event["Label"] as? [String : Any]
        self.ID =  event["ID"] as! String
    }
}



