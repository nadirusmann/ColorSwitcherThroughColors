import Foundation
import UIKit

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private var deviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.lowercased()
    }
    
    private var systemLanguage: String {
        let language = Locale.preferredLanguages.first ?? "en"
        if let dashIndex = language.firstIndex(of: "-") {
            return String(language[..<dashIndex])
        }
        return language
    }
    
    private var countryCode: String {
        return Locale.current.region?.identifier ?? "US"
    }
    
    private var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    func checkAccess(completion: @escaping (Result<(token: String, link: String)?, Error>) -> Void) {
        let baseAddress = "https://infoaitextapps.site/ios-colorswitcher-throughcolors/server.php"
        var components = URLComponents(string: baseAddress)
        components?.queryItems = [
            URLQueryItem(name: "p", value: "Bs2675kDjkb5Ga"),
            URLQueryItem(name: "os", value: osVersion),
            URLQueryItem(name: "lng", value: systemLanguage),
            URLQueryItem(name: "devicemodel", value: deviceIdentifier),
            URLQueryItem(name: "country", value: countryCode)
        ]
        
        guard let requestAddress = components?.url else {
            completion(.failure(NSError(domain: "NetworkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid address"])))
            return
        }
        
        var request = URLRequest(url: requestAddress)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.timeoutInterval = 30
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
                return
            }
            
            if responseString.contains("#") {
                let parts = responseString.components(separatedBy: "#")
                if parts.count >= 2 {
                    let token = parts[0]
                    let link = parts[1]
                    DispatchQueue.main.async {
                        completion(.success((token: token, link: link)))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(nil))
                }
            }
        }
        task.resume()
    }
}
