//
//  GameScene.swift
//  Puzzled
//
//  Created by Dylan, Alistair, and Peter on 3/29/22.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    //variables and things
    var arrow = SKSpriteNode()
    var target = SKSpriteNode()
    var brick = SKSpriteNode()
    var bow = SKSpriteNode()
    var arrowShot = false
    
    //functions and things
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //restarts game when app starts
        createBackground()
        resetGame()
    }
    func resetGame() { //before game starts
        makeArrow(y: -1)
        makeTarget(y: -1)
        makeBow(y: -1)
        makeBrick(x: 100, y: 100, color: .black)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "arrow" {
            collisionBetween(arrow: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "arrow" {
            collisionBetween(arrow: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    func collisionBetween(arrow: SKNode, object: SKNode){
        //what happens when arrow hits target
        if object.name == "target" {
            print("Win")
            arrow.physicsBody?.isDynamic = false
        }
    }
    func makeArrow(y: Int /* Changes the starting y position for 3 diff options */) {
        arrow.removeFromParent() //remove arrow if exists
        arrow = SKSpriteNode(color: .red, size: CGSize(width: 75, height: 10))
        arrow.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)))
        arrow.name = "arrow"
        
        arrow.physicsBody?.usesPreciseCollisionDetection = true
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody!.contactTestBitMask = arrow.physicsBody!.collisionBitMask
        arrow.physicsBody?.isDynamic = false
        arrow.physicsBody?.friction = 0
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.restitution = 1
        arrow.physicsBody?.linearDamping = 0
        
        addChild(arrow)
    }
    func makeBow(y: Int){
        bow.removeFromParent()
        let bowPicture = SKTexture(imageNamed: "bow")
        bow = SKSpriteNode(texture: bowPicture, size: CGSize(width: 75, height: 75))
        bow.physicsBody = SKPhysicsBody(rectangleOf: bow.size)
        bow.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)))
        bow.zRotation = -.pi/9
        bow.name = "bow"
        
        bow.physicsBody?.isDynamic = false
        //makes it so arrow doesnt interact with the bow
        bow.physicsBody?.categoryBitMask = 0
        //makes it so the bow is always under the arrow
        bow.zPosition = -1
        
        addChild(bow)
    }
    func shootArrow() {
        arrow.physicsBody?.isDynamic = true
        arrow.physicsBody?.applyImpulse(CGVector(dx: 15, dy: 0))
    }
    func makeTarget(y : Int) {
        target.removeFromParent() //remove target if exists
        let targetPicture = SKTexture(imageNamed: "target")
        target = SKSpriteNode(texture: targetPicture, size: CGSize(width: 75, height: 75))
        target.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: 75))
        target.position = CGPoint(x: frame.maxX - 50, y: frame.midY + CGFloat((200 * y)))
        target.zPosition = -1
        target.name = "target"
        target.physicsBody?.isDynamic = false
        target.physicsBody?.usesPreciseCollisionDetection = true
        target.physicsBody?.contactTestBitMask = (target.physicsBody?.collisionBitMask)!
        
        addChild(target)
    }
    func createBackground() {
        for i in 0...1 {
            let sunset = SKTexture(imageNamed: "sunset")
            let sunsetBackground = SKSpriteNode(texture: sunset)
            sunsetBackground.zPosition = -2
            sunsetBackground.position = CGPoint(x: 0, y: sunsetBackground.size.height * CGFloat(i))
            addChild(sunsetBackground)
        }
    }
    // helper function used to make each brick
    func makeBrick(x: Int, y: Int, color: UIColor) {
        brick.removeFromParent()
        brick = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 100))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "Brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.physicsBody?.affectedByGravity = false
        addChild(brick)
    }
    
    func makeBouncyBrick(x: Int, y: Int, color: UIColor) {
        let bouncybrick = SKSpriteNode(color: color, size: CGSize(width: 25, height: 25))
        bouncybrick.position = CGPoint(x: x, y: y)
        bouncybrick.physicsBody = SKPhysicsBody(rectangleOf: bouncybrick.size)
        bouncybrick.physicsBody?.isDynamic = false
        addChild(bouncybrick)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for node in nodes(at: location) {
                if arrowShot {
                    if node.name == "Brick" {
                        brick.position.x = location.x
                        brick.position.y = location.y
                    }
                } else {
                    if node.name == "bow" {
                        shootArrow()
                        arrowShot = true
                    }
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            for node in nodes(at: location) {
                if arrowShot {
                    if node.name == "Brick" {
                        brick.position.x = location.x
                        brick.position.y = location.y
                    }
                }
            }
        }
    }
}


