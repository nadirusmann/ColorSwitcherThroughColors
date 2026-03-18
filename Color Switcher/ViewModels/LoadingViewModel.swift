import UIKit
import StoreKit

enum LoadingResult {
    case showContent(link: String)
    case showGame
}

final class LoadingViewModel {
    
    private let storage = StorageService.shared
    private let network = NetworkService.shared
    
    var onLoadingComplete: ((LoadingResult) -> Void)?
    
    private var shouldRequestReview = false
    
    func checkAccessOnLaunch() {
        let hadTokenBefore = storage.accessToken != nil && !storage.accessToken!.isEmpty
        
        if hadTokenBefore, let link = storage.contentLink {
            if !storage.hasRequestedReview {
                shouldRequestReview = true
            }
            onLoadingComplete?(.showContent(link: link))
            return
        }
        
        network.checkAccess { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                if let data = data {
                    self.storage.accessToken = data.token
                    self.storage.contentLink = data.link
                    self.onLoadingComplete?(.showContent(link: data.link))
                } else {
                    self.onLoadingComplete?(.showGame)
                }
            case .failure:
                self.onLoadingComplete?(.showGame)
            }
        }
    }
    
    func requestReviewIfNeeded() {
        guard shouldRequestReview else { return }
        guard !storage.hasRequestedReview else { return }
        
        storage.hasRequestedReview = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
}
