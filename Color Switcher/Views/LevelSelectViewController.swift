import UIKit

final class LevelSelectViewController: UIViewController {
    
    private let viewModel = LevelSelectViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Level"
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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
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
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LevelCell.self, forCellWithReuseIdentifier: "LevelCell")
    }
    
    @objc private func backTapped() {
        HapticService.shared.selection()
        navigationController?.popViewController(animated: true)
    }
}

extension LevelSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        let level = viewModel.levels[indexPath.item]
        let isUnlocked = viewModel.isLevelUnlocked(level)
        let stats = viewModel.getStatsForLevel(level.id)
        cell.configure(with: level, isUnlocked: isUnlocked, highScore: stats?.highScore ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 55) / 2
        return CGSize(width: width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = viewModel.levels[indexPath.item]
        guard viewModel.isLevelUnlocked(level) else {
            HapticService.shared.warning()
            return
        }
        
        HapticService.shared.selection()
        let gameVC = GameViewController(level: level)
        navigationController?.pushViewController(gameVC, animated: true)
    }
}

final class LevelCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let levelLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.9)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lockImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.tintColor = .white.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(levelLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(highScoreLabel)
        containerView.addSubview(lockImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            levelLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            highScoreLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            highScoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            lockImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lockImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            lockImageView.widthAnchor.constraint(equalToConstant: 40),
            lockImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with level: Level, isUnlocked: Bool, highScore: Int) {
        let colors: [UIColor] = [
            GameColor.red.uiColor,
            GameColor.blue.uiColor,
            GameColor.green.uiColor,
            GameColor.yellow.uiColor
        ]
        
        containerView.backgroundColor = colors[(level.id - 1) % colors.count]
        
        if isUnlocked {
            levelLabel.text = "Level \(level.id)"
            nameLabel.text = level.name
            highScoreLabel.text = "Best: \(highScore)"
            lockImageView.isHidden = true
            levelLabel.isHidden = false
            nameLabel.isHidden = false
            highScoreLabel.isHidden = false
            containerView.alpha = 1.0
        } else {
            lockImageView.isHidden = false
            levelLabel.isHidden = true
            nameLabel.isHidden = true
            highScoreLabel.isHidden = true
            containerView.alpha = 0.5
        }
    }
}
