//
//  KeychainUtils.swift
//  CardinalDebugToolkit
//
//  Copyright (c) 2017 Cardinal Solutions (https://www.cardinalsolutions.com/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// Based on KeychainAccess by Kishikawa Katsumi (https://github.com/kishikawakatsumi/KeychainAccess)

import Foundation
import Security

internal final class Keychain {
    internal class func allItems(forItemClass itemClass: ItemClass) -> [[String: Any]] {
        let query: [String: Any] = [
            KeychainItemClass: itemClass.rawValue,
            MatchLimit: MatchLimitAll,
            ReturnAttributes: kCFBooleanTrue,
            ReturnData: kCFBooleanTrue,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let results = result as? [[String: Any]] {
            return Keychain.prettify(itemClass: itemClass, items: results)
        }

        return []
    }

    fileprivate class func prettify(itemClass: ItemClass, items: [[String: Any]]) -> [[String: Any]] {
        var translationDict: [String: String] = [
            AttributeAccessControl: "accessControl",
            AttributeAccessGroup: "accessGroup",
            AttributeAccessible: "accessible",
            AttributeAccount: "account",
            AttributeApplicationLabel: "applicationLabel",
            AttributeApplicationTag: "applicationTag",
            AttributeAuthenticationType: "authenticationType",
            AttributeCanDecrypt: "canDecrypt",
            AttributeCanDerive: "canDerive",
            AttributeCanEncrypt: "canEncrypt",
            AttributeCanSign: "canSign",
            AttributeCanUnwrap: "canUnwrap",
            AttributeCanVerify: "canVerify",
            AttributeCanWrap: "canWrap",
            AttributeCertificateEncoding: "certificateEncoding",
            AttributeCertificateType: "certificateType",
            AttributeComment: "comment",
            AttributeCreationDate: "creationDate",
            AttributeCreator: "creator",
            AttributeDescription: "description",
            AttributeEffectiveKeySize: "effectiveKeySize",
            AttributeGeneric: "generic",
            AttributeIsExtractable: "isExtractable",
            AttributeIsInvisible: "isInvisible",
            AttributeIsNegative: "isNegative",
            AttributeIsPermanent: "isPermanent",
            AttributeIsSensitive: "isSensitive",
            AttributeIssuer: "issuer",
            AttributeKeyClass: "keyClass",
            AttributeKeySizeInBits: "keySizeInBits",
//            AttributeKeyType: "keyType",
            AttributeLabel: "label",
            AttributeModificationDate: "modificationDate",
//            AttributePRF: "prf",
            AttributePath: "path",
            AttributePort: "port",
            AttributeProtocol: "protocol",
            AttributePublicKeyHash: "publicKeyHash",
//            AttributeRounds: "rounds",
//            AttributeSalt: "salt",
            AttributeSecurityDomain: "securityDomain",
            AttributeSerialNumber: "serialNumber",
            AttributeServer: "server",
            AttributeService: "service",
            AttributeSubject: "subject",
            AttributeSubjectKeyID: "subjectKeyID",
            AttributeSyncViewHint: "syncViewHint",
            AttributeSynchronizable: "synchronizable",
            AttributeTokenID: "tokenID",
            AttributeType: "type",
            ValueData: "value",
        ]

        if #available(iOS 10.0, *) {
            translationDict[AttributeAccessGroupToken] = "accessGroupToken"
        }
        if #available(iOS 11.0, *) {
            translationDict[AttributePersistantReference] = "persistantReference"
            translationDict[AttributePersistentReference] = "persistentReference"
        }

        let items = items.map { attributes -> [String: Any] in
            var item = [String: Any]()

            for (key, value) in attributes {
                if let displayKey = translationDict[key] {
                    item[displayKey] = value
                } else {
                    item[key] = value
                }
            }

            item["class"] = itemClass.description

            if let proto = item["protocol"] as? String {
                if let protocolType = ProtocolType(rawValue: proto) {
                    item["protocol"] = protocolType.description
                }
            }
            if let auth = item["authenticationType"] as? String {
                if let authenticationType = AuthenticationType(rawValue: auth) {
                    item["authenticationType"] = authenticationType.description
                }
            }
            if let accessible = item["accessible"] as? String {
                if let accessibility = Accessibility(rawValue: accessible) {
                    item["accessibility"] = accessibility.description
                    item["accessible"] = nil
                }
            }
            if let synchronizable = item["synchronizable"] as? Bool {
                item["synchronizable"] = synchronizable ? "true" : "false"
            }
            if itemClass == .key {
                item["keyType"] = item[AttributeKeyType]
                item[AttributeKeyType] = nil
            }

            return item
        }
        return items
    }
}

