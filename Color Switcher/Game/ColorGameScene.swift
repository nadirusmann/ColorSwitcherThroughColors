import SpriteKit

protocol ColorGameSceneDelegate: AnyObject {
    func didPassRing()
    func didCollide()
    func didCompleteLevel()
}

final class ColorGameScene: SKScene {
    
    weak var gameDelegate: ColorGameSceneDelegate?
    
    private let level: Level
    private var ball: SKShapeNode!
    private var currentColor: GameColor = .red
    private var obstacles: [ObstacleNode] = []
    private var isGameOver = false
    private var availableColors: [GameColor] = []
    private var totalCreated = 0
    private var totalPassed = 0
    private var gameReady = false
    
    private let ballRadius: CGFloat = 16
    private var obstacleSpacing: CGFloat = 260
    
    private var cameraNode: SKCameraNode!
    private var tapToPlayLabel: SKLabelNode!
    
    init(size: CGSize, level: Level) {
        self.level = level
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        availableColors = Array(GameColor.allCases.prefix(level.colorsAvailable))
        currentColor = availableColors.first ?? .red
        
        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode
        
        setupBall()
        setupInitialObstacles()
        setupTapToPlay()
        cameraNode.position = ball.position
    }
    
    private func setupTapToPlay() {
        tapToPlayLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tapToPlayLabel.text = "Tap to Play"
        tapToPlayLabel.fontSize = 28
        tapToPlayLabel.fontColor = .white
        tapToPlayLabel.position = CGPoint(x: size.width / 2, y: ball.position.y - 80)
        tapToPlayLabel.zPosition = 150
        tapToPlayLabel.alpha = 0
        addChild(tapToPlayLabel)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        tapToPlayLabel.run(SKAction.sequence([fadeIn, SKAction.repeatForever(pulse)]), withKey: "pulse")
        
        let arrow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        arrow.text = "↓"
        arrow.fontSize = 36
        arrow.fontColor = currentColor.uiColor
        arrow.position = CGPoint(x: 0, y: -50)
        arrow.name = "arrow"
        tapToPlayLabel.addChild(arrow)
        
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 0.5)
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
        arrow.run(SKAction.repeatForever(SKAction.sequence([moveDown, moveUp])))
    }
    
    private func setupBall() {
        ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = currentColor.uiColor
        ball.strokeColor = .white.withAlphaComponent(0.4)
        ball.lineWidth = 2
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2 + 200)
        ball.zPosition = 100
        addChild(ball)
        
        let glow = SKShapeNode(circleOfRadius: ballRadius + 6)
        glow.fillColor = currentColor.uiColor.withAlphaComponent(0.15)
        glow.strokeColor = .clear
        glow.name = "ballGlow"
        ball.addChild(glow)
    }
    
    private func updateBallColor() {
        ball.fillColor = currentColor.uiColor
        if let glow = ball.childNode(withName: "ballGlow") as? SKShapeNode {
            glow.fillColor = currentColor.uiColor.withAlphaComponent(0.15)
        }
    }
    
    private func setupInitialObstacles() {
        let firstY = ball.position.y - obstacleSpacing
        for i in 0..<min(5, level.ringCount) {
            let y = firstY - CGFloat(i) * obstacleSpacing
            let color = (i == 0) ? currentColor : availableColors.randomElement()!
            spawnObstacle(at: y, color: color)
        }
    }
    
    private func spawnObstacle(at y: CGFloat, color: GameColor) {
        let obstacle = ObstacleNode(
            id: totalCreated,
            color: color,
            sceneWidth: size.width,
            speed: level.ringSpeed
        )
        totalCreated += 1
        obstacle.position = CGPoint(x: size.width / 2, y: y)
        obstacle.zPosition = 50
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        
        if !gameReady {
            gameReady = true
            
            tapToPlayLabel.removeAction(forKey: "pulse")
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let remove = SKAction.removeFromParent()
            tapToPlayLabel.run(SKAction.sequence([fadeOut, remove]))
            
            let move = SKAction.moveBy(x: 0, y: -level.ballSpeed, duration: 1.0)
            ball.run(SKAction.repeatForever(move), withKey: "falling")
            SoundService.shared.playTap()
            return
        }
        
        guard let idx = availableColors.firstIndex(of: currentColor) else { return }
        currentColor = availableColors[(idx + 1) % availableColors.count]
        updateBallColor()
        HapticService.shared.lightImpact()
        SoundService.shared.playColorChange()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver, gameReady else { return }
        
        cameraNode.position.y = ball.position.y
        
        let ballY = ball.position.y
        
        for obstacle in obstacles {
            guard !obstacle.passed else { continue }
            
            let hitZone = ballY - ballRadius
            let obstacleTop = obstacle.position.y + obstacle.halfHeight
            let obstacleBottom = obstacle.position.y - obstacle.halfHeight
            
            if hitZone <= obstacleTop && ballY >= obstacleBottom {
                if obstacle.obstacleColor == currentColor {
                    obstacle.passed = true
                    totalPassed += 1
                    gameDelegate?.didPassRing()
                    showPassEffect(obstacle: obstacle)
                    
                    if totalPassed >= level.ringCount {
                        completeLevel()
                        return
                    }
                } else {
                    ball.removeAction(forKey: "falling")
                    ball.position.y = obstacleTop + ballRadius
                    showCollisionEffect(at: CGPoint(x: ball.position.x, y: obstacleTop))
                    endGame()
                    return
                }
            }
        }
        
        obstacles.removeAll { o in
            if o.position.y > ballY + size.height {
                o.removeFromParent()
                return true
            }
            return false
        }
        
        if let last = obstacles.last, totalCreated < level.ringCount {
            if last.position.y > ballY - size.height {
                let newY = last.position.y - obstacleSpacing
                let color = availableColors.randomElement()!
                spawnObstacle(at: newY, color: color)
            }
        }
    }
    
    private func showPassEffect(obstacle: ObstacleNode) {
        obstacle.animatePass()
        SoundService.shared.playPass()
        
        let particles = SKEmitterNode()
        particles.particleTexture = nil
        particles.position = obstacle.position
        particles.zPosition = 60
        particles.particleBirthRate = 30
        particles.numParticlesToEmit = 15
        particles.particleLifetime = 0.4
        particles.particleSpeed = 80
        particles.particleSpeedRange = 40
        particles.emissionAngleRange = .pi * 2
        particles.particleScale = 0.15
        particles.particleScaleRange = 0.1
        particles.particleAlpha = 0.8
        particles.particleAlphaSpeed = -2.0
        particles.particleColor = obstacle.obstacleColor.uiColor
        particles.particleColorBlendFactor = 1.0
        addChild(particles)
        particles.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.removeFromParent()]))
    }
    
    private func showCollisionEffect(at position: CGPoint) {
        SoundService.shared.playFail()
        
        for i in 0..<8 {
            let shard = SKShapeNode(rectOf: CGSize(width: 6, height: 14), cornerRadius: 2)
            shard.fillColor = currentColor.uiColor
            shard.strokeColor = .clear
            shard.position = position
            shard.zPosition = 200
            addChild(shard)
            
            let angle = CGFloat(i) * (.pi * 2 / 8.0)
            let dx = cos(angle) * 80
            let dy = sin(angle) * 80
            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.35)
            let fade = SKAction.fadeOut(withDuration: 0.35)
            let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 0.35)
            let group = SKAction.group([move, fade, rotate])
            shard.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
        
        let flash = SKShapeNode(circleOfRadius: ballRadius * 2)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.position = position
        flash.zPosition = 199
        flash.alpha = 0.9
        addChild(flash)
        
        let expand = SKAction.scale(to: 3.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        flash.run(SKAction.sequence([SKAction.group([expand, fadeOut]), SKAction.removeFromParent()]))
    }
    
    private func completeLevel() {
        guard !isGameOver else { return }
        isGameOver = true
        ball.removeAction(forKey: "falling")
        obstacles.forEach { $0.stopAnimation() }
        SoundService.shared.playLevelComplete()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.gameDelegate?.didCompleteLevel()
        }
    }
    
    private func endGame() {
        guard !isGameOver else { return }
        isGameOver = true
        ball.removeAction(forKey: "falling")
        
        let shrink = SKAction.scale(to: 0.0, duration: 0.25)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        ball.run(SKAction.group([shrink, fade]))
        
        obstacles.forEach { $0.stopAnimation() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.gameDelegate?.didCollide()
        }
    }
}

