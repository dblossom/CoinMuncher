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

        // Add the 'coin muncher' label
        addChild(GameTitleLabel(atPosition: CGPoint(x: xMid, y: yMid+100)))

        // Add the 'click to play' label
        addChild(ClickToPlayLabel(atPosition: CGPoint(x: xMid, y: yMid-150)))

        // Add the muncher guy
        let muncher = Muncher(position: CGPoint(x: xMid, y: yMid))
        addChild(muncher)

        let tapMethod = #selector(SplashScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        goNext(scene: GameScene())
    }

    func goNext(scene: SKScene) {
        if let view = self.view {

            scene.scaleMode = .aspectFill

            let width = view.bounds.width
            let height = view.bounds.height
            scene.size = CGSize(width: width, height: height)

            let reveal = SKTransition.crossFade(withDuration: 5)
            view.presentScene(scene, transition: reveal)
            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
