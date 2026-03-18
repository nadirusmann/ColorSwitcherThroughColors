import UIKit

final class LoadingViewController: UIViewController {
    
    private let viewModel = LoadingViewModel()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkAccessOnLaunch()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    private func bindViewModel() {
        viewModel.onLoadingComplete = { [weak self] result in
            DispatchQueue.main.async {
                self?.handleResult(result)
            }
        }
    }
    
    private func handleResult(_ result: LoadingResult) {
        switch result {
        case .showContent(let link):
            let contentVC = ContentDisplayController(address: link)
            let vm = viewModel
            setRootViewController(contentVC) {
                vm.requestReviewIfNeeded()
            }
        case .showGame:
            let menuVC = MainMenuViewController()
            let navController = UINavigationController(rootViewController: menuVC)
            navController.setNavigationBarHidden(true, animated: false)
            setRootViewController(navController, completion: nil)
        }
    }
    
    private func setRootViewController(_ viewController: UIViewController, completion: (() -> Void)?) {
        guard let window = view.window else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: { _ in
            completion?()
        })
    }
}
