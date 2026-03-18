import UIKit

final class SettingsViewController: UIViewController {
    
    private let viewModel = SettingsViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let vibrationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "Vibration"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let vibrationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = GameColor.green.uiColor
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let soundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let soundLabel: UILabel = {
        let label = UILabel()
        label.text = "Sound"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let soundSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = GameColor.green.uiColor
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Progress", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = GameColor.red.uiColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadSettings()
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
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(vibrationContainer)
        view.addSubview(soundContainer)
        view.addSubview(resetButton)
        
        vibrationContainer.addSubview(vibrationLabel)
        vibrationContainer.addSubview(vibrationSwitch)
        
        soundContainer.addSubview(soundLabel)
        soundContainer.addSubview(soundSwitch)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            vibrationContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            vibrationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vibrationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            vibrationContainer.heightAnchor.constraint(equalToConstant: 60),
            
            vibrationLabel.centerYAnchor.constraint(equalTo: vibrationContainer.centerYAnchor),
            vibrationLabel.leadingAnchor.constraint(equalTo: vibrationContainer.leadingAnchor, constant: 20),
            
            vibrationSwitch.centerYAnchor.constraint(equalTo: vibrationContainer.centerYAnchor),
            vibrationSwitch.trailingAnchor.constraint(equalTo: vibrationContainer.trailingAnchor, constant: -20),
            
            soundContainer.topAnchor.constraint(equalTo: vibrationContainer.bottomAnchor, constant: 15),
            soundContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            soundContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            soundContainer.heightAnchor.constraint(equalToConstant: 60),
            
            soundLabel.centerYAnchor.constraint(equalTo: soundContainer.centerYAnchor),
            soundLabel.leadingAnchor.constraint(equalTo: soundContainer.leadingAnchor, constant: 20),
            
            soundSwitch.centerYAnchor.constraint(equalTo: soundContainer.centerYAnchor),
            soundSwitch.trailingAnchor.constraint(equalTo: soundContainer.trailingAnchor, constant: -20),
            
            resetButton.topAnchor.constraint(equalTo: soundContainer.bottomAnchor, constant: 40),
            resetButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resetButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        vibrationSwitch.addTarget(self, action: #selector(vibrationChanged), for: .valueChanged)
        soundSwitch.addTarget(self, action: #selector(soundChanged), for: .valueChanged)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
    }
    
    private func loadSettings() {
        vibrationSwitch.isOn = viewModel.vibrationEnabled
        soundSwitch.isOn = viewModel.soundEnabled
    }
    
    @objc private func backTapped() {
        HapticService.shared.selection()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func vibrationChanged() {
        viewModel.vibrationEnabled = vibrationSwitch.isOn
        if vibrationSwitch.isOn {
            HapticService.shared.lightImpact()
        }
    }
    
    @objc private func soundChanged() {
        viewModel.soundEnabled = soundSwitch.isOn
        HapticService.shared.selection()
        if soundSwitch.isOn {
            SoundService.shared.playButtonClick()
        }
    }
    
    @objc private func resetTapped() {
        HapticService.shared.warning()
        
        let alert = UIAlertController(
            title: "Reset Progress",
            message: "Are you sure you want to reset all progress? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.viewModel.resetProgress()
            HapticService.shared.success()
        })
        
        present(alert, animated: true)
    }
}
