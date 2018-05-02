//
//  ClickToPlayLabel.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/9/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* A class for the click to play label */
class ClickToPlayLabel: SKLabelNode {

    init(atPosition: CGPoint) {
        super.init()
        self.fontName = "AmericanTypewriter-Bold"
        self.text = "Click To Play"
        self.fontSize = 20
        self.fontColor = SKColor.black
        self.position = atPosition
        self.zPosition = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
