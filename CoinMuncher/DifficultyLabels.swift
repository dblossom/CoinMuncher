//
//  DifficultyLabels.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 4/6/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* a class for the difficulty labels */
class DifficultyLabels: SKLabelNode {
    
    func createHardModeLabel() {
        self.fontName = "AmericanTypewriter-Bold"
        self.text = "Hard Mode"
        self.name = "hardLabel"
        self.fontSize = 20
        self.fontColor = SKColor.black
        self.zPosition = 5
    }
    
}
