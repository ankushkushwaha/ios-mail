//
//  EncryptTypes.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 3/26/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation

enum EncryptTypes: Int, Printable {
    case Plain = 0          //Plain text
    case Internal = 1       // ProtonMail encrypted emails
    case External = 2       // Encrypted from outside
    case OutEnc = 3         // Encrypted for outside
    case OutPlain = 4       // Send plain but stored enc
    case DraftStoreEnc = 5  // Draft
    case OutEncReply = 6    // Encrypted for outside reply
    
    case OutPGPInline = 7    // out side pgp inline
    case OutPGPMime = 8    // out pgp mime
    
    var description : String {
        switch(self){
        case Plain:
            return NSLocalizedString("Plain text")
        case Internal:
            return NSLocalizedString("ProtonMail encrypted emails")
        case External:
            return NSLocalizedString("Encrypted from outside")
        case OutEnc:
            return NSLocalizedString("Encrypted for outside")
        case OutPlain:
            return NSLocalizedString("Send plain but stored enc")
        case DraftStoreEnc:
            return NSLocalizedString("Draft")
        case OutEncReply:
            return NSLocalizedString("Encrypted for outside reply")
        case OutPGPInline:
            return NSLocalizedString("Encrypted from outside pgp inline")
        case OutPGPMime:
            return NSLocalizedString("Encrypted from outside pgp mime")
        }
    }
    
    var isEncrypted: Bool {
        switch(self) {
        case Plain:
            return false
        default:
            return true
        }
    }
    
    var lockType : LockTypes {
        switch(self) {
        case Plain, OutPlain, External:
            return .PlainTextLock
        case Internal, OutEnc, DraftStoreEnc, OutEncReply:
            return .EncryptLock
        case OutPGPInline, OutPGPMime:
            return .PGPLock
        default:
            return .EncryptLock
        }
    }
}

enum LockTypes : Int {
    case PlainTextLock = 0
    case EncryptLock = 1
    case PGPLock = 2
}


extension NSNumber {
    
    func isEncrypted() -> Bool {
        let enc_type = EncryptTypes(rawValue: self.integerValue) ?? EncryptTypes.Internal
        let checkIsEncrypted:Bool = enc_type.isEncrypted

        return checkIsEncrypted
    }
    
}