final class ObstacleNode: SKNode {
    
    let id: Int
    let obstacleColor: GameColor
    var passed = false
    let halfHeight: CGFloat = 10
    
    private let barWidth: CGFloat
    private var leftBar: SKShapeNode!
    private var rightBar: SKShapeNode!
    private var centerGlow: SKShapeNode!
    
    init(id: Int, color: GameColor, sceneWidth: CGFloat, speed: Double) {
        self.id = id
        self.obstacleColor = color
        self.barWidth = sceneWidth
        super.init()
        
        let barHeight: CGFloat = 20
        let gapWidth: CGFloat = 50
        let sideWidth = (barWidth - gapWidth) / 2
        
        leftBar = SKShapeNode(rectOf: CGSize(width: sideWidth, height: barHeight), cornerRadius: 4)
        leftBar.fillColor = color.uiColor
        leftBar.strokeColor = color.uiColor.withAlphaComponent(0.6)
        leftBar.lineWidth = 1
        leftBar.position = CGPoint(x: -gapWidth / 2 - sideWidth / 2, y: 0)
        leftBar.alpha = 0.9
        addChild(leftBar)
        
        rightBar = SKShapeNode(rectOf: CGSize(width: sideWidth, height: barHeight), cornerRadius: 4)
        rightBar.fillColor = color.uiColor
        rightBar.strokeColor = color.uiColor.withAlphaComponent(0.6)
        rightBar.lineWidth = 1
        rightBar.position = CGPoint(x: gapWidth / 2 + sideWidth / 2, y: 0)
        rightBar.alpha = 0.9
        addChild(rightBar)
        
        centerGlow = SKShapeNode(circleOfRadius: gapWidth / 2)
        centerGlow.fillColor = color.uiColor.withAlphaComponent(0.1)
        centerGlow.strokeColor = color.uiColor.withAlphaComponent(0.4)
        centerGlow.lineWidth = 2
        centerGlow.position = .zero
        addChild(centerGlow)
        
        let topLine = SKShapeNode(rectOf: CGSize(width: barWidth, height: 1))
        topLine.fillColor = color.uiColor.withAlphaComponent(0.3)
        topLine.strokeColor = .clear
        topLine.position = CGPoint(x: 0, y: barHeight / 2 + 2)
        addChild(topLine)
        
        let bottomLine = SKShapeNode(rectOf: CGSize(width: barWidth, height: 1))
        bottomLine.fillColor = color.uiColor.withAlphaComponent(0.3)
        bottomLine.strokeColor = .clear
        bottomLine.position = CGPoint(x: 0, y: -barHeight / 2 - 2)
        addChild(bottomLine)
        
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.0 / speed),
            SKAction.fadeAlpha(to: 0.1, duration: 1.0 / speed)
        ])
        centerGlow.run(SKAction.repeatForever(pulse), withKey: "pulse")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animatePass() {
        let spreadLeft = SKAction.moveBy(x: -20, y: 0, duration: 0.15)
        let returnLeft = SKAction.moveBy(x: 20, y: 0, duration: 0.15)
        leftBar.run(SKAction.sequence([spreadLeft, returnLeft]))
        
        let spreadRight = SKAction.moveBy(x: 20, y: 0, duration: 0.15)
        let returnRight = SKAction.moveBy(x: -20, y: 0, duration: 0.15)
        rightBar.run(SKAction.sequence([spreadRight, returnRight]))
        
        let glowUp = SKAction.group([
            SKAction.scale(to: 1.8, duration: 0.2),
            SKAction.fadeAlpha(to: 0.6, duration: 0.2)
        ])
        let glowDown = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.fadeAlpha(to: 0.1, duration: 0.2)
        ])
        centerGlow.run(SKAction.sequence([glowUp, glowDown]))
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        run(SKAction.sequence([SKAction.wait(forDuration: 0.3), fadeOut]))
    }
    
    func stopAnimation() {
        centerGlow?.removeAction(forKey: "pulse")
    }
}
