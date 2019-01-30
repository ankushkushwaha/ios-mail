//
//  OpenPGPExtension.swift
//  ProtonMail
//
//
//  The MIT License
//
//  Copyright (c) 2018 Proton Technologies AG
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import Foundation
import Crypto

let sharedOpenPGP = CryptoPmCrypto()!


// MARK: - OpenPGP String extension

extension String {
    
    func getSignature() throws -> String? {
        var error : NSError?
        let dec_out_att : String = ArmorReadClearSignedMessage(self, &error)
        if let err = error {
            throw err
        }
        return dec_out_att
    }
    
    func decryptMessage(binKeys: Data, passphrase: String) throws -> String? {
        return try sharedOpenPGP.decryptMessageBinKey(self, privateKey: binKeys, passphrase: passphrase)
    }
    
    func verifyMessage(verifier: Data, binKeys: Data, passphrase: String, time : Int64) throws -> ModelsDecryptSignedVerify? {
        return try sharedOpenPGP.decryptMessageVerifyBinKeyPrivBinKeys(self,
                                                                       verifierKey: verifier,
                                                                       privateKeys: binKeys,
                                                                       passphrase: passphrase,
                                                                       verifyTime: time)
    }
    
    func decryptMessageWithSinglKey(_ privateKey: String, passphrase: String) throws -> String? {
        return try sharedOpenPGP.decryptMessage(self, privateKey: privateKey, passphrase: passphrase)
    }
    
    func split() throws -> ModelsEncryptedSplit? {
        var error : NSError?
        let out = ArmorSplitArmor(self, &error)
        if let err = error {
            throw err
        }
        return out
    }
    
    func encrypt(withAddr address_id: String, mailbox_pwd: String, key: String) throws -> String? {
        return try sharedOpenPGP.encryptMessage(self, publicKey: key, privateKey: key, passphrase: mailbox_pwd, trim: true)
    }
    
    func encrypt(withPubKey publicKey: String, privateKey: String, mailbox_pwd: String) throws -> String? {
        return try sharedOpenPGP.encryptMessage(self, publicKey: publicKey, privateKey: privateKey, passphrase: mailbox_pwd, trim: true)
    }
    
    func encrypt(withPwd passphrase: String) throws -> String? {
        return try sharedOpenPGP.encryptMessage(withPassword: self, password: passphrase)
    }
    
    func decrypt(withPwd passphrase: String) throws -> String? {
        return try sharedOpenPGP.decryptMessage(withPassword: self, password: passphrase)
    }
    
    //self is private key
    func check(passphrase: String) -> Bool {
        return KeyCheckPassphrase(self, passphrase)
    }
}

