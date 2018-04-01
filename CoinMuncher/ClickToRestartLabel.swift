//
//  ClickToRestart.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/24/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

class ClickToRestartLabel: SKLabelNode {

    init(atPosition: CGPoint) {
        super.init()
        self.fontName = "AmericanTypewriter-Bold"
        self.text = "Click To Restart"
        self.name = "restartLabel"
        self.isUserInteractionEnabled = true
        self.fontSize = 20
        self.fontColor = SKColor.black
        self.position = atPosition
        self.zPosition = 11
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
