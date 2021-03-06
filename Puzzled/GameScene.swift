//
//  GameScene.swift
//  Puzzled
//
//  Created by Dylan, Alistair, and Peter on 3/29/22.
//

import SpriteKit
import GameplayKit
import AVFoundation
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
    var restartLabel = SKLabelNode()
    var tutorialLabel = SKLabelNode()
    var tutorialState = 0
    var bkMusic = SKAudioNode()
    var borders = [SKSpriteNode()]
    var tutorial = SKLabelNode()
    var currentLvl = 1
    var nextLvl = false
    var resetLvl = false
    var restartGame = false
    
    //functions and things
    
    //start game function
    override func didMove(to view: SKView) {
        self.scaleMode = SKSceneScaleMode.aspectFill
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //restarts game when app starts
        //removes all borders
        for border in borders {
            if border.parent != nil {
                border.removeFromParent()
            }
        }
        borders.removeAll()
        //creates other stuff
        createBackground()
        makeBorders()
        makeBKMusic()
        bkMusic.run(SKAction.play())
        makeLabels(color: .black)
        makeTutorial(color: .black)
        setLevel(level: currentLvl, reset: false)
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
            for brick in bouncyBricks {
                if object == brick {
                    run(SKAction.playSoundFileNamed("boing.mp3", waitForCompletion: false))
                }
            }
            for brick in bricks {
                if object == brick {
                    ball.physicsBody?.isDynamic = false
                    if object.name == "noMove" {
                        run(SKAction.playSoundFileNamed("metalHit.wav", waitForCompletion: false))
                    } else {
                        run(SKAction.playSoundFileNamed("woodHit.wav", waitForCompletion: false))
                    }
                    resetLevel()
                }
            }
            if object.name == "target" {
                ball.physicsBody?.isDynamic = false
                run(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
                nextLevel()
                //print("Win")
            }
            for border in borders {
                if object == border {
                    ball.physicsBody?.isDynamic = false
                    run(SKAction.playSoundFileNamed("metalHit.wav", waitForCompletion: false))
                    resetLevel()
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
    func makeTarget(pos : CGPoint) {
        target.removeFromParent() //remove target if exists
        let targetPicture = SKTexture(imageNamed: "target")
        target = SKSpriteNode(texture: targetPicture, size: CGSize(width: 75, height: 75))
        target.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        target.position = pos
        target.zPosition = -1
        target.name = "target"
        target.physicsBody?.isDynamic = false
        target.physicsBody?.usesPreciseCollisionDetection = true
        target.physicsBody?.contactTestBitMask = (target.physicsBody?.collisionBitMask)!
        
        addChild(target)
    }
    //creates the background
    func createBackground() {
        let sunset = SKTexture(imageNamed: "sunset")
        let sunsetBackground = SKSpriteNode(texture: sunset)
        sunsetBackground.zPosition = -2
        sunsetBackground.position = CGPoint(x: 0, y: frame.midY)
        addChild(sunsetBackground)
    }
    // helper function used to make each brick
    func makeBrick(x: Int, y: Int, canMove: Bool) {
        let brickPicture = SKTexture(imageNamed: canMove ? "wood" : "metal")
        let brick = SKSpriteNode(texture: brickPicture, color: canMove ? .brown : .gray, size: CGSize(width: 75, height: 75))
        brick.position = CGPoint(x: x, y: y)
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.colorBlendFactor = 0.5
        brick.name = canMove ? "yesMove" : "noMove"
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.allowsRotation = false
        addChild(brick)
        bricks.append(brick) //adds to list of bricks so code can keep track of all the different bricks
    }
    //creates bouncy bricks
    func makeBouncyBrick(x: Int, y: Int, canMove: Bool, rotate: Int /* 0 means flat, 6 means verticle, 3 means 45 leaning right, 9 means 45 leaning left*/ ) {
        let brickPicture = SKTexture(imageNamed: "Bouncy")
        let bouncyBrick = SKSpriteNode(texture: brickPicture, color: canMove ? .magenta : .black, size: CGSize(width: 100, height: 20))
        bouncyBrick.colorBlendFactor = canMove ? 0.3 : 0.7
        bouncyBrick.position = CGPoint(x: x, y: y)
        bouncyBrick.physicsBody = SKPhysicsBody(rectangleOf: bouncyBrick.size)
        bouncyBrick.physicsBody?.isDynamic = false
        bouncyBrick.name = canMove ? "yesMove" : "noMove"
        bouncyBrick.physicsBody?.affectedByGravity = false
        bouncyBrick.physicsBody?.allowsRotation = false
        bouncyBrick.zRotation = (CGFloat(rotate) * .pi)/12
        addChild(bouncyBrick)
        bouncyBricks.append(bouncyBrick)
    }
    //creates the win lose labels
    func makeLabels(color : UIColor) {
        winLabel.fontSize = 100
        winLabel.text = "You Win"
        winLabel.fontName = "Georgia-Bold" //big font for easier reading
        winLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        winLabel.name = "winLabel"
        winLabel.fontColor = color
        winLabel.alpha = 0
        winLabel.zPosition = 1
        addChild(winLabel)
        
        nextLabel.fontSize = 50
        nextLabel.text = "Next Level"
        nextLabel.fontName = "Georgia-Bold"
        nextLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        nextLabel.name = "nextLabel"
        nextLabel.fontColor = color
        nextLabel.alpha = 0
        nextLabel.zPosition = 1
        addChild(nextLabel)
        
        loseLabel.fontSize = 100
        loseLabel.text = "You Lose"
        loseLabel.fontName = "Georgia-Bold"
        loseLabel.position = CGPoint(x: frame.midX, y: frame.midY + 150)
        loseLabel.name = "loseLabel"
        loseLabel.fontColor = color
        loseLabel.alpha = 0
        loseLabel.zPosition = 1
        addChild(loseLabel)
        
        resetLabel.fontSize = 50
        resetLabel.text = "Reset Level"
        resetLabel.fontName = "Georgia-Bold"
        resetLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        resetLabel.name = "resetLabel"
        resetLabel.fontColor = color
        resetLabel.alpha = 0
        resetLabel.zPosition = 1
        addChild(resetLabel)
        
        restartLabel.fontSize = 50
        restartLabel.text = "Restart Level"
        restartLabel.fontName = "Georgia-Bold"
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        restartLabel.name = "restartLabel"
        restartLabel.fontColor = color
        restartLabel.alpha = 0
        restartLabel.zPosition = 1
        addChild(restartLabel)
    }
    func makeTutorial(color : UIColor) {
        tutorialLabel.fontSize = 50
        tutorialLabel.text = ""
        tutorialLabel.fontName = "Georgia-Bold"
        tutorialLabel.position = CGPoint(x: 0, y: 0)
        tutorialLabel.name = "restartLabel"
        tutorialLabel.fontColor = color
        tutorialLabel.alpha = 0
        tutorialLabel.zPosition = 1
        addChild(tutorialLabel)
    }
    func updateTutorial() {
        switch (tutorialState) {
        case 0: //move brick label
            tutorialLabel.position = CGPoint(x: 0, y: 100)
            tutorialLabel.fontSize = 40
            tutorialLabel.text = "Touch and Drag the wooden brick"
            tutorialLabel.alpha = 1
            
        case 1: //shoot ball label
            tutorialLabel.position = CGPoint(x: 0, y: 100)
            tutorialLabel.fontSize = 50
            tutorialLabel.text = "Tap the slingshot"
            tutorialLabel.alpha = 1
        case 2: //teaches other bricks
            tutorialLabel.position = CGPoint(x: 0, y: 100)
            tutorialLabel.text = "Metal Bricks can't be moved"
            tutorialLabel.alpha = 1
        default:
            tutorialLabel.alpha = 0
            break
        }
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
                            if (currentLvl == 2 && tutorialState == 2) {
                                tutorialLabel.alpha = 0
                                tutorialState += 1
                            }
                            run(SKAction.playSoundFileNamed("pickUp.wav", waitForCompletion: false))
                            currentBrick = brick
                            //letting current brick use physics so they cant be placed inside other bricks
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    for brick in bricks {
                        if currentBrick == target && brick.name != "noMove" && node == brick {
                            if (currentLvl == 1 && tutorialState == 0) {
                                tutorialLabel.alpha = 0
                                tutorialState += 1
                            }
                            run(SKAction.playSoundFileNamed("pickUp.wav", waitForCompletion: false))
                            currentBrick = brick
                            brick.physicsBody?.isDynamic = true
                            brick.position = location
                        }
                    }
                    //shoots ball if touching the bow
                    if node.name == "bow" {
                        if (currentLvl == 1 && tutorialState == 1){
                            tutorialLabel.alpha = 0
                            tutorialState += 1
                        }
                        shootBall()
                        ballShot = true
                        
                    }
                }
                //if touching reset or next level labels does the corrisponding action
                if nextLvl {
                    if node.name == "nextLabel" {
                        run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                        nextLevel()
                    }
                }
                if resetLvl {
                    if node.name == "resetLabel" {
                        run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                        resetLevel()
                    }
                }
                if restartGame {
                    if node.name == "restartLabel" {
                        run(SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false))
                        restartLevel()
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
        // if released brick on level 1 updates tutorial text
        if (currentLvl == 1 && tutorialState == 1) {
            updateTutorial()
        }
        //teleports bricks moved outside the border back to middle
        if abs(currentBrick.position.y) > 220 || abs(currentBrick.position.x) > frame.maxX{
            currentBrick.position = CGPoint(x: 0, y: 0)
        }
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
            setLevel(level: currentLvl + 1, reset: false)
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
            setLevel(level: currentLvl, reset: true)
        }
    }
    //restarts game when get to last level
    func restartLevel() {
        if !restartGame {
            winLabel.alpha = 1
            restartLabel.alpha = 1
            restartGame.toggle()
        } else {
            winLabel.alpha = 0
            restartLabel.alpha = 0
            restartGame.toggle()
            setLevel(level: 1, reset: false)
        }
    }
    //sets level specified number, also resets everything. (clearing all bricks, stopping ball, reseting variables etc.)
    func setLevel(level : Int, reset : Bool /*changes wether or not  bricks positions get reset or not*/) {
        currentLvl = level
        ballShot = false
        ball.physicsBody?.isDynamic = false
        if !reset {
            clearBricks()
        }
        switch currentLvl {
        case 0: //for testing
            makeBall(y: -1)
            makeTarget(pos: CGPoint(x: 315, y: -200))
            makeBow(y: -1)
            if !reset {
                makeBouncyBrick(x: 50, y: 50, canMove: true, rotate: 3)
                makeBrick(x: 100, y: 100, canMove: true)
                makeBrick(x: 0, y: 100, canMove: true)
                makeBrick(x: -100, y: 100, canMove: false)
            }
        case 1: //level 1
            makeBow(y: 0)
            makeBall(y: 0)
            makeTarget(pos: CGPoint(x: 315, y: frame.midY))
            if !reset {
                makeBrick(x: 0, y: 0, canMove: true)
            }
            if tutorialState == 0 {
                updateTutorial()
            }
            return
        case 2: //level 2
            makeBow(y: 0)
            makeBall(y: 0)
            makeTarget(pos: CGPoint(x: 315, y: -200))
            if !reset {
                makeBouncyBrick(x: 50, y: 50, canMove: true, rotate: 3)
                makeBouncyBrick(x: 100, y: 100, canMove: true, rotate: 9)
                makeBouncyBrick(x: 100, y: 50, canMove: true, rotate: 9)
                makeBrick(x: 300, y: 0, canMove: false)
                makeBrick(x: -375, y: 0, canMove: false)
            }
            if tutorialState == 2 {
                updateTutorial()
            }
        case 3:  //level 3
            makeBow(y: 1)
            makeBall(y: 1)
            makeTarget(pos: CGPoint(x: 315, y: 200))
            if !reset {
                makeBrick(x: -175, y: 200, canMove: false)
                makeBrick(x: 325, y: 125, canMove: false)
                makeBouncyBrick(x: 50, y: 0, canMove: true, rotate: 9)
                makeBouncyBrick(x: -50, y: 0, canMove: true, rotate: 9)
                makeBouncyBrick(x: 0, y: 50, canMove: true, rotate: 3)
                makeBouncyBrick(x: 0, y: -50, canMove: true, rotate: 3)
            }
        case 4: //level 4
            makeBow(y: 1)
            makeBall(y: 1)
            makeTarget(pos: CGPoint(x: 315, y: 0))
            if !reset {
                makeBrick(x: 325, y: 80, canMove: false)
                makeBrick(x: 325, y: -80, canMove: false)
                makeBrick(x: 0, y: 200, canMove: false)
                makeBrick(x: 300, y: 155, canMove: false)
                makeBouncyBrick(x: -300, y: 0, canMove: true, rotate: -3)
                makeBouncyBrick(x: -325, y: -200, canMove: true, rotate: -3)
                makeBouncyBrick(x: 0, y: 120, canMove: false, rotate: -3)
                makeBouncyBrick(x: 240, y: -11, canMove: false, rotate: -3)
                makeBouncyBrick(x: 175, y: 55, canMove: false, rotate: -3)
                makeBouncyBrick(x: -100, y: 0, canMove: true, rotate: -3)
                makeBouncyBrick(x: -175, y: 0, canMove: true, rotate: -3)
                makeBouncyBrick(x: -175, y: -175, canMove: true, rotate: 3)
                makeBouncyBrick(x: 75, y: -200, canMove: false, rotate: -3)
                makeBouncyBrick(x: 175, y: -200, canMove: false, rotate: 3)
                //makeBrick(x: 0, y: 0, canMove: true)
                //makeBrick(x: 0, y: 1, canMove: true)
                //makeBrick(x: 0, y: -1, canMove: true)
            }
        default:
            //            makeBall(y: 0)
            //            makeTarget(pos: CGPoint(x: 315, y: frame.midY))
            //            makeBow(y: 0)
            tutorialState = 0
            restartLevel()
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
    //background musjc
    func makeBKMusic(){
        //credits:
        //        Endless Summer by Luke Bergs | https://soundcloud.com/bergscloud/
        //        Music promoted by https://www.chosic.com/free-music/all/
        //        Creative Commons CC BY-SA 3.0
        //        https://creativecommons.org/licenses/by-sa/3.0/
        //        Tropical Soul by Luke Bergs | https://soundcloud.com/bergscloud/
        //        Music promoted by https://www.chosic.com/free-music/all/
        //        Creative Commons CC BY-SA 3.0
        //        https://creativecommons.org/licenses/by-sa/3.0/
        //        Downtown Glow by Ghostrifter & Devyzed
        //        Creative Commons ??? Attribution-NoDerivs 3.0 Unported ??? CC BY-ND 3.0
        //        Music promoted by https://www.chosic.com/free-music/all/
        bkMusic.removeFromParent()
        bkMusic = SKAudioNode(fileNamed : "background 1")
        bkMusic.isPositional = false
        bkMusic.run(SKAction.changeVolume(to: 0.5, duration: 0))
        addChild(bkMusic)
    }
    //makes border surrounding the play area
    func makeTopBottomBorder(isTop : Bool) {
        let border = SKSpriteNode(color: .clear, size: CGSize(width: frame.maxX - frame.minY, height: 50))
        border.physicsBody = SKPhysicsBody(rectangleOf: border.size)
        border.physicsBody?.affectedByGravity = false
        border.physicsBody?.isDynamic = false
        border.position = CGPoint(x: frame.midX, y: isTop ? 275 : -275)
        addChild(border)
        borders.append(border)
    }
    func makeLeftRightBorder(isLeft : Bool) {
        let border = SKSpriteNode(color: .clear, size: CGSize(width: 50, height: 400))
        border.physicsBody = SKPhysicsBody(rectangleOf: border.size)
        border.physicsBody?.affectedByGravity = false
        border.physicsBody?.isDynamic = false
        border.position = CGPoint(x: isLeft ? frame.maxX + 20: frame.minX - 20, y: frame.midY)
        addChild(border)
        borders.append(border)
    }
    func makeBorders(){
        makeTopBottomBorder(isTop: true)
        makeTopBottomBorder(isTop: false)
        makeLeftRightBorder(isLeft: true)
        makeLeftRightBorder(isLeft: false)
    }
}


