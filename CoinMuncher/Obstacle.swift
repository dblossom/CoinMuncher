//
//  Obstacle.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/9/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* class that represents the obstacle */
class Obstacle: SKSpriteNode {

    // creates a random colored obstacle
    init(positionAt position: CGPoint) {
        // the obstacle that we have
        let images = ["orange", "green", "blue", "brown"]
        // randomly generate one of the 4
        let ran = Int(arc4random_uniform(3))
        let name = images[ran]
        // setup texture - and - color
        let texture = SKTexture(imageNamed: name)
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        // create it
        super.init(texture: texture, color: color, size: texture.size())
        zPosition = 9
    }

    /* function to setup the physics for the block */
    func setupPhysicsBody() {

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        physicsBody?.isDynamic = true
        physicsBody?.density = 10000
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false

        // the bitmasks for collision.
        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.muncher
        physicsBody?.contactTestBitMask = PhysicsCategory.muncher
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
