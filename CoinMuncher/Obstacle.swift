//
//  Obstacle.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/9/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

class Obstacle: SKSpriteNode {

    init(positionAt position: CGPoint) {
        let images = ["orange", "green", "blue", "brown"]
        let ran = Int(arc4random_uniform(3))
        let name = images[ran]
        let texture = SKTexture(imageNamed: name)
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
        super.init(texture: texture, color: color, size: texture.size())
        zPosition = 9
    }

    func setupPhysicsBody() {

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        physicsBody?.isDynamic = true
        physicsBody?.density = 10000
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false

        physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.muncher
        physicsBody?.contactTestBitMask = PhysicsCategory.muncher
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
