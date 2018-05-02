//
//  SplashScene.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/3/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {

    let muncher = SKSpriteNode(imageNamed: "cm_frame-1.png")
    var textureArray = [SKTexture]()

    override func didMove(to view: SKView) {

        anchorPoint = CGPoint.zero

        let background = SKSpriteNode(imageNamed: "splash")
        let xMid = frame.midX
        let yMid = frame.midY

        background.position = CGPoint(x: xMid, y: yMid)
        background.zPosition = 0
        addChild(background)

        // Add my name for credit
        createNameCreditLabel()

        // Add the 'coin muncher' label
        addChild(GameTitleLabel(atPosition: CGPoint(x: xMid, y: yMid+100)))

        // Add the 'click to play' label
        addChild(ClickToPlayLabel(atPosition: CGPoint(x: xMid, y: yMid-130)))

        // Add the 'hard' label
        createDifficultyLabels()

        // Add the muncher guy
        let muncher = Muncher(position: CGPoint(x: xMid, y: yMid))
        addChild(muncher)

        let tapMethod = #selector(SplashScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
    }

    /* function to create a label for the game difficulty */
    func createDifficultyLabels() {
        let hardMode = DifficultyLabels()
        hardMode.createHardModeLabel()
        hardMode.position.x = frame.midX
        hardMode.position.y = frame.midY-175
        addChild(hardMode)
    }

/* function to put my name on for credit - eh. :) */
    func createNameCreditLabel() {
        let creditNameNode = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        creditNameNode.position = CGPoint(x: frame.midX, y: frame.midY+65)
        creditNameNode.text = "By Dan Blossom"
        creditNameNode.fontSize = 14
        creditNameNode.fontColor = SKColor.black
        creditNameNode.zPosition = 5
        addChild(creditNameNode)
    }

    @objc func handleTap(tapGesture: UITapGestureRecognizer) {

        // did we click on the hard label?
        if let hardLabel = childNode(withName: "hardLabel") as? SKLabelNode {

            if tapGesture.location(in: self.view).x > hardLabel.frame.minX &&
                tapGesture.location(in: self.view).x < hardLabel.frame.maxX &&
                tapGesture.location(in: self.view).y+hardLabel.fontSize > hardLabel.frame.midX &&
                tapGesture.location(in: self.view).y < hardLabel.frame.midX {

                // if we did then - start in 'hard' mode.
                goNext(scene: GameScene(Difficulty.hard))
            } else {
                // otherwise just start in normal mode.
                goNext(scene: GameScene(Difficulty.normal))
            }
        }
    }

    /* starts the game */
    func goNext(scene: SKScene) {
        if let view = self.view {

            scene.scaleMode = .aspectFill

            let width = view.bounds.width
            let height = view.bounds.height
            scene.size = CGSize(width: width, height: height)

            let reveal = SKTransition.crossFade(withDuration: 3)
            view.presentScene(scene, transition: reveal)
            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
