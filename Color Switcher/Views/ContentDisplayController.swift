import UIKit
import WebKit

final class ContentDisplayController: UIViewController {
    
    private let viewModel: ContentDisplayViewModel
    private var isFirstLoad = true
    
    private let contentView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.allowsBackForwardNavigationGestures = true
        return view
    }()
    
    private let loadingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(address: String) {
        self.viewModel = ContentDisplayViewModel(address: address)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateOrientation()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func updateOrientation() {
        guard let windowScene = view.window?.windowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all)) { _ in }
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        view.addSubview(loadingContainer)
        loadingContainer.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingContainer.topAnchor.constraint(equalTo: view.topAnchor),
            loadingContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor)
        ])
        
        contentView.navigationDelegate = self
    }
    
    private func loadContent() {
        loadingContainer.isHidden = false
        loadingIndicator.startAnimating()
        
        if let request = viewModel.getRequest() {
            contentView.load(request)
        }
    }
}

extension ContentDisplayController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isFirstLoad {
            isFirstLoad = false
            UIView.animate(withDuration: 0.3) {
                self.loadingContainer.alpha = 0
            } completion: { _ in
                self.loadingContainer.isHidden = true
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingContainer.isHidden = true
        loadingIndicator.stopAnimating()
    }
}
