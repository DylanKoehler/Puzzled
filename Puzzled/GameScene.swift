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
    var target = SKShapeNode()
    var brick = SKSpriteNode()
    
    
    //functions and things
    override func didMove(to view: SKView) {
        //restarts game when app starts
        createBackground()
        resetGame()
        shootArrow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    func resetGame() { //before game starts
        makeArrow()
        makeTarget()
        makeBrick(x: 100, y: 100, color: .black)

    }
    func makeArrow() {
        arrow.removeFromParent() //remove arrow if exists
        arrow = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 20))
        arrow.position = CGPoint(x: frame.midX, y: frame.midY)
        arrow.name = "arrow"
        
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = false
        arrow.physicsBody?.usesPreciseCollisionDetection = true
        arrow.physicsBody?.friction = 0
        arrow.physicsBody?.affectedByGravity = false
        arrow.physicsBody?.restitution = 1
        arrow.physicsBody?.linearDamping = 0
        arrow.physicsBody?.contactTestBitMask = (arrow.physicsBody?.collisionBitMask)!
        
        addChild(arrow)
    }
    func shootArrow() {
        arrow.physicsBody?.isDynamic = true
        arrow.physicsBody?.applyImpulse(CGVector(dx: 3, dy: 0))
    }
    func makeTarget() {
        target.removeFromParent() //remove target if exists
        target = SKShapeNode(circleOfRadius: 50)
        target.position = CGPoint(x: frame.midX - 150, y: frame.midY + 100)
        target.strokeColor = .black
        target.fillColor = .blue
        target.name = "target"
        target.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        target.physicsBody?.isDynamic = false
        addChild(target)
    }
    func createBackground() {
        for i in 0...1 {
            let sunset = SKTexture(imageNamed: "Sunset")
            let sunsetBackground = SKSpriteNode(texture: sunset)
            sunsetBackground.zPosition = -1
            sunsetBackground.position = CGPoint(x: 0, y: sunsetBackground.size.height * CGFloat(i))
            addChild(sunsetBackground)
        }
        
        
    }
    // helper function used to make each brick
    func makeBrick(x: Int, y: Int, color: UIColor) {
        let brick = SKSpriteNode(color: .black, size: CGSize(width: 100, height: 100))
        brick.position = CGPoint(x: x, y: y)
        brick.name = "Brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
    }
}


