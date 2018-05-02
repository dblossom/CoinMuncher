//
//  GameOver.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 4/5/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* Class to manage the GameOver overlay */
class GameOver: SKSpriteNode {

    func display(message: String) {

        // Create a message label using the passed-in message
        let messageLabel: SKLabelNode = SKLabelNode(text: message)

        // Set the label's starting position to the left of the menu layer
        let messageX = -frame.width
        let messageY = frame.height / 2.0
        messageLabel.position = CGPoint(x: messageX, y: messageY)

        messageLabel.horizontalAlignmentMode = .center
        messageLabel.fontName = "Courier-Bold"
        messageLabel.fontSize = 48.0
        messageLabel.zPosition = 20
        self.addChild(messageLabel)

        // Animate the message label to the center of the screen
        let finalX = frame.width / 2.0
        let messageAction = SKAction.moveTo(x: finalX, duration: 0.8)
        messageLabel.run(messageAction)
    }
}