/** Class Key Constant */
private let KeychainItemClass = String(kSecClass)

/** Attribute Key Constants */

//private let AttributeAccess = String(kSecAttrAccess)
private let AttributeAccessControl = String(kSecAttrAccessControl)
private let AttributeAccessGroup = String(kSecAttrAccessGroup)
@available(iOS 10.0, *)
private let AttributeAccessGroupToken = String(kSecAttrAccessGroupToken)
private let AttributeAccessible = String(kSecAttrAccessible)
private let AttributeAccount = String(kSecAttrAccount)
private let AttributeApplicationLabel = String(kSecAttrApplicationLabel)
private let AttributeApplicationTag = String(kSecAttrApplicationTag)
private let AttributeAuthenticationType = String(kSecAttrAuthenticationType)
private let AttributeCanDecrypt = String(kSecAttrCanDecrypt)
private let AttributeCanDerive = String(kSecAttrCanDerive)
private let AttributeCanEncrypt = String(kSecAttrCanEncrypt)
private let AttributeCanSign = String(kSecAttrCanSign)
private let AttributeCanUnwrap = String(kSecAttrCanUnwrap)
private let AttributeCanVerify = String(kSecAttrCanVerify)
private let AttributeCanWrap = String(kSecAttrCanWrap)
private let AttributeCertificateEncoding = String(kSecAttrCertificateEncoding)
private let AttributeCertificateType = String(kSecAttrCertificateType)
private let AttributeComment = String(kSecAttrComment)
private let AttributeCreationDate = String(kSecAttrCreationDate)
private let AttributeCreator = String(kSecAttrCreator)
private let AttributeDescription = String(kSecAttrDescription)
private let AttributeEffectiveKeySize = String(kSecAttrEffectiveKeySize)
private let AttributeGeneric = String(kSecAttrGeneric)
private let AttributeIsExtractable = String(kSecAttrIsExtractable)
private let AttributeIsInvisible = String(kSecAttrIsInvisible)
private let AttributeIsNegative = String(kSecAttrIsNegative)
private let AttributeIsPermanent = String(kSecAttrIsPermanent)
private let AttributeIsSensitive = String(kSecAttrIsSensitive)
private let AttributeIssuer = String(kSecAttrIssuer)
private let AttributeKeyClass = String(kSecAttrKeyClass)
private let AttributeKeySizeInBits = String(kSecAttrKeySizeInBits)
private let AttributeKeyType = String(kSecAttrKeyType)
private let AttributeLabel = String(kSecAttrLabel)
private let AttributeModificationDate = String(kSecAttrModificationDate)
//private let AttributePRF = String(kSecAttrPRF)
private let AttributePath = String(kSecAttrPath)
@available(iOS 11.0, *)
private let AttributePersistantReference = String(kSecAttrPersistantReference)
@available(iOS 11.0, *)
private let AttributePersistentReference = String(kSecAttrPersistentReference)
private let AttributePort = String(kSecAttrPort)
private let AttributeProtocol = String(kSecAttrProtocol)
private let AttributePublicKeyHash = String(kSecAttrPublicKeyHash)
//private let AttributeRounds = String(kSecAttrRounds)
//private let AttributeSalt = String(kSecAttrSalt)
private let AttributeSecurityDomain = String(kSecAttrSecurityDomain)
private let AttributeSerialNumber = String(kSecAttrSerialNumber)
private let AttributeServer = String(kSecAttrServer)
private let AttributeService = String(kSecAttrService)
private let AttributeSubject = String(kSecAttrSubject)
private let AttributeSubjectKeyID = String(kSecAttrSubjectKeyID)
private let AttributeSyncViewHint = String(kSecAttrSyncViewHint)
private let AttributeSynchronizable = String(kSecAttrSynchronizable)
private let AttributeTokenID = String(kSecAttrTokenID)
private let AttributeType = String(kSecAttrType)

/** Certificate Encoding Constants */
//private let AttributeCertificateEncodingDER = String(kSecAttrCertificateEncodingDER)

/** Key Class Constants */
private let KeyClassPrivate = String(kSecAttrKeyClassPrivate)
private let KeyClassinternal = String(kSecAttrKeyClassPublic)
private let KeyClassSymmetric = String(kSecAttrKeyClassSymmetric)

