//
//  GameTitleLabel.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/8/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* A class for the game title label */
class GameTitleLabel: SKLabelNode {

    init(atPosition: CGPoint) {
        super.init()
        self.fontName = "Chalkduster"
        self.text = "Coin Muncher"
        self.fontSize = 65
        self.fontColor = SKColor.green
        self.position = atPosition
        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
