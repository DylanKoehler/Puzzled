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
    var currentLvl = 1
    var nextLvl = false
    var resetLvl = false
    
    //functions and things
    
    //start game function
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //restarts game when app starts
        createBackground()
        makeLabels()
        setLevel(level: currentLvl)
    }
    //used for collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    //detects collision between a ball and inputed object
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
    //creates the ball
    func makeBall(y: Int /* Changes the starting y position for 3 diff options */) {
        ball.removeFromParent() //remove ball if exists
        let ballPicture = SKTexture(imageNamed: "Ball") //creates a texture that is overlayed on the ball
        ball = SKShapeNode(circleOfRadius: 15)
        ball.fillTexture = ballPicture
        ball.fillColor = .darkGray
        ball.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)))
        ball.name = "ball"
        
        ball.physicsBody?.usesPreciseCollisionDetection = true
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.isDynamic = false
        //makes sure ball doesnt slow down when shot
        ball.physicsBody?.friction = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        
        addChild(ball)
    }
    //creates the target
    func makeBow(y: Int) {
        bow.removeFromParent()
        let bowPicture = SKTexture(imageNamed: "slingshot") //create texture that is overlayed on the "bow"
        bow = SKSpriteNode(texture: bowPicture, size: CGSize(width: 75, height: 75))
        bow.physicsBody = SKPhysicsBody(rectangleOf: bow.size)
        bow.position = CGPoint(x: frame.minX + 50, y: frame.midY + CGFloat((200 * y)) - 10)
        bow.zRotation = -.pi/9
        bow.name = "bow"
        
        bow.physicsBody?.isDynamic = false
        //makes it so ball doesnt interact with the bow
        bow.physicsBody?.categoryBitMask = 0
        //makes it so the bow is always under the ball
        bow.zPosition = -1
        
        addChild(bow)
    }
    //starts moving the ball
    func shootBall() {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
    }
    //creates the target
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
    //creates the background
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
        bricks.append(brick) //adds to list of bricks so code can keep track of all the different bricks
    }
    //creates bouncy bricks
    func makeBouncyBrick(x: Int, y: Int, canMove: Bool, type: Int /* -1 means top leans left, 1 means leans right*/ ) {
        let brickPicture = SKTexture(imageNamed: "Bouncy")
        let bouncyBrick = SKSpriteNode(texture: brickPicture, color: canMove ? .magenta : .black, size: CGSize(width: 100, height: 20))
        bouncyBrick.colorBlendFactor = canMove ? 0.3 : 0.7
        bouncyBrick.position = CGPoint(x: x, y: y)
        bouncyBrick.physicsBody = SKPhysicsBody(rectangleOf: bouncyBrick.size)
        bouncyBrick.physicsBody?.isDynamic = false
        bouncyBrick.name = canMove ? "yesMove" : "noMove"
        bouncyBrick.physicsBody?.affectedByGravity = false
        bouncyBrick.physicsBody?.allowsRotation = false
        bouncyBrick.zRotation = 0.8 * CGFloat(type) //sets rectangle to 45 degrees so ball bounces 90 degrees
        addChild(bouncyBrick)
        bouncyBricks.append(bouncyBrick)
    }
    //creates the win lose labels
    func makeLabels() {
        winLabel.fontSize = 100
        winLabel.text = "You Win"
        winLabel.fontName = "Georgia-Bold" //big font for easier reading
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        winLabel.name = "winLabel"
        winLabel.color = .darkGray
        winLabel.alpha = 0
        winLabel.zPosition = 1
        addChild(winLabel)
        
        nextLabel.fontSize = 50
        nextLabel.text = "Next Level"
        nextLabel.fontName = "Georgia-Bold"
        nextLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        nextLabel.name = "nextLabel"
        nextLabel.color = .darkGray
        nextLabel.alpha = 0
        nextLabel.zPosition = 1
        addChild(nextLabel)
        
        loseLabel.fontSize = 100
        loseLabel.text = "You Lose"
        loseLabel.fontName = "Georgia-Bold"
        loseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        loseLabel.name = "loseLabel"
        loseLabel.color = .darkGray
        loseLabel.alpha = 0
        loseLabel.zPosition = 1
        addChild(loseLabel)
        
        resetLabel.fontSize = 50
        resetLabel.text = "Reset Level"
        resetLabel.fontName = "Georgia-Bold"
        resetLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        resetLabel.name = "resetLabel"
        resetLabel.color = .darkGray
        resetLabel.alpha = 0
        resetLabel.zPosition = 1
        addChild(resetLabel)
    }
    //detects finger presses
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //makes sure none of the bricks can move on there own
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
                    //checks all bouncy and normal bricks if they are being touched by finger
                    for brick in bouncyBricks {
                        if currentBrick == target && brick.name != "noMove" && node == brick {
                            currentBrick = brick
                            //letting current brick use physics so they cant be placed inside other bricks
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    for brick in bricks {
                        if currentBrick == target && brick.name != "noMove" && node == brick {
                            currentBrick = brick
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    //shoots ball if touching the bow
                    if node.name == "bow" {
                        shootBall()
                        ballShot = true
                        
                    }
                }
                //if touching reset or next level labels does the corrisponding action
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
    //detects finger movment/dragging
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            //for node in nodes(at: location) {
            if !ballShot {
                for brick in bouncyBricks {
                    //uses current brick instead of checking every brick, so if user moves finger to fast, it wont lose the brick they want to move
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
    //for finger release
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //fixes bricks that could be inside eachother.
        spreadBricks(condition: currentBrick != target)
        //changes current brick on release so next finger press wont confuse previous current brick with the current
        currentBrick = target
    }
    func spreadBricks (condition : Bool) {
        if condition {
            //sets all bricks and bouncy bricks to dynamic so physics can push bricks outside of eachother
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
    }
    //creates next level and next level labels
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
    //resets level and creates reset level labels
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
    //sets level specified number, also resets everything. (clearing all bricks, stopping ball, reseting variables etc.)
    func setLevel(level : Int) {
        currentLvl = level
        ballShot = false
        ball.physicsBody?.isDynamic = false
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
            makeBow(y: 0)
            makeBall(y: 0)
            makeTarget(y: 0)
            makeBrick(x: 0, y: 0, canMove: true)
            return
        case 2: //level 2
            makeBow(y: 0)
            makeBall(y: 0)
            makeTarget(y: -1)
            makeBrick(x: 0, y: -200, canMove: true)
            makeBouncyBrick(x: -100, y: 30, canMove: false, type: -1)
            makeBouncyBrick(x: -70, y: -200, canMove: false, type: -1)
        default:
            makeBall(y: 0)
            makeTarget(y: 0)
            makeBow(y: 0)
        }
        spreadBricks(condition: true)
    }
    //clears all bricks and bouncy bricks
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


