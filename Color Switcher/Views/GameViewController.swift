import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    private let viewModel: GameViewModel
    private var gameScene: ColorGameScene?
    private var hasStarted = false
    
    private let skView: SKView = {
        let view = SKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.ignoresSiblingOrder = true
        return view
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let finalScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.green.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nextLevelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next Level", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.yellow.uiColor
        button.layer.cornerRadius = 12
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Menu", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.blue.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(level: Level) {
        self.viewModel = GameViewModel(level: level)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !hasStarted && skView.bounds.width > 0 && skView.bounds.height > 0 {
            hasStarted = true
            startGame()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateOrientation()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func updateOrientation() {
        guard let windowScene = view.window?.windowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait)) { _ in }
        setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
        
        view.addSubview(skView)
        view.addSubview(scoreLabel)
        view.addSubview(levelLabel)
        view.addSubview(pauseButton)
        view.addSubview(overlayView)
        
        overlayView.addSubview(resultTitleLabel)
        overlayView.addSubview(finalScoreLabel)
        overlayView.addSubview(retryButton)
        overlayView.addSubview(nextLevelButton)
        overlayView.addSubview(menuButton)
        
        levelLabel.text = viewModel.level.name
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            levelLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            pauseButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pauseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pauseButton.widthAnchor.constraint(equalToConstant: 44),
            pauseButton.heightAnchor.constraint(equalToConstant: 44),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultTitleLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            resultTitleLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -100),
            
            finalScoreLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 20),
            finalScoreLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            
            retryButton.topAnchor.constraint(equalTo: finalScoreLabel.bottomAnchor, constant: 40),
            retryButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 180),
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            nextLevelButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 15),
            nextLevelButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            nextLevelButton.widthAnchor.constraint(equalToConstant: 180),
            nextLevelButton.heightAnchor.constraint(equalToConstant: 50),
            
            menuButton.topAnchor.constraint(equalTo: nextLevelButton.bottomAnchor, constant: 15),
            menuButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 180),
            menuButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        nextLevelButton.addTarget(self, action: #selector(nextLevelTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.onScoreChanged = { [weak self] score in
            self?.scoreLabel.text = "\(score)"
        }
        
        viewModel.onGameOver = { [weak self] score, time in
            self?.showResult(score: score, completed: false)
        }
    }
    
    func startGame() {
        overlayView.isHidden = true
        scoreLabel.text = "0"
        viewModel.startGame()
        
        let sceneSize = skView.bounds.size
        gameScene = ColorGameScene(size: sceneSize, level: viewModel.level)
        gameScene?.scaleMode = .aspectFill
        gameScene?.gameDelegate = self
        skView.presentScene(gameScene)
    }
    
    private func showResult(score: Int, completed: Bool) {
        if completed {
            resultTitleLabel.text = "Level Complete!"
            resultTitleLabel.textColor = GameColor.green.uiColor
            retryButton.setTitle("Play Again", for: .normal)
            
            let nextLevelId = viewModel.level.id + 1
            let hasNextLevel = Level.allLevels.contains { $0.id == nextLevelId }
            nextLevelButton.isHidden = !hasNextLevel
        } else {
            resultTitleLabel.text = "Game Over"
            resultTitleLabel.textColor = .white
            retryButton.setTitle("Retry", for: .normal)
            nextLevelButton.isHidden = true
        }
        
        finalScoreLabel.text = "Score: \(score)"
        overlayView.isHidden = false
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1
        }
    }
    
    @objc private func pauseTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        gameScene?.isPaused.toggle()
        pauseButton.setImage(UIImage(systemName: gameScene?.isPaused == true ? "play.fill" : "pause.fill"), for: .normal)
    }
    
    @objc private func retryTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        startGame()
    }
    
    @objc private func nextLevelTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        let nextLevelId = viewModel.level.id + 1
        guard let nextLevel = Level.allLevels.first(where: { $0.id == nextLevelId }) else { return }
        
        let nextGameVC = GameViewController(level: nextLevel)
        var viewControllers = navigationController?.viewControllers ?? []
        viewControllers.removeLast()
        viewControllers.append(nextGameVC)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @objc private func menuTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        navigationController?.popToRootViewController(animated: true)
    }
}

extension GameViewController: ColorGameSceneDelegate {
    func didPassRing() {
        viewModel.addScore()
    }
    
    func didCollide() {
        viewModel.endGame(completed: false)
    }
    
    func didCompleteLevel() {
        viewModel.endGame(completed: true)
        showResult(score: viewModel.score, completed: true)
    }
}
