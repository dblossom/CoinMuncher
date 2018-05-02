//
//  Muncher.swift
//  CoinMuncher
//
//  Created by Dan Blossom on 3/9/18.
//  Copyright © 2018 danielblossom.com. All rights reserved.
//

import SpriteKit

/* Class that handles our little flying guy - 'muncher'
   the flying fish */
class Muncher: SKSpriteNode {

    // texture array to hold the images for the animated muncher
    var textureArray = [SKTexture]()

    // create the node at a position
    init(position anyPosition: CGPoint) {

        // here we setup the animation, runs 4 images in a loop
        let texture = SKTexture(imageNamed: "cm_frame-1.png")
        for i in 1...4 {
            let image = "cm_frame-\(i).png"
            textureArray.append(SKTexture(imageNamed: image))
        }
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        position = anyPosition
        zPosition = 10

        // animate the 4 images
        run(SKAction.repeatForever(SKAction.animate(with: textureArray, timePerFrame: 0.1)))
    }

    init(texture: SKTexture!) {
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }

    override init(texture: SKTexture!, color: (UIColor!), size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /* function to call if we crash, swap out images for the 'crashed' guy */
    func crashedAnimate() {

        // remove images
        textureArray.removeAll()

        // add new images
        for i in 1...2 {
            let image = "cm_hit_frame-\(i).png"
            textureArray.append(SKTexture(imageNamed: image))
        }

        // run those 'forever'
        run(SKAction.repeatForever(SKAction.animate(with: textureArray, timePerFrame: 0.3)))
    }

    /* this will push out a little smoke when called, for this games purpose
       it will push out smoke when he hits the block obstacle */
    func crashSmoke() {

        // Find the sparks emitter file in the project's bundle
        let bundle = Bundle.main

        if let crashPath = bundle.path(forResource: "crash", ofType: "sks") {

            // Create emitter node
            let crashNode = NSKeyedUnarchiver.unarchiveObject (withFile: crashPath) as! SKEmitterNode
            crashNode.position = CGPoint(x: 0.0, y: -50.0)
            addChild(crashNode)

            // Run an action to wait half a second and then remove the emitter
            let waitAction = SKAction.wait(forDuration: 0.5)
            let removeAction = SKAction.removeFromParent()
            let waitThenRemove = SKAction.sequence([waitAction, removeAction])

            crashNode.run(waitThenRemove)
        }
    }

    /* sets up all the needed physics stuff for our muncher */
    func setupPhysicsBody() {

        physicsBody = SKPhysicsBody(circleOfRadius: max(self.size.width / 2, self.size.height / 2))
        physicsBody?.isDynamic = true
        physicsBody?.density = 6.0
        physicsBody?.allowsRotation = true
        physicsBody?.angularDamping = 1.0

        // to give the play a chance, start with no gravity
        physicsBody?.affectedByGravity = false

        // bit masks for collison
        physicsBody?.categoryBitMask = PhysicsCategory.muncher
        physicsBody?.collisionBitMask = PhysicsCategory.obstacle | PhysicsCategory.ground
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.coin | PhysicsCategory.ground
    }
}
