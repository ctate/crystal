class KeychainService {
    func apiKeyExists() -> Bool {
        if let _ = load(key: "\(bundleIdentifier).OpenAIApiKey"), let _ = load(key: "\(bundleIdentifier).GoogleApiKey"), let _ = load(key: "\(bundleIdentifier).GoogleSearchEngineId") {
            return true
        } else {
            return false
        }
    }
}
