import Foundation
import Security

func delete(_ key: String) -> OSStatus {
    let query = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key ] as [String : Any]

    return SecItemDelete(query as CFDictionary)
}

func load(_ key: String) -> Data? {
    let query = [
        kSecClass as String       : kSecClassGenericPassword,
        kSecAttrAccount as String : key,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

    var item: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == noErr else { return nil }
    return item as? Data
}

func save(_ key: String, data: Data) -> OSStatus {
    let query = [
        kSecClass as String       : kSecClassGenericPassword as String,
        kSecAttrAccount as String : key,
        kSecValueData as String   : data ] as [String : Any]

    SecItemDelete(query as CFDictionary)
    return SecItemAdd(query as CFDictionary, nil)
}
