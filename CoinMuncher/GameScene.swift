//
//  GameScene.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/3/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let muncher: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let coin: UInt32 = 0x1 << 2
    static let ground: UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var muncher: Muncher = Muncher()

    var obstacles = [SKSpriteNode]()
    var obstacleSize = CGSize.zero

    var coins = [SKSpriteNode]()
    var coinSize = CGSize.zero
    let coinSound = SKAction.playSoundFileNamed("coin10.wav", waitForCompletion: false)

    var coinsCollected = 0

    var gapBetweenObstacles: CGFloat = 5
    var scrollSpeed: CGFloat = 1.0
    let startingScrollSpeed: CGFloat = 1.0
    let gravitySpeed: CGFloat = 0.5
    var lastUpdateTime: TimeInterval?

    var gameRunning = false

    override func didMove(to view: SKView) {
        startGame()
    }

    func startGame() {
        setupPhysics()
        setupMuncher()
        setupCoinsCollectedLabels()
        setupBackground()

        anchorPoint = CGPoint.zero

        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view?.addGestureRecognizer(tapGesture)

        scrollSpeed = startingScrollSpeed
        lastUpdateTime = nil

        cleanupObstacles()
        cleanupCoins()
        gameRunning = true
    }

    func setupMuncher() {
        muncher = Muncher(position: CGPoint(x: frame.midX-175, y: frame.midY))
        muncher.setupPhysicsBody()
        addChild(muncher)
    }

    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self

        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ground
        self.physicsBody?.collisionBitMask = PhysicsCategory.muncher
        self.physicsBody?.contactTestBitMask = PhysicsCategory.muncher
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
    }

    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        background.zPosition = 0
        addChild(background)
    }

    func setupCoinsCollectedLabels() {
        let coinsCollectedLabel: SKLabelNode = SKLabelNode(text: "Coins Collected:")
        coinsCollectedLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        coinsCollectedLabel.horizontalAlignmentMode = .left
        coinsCollectedLabel.fontName = "Courier-Bold"
        coinsCollectedLabel.fontSize = 16.0
        coinsCollectedLabel.zPosition = 20
        addChild(coinsCollectedLabel)

        let coinsLabel: SKLabelNode = SKLabelNode(text: "0")
        coinsLabel.position = CGPoint(x: 170.0, y: frame.size.height - 20.0)
        coinsLabel.horizontalAlignmentMode = .left
        coinsLabel.fontName = "Courier-Bold"
        coinsLabel.fontSize = 18.0
        coinsLabel.name = "coinsLabel"
        coinsLabel.zPosition = 20
        addChild(coinsLabel)
    }

    func gameOver() {
        gameRunning = false
        scrollSpeed = 0
        updateObstacles(withScrollAmount: 0.0)

        restartLabel()
    }

    func restartLabel() {
        addChild(ClickToRestartLabel(atPosition: CGPoint(x: frame.midX, y: frame.midY)))
    }

    func restartGame() {
        self.removeAllActions()
        self.removeAllChildren()
        coinsCollected = 0
        startGame()
    }

    func cleanupObstacles() {
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll(keepingCapacity: true)
    }

    func cleanupCoins() {
        for coin in coins {
            coin.removeFromParent()
        }
        coins.removeAll(keepingCapacity: true)
    }

    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if gameRunning {
            muncher.physicsBody?.affectedByGravity = true
            muncher.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            muncher.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 125))
        } else if !gameRunning {

            if let label = childNode(withName: "restartLabel") as? SKLabelNode {

                print(tapGesture.location(in: self.view).y)
                print("\(label.frame.minY) \(label.frame.maxY)")

                if tapGesture.location(in: self.view).x > label.frame.minX &&
                    tapGesture.location(in: self.view).x < label.frame.maxX &&
                    tapGesture.location(in: self.view).y+label.fontSize > label.frame.minY &&
                    tapGesture.location(in: self.view).y+15 < label.frame.maxY {

                    restartGame()
                }
            }
        }
    }

    func spawnCoin(atPosition position: CGPoint) -> SKSpriteNode {

        let coin = Coin(position: position)
        coin.position = position
        coin.zPosition = 10
        coin.setupPhysicsBody()

        addChild(coin)

        coinSize = coin.size

        coins.append(coin)

        return coin
    }

    func spawnObstacle(atPosition position: CGPoint) -> SKSpriteNode {

        let obstacle = Obstacle(positionAt: position)
        obstacle.position = position
        obstacle.zPosition = 10
        obstacle.setupPhysicsBody()

        addChild(obstacle)

        obstacleSize = obstacle.size

        coins.append(obstacle)

        // Return the new obstacle
        return obstacle
    }

    func updateObstacles(withScrollAmount currentScrollAmount: CGFloat) {

        // Keep track of the greatest x-position
        var farthestRightObstacleX: CGFloat = 0.0

        for obstacle in coins {

            let newX = obstacle.position.x - currentScrollAmount

            // If a brick has moved too far left (off the screen), remove it
            if newX < -obstacleSize.width {

                obstacle.removeFromParent()

                if let obstacleIndex = coins.index(of: obstacle) {
                    coins.remove(at: obstacleIndex)
                }

            } else {

                obstacle.position = CGPoint(x: newX, y: obstacle.position.y)

                if obstacle.position.x > farthestRightObstacleX {
                    farthestRightObstacleX = obstacle.position.x
                }
            }
        }

        while farthestRightObstacleX < frame.width {

            let offsetRange = frame.midY+40 - frame.midY+40
            let obstacleX = farthestRightObstacleX + (obstacleSize.width * gapBetweenObstacles) + 1.0
            let obstacleY = arc4random_uniform(UInt32(offsetRange)) + UInt32(frame.midY-40)

            let newObstacle = spawnObstacle(atPosition: CGPoint(x: obstacleX, y: CGFloat(obstacleY)))

            farthestRightObstacleX = newObstacle.position.x

            // Points for putting coin around the brick ...

            // TOP ROWS
            // topLeft(-75, 80)
            // topMiddle(0, 80)
            // topRight(75, 80)

            // BOTTOM ROWS
            // bottomLeft(-75,-80)
            // bottomMiddle(0,-80)
            // bottomRight(75,-80)

            // MIDDLE ROWS
            // middleLeft(-75,0)
            // middleRight(75,0)

            let ranX = arc4random_uniform(2)
            let ranY = arc4random_uniform(2)

            let coinXOffset: [CGFloat] = [-85, 0, 85]

            // temp not allow -80 for bottom
            // because if block is on bottom coin will be too low
            let coinYOffset: [CGFloat] = [-80, 0, 80]

            let coinX = coinXOffset[Int(ranX)]
            let coinY = coinYOffset[Int(ranY)]

            // A bit of a hack for now to not allow (0,0) only time they are equal
            if coinX == coinY {
                _ = spawnCoin(atPosition: CGPoint(x: obstacleX + -85, y: CGFloat(obstacleY + 0)))
            } else {
                _ = spawnCoin(atPosition: CGPoint(x: obstacleX + coinX, y: CGFloat(obstacleY) + coinY))
            }
        }
    }

    func updateCoinsCollected() {
        if let coinsLabel = childNode(withName: "coinsLabel") as? SKLabelNode {
            coinsLabel.text = String(coinsCollected)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        var elapsedTime: TimeInterval = 0.0

        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }

        lastUpdateTime = currentTime

        let expectedElapsedTime: TimeInterval = 1.0 / 60.0

        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment

        updateObstacles(withScrollAmount: currentScrollAmount)
        updateCoinsCollected()
    }

    func didBegin(_ contact: SKPhysicsContact) {

        if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle &&
            contact.bodyB.categoryBitMask == PhysicsCategory.muncher {

            muncher.physicsBody?.affectedByGravity = true
            muncher.physicsBody?.applyForce(CGVector(dx: -20, dy: -10))

            gameOver()
        }

        if contact.bodyA.categoryBitMask == PhysicsCategory.coin &&
            contact.bodyB.categoryBitMask == PhysicsCategory.muncher {

            contact.bodyA.node?.removeFromParent()

            if let coinIndex = coins.index(of: contact.bodyA.node as! SKSpriteNode) {
                coins.remove(at: coinIndex)
            }
            run(coinSound)
            coinsCollected += 1
            scrollSpeed += 0.1
            print(scrollSpeed)
            print(coinsCollected)
        }
    }
}