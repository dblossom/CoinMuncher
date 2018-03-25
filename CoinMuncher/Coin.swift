//
//  Coin
//  CoinMuncher
//
//  Created by Dan Blossom on 3/9/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

class Coin: SKSpriteNode {

    var textureArray = [SKTexture]()

    init(position anyPosition: CGPoint) {
        let texture = SKTexture(imageNamed: "coin1")
        for i in 1...6 {
            let image = "coin\(i).png"
            textureArray.append(SKTexture(imageNamed: image))
        }
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        position = anyPosition
        zPosition = 8
        run(SKAction.repeatForever(SKAction.animate(with: textureArray, timePerFrame: 0.1)))
    }

    func setupPhysicsBody() {

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        physicsBody?.isDynamic = true
        physicsBody?.density = 10000
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false

        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.collisionBitMask = PhysicsCategory.muncher
        physicsBody?.contactTestBitMask = PhysicsCategory.muncher
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}
