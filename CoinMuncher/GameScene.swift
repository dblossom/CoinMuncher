//
//  GameScene.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/3/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* This strut is used to create references to objects that collide */
struct PhysicsCategory {
    static let muncher: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let coin: UInt32 = 0x1 << 2
    static let ground: UInt32 = 0x1 << 3
}

/* The main class, it subclasses SKScene, implements SKPhysicsContactDelegate */
class GameScene: SKScene, SKPhysicsContactDelegate {

    // The guy who "flys" in our world
    var muncher: Muncher = Muncher()

    // The obstacles to which we need to avoid
    var obstacles = [SKSpriteNode]()
    // Set width / height to zero
    var obstacleSize = CGSize.zero

    // The coins to which we need to collect
    var coins = [SKSpriteNode]()
    // set width / height to zero
    var coinSize = CGSize.zero

    // Sound made when collecting a coind
    let coinSound = SKAction.playSoundFileNamed("coin10.wav", waitForCompletion: false)

    // Sound made when player clicks (commented out for now, do not like it)
    //let jumpSound = SKAction.playSoundFileNamed("Jump.wav", waitForCompletion: false)

    // Sound made when player crashes into block
    let crashSound = SKAction.playSoundFileNamed("Explosion.wav", waitForCompletion: false)

    // number of coins we have collected
    var coinsCollected = 0
    // our high score.
    var highScore = 0

    // how far the blocks are apart
    var gapBetweenObstacles: CGFloat = 5

    // how fast the blocks are scrolling
    var scrollSpeed: CGFloat = 1.0
    // the starting speed
    let startingScrollSpeed: CGFloat = 3.0

    // how fast is gravity / downward pull
    let gravitySpeed: CGFloat = 0.5

    // last time the update loop ran
    var lastUpdateTime: TimeInterval?

    // if the game is running
    var gameRunning = false

    // did the player choose easy or hard
    var difficulty: Difficulty = Difficulty.normal

    /* We call this to set the difficulty (normal / hard) */
    init(_ difficulty: Difficulty) {
        super.init()
        self.difficulty = difficulty
    }

    /* init with CGSize */
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /* The first function that gets called and only called upon creation
        so we actually call another method within that we can call during restarts */
    override func didMove(to view: SKView) {
        // put all function into method that can be called outside instantiation
        startGame()
    }

    /* The fucntion that starts the game
       Also sets up the SKScene with all objects */
    func startGame() {
        // gets the physics setup for the scene
        setupPhysics()

        // sets up our flying guy
        setupMuncher()

        // if a highscore is saved, grab it
        retrieveHighScore()

        // set up the labels for coins collected and high score
        setupCoinsCollectedLabels()
        setupHighScoreLabel()

        // sets up the background
        setupBackground()

        anchorPoint = CGPoint.zero

        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view?.addGestureRecognizer(tapGesture)

        // make the active scroll speed the starting speed.
        scrollSpeed = startingScrollSpeed

        // last time is nil, hasn't happned yet
        lastUpdateTime = nil

        // wipe out any existing obstacles or coins to start fresh
        cleanupObstacles()
        cleanupCoins()

        // set game running to true
        gameRunning = true
    }

    /* function to get the high schore */
    func retrieveHighScore() {
        let userDefined = UserDefaults.standard

        // if the highscore exists, override the previous highscore
        if let highscore = userDefined.object(forKey: "highscore") as? Int {
            highScore = highscore
        }
    }

    /* function to setup our little flying guy */
    func setupMuncher() {
        // create a muncher object
        muncher = Muncher(position: CGPoint(x: frame.midX-175, y: frame.midY))
        // setup the physics
        muncher.setupPhysicsBody()
        // add to scene
        addChild(muncher)
    }