/** Key Type Constants */
//private let KeyTypeAES = String(kSecAttrKeyTypeAES)
//private let KeyTypeCAST = String(kSecAttrKeyTypeCAST)
//private let KeyTypeDSA = String(kSecAttrKeyTypeDSA)
private let KeyTypeEC = String(kSecAttrKeyTypeEC)
//private let KeyTypeECDSA = String(kSecAttrKeyTypeECDSA)
@available(iOS 10.0, *)
private let KeyTypeECSECPrimeRandom = String(kSecAttrKeyTypeECSECPrimeRandom)
//private let KeyTypeRC4 = String(kSecAttrKeyTypeRC4)
//private let KeyTypeRC2 = String(kSecAttrKeyTypeRC2)
private let KeyTypeRSA = String(kSecAttrKeyTypeRSA)

/** Synchronizable Constants */
private let SynchronizableAny = kSecAttrSynchronizableAny

/** Search Constants */
private let MatchLimit = String(kSecMatchLimit)
private let MatchLimitOne = kSecMatchLimitOne
private let MatchLimitAll = kSecMatchLimitAll

/** Token ID Constants */
private let AttributeTokenIDSecureEnclave = String(kSecAttrTokenIDSecureEnclave)

/** Return Type Key Constants */
private let ReturnData = String(kSecReturnData)
private let ReturnAttributes = String(kSecReturnAttributes)
private let ReturnRef = String(kSecReturnRef)
private let ReturnPersistentRef = String(kSecReturnPersistentRef)

/** Value Type Key Constants */
private let ValueData = String(kSecValueData)
private let ValueRef = String(kSecValueRef)
private let ValuePersistentRef = String(kSecValuePersistentRef)


// MARK:

internal enum ItemClass {
    case certificate
    case genericPassword
    case identity
    case internetPassword
    case key
}

extension ItemClass: RawRepresentable, CustomStringConvertible {
    internal init?(rawValue: String) {
        switch rawValue {
        case String(kSecClassCertificate): self = .certificate
        case String(kSecClassGenericPassword): self = .genericPassword
        case String(kSecClassIdentity): self = .identity
        case String(kSecClassInternetPassword): self = .internetPassword
        case String(kSecClassKey): self = .key
        default: return nil
        }
    }

    internal var rawValue: String {
        switch self {
        case .certificate: return String(kSecClassCertificate)
        case .genericPassword: return String(kSecClassGenericPassword)
        case .identity: return String(kSecClassIdentity)
        case .internetPassword: return String(kSecClassInternetPassword)
        case .key: return String(kSecClassKey)
        }
    }

    internal var description: String {
        switch self {
        case .certificate: return "Certificate"
        case .genericPassword: return "GenericPassword"
        case .identity: return "Identity"
        case .internetPassword: return "InternetPassword"
        case .key: return "Key"
        }
    }
}

internal enum ProtocolType {
    case ftp
    case ftpAccount
    case http
    case irc
    case nntp
    case pop3
    case smtp
    case socks
    case imap
    case ldap
    case appleTalk
    case afp
    case telnet
    case ssh
    case ftps
    case https
    case httpProxy
    case httpsProxy
    case ftpProxy
    case smb
    case rtsp
    case rtspProxy
    case daap
    case eppc
    case ipp
    case nntps
    case ldaps
    case telnetS
    case imaps
    case ircs
    case pop3S
}

