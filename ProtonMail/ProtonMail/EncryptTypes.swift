//
//  EncryptTypes.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 3/26/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation

enum EncryptTypes: Int, CustomStringConvertible {
    case plain = 0          //Plain text
    case inner = 1       // ProtonMail encrypted emails
    case external = 2       // Encrypted from outside
    case outEnc = 3         // Encrypted for outside
    case outPlain = 4       // Send plain but stored enc
    case draftStoreEnc = 5  // Draft
    case outEncReply = 6    // Encrypted for outside reply
    
    case outPGPInline = 7    // out side pgp inline
    case outPGPMime = 8    // out pgp mime
    
    var description : String {
        switch(self){
        case .plain:
            return NSLocalizedString("Plain text")
        case .inner:
            return NSLocalizedString("ProtonMail encrypted emails")
        case .external:
            return NSLocalizedString("Encrypted from outside")
        case .outEnc:
            return NSLocalizedString("Encrypted for outside")
        case .outPlain:
            return NSLocalizedString("Send plain but stored enc")
        case .draftStoreEnc:
            return NSLocalizedString("Draft")
        case .outEncReply:
            return NSLocalizedString("Encrypted for outside reply")
        case .outPGPInline:
            return NSLocalizedString("Encrypted from outside pgp inline")
        case .outPGPMime:
            return NSLocalizedString("Encrypted from outside pgp mime")
        }
    }
    
    var isEncrypted: Bool {
        switch(self) {
        case .plain:
            return false
        default:
            return true
        }
    }
    
    var lockType : LockTypes {
        switch(self) {
        case .plain, .outPlain, .external:
            return .plainTextLock
        case .inner, .outEnc, .draftStoreEnc, .outEncReply:
            return .encryptLock
        case .outPGPInline, .outPGPMime:
            return .pgpLock
        }
    }
}

enum LockTypes : Int {
    case plainTextLock = 0
    case encryptLock = 1
    case pgpLock = 2
}


extension NSNumber {
    
    func isEncrypted() -> Bool {
        let enc_type = EncryptTypes(rawValue: self.intValue) ?? .inner
        let checkIsEncrypted:Bool = enc_type.isEncrypted

        return checkIsEncrypted
    }
    
}
