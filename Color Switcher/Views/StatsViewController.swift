import UIKit

final class StatsViewController: UIViewController {
    
    private let viewModel = StatsViewModel()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Statistics"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStats()
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
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func refreshStats() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let overall = viewModel.overallStats
        contentStack.addArrangedSubview(createOverallStatsCard(stats: overall))
        
        let levelsHeader = createSectionHeader(title: "Level Progress")
        contentStack.addArrangedSubview(levelsHeader)
        
        for levelStat in viewModel.statsData {
            let card = createLevelCard(stats: levelStat)
            contentStack.addArrangedSubview(card)
        }
    }
    
    private func createOverallStatsCard(stats: OverallStats) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let row1 = UIStackView()
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 10
        row1.translatesAutoresizingMaskIntoConstraints = false
        
        row1.addArrangedSubview(createStatItem(value: "\(stats.levelsCompleted)/\(stats.totalLevels)", label: "Completed", color: GameColor.green.uiColor))
        row1.addArrangedSubview(createStatItem(value: "\(stats.totalGames)", label: "Games", color: GameColor.blue.uiColor))
        row1.addArrangedSubview(createStatItem(value: String(format: "%.0f%%", stats.overallWinRate), label: "Win Rate", color: GameColor.yellow.uiColor))
        
        let row2 = UIStackView()
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 10
        row2.translatesAutoresizingMaskIntoConstraints = false
        
        row2.addArrangedSubview(createStatItem(value: "\(stats.totalWins)", label: "Wins", color: GameColor.green.uiColor))
        row2.addArrangedSubview(createStatItem(value: "\(stats.totalLosses)", label: "Losses", color: GameColor.red.uiColor))
        row2.addArrangedSubview(createStatItem(value: "\(stats.totalHighScore)", label: "Total Best", color: .white))
        
        card.addSubview(row1)
        card.addSubview(row2)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 160),
            
            row1.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            row1.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            row1.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            row1.heightAnchor.constraint(equalToConstant: 60),
            
            row2.topAnchor.constraint(equalTo: row1.bottomAnchor, constant: 10),
            row2.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            row2.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            row2.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return card
    }
    
    private func createStatItem(value: String, label: String, color: UIColor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        return container
    }
    
    private func createSectionHeader(title: String) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createLevelCard(stats: LevelStatDisplay) -> UIView {
        let colors: [UIColor] = [
            GameColor.red.uiColor,
            GameColor.blue.uiColor,
            GameColor.green.uiColor,
            GameColor.yellow.uiColor
        ]
        let accentColor = colors[(stats.levelId - 1) % colors.count]
        
        let card = UIView()
        card.backgroundColor = accentColor.withAlphaComponent(0.15)
        card.layer.cornerRadius = 14
        card.layer.borderWidth = stats.isCompleted ? 2 : 0
        card.layer.borderColor = GameColor.green.uiColor.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let levelLabel = UILabel()
        levelLabel.text = "Level \(stats.levelId)"
        levelLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        levelLabel.textColor = accentColor
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = stats.levelName
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let completedIcon = UIImageView(image: UIImage(systemName: stats.isCompleted ? "checkmark.circle.fill" : "circle"))
        completedIcon.tintColor = stats.isCompleted ? GameColor.green.uiColor : .gray
        completedIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let progressContainer = UIView()
        progressContainer.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        progressContainer.layer.cornerRadius = 4
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let progressBar = UIView()
        let progress = min(CGFloat(stats.highScore) / CGFloat(stats.targetScore), 1.0)
        progressBar.backgroundColor = accentColor
        progressBar.layer.cornerRadius = 4
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        let scoreLabel = UILabel()
        scoreLabel.text = "Best: \(stats.highScore)/\(stats.targetScore)"
        scoreLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        scoreLabel.textColor = .white
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let statsRow = UIStackView()
        statsRow.axis = .horizontal
        statsRow.distribution = .equalSpacing
        statsRow.translatesAutoresizingMaskIntoConstraints = false
        
        let gamesLabel = createSmallStat(icon: "gamecontroller.fill", value: "\(stats.gamesPlayed)", color: .lightGray)
        let winsLabel = createSmallStat(icon: "trophy.fill", value: "\(stats.wins)", color: GameColor.green.uiColor)
        let winRateLabel = createSmallStat(icon: "percent", value: String(format: "%.0f", stats.winRate), color: GameColor.yellow.uiColor)
        let timeLabel = createSmallStat(icon: "clock.fill", value: stats.bestTime, color: GameColor.blue.uiColor)
        
        statsRow.addArrangedSubview(gamesLabel)
        statsRow.addArrangedSubview(winsLabel)
        statsRow.addArrangedSubview(winRateLabel)
        statsRow.addArrangedSubview(timeLabel)
        
        card.addSubview(levelLabel)
        card.addSubview(nameLabel)
        card.addSubview(completedIcon)
        card.addSubview(progressContainer)
        progressContainer.addSubview(progressBar)
        card.addSubview(scoreLabel)
        card.addSubview(statsRow)
        
        let progressWidth = UIScreen.main.bounds.width - 80
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 120),
            
            levelLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            levelLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            
            nameLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            
            completedIcon.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
            completedIcon.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            completedIcon.widthAnchor.constraint(equalToConstant: 24),
            completedIcon.heightAnchor.constraint(equalToConstant: 24),
            
            progressContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            progressContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            progressContainer.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            progressContainer.heightAnchor.constraint(equalToConstant: 8),
            
            progressBar.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor),
            progressBar.widthAnchor.constraint(equalTo: progressContainer.widthAnchor, multiplier: progress),
            
            scoreLabel.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 4),
            scoreLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            
            statsRow.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            statsRow.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
            statsRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
            statsRow.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return card
    }
    
    private func createSmallStat(icon: String, value: String, color: UIColor) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 4
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        let label = UILabel()
        label.text = value
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addArrangedSubview(iconView)
        container.addArrangedSubview(label)
        
        return container
    }
    
    @objc private func backTapped() {
        HapticService.shared.selection()
        navigationController?.popViewController(animated: true)
    }
}
