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
        self.text = "Click Here To Restart"
        self.name = "restartLabel"
        self.isUserInteractionEnabled = true
        self.fontSize = 16
        self.fontColor = SKColor.white
        self.position = atPosition
        self.zPosition = 31
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