extension ProtocolType: RawRepresentable, CustomStringConvertible {
    internal init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrProtocolFTP): self = .ftp
        case String(kSecAttrProtocolFTPAccount): self = .ftpAccount
        case String(kSecAttrProtocolHTTP): self = .http
        case String(kSecAttrProtocolIRC): self = .irc
        case String(kSecAttrProtocolNNTP): self = .nntp
        case String(kSecAttrProtocolPOP3): self = .pop3
        case String(kSecAttrProtocolSMTP): self = .smtp
        case String(kSecAttrProtocolSOCKS): self = .socks
        case String(kSecAttrProtocolIMAP): self = .imap
        case String(kSecAttrProtocolLDAP): self = .ldap
        case String(kSecAttrProtocolAppleTalk): self = .appleTalk
        case String(kSecAttrProtocolAFP): self = .afp
        case String(kSecAttrProtocolTelnet): self = .telnet
        case String(kSecAttrProtocolSSH): self = .ssh
        case String(kSecAttrProtocolFTPS): self = .ftps
        case String(kSecAttrProtocolHTTPS): self = .https
        case String(kSecAttrProtocolHTTPProxy): self = .httpProxy
        case String(kSecAttrProtocolHTTPSProxy): self = .httpsProxy
        case String(kSecAttrProtocolFTPProxy): self = .ftpProxy
        case String(kSecAttrProtocolSMB): self = .smb
        case String(kSecAttrProtocolRTSP): self = .rtsp
        case String(kSecAttrProtocolRTSPProxy): self = .rtspProxy
        case String(kSecAttrProtocolDAAP): self = .daap
        case String(kSecAttrProtocolEPPC): self = .eppc
        case String(kSecAttrProtocolIPP): self = .ipp
        case String(kSecAttrProtocolNNTPS): self = .nntps
        case String(kSecAttrProtocolLDAPS): self = .ldaps
        case String(kSecAttrProtocolTelnetS): self = .telnetS
        case String(kSecAttrProtocolIMAPS): self = .imaps
        case String(kSecAttrProtocolIRCS): self = .ircs
        case String(kSecAttrProtocolPOP3S): self = .pop3S
        default: return nil
        }
    }

    internal var rawValue: String {
        switch self {
        case .ftp: return String(kSecAttrProtocolFTP)
        case .ftpAccount: return String(kSecAttrProtocolFTPAccount)
        case .http: return String(kSecAttrProtocolHTTP)
        case .irc: return String(kSecAttrProtocolIRC)
        case .nntp: return String(kSecAttrProtocolNNTP)
        case .pop3: return String(kSecAttrProtocolPOP3)
        case .smtp: return String(kSecAttrProtocolSMTP)
        case .socks: return String(kSecAttrProtocolSOCKS)
        case .imap: return String(kSecAttrProtocolIMAP)
        case .ldap: return String(kSecAttrProtocolLDAP)
        case .appleTalk: return String(kSecAttrProtocolAppleTalk)
        case .afp: return String(kSecAttrProtocolAFP)
        case .telnet: return String(kSecAttrProtocolTelnet)
        case .ssh: return String(kSecAttrProtocolSSH)
        case .ftps: return String(kSecAttrProtocolFTPS)
        case .https: return String(kSecAttrProtocolHTTPS)
        case .httpProxy: return String(kSecAttrProtocolHTTPProxy)
        case .httpsProxy: return String(kSecAttrProtocolHTTPSProxy)
        case .ftpProxy: return String(kSecAttrProtocolFTPProxy)
        case .smb: return String(kSecAttrProtocolSMB)
        case .rtsp: return String(kSecAttrProtocolRTSP)
        case .rtspProxy: return String(kSecAttrProtocolRTSPProxy)
        case .daap: return String(kSecAttrProtocolDAAP)
        case .eppc: return String(kSecAttrProtocolEPPC)
        case .ipp: return String(kSecAttrProtocolIPP)
        case .nntps: return String(kSecAttrProtocolNNTPS)
        case .ldaps: return String(kSecAttrProtocolLDAPS)
        case .telnetS: return String(kSecAttrProtocolTelnetS)
        case .imaps: return String(kSecAttrProtocolIMAPS)
        case .ircs: return String(kSecAttrProtocolIRCS)
        case .pop3S: return String(kSecAttrProtocolPOP3S)
        }
    }

    internal var description: String {
        switch self {
        case .ftp: return "FTP"
        case .ftpAccount: return "FTPAccount"
        case .http: return "HTTP"
        case .irc: return "IRC"
        case .nntp: return "NNTP"
        case .pop3: return "POP3"
        case .smtp: return "SMTP"
        case .socks: return "SOCKS"
        case .imap: return "IMAP"
        case .ldap: return "LDAP"
        case .appleTalk: return "AppleTalk"
        case .afp: return "AFP"
        case .telnet: return "Telnet"
        case .ssh: return "SSH"
        case .ftps: return "FTPS"
        case .https: return "HTTPS"
        case .httpProxy: return "HTTPProxy"
        case .httpsProxy: return "HTTPSProxy"
        case .ftpProxy: return "FTPProxy"
        case .smb: return "SMB"
        case .rtsp: return "RTSP"
        case .rtspProxy: return "RTSPProxy"
        case .daap: return "DAAP"
        case .eppc: return "EPPC"
        case .ipp: return "IPP"
        case .nntps: return "NNTPS"
        case .ldaps: return "LDAPS"
        case .telnetS: return "TelnetS"
        case .imaps: return "IMAPS"
        case .ircs: return "IRCS"
        case .pop3S: return "POP3S"
        }
    }
}

