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
    
    //functions and things
    override func didMove(to view: SKView) {
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    func makeArrow() {
        arrow.removeFromParent() //remove arrow if exists
        arrow = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 20))
        arrow.position = CGPoint(x: frame.midX, y: frame.midY)
        arrow.name = "arrow"
        arrow.physicsBody = SKPhysicsBody(rectangleOf: arrow.size)
        arrow.physicsBody?.isDynamic = false
        addChild(arrow)
    }
}