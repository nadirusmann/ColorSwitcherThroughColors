import Foundation

final class ContentDisplayViewModel {
    
    let contentAddress: String
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    init(address: String) {
        self.contentAddress = address
    }
    
    func getRequest() -> URLRequest? {
        guard let destination = URL(string: contentAddress) else { return nil }
        var request = URLRequest(url: destination)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        return request
    }
}