    /* function sets up physics for the scene */
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self

        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)

        // the collision detection bits
        self.physicsBody?.categoryBitMask = PhysicsCategory.ground
        self.physicsBody?.collisionBitMask = PhysicsCategory.muncher
        self.physicsBody?.contactTestBitMask = PhysicsCategory.muncher
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
    }

    /* function sets up the background image, layout and adds to scene */
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        background.zPosition = 0
        addChild(background)
    }

    /* sets up the coins collected label in the top left corner */
    func setupCoinsCollectedLabels() {

        // two labels are actually being created here -

        // this label just says "coins collected" here is where everything is setup
        let coinsCollectedLabel: SKLabelNode = SKLabelNode(text: "Coins Collected: ")
        coinsCollectedLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        coinsCollectedLabel.horizontalAlignmentMode = .left
        coinsCollectedLabel.fontName = "Courier-Bold"
        coinsCollectedLabel.fontSize = 16.0
        coinsCollectedLabel.zPosition = 20
        coinsCollectedLabel.fontColor = SKColor.black
        addChild(coinsCollectedLabel)

        // this label is the acutal score. It will be updated later in the code as coins are collected
        let coinsLabel: SKLabelNode = SKLabelNode(text: "0")
        coinsLabel.position = CGPoint(x: 170.0, y: frame.size.height - 20.0)
        coinsLabel.horizontalAlignmentMode = .left
        coinsLabel.fontName = "Courier-Bold"
        coinsLabel.fontSize = 18.0
        coinsLabel.name = "coinsLabel"
        coinsLabel.zPosition = 20
        coinsLabel.fontColor = SKColor.black
        addChild(coinsLabel)
    }

    /* this function sets up the two labels required for highscore */
    func setupHighScoreLabel() {

        // this label sets up the text to display 'high score'
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "High Score: ")
        highScoreLabel.position = CGPoint(x: 670.0, y: frame.size.height - 20.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 16.0
        highScoreLabel.zPosition = 20
        highScoreLabel.fontColor = SKColor.black
        addChild(highScoreLabel)

        // this label sets up the text to display the actual high score
        let highScore: SKLabelNode = SKLabelNode(text: String(self.highScore))
        highScore.position = CGPoint(x: 700, y: frame.size.height - 20.0)
        highScore.horizontalAlignmentMode = .right
        highScore.fontName = "Courier-Bold"
        highScore.fontSize = 18.0
        highScore.name = "highScore"
        highScore.zPosition = 20
        highScore.fontColor = SKColor.black
        addChild(highScore)
    }

    /* fucntion to run when the game is over */
    func gameOver() {
        // since gameOver() can be called numerous times is a situation
        // where multiple collisions happen, we only want to excute steps
        // if gameRunning is true, and ensure we set it to false, here and
        // only here.
        if gameRunning {
            gameRunning = false
            // give the illision of a stopped game
            scrollSpeed = 0
            // disply the gameover background / overlay
            gameOverBackground()
            // get the restart labels out for clicking
            restartLabel()
            // save the high score
            UserDefaults.standard.set(highScore, forKey: "highscore")
        }
    }

    /* function to display the game over backgound / overlay */
    func gameOverBackground() {
        // set transparacy
        let gameOverBackground = UIColor.black.withAlphaComponent(0.4)
        // create a gameover object
        let gameOver = GameOver(color: gameOverBackground, size: frame.size)
        // position stuff
        gameOver.anchorPoint = CGPoint.zero
        gameOver.position = CGPoint.zero
        gameOver.zPosition = 30

        gameOver.name = "gameOverOverlay"

        // the message to display ...
        gameOver.display(message: "Game Over!")
        // add to scene
        addChild(gameOver)
    }

    /* a simple label to restart or change game difficulty */
    func restartLabel() {
        // add to scene, this creates the object at a postion, rest is done in ClickToRestartLabel class
        addChild(ClickToRestartLabel(atPosition: CGPoint(x: frame.midX, y: frame.midY-75)))
        // put a lable out there for player to make game easier or harder without going to main screen
        switchDifficultyLabel()
    }

    /* function to create a label to enable player to switch difficulty */
    func switchDifficultyLabel() {
        let switchDL = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        switchDL.name = "switchDifficulty"
        switchDL.isUserInteractionEnabled = true
        switchDL.fontSize = 14
        switchDL.position = CGPoint(x: frame.midX, y: frame.midY-100)
        switchDL.fontColor = SKColor.white
        switchDL.zPosition = 31

        // Not my favorite solution - but - it will set the text based on
        // what the difficulty isn't.
        if difficulty == Difficulty.normal {
            switchDL.text = "Switch to Hard Mode"
        } else if difficulty == Difficulty.hard {
            switchDL.text = "Switch to Normal Mode"
        }
        addChild(switchDL)
    }

    /* function for when a game is restarted */
    func restartGame() {
        // clear everything
        self.removeAllActions()
        self.removeAllChildren()

        // reset the coins label (could do this in start?)
        coinsCollected = 0
        // run the startGame() function to take actions to setup the game
        startGame()
    }

    /* simple function to remove all obstables from parent & array */
    func cleanupObstacles() {
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll(keepingCapacity: true)
    }

    /* simple function to remove all coins from parent and array */
    func cleanupCoins() {
        for coin in coins {
            coin.removeFromParent()
        }
        coins.removeAll(keepingCapacity: true)
    }

    /* what to do when the player taps the screen */
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {

        // Is the game running? Then we are tapping for game play
        if gameRunning {
            // comment out too much sound
            //run(jumpSound)

            // simulate a temporary upward movement 'against' 'gravity'
            muncher.physicsBody?.affectedByGravity = true
            muncher.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            muncher.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 125))

        // if the game isn't running, then, we must be trying to start --
        } else if !gameRunning {

            // Do we have a restart label?
            if let label = childNode(withName: "restartLabel") as? SKLabelNode {

                // Do we have a difficulty switch label?
                let mode = childNode(withName: "switchDifficulty") as! SKLabelNode

                // did we click the difficulty label?
                if tapGesture.location(in: self.view).x > mode.frame.minX &&
                    tapGesture.location(in: self.view).x < mode.frame.maxX &&
                    tapGesture.location(in: self.view).y > mode.frame.minX &&
                    tapGesture.location(in: self.view).y < mode.frame.minX+20 {

                    // if so, swap the difficulty before restarting
                    if difficulty == Difficulty.normal {
                        difficulty = Difficulty.hard
                    } else {
                        difficulty = Difficulty.normal
                    }
                    // restart game.
                    restartGame()
                }

                // If the player clicks the restart label
                // This is werid --
                // if tap is > minX and < maxX for X-axis we are good
                // y-axis had a big discrepancy between label.position.y or label.frame.[min/max]Y
                // In the end, the tap location for Y does happen to be around the x-axis
                // so, we use that. My testing is being done via iPhone 8P simulator. I fear
                // other devices will not work correctly.
                if tapGesture.location(in: self.view).x > label.frame.minX &&
                    tapGesture.location(in: self.view).x < label.frame.maxX &&
                    tapGesture.location(in: self.view).y+label.fontSize > label.frame.minX &&
                    tapGesture.location(in: self.view).y < label.frame.minX {

                    restartGame()
                }
            }
        }
    }

    /* Simple function that spawns a coin around a brick */
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

    /* simple function to spawn an obstacle */
    func spawnObstacle(atPosition position: CGPoint) -> SKSpriteNode {

        let obstacle = Obstacle(positionAt: position)
        obstacle.position = position
        obstacle.zPosition = 10
        obstacle.setupPhysicsBody()

        addChild(obstacle)

        obstacleSize = obstacle.size

        obstacles.append(obstacle)

        // Return the new obstacle
        return obstacle
    }

    /* function that updates the obstacles ... adds new and "moves" others across screen */
    func updateObstacles(withScrollAmount currentScrollAmount: CGFloat) {

        var farthestRightObstacleX: CGFloat = frame.maxX

        for obstacle in obstacles {

            let newX = obstacle.position.x - currentScrollAmount

            if newX < frame.minX {

                obstacle.removeFromParent()

                if let obstacleIndex = obstacles.index(of: obstacle) {
                    obstacles.remove(at: obstacleIndex)
                }

            } else {

                obstacle.position = CGPoint(x: newX, y: obstacle.position.y)

                if obstacle.position.x > farthestRightObstacleX {
                    farthestRightObstacleX = obstacle.position.x
                }
            }
        }

        // this controls the node population, other wise, it will spawn TONS of unneeded nodes
        // trying to be memory responsible - even 10 is kind of high, 5 would probably do it.
        // an even better, for next "performance enhancement" might be to spawn a new one everytime
        // we remove one -- so start with say 10, then everytime we remove one, spawn a new one in back
        // code would look cleaner too I bet....
        if obstacles.count < 10 {
            let offsetRange = frame.midY+40 - frame.midY+40
            let obstacleX = farthestRightObstacleX + (obstacleSize.width * gapBetweenObstacles) + 1.0
            let obstacleY = arc4random_uniform(UInt32(offsetRange)) + UInt32(frame.midY-40)

            let newObstacle = spawnObstacle(atPosition: CGPoint(x: obstacleX, y: CGFloat(obstacleY)))

            farthestRightObstacleX = newObstacle.position.x

            // Points for putting coin around the brick ...
            // TOP ROWS: topLeft(-75, 80) topMiddle(0, 80) topRight(75, 80)

            // BOTTOM ROWS: bottomLeft(-75,-80) bottomMiddle(0,-80) bottomRight(75,-80)

            // MIDDLE ROWS: middleLeft(-75,0) middleRight(75,0)

            let ranX = arc4random_uniform(3)
            let ranY = arc4random_uniform(3)

            let coinXOffset: [CGFloat] = [-85, 0, 85]
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

    /* function to update the coins - spawn new, remove and "scroll them" */
    func updateCoins(withScrollAmount currentScrollAmount: CGFloat) {

        var farthestRightCoinX: CGFloat = frame.maxX

        for coin in coins {

            let newX = coin.position.x - currentScrollAmount

            if newX < frame.minX {

                coin.removeFromParent()

                if let coinIndex = coins.index(of: coin) {
                    coins.remove(at: coinIndex)
                }

                if coinsCollected > 0 {
                    gameOver()
                }

            } else {

                coin.position = CGPoint(x: newX, y: coin.position.y)

                if coin.position.x > farthestRightCoinX {
                    farthestRightCoinX = coin.position.x
                }
            }
        }
    }

    /* function athat updates the coin label with active amount of coins collected */
    func updateCoinsLabel() {
        if let coinsLabel = childNode(withName: "coinsLabel") as? SKLabelNode {
            coinsLabel.text = String(coinsCollected)
        }
        updateHighScoreLabel()
    }

    /* function to update the high score count */
    func updateHighScoreLabel() {
        if coinsCollected > highScore {
            if let highScoreLabel = childNode(withName: "highScore") as? SKLabelNode {
                highScore = coinsCollected
                highScoreLabel.text = String(highScore)
            }
        }
    }

    /* function that runs update */
    override func update(_ currentTime: TimeInterval) {

        // we only want to run the update if the game state is running.
        if gameRunning {

            // here we update the obstacles and coins so they 'scroll'
            print(scrollSpeed)
            updateObstacles(withScrollAmount: scrollSpeed)
            updateCoins(withScrollAmount: scrollSpeed)

            // update score
            updateCoinsLabel()
        }
    }

    /* the function required for the collision detection with SKPhysicsContactDelegate */
    func didBegin(_ contact: SKPhysicsContact) {

        // did the flying muncher guy hit a brick?
        if contact.bodyA.categoryBitMask == PhysicsCategory.obstacle &&
            contact.bodyB.categoryBitMask == PhysicsCategory.muncher {

            // change to a crashed looking one
            muncher.crashedAnimate()

            // make a little smoke when he hits
            muncher.crashSmoke()

            // run the 'crash sound'
            run(crashSound)

            // force him to the ground
            muncher.physicsBody?.affectedByGravity = true
            muncher.physicsBody?.applyForce(CGVector(dx: -20, dy: -10))

            // end the game
            gameOver()
        }

        // ih hard mode, if we hit top or bottom edge, game's over
        if difficulty == Difficulty.hard &&
            contact.bodyA.categoryBitMask == PhysicsCategory.ground {

            gameOver()
        }

        // did we collect a coin?
        if contact.bodyA.categoryBitMask == PhysicsCategory.coin &&
            contact.bodyB.categoryBitMask == PhysicsCategory.muncher {

            // remove coin from scene
            contact.bodyA.node?.removeFromParent()

            // remove it from the array of coins
            if let coinIndex = coins.index(of: contact.bodyA.node as! SKSpriteNode) {
                coins.remove(at: coinIndex)
            }

            // make coin sound
            run(coinSound)

            // increase score
            coinsCollected += 1

            // increase the scroll speed depending on difficulty
            if difficulty == Difficulty.hard {
                scrollSpeed += 0.7
            } else {
                scrollSpeed += 0.5
            }
        }
    }
}
