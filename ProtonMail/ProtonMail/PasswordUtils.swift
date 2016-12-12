//
//  PasswordUtils.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 9/28/16.
//  Copyright © 2016 ProtonMail. All rights reserved.
//

import Foundation

enum PasswordError: ErrorType {
    case HashEmpty
    case HashEmptyEncode
    case HashSizeWrong
}

public class PasswordUtils {
    
    
    public static func getHashedPwd(authVersion: Int , password: String, username: String, decodedSalt : NSData, decodedModulus : NSData) -> NSData? {
        var hashedPassword : NSData?
        switch authVersion {
        case 0:
            hashedPassword = PasswordUtils.hashPasswordVersion0(password, username: username, modulus: decodedModulus)
            break
        case 1:
            hashedPassword = PasswordUtils.hashPasswordVersion1(password, username: username, modulus: decodedModulus)
            break
        case 2:
            hashedPassword = PasswordUtils.hashPasswordVersion2(password, username: username, modulus: decodedModulus)
            break
        case 3:
            hashedPassword = PasswordUtils.hashPasswordVersion3(password, salt: decodedSalt, modulus: decodedModulus)
            break
        case 4:
            hashedPassword = PasswordUtils.hashPasswordVersion4(password, salt: decodedSalt, modulus: decodedModulus)
            break
        default: break
        }
        return hashedPassword
    }
    
    
    public static func CleanUserName(username : String) -> String {
        return username.preg_replace("_|\\.|-", replaceto: "").lowercaseString
    }
    
    private static func bcrypt(password :String, salt :String) throws -> String {
        if let out = JKBCrypt.hashPassword(password, withSalt: "$2a$10$" + salt) where !out.isEmpty {
            let size = out.characters.count
            if size > 4 {
                let index = out.startIndex.advancedBy(4)
                return "$2y$" + out.substringFromIndex(index)
            } else {
                throw PasswordError.HashSizeWrong
            }
        }
        throw PasswordError.HashEmpty
    }
    
    private static func bcrypt_byte(password :String, salt :String) throws -> NSData? {
        let b = try bcrypt(password, salt: salt)
        if let stringData = b.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            return stringData
        }
        throw PasswordError.HashEmptyEncode
    }
    
    private static func bcrypt_string(password :String, salt :String) throws -> String {
        let b = try bcrypt(password, salt: salt)
        return b
    }
    
    
    public static func expandHash(input : NSData) -> NSData {
        return PMNSrpClient.expandHash(input);
    }
    
    public static func getMailboxPassword(password : String, salt : NSData) -> String {
        let byteArray = NSMutableData()
        byteArray.appendData(salt)
        let source = NSData(data: byteArray)
        let encodedSalt = JKBCrypt.based64DotSlash(source)
        do {
            let out = try bcrypt_string(password, salt: encodedSalt)
            let index = out.startIndex.advancedBy(29)
            return out.substringFromIndex(index)
        } catch PasswordError.HashEmpty {
            // check error
        } catch PasswordError.HashSizeWrong {
            // check error
        } catch {
            // check error
        }
        return ""
        
    }
    
    public static func hashPasswordVersion4(password : String, salt : NSData, modulus : NSData) -> NSData? {
        return hashPasswordVersion3(password, salt: salt, modulus: modulus);
    }
    
    public static func hashPasswordVersion3(password : String, salt : NSData, modulus : NSData) -> NSData? {
        let byteArray = NSMutableData()
        byteArray.appendData(salt)
        if let encodedSalt = "proton".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            byteArray.appendData(encodedSalt)
        }
        
        let source = NSData(data: byteArray)
        let encodedSalt = JKBCrypt.based64DotSlash(source)
        
        do {
            if let out = try bcrypt_byte(password, salt: encodedSalt) {
                let outArray = NSMutableData()
                outArray.appendData(out)
                outArray.appendData(modulus)
                return expandHash(NSData(data: outArray))
            }
        } catch PasswordError.HashEmpty {
            // check error
        } catch PasswordError.HashSizeWrong {
            // check error
        } catch {
            // check error
        }
        return nil
    }

    public static func hashPasswordVersion2(password : String, username : String, modulus : NSData) -> NSData? {
        return hashPasswordVersion1(password, username: CleanUserName(username), modulus: modulus);
    }
    
    public static func hashPasswordVersion1(password : String, username : String, modulus : NSData) -> NSData? {
        let un = username.lowercaseString
        let salt = un.md5
        do {
            if let out = try bcrypt_byte(password, salt: salt) {
                let byteArray = NSMutableData()
                byteArray.appendData(out)
                byteArray.appendData(modulus)
                return expandHash(NSData(data: byteArray))
            }
        } catch PasswordError.HashEmpty {
            // check error
        } catch PasswordError.HashSizeWrong {
            // check error
        } catch {
            // check error
        }
        return nil
    }
    
    public static func hashPasswordVersion0(password : String,   username : String,  modulus: NSData ) -> NSData? {
        //need check password size
        if let prehashed = password.sha512_byte {
            let encoded = prehashed.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
            return hashPasswordVersion1(encoded, username: username, modulus: modulus);
        }
        return nil
    }
    
}