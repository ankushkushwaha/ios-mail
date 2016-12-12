// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from open_pgp.djinni

#import "PMNAddress.h"
#import "PMNEncryptPackage.h"
#import "PMNOpenPgpKey.h"
#import <Foundation/Foundation.h>
@class PMNOpenPgp;


/**
 *open_pgp_key_manager = interface +c {
 *    static create_instance() : open_pgp_key_manager;
 *}
 */
@interface PMNOpenPgp : NSObject

/**
 * create and init an instance those instance have addresses manager build in
 * if want deal with single key should use the static functions
 */
+ (nullable PMNOpenPgp *)createInstance;

/** create and init an instance with addresses */
+ (nullable PMNOpenPgp *)createInstanceWithAddress:(nonnull PMNAddress *)address;

+ (nullable PMNOpenPgp *)createInstanceWithAddresses:(nonnull NSArray<PMNAddress *> *)address;

/** generate new key  */
+ (nonnull PMNOpenPgpKey *)generateNewKey:(nonnull NSString *)userId
                                    email:(nonnull NSString *)email
                               passphrase:(nonnull NSString *)passphrase
                                     bits:(int32_t)bits;

/**update single private key password */
+ (nonnull NSString *)updateSinglePassphrase:(nonnull NSString *)privateKey
                               oldPassphrase:(nonnull NSString *)oldPassphrase
                               newPassphrase:(nonnull NSString *)newPassphrase;

/**disable/enable debug model */
+ (void)enableDebug:(BOOL)isDebug;

/**check is private key passphrase ok */
+ (BOOL)checkPassphrase:(nonnull NSString *)privateKey
             passphrase:(nonnull NSString *)passphrase;

/**update multiple pgp private keys return are new keys */
+ (nonnull NSArray<PMNOpenPgpKey *> *)updateKeysPassphrase:(nonnull NSArray<PMNOpenPgpKey *> *)privateKeys
                                             oldPassphrase:(nonnull NSString *)oldPassphrase
                                             newPassphrase:(nonnull NSString *)newPassphrase;

/**Random bits */
+ (nonnull NSData *)randomBits:(int32_t)bits;

/**add a new address into addresses list */
- (BOOL)addAddress:(nonnull PMNAddress *)address;

/**remove a exsit address from the list based on address id */
- (BOOL)removeAddress:(nonnull NSString *)addressId;

/**clean address list */
- (BOOL)cleanAddresses;

/**
 * old functions blow
 *generat new key pair (will be deprecated)
 */
- (nonnull PMNOpenPgpKey *)generateKey:(nonnull NSString *)userName
                                domain:(nonnull NSString *)domain
                            passphrase:(nonnull NSString *)passphrase
                                  bits:(int32_t)bits;

/**update the information carried in the packet. //TODO need add more parameters */
- (void)updatePrivateInfo:(nonnull NSString *)privateKey;

/**encrypt message */
- (nonnull NSString *)encryptMessage:(nonnull NSString *)addressId
                           plainText:(nonnull NSString *)plainText;

- (nonnull NSString *)encryptMessageSingleKey:(nonnull NSString *)publicKey
                                    plainText:(nonnull NSString *)plainText;

- (nonnull NSString *)decryptMessage:(nonnull NSString *)encryptText
                           passphras:(nonnull NSString *)passphras;

- (nonnull NSString *)decryptMessageSingleKey:(nonnull NSString *)encryptText
                                   privateKey:(nonnull NSString *)privateKey
                                    passphras:(nonnull NSString *)passphras;

- (nonnull PMNEncryptPackage *)encryptAttachment:(nonnull NSString *)addressId
                                   unencryptData:(nonnull NSData *)unencryptData
                                        fileName:(nonnull NSString *)fileName;

- (nonnull PMNEncryptPackage *)encryptAttachmentSingleKey:(nonnull NSString *)publicKey
                                            unencryptData:(nonnull NSData *)unencryptData
                                                 fileName:(nonnull NSString *)fileName;

- (nonnull NSData *)decryptAttachment:(nonnull NSData *)key
                                 data:(nonnull NSData *)data
                            passphras:(nonnull NSString *)passphras;

- (nonnull NSData *)decryptAttachmentSingleKey:(nonnull NSData *)key
                                          data:(nonnull NSData *)data
                                    privateKey:(nonnull NSString *)privateKey
                                     passphras:(nonnull NSString *)passphras;

- (nonnull NSData *)decryptAttachmentWithPassword:(nonnull NSData *)key
                                             data:(nonnull NSData *)data
                                         password:(nonnull NSString *)password;

- (nonnull NSData *)getPublicKeySessionKey:(nonnull NSData *)keyPackage
                                passphrase:(nonnull NSString *)passphrase;

- (nonnull NSData *)getPublicKeySessionKeySingleKey:(nonnull NSData *)keyPackage
                                         privateKey:(nonnull NSString *)privateKey
                                         passphrase:(nonnull NSString *)passphrase;

- (nonnull NSData *)getSymmetricSessionKey:(nonnull NSData *)keyPackage
                                  password:(nonnull NSString *)password;

- (nonnull NSData *)getNewPublicKeyPackage:(nonnull NSData *)session
                                 publicKey:(nonnull NSString *)publicKey;

- (nonnull NSData *)getNewSymmetricKeyPackage:(nonnull NSData *)session
                                     password:(nonnull NSString *)password;

- (nonnull NSString *)encryptMessageAes:(nonnull NSString *)plainText
                               password:(nonnull NSString *)password;

- (nonnull NSString *)decryptMessageAes:(nonnull NSString *)encryptedMessage
                               password:(nonnull NSString *)password;

- (nonnull NSString *)encryptMailboxPwd:(nonnull NSString *)unencryptedPwd
                                   salt:(nonnull NSString *)salt;

- (nonnull NSString *)decryptMailboxPwd:(nonnull NSString *)encryptedPwd
                                   salt:(nonnull NSString *)salt;

- (nonnull NSString *)readClearsignedMessage:(nonnull NSString *)signedMessage;

/**test functions */
- (int32_t)throwAnException;

/**PBE */
- (nonnull NSString *)encryptHashCbc:(nonnull NSString *)plainText
                            password:(nonnull NSString *)password;

- (nonnull NSString *)decryptHashCbc:(nonnull NSString *)encryptedText
                            password:(nonnull NSString *)password;

@end
