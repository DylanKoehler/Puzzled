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
    var ball = SKShapeNode()
    var target = SKSpriteNode()
    var bouncyBricks = [SKSpriteNode]()
    var bricks = [SKSpriteNode]()
    var bow = SKSpriteNode()
    var currentBrick = SKSpriteNode() //when moving brick faster than touches moved can keep up, this variable fixes by storing last touched node
    var ballShot = false
    var winLabel = SKLabelNode()
    var nextLabel = SKLabelNode()
    var loseLabel = SKLabelNode()
    var resetLabel = SKLabelNode()
    var currentLvl = 0
    var nextLvl = false
    var resetLvl = false
    
    //functions and things
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //restarts game when app starts
        createBackground()
        makeLabels()
        setLevel(level: currentLvl)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    func collisionBetween(ball: SKNode, object: SKNode) {
        //what happens when ball hits target
        if ballShot {
            for brick in bricks {
                if object == brick {
                    ball.physicsBody?.isDynamic = false
                    print("Lose")
                    resetLevel()
                }
            }
            if object.name == "target" {
                ball.physicsBody?.isDynamic = false
                nextLevel()
                print("Win")
            }
            for brick in bouncyBricks {
                if object == brick {
                    
                }
            }
        }
    }
    func makeBall(y: Int /* Changes the starting y position for 3 diff options */) {
        ball.removeFromParent() //remove ball if exists
        let ballPicture = SKTexture(imageNamed: "Ball")
        ball = SKShapeNode(circleOfRadius: 15)
        ball.fillTexture = ballPicture
        ball.fillColor = .darkGray
        ball.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)))
        ball.name = "ball"
        
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.isDynamic = false
        ball.physicsBody?.friction = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        
        addChild(ball)
    }
    func makeBow(y: Int) {
        bow.removeFromParent()
        let bowPicture = SKTexture(imageNamed: "bow")
        bow = SKSpriteNode(texture: bowPicture, size: CGSize(width: 75, height: 75))
        bow.physicsBody = SKPhysicsBody(rectangleOf: bow.size)
        bow.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)))
        bow.zRotation = -.pi/9
        bow.name = "bow"
        
        bow.physicsBody?.isDynamic = false
        //makes it so ball doesnt interact with the bow
        bow.physicsBody?.categoryBitMask = 0
        //makes it so the bow is always under the ball
        bow.zPosition = -1
        
        addChild(bow)
    }
    func shootBall() {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
    }
    func makeTarget(y : Int) {
        target.removeFromParent() //remove target if exists
        let targetPicture = SKTexture(imageNamed: "target")
        target = SKSpriteNode(texture: targetPicture, size: CGSize(width: 75, height: 75))
        target.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
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
    func makeBrick(x: Int, y: Int, canMove: Bool) {
        let brickPicture = SKTexture(imageNamed: "brick")
        let brick = SKSpriteNode(texture: brickPicture, color: canMove ? .red : .black, size: CGSize(width: 75, height: 75))
        brick.position = CGPoint(x: x, y: y)
        brick.colorBlendFactor = canMove ? 0.7 : 0.5
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.name = canMove ? "yesMove" : "noMove"
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.allowsRotation = false
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeBouncyBrick(x: Int, y: Int, canMove: Bool, type: Int) {
        let brickPicture = SKTexture(imageNamed: "Bouncy")
        let bouncyBrick = SKSpriteNode(texture: brickPicture, color: canMove ? .magenta : .black, size: CGSize(width: 100, height: 20))
        bouncyBrick.colorBlendFactor = canMove ? 0.3 : 0.7
        bouncyBrick.position = CGPoint(x: x, y: y)
        bouncyBrick.physicsBody = SKPhysicsBody(rectangleOf: bouncyBrick.size)
        bouncyBrick.physicsBody?.isDynamic = false
        bouncyBrick.name = canMove ? "yesMove" : "noMove"
        bouncyBrick.physicsBody?.affectedByGravity = false
        bouncyBrick.physicsBody?.allowsRotation = false
        bouncyBrick.zRotation = 0.8 * CGFloat(type)
        addChild(bouncyBrick)
        bouncyBricks.append(bouncyBrick)
    }
    func makeLabels() {
        winLabel.fontSize = 100
        winLabel.text = "You Win"
        winLabel.fontName = "Georgia-Bold"
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        winLabel.name = "winLabel"
        winLabel.color = .darkGray
        winLabel.alpha = 0
        addChild(winLabel)
        
        nextLabel.fontSize = 50
        nextLabel.text = "Next Level"
        nextLabel.fontName = "Georgia-Bold"
        nextLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        nextLabel.name = "nextLabel"
        nextLabel.color = .darkGray
        nextLabel.alpha = 0
        addChild(nextLabel)
        
        loseLabel.fontSize = 100
        loseLabel.text = "You Lose"
        loseLabel.fontName = "Georgia-Bold"
        loseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        loseLabel.name = "loseLabel"
        loseLabel.color = .darkGray
        loseLabel.alpha = 0
        addChild(loseLabel)
        
        resetLabel.fontSize = 50
        resetLabel.text = "Reset Level"
        resetLabel.fontName = "Georgia-Bold"
        resetLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        resetLabel.name = "resetLabel"
        resetLabel.color = .darkGray
        resetLabel.alpha = 0
        addChild(resetLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for brick in bricks {
            brick.physicsBody?.isDynamic = false
        }
        for brick in bouncyBricks {
            brick.physicsBody?.isDynamic = false
        }
        for touch in touches {
            let location = touch.location(in: self)
            for node in nodes(at: location) {
                if !ballShot {
                    for brick in bouncyBricks {
                        if brick.name != "noMove" && node == brick {
                            currentBrick = brick
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    for brick in bricks {
                        if brick.name != "noMove" && node == brick {
                            currentBrick = brick
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    if node.name == "bow" {
                        shootBall()
                        ballShot = true
                        
                    }
                }
                if nextLvl {
                    if node.name == "nextLabel" {
                        nextLevel()
                    }
                }
                if resetLvl {
                    if node.name == "resetLabel" {
                        resetLevel()
                    }
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            //for node in nodes(at: location) {
            if !ballShot {
                for brick in bouncyBricks {
                    if currentBrick == brick {
                        brick.position = location
                    }
                }
                for brick in bricks {
                    if currentBrick == brick {
                        brick.position = location
                    }
                }
            }
            
            //}
        }
    }
    //when you take finger off it changes current so next time you press it wont jump to the old current
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //fixes bricks that could be inside eachother.
        if currentBrick != target {
            for brick in bricks {
                if (brick.name != "noMove"){
                    brick.physicsBody?.isDynamic = true
                }
            }
            for brick in bouncyBricks {
                if (brick.name != "noMove"){
                    brick.physicsBody?.isDynamic = true
                }
            }
        }
        currentBrick = target
        
    }
    func nextLevel() {
        if !nextLvl {
            winLabel.alpha = 1
            nextLabel.alpha = 1
            nextLvl.toggle()
        } else {
            winLabel.alpha = 0
            nextLabel.alpha = 0
            nextLvl.toggle()
            setLevel(level: currentLvl + 1)
        }
    }
    func resetLevel() {
        if !resetLvl {
            loseLabel.alpha = 1
            resetLabel.alpha = 1
            resetLvl.toggle()
        } else {
            loseLabel.alpha = 0
            resetLabel.alpha = 0
            resetLvl.toggle()
            setLevel(level: currentLvl)
        }
    }
    func setLevel(level : Int) {
        currentLvl = level
        ballShot = false
        clearBricks()
        switch currentLvl {
        case 0: //for testing
            makeBall(y: -1)
            makeTarget(y: -1)
            makeBow(y: -1)
            makeBouncyBrick(x: 50, y: 50, canMove: true, type: 1)
            makeBrick(x: 100, y: 100, canMove: true)
            makeBrick(x: 0, y: 100, canMove: true)
            makeBrick(x: -100, y: 100, canMove: false)
        case 1: //level 1
            makeBow(y: 1)
            makeBall(y: 1)
            makeTarget(y: -1)
            makeBouncyBrick(x: 50, y: 50, canMove: true, type: 1)
            makeBouncyBrick(x: 100, y: 100, canMove: true, type: -1)
            makeBouncyBrick(x: 100, y: 50, canMove: true, type: -1)
            return
        default:
            return
        }
    }
    func clearBricks () {
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll()
        for brick in bouncyBricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bouncyBricks.removeAll()
    }
}


