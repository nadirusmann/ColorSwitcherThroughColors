import UIKit

final class MainMenuViewController: UIViewController {
    
    private let viewModel = MainMenuViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Color Switcher"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ballImageView: UIView = {
        let view = UIView()
        view.backgroundColor = GameColor.red.uiColor
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.blue.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Statistics", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.green.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.yellow.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let howToPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("How to Play", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.red.uiColor.withAlphaComponent(0.8)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        startBallAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStats()
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
        
        view.addSubview(titleLabel)
        view.addSubview(ballImageView)
        view.addSubview(playButton)
        view.addSubview(statsButton)
        view.addSubview(settingsButton)
        view.addSubview(howToPlayButton)
        view.addSubview(highScoreLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            ballImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            ballImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ballImageView.widthAnchor.constraint(equalToConstant: 80),
            ballImageView.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            statsButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            statsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsButton.widthAnchor.constraint(equalToConstant: 200),
            statsButton.heightAnchor.constraint(equalToConstant: 50),
            
            settingsButton.topAnchor.constraint(equalTo: statsButton.bottomAnchor, constant: 15),
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            howToPlayButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 15),
            howToPlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            howToPlayButton.widthAnchor.constraint(equalToConstant: 200),
            howToPlayButton.heightAnchor.constraint(equalToConstant: 50),
            
            highScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            highScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        statsButton.addTarget(self, action: #selector(statsTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        howToPlayButton.addTarget(self, action: #selector(howToPlayTapped), for: .touchUpInside)
    }
    
    private func updateStats() {
        highScoreLabel.text = "Total High Score: \(viewModel.totalHighScore)"
    }
    
    private func startBallAnimation() {
        let colors = GameColor.allCases.map { $0.uiColor }
        var colorIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            colorIndex = (colorIndex + 1) % colors.count
            UIView.animate(withDuration: 0.3) {
                self.ballImageView.backgroundColor = colors[colorIndex]
            }
        }
    }
    
    @objc private func playTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        let levelSelectVC = LevelSelectViewController()
        navigationController?.pushViewController(levelSelectVC, animated: true)
    }
    
    @objc private func statsTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        let statsVC = StatsViewController()
        navigationController?.pushViewController(statsVC, animated: true)
    }
    
    @objc private func settingsTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func howToPlayTapped() {
        HapticService.shared.selection()
        SoundService.shared.playButtonClick()
        let howToPlayVC = HowToPlayViewController()
        navigationController?.pushViewController(howToPlayVC, animated: true)
    }
}
