//
//  GameScene.swift
//  Puzzled
//
//  Created by Dylan, Alistair, and Peter on 3/29/22.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene {
    //variables and things
    var arrow = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var removedBricks = 0

    
    //functions and things
    override func didMove(to view: SKView) {
        makeBricks()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    func makeArrow() {
        arrow.removeFromParent() //remove arrow if exists
        arrow = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 20))
        arrow.position = CGPoint(x: frame.midX, y: frame.midY)
        arrow.name = "arrow"
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = false
        addChild(arrow)
    }
    func makeBricks() {
        // first, remove any leftover bricks (from prior game)
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll()  // clear the array
        removedBricks = 0   // reset the counter
        
    }
    // helper function used to make each brick
    func makeBrick(x: Int, y: Int, color: UIColor) {
        let brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        bricks.append(brick)
    }
}