internal enum AuthenticationType {
    case ntlm
    case msn
    case dpa
    case rpa
    case httpBasic
    case httpDigest
    case htmlForm
    case `default`
}

extension AuthenticationType: RawRepresentable, CustomStringConvertible {
    internal init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrAuthenticationTypeNTLM):
            self = .ntlm
        case String(kSecAttrAuthenticationTypeMSN):
            self = .msn
        case String(kSecAttrAuthenticationTypeDPA):
            self = .dpa
        case String(kSecAttrAuthenticationTypeRPA):
            self = .rpa
        case String(kSecAttrAuthenticationTypeHTTPBasic):
            self = .httpBasic
        case String(kSecAttrAuthenticationTypeHTTPDigest):
            self = .httpDigest
        case String(kSecAttrAuthenticationTypeHTMLForm):
            self = .htmlForm
        case String(kSecAttrAuthenticationTypeDefault):
            self = .`default`
        default:
            return nil
        }
    }

    internal var rawValue: String {
        switch self {
        case .ntlm:
            return String(kSecAttrAuthenticationTypeNTLM)
        case .msn:
            return String(kSecAttrAuthenticationTypeMSN)
        case .dpa:
            return String(kSecAttrAuthenticationTypeDPA)
        case .rpa:
            return String(kSecAttrAuthenticationTypeRPA)
        case .httpBasic:
            return String(kSecAttrAuthenticationTypeHTTPBasic)
        case .httpDigest:
            return String(kSecAttrAuthenticationTypeHTTPDigest)
        case .htmlForm:
            return String(kSecAttrAuthenticationTypeHTMLForm)
        case .`default`:
            return String(kSecAttrAuthenticationTypeDefault)
        }
    }

    internal var description: String {
        switch self {
        case .ntlm: return "NTLM"
        case .msn: return "MSN"
        case .dpa: return "DPA"
        case .rpa: return "RPA"
        case .httpBasic: return "HTTPBasic"
        case .httpDigest: return "HTTPDigest"
        case .htmlForm: return "HTMLForm"
        case .`default`: return "Default"
        }
    }
}

internal enum Accessibility {
    case whenUnlocked
    case afterFirstUnlock
    case always
    @available(iOS 8.0, OSX 10.10, *)
    case whenPasscodeSetThisDeviceOnly
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case alwaysThisDeviceOnly
}

extension Accessibility: RawRepresentable, CustomStringConvertible {
    internal init?(rawValue: String) {
        switch rawValue {
        case String(kSecAttrAccessibleWhenUnlocked):
            self = .whenUnlocked
        case String(kSecAttrAccessibleAfterFirstUnlock):
            self = .afterFirstUnlock
        case String(kSecAttrAccessibleAlways):
            self = .always
        case String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly):
            self = .whenPasscodeSetThisDeviceOnly
        case String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly):
            self = .whenUnlockedThisDeviceOnly
        case String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly):
            self = .afterFirstUnlockThisDeviceOnly
        case String(kSecAttrAccessibleAlwaysThisDeviceOnly):
            self = .alwaysThisDeviceOnly
        default:
            return nil
        }
    }

    internal var rawValue: String {
        switch self {
        case .whenUnlocked:
            return String(kSecAttrAccessibleWhenUnlocked)
        case .afterFirstUnlock:
            return String(kSecAttrAccessibleAfterFirstUnlock)
        case .always:
            return String(kSecAttrAccessibleAlways)
        case .whenPasscodeSetThisDeviceOnly:
            return String(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        case .whenUnlockedThisDeviceOnly:
            return String(kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        case .afterFirstUnlockThisDeviceOnly:
            return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        case .alwaysThisDeviceOnly:
            return String(kSecAttrAccessibleAlwaysThisDeviceOnly)
        }
    }

    internal var description: String {
        switch self {
        case .whenUnlocked: return "WhenUnlocked"
        case .afterFirstUnlock: return "AfterFirstUnlock"
        case .always: return "Always"
        case .whenPasscodeSetThisDeviceOnly: return "WhenPasscodeSetThisDeviceOnly"
        case .whenUnlockedThisDeviceOnly: return "WhenUnlockedThisDeviceOnly"
        case .afterFirstUnlockThisDeviceOnly: return "AfterFirstUnlockThisDeviceOnly"
        case .alwaysThisDeviceOnly: return "AlwaysThisDeviceOnly"
        }
    }
}
