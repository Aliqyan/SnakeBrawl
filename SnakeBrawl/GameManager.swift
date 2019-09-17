import SpriteKit
class GameManager {
    
    var scene: GameScene!
    var nextTime: Double?
    var timeExtension: Double = 0.2

    var lastCollision: Double = 0
    var gameResult = 0;
    var gameInitialized = false;
    var gameOver = false;
    var gameOn = false;
    var player1: Snake = Snake()
    var player2: Snake = Snake()
    
    //Struct for the snake class
    struct Snake{
        var direction = 4;
        var color = SKColor.blue;
        var hit = false;
        var flicker = true;
        var position: [(Int, Int)] = [];
        var victories = 0;
    }
    
    init(scene: GameScene) {
        self.scene = scene
    }
    //Initializes snake objects and sets their positions on the board as well as generating a new point
    func initGame() {
        gameOn = true;
        player1 = Snake()
        player2 = Snake()
        
        //Player 1 starting positions
        player1.position.append((3, 2))
        player1.position.append((4, 1))
        player1.position.append((3, 0))
        player1.direction = 3;
     
        //Player 2 starting positions
        player2.position.append((11, 22))
        player2.position.append((11, 23))
        player2.position.append((11, 24))
        player2.direction = 1;
        gameInitialized = true;
        //Sets the colors of the snakes
        renderChange()
        //Generates 'food'
        generateNewPoint()
    }
    
    //Checks if the input movement will make the snake turn back onto itself. ie: Moving left and input is to the right
    //If it does true is returned, otherwise, false
    func checkOverlap(dir: Int, player: Snake) -> Bool {
        var xChange = -1
        var yChange = 0
        switch dir {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        var x = player.position[0].1 + xChange
        var y = player.position[0].0 + yChange
        if player.position.count > 0 {
            if y > 14 {
                y = 0
            } else if y < 0 {
                y = 14
            } else if x > 24 {
                x = 0
            } else if x < 0 {
                x = 24
            }
        }
        return (y == player.position[1].0 &&
            x == player.position[1].1);
    }
    
    //If the input direction does not cause the snake to move back onto itself, then the input is valid and the snake's direction will be changed to the input
    //Direction is a variable contained within the snake struct
    func setDirection(playerID: String, direction: Int){
        if(playerID == "1"){
            if(player1.direction != 0 && player1.position.count > 1 && !checkOverlap(dir: direction, player: player1)){
                player1.direction = direction
            }
        }else if(playerID == "2" ){
            if(player2.direction != 0 && player2.position.count > 1 && !checkOverlap(dir: direction, player: player2)){
                player2.direction = direction
            }        
        }
    }
    
    //Generates 'food' on the board at a random point. This random point excludes the positions where the snakes are.
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(24))
        var randomY = CGFloat(arc4random_uniform(14))
        
        while contains(a: player1.position, v: (Int(randomX), Int(randomY))) || contains(a: player2.position, v: (Int(randomX), Int(randomY)))  {
            randomX = CGFloat(arc4random_uniform(24))
            randomY = CGFloat(arc4random_uniform(14))
        }
        scene.scorePos = CGPoint(x: randomX, y: randomY)
    }
    
    //If a snake goes onto the square with 'food' on it, a new point is generated and the size of the snake increases by one. This block is appended to the end of the snake.
    private func checkForScore(player: inout Snake) {
        if scene.scorePos != nil {
            let x = player.position[0].0
            let y = player.position[0].1
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                generateNewPoint()
                player.position.append(player.position.last!)
            }
        }
    }


    // Game Driver // time is in seconds
    //Runs continuously, calling the functions necessary to play, like updatePlayerPosition and the checkForScore functions.
    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if (time >= nextTime! && gameOn && gameInitialized) {
                if(!gameOver){

                    nextTime = time + timeExtension
                    //print(time)
                    
                    updatePlayerPosition(player: &player1)
                    updatePlayerPosition(player: &player2)

                    checkForScore(player: &player2)
                    checkForScore(player: &player1)
                    
                    //Gives the snake 2.5 seconds of invulnerability once it collides with the enemy snake
                    if(time > 2.5 + lastCollision){
                        player1.hit = false;
                        player2.hit = false;
                        if(checkCollision(player1: &player1, player2: &player2)){
                            lastCollision = time;
                        }
                    }
                    checkForDeath()
                }else{
                    //If the game is over, run the finishAnimation
                    finishAnimation(player: &player2)
                    finishAnimation(player: &player1)
                }

            }
        }
    }
    // Collisions between snakes
    //When a snake's head hits the enemy snake, the enemy snake loses a square. If a snake is of size 3 and gets hit, it dies/loses.
    private func checkCollision(player1: inout Snake, player2: inout Snake) ->Bool {
        if player1.position.count > 0 && player2.position.count > 0{
            let player1Head = player1.position[0]
            let player2Head = player2.position[0]
            //Checks if the position of both of the snakes heads are at the same point on the board. If they are, both lose a square.
            if (player1Head.0 == player2Head.0 && player1Head.1 == player2Head.1) {
                player1.position.remove(at: player1.position.count-1)
                player2.position.remove(at: player2.position.count-1)
                player1.hit = true;
                player2.hit = true;
                return true;
            }
            //If the head of a snake has the same position as one of the squares of the enemy snake, the enemy has been hit. This is implemented by seeing if the 'head' (player1head) of a snake is contained inside the 'body'(player2.position, the array of all positions on the board a snake occupies) of the enemy. 'contains' function implementation is further below.
            if contains(a:player2.position, v:player1Head){
                player2.position.remove(at: player2.position.count-1)
                player2.hit = true;
                return true;
            }
            if contains(a:player1.position, v:player2Head){
                player1.position.remove(at: player1.position.count-1)
                player1.hit = true;
                return true;
            }
        }
        return false;
    }
    //If a snake is dead (has direction = 0), the game is over, the if condition is satisfied and finish animation runs
    private func finishAnimation(player: inout Snake) {
        if ( (player1.direction == 0 && player1.position.count > 0) || (player2.direction == 0 && player2.position.count > 0)) {
            
            print("end game")
            //Resets game variables
            gameOver = false;
            gameOn = false;
            
            player1.direction = 4
            player2.direction = 2
            scene.scorePos = nil
            player1.position.removeAll()
            player2.position.removeAll()
            renderChange()
            
            if(gameResult == 1){
                self.scene.player2ScoreValue += 1;
                self.scene.winningMessage.text = "Player 2 Wins"

            } else  if(gameResult == 2){
                self.scene.player1ScoreValue += 1;
                self.scene.winningMessage.text = "Player 1 Wins"

            }else{
                self.scene.winningMessage.text = "It's A Tie"

            }
            self.scene.player1Score.text = "Player 1 Score: " + String(self.scene.player1ScoreValue)
            self.scene.player2Score.text = "Player 2 Score: " + String(self.scene.player2ScoreValue)
            
            //Resets positions
            player1.position.append((1, 1))
            player1.position.append((1, 2))
            player1.position.append((1, 3))
            player1.direction = 1;
            
            player2.position.append((5, 10))
            player2.position.append((5, 11))
            player2.position.append((5, 12))
            
            //Opens up the menu
            scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
                self.scene.gameBG.isHidden = true
                self.scene.gameLogo.isHidden = false
                self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                    self.scene.playButton.isHidden = false
                    self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                }
            }
            
        }
    }
    
    //Checks if a snake is dead. Snake is dead when its 'count' or size is less than 3. Snake also dies immediately if it runs into itself.
    private func checkForDeath() {
        //Checks if size < 3, if it is, direction is set to 0, meaning it is dead
        if(player1.position.count < 3){
            player1.direction = 0
            gameResult = 1;
            gameOver = true;
        }
        if (player2.position.count < 3){
            player2.direction = 0
            gameResult = 2;
            gameOver = true;
        }
        //Checks if both directions are 0, meaning game is a tie, gameResult = 3
        if(player2.direction == 0 && player1.direction == 0){
            gameResult = 3;
        }
        //Checks if the snake ran into itself by seeing if its own head is contained within the elements of its body. The snakes head is first removed from the array of its body and then the check is done.
        if (player1.position.count >= 3 && player2.position.count >= 3) {
            var arrayOfPositions1 = player1.position
            var arrayOfPositions2 = player2.position
            let headOfSnake1 = arrayOfPositions1[0]
            let headOfSnake2 = arrayOfPositions2[0]
            arrayOfPositions1.remove(at: 0)
            arrayOfPositions2.remove(at: 0)
            if contains(a: arrayOfPositions1, v: headOfSnake1) {
                player1.direction = 0
                gameResult = 1;
                gameOver = true;
            }
            if contains(a: arrayOfPositions2, v: headOfSnake2) {
                player2.direction = 0
                gameResult = 2;
                gameOver = true;
            }
        }
    }
    
    //Allows touch input for player 1's snake. Useful for testing.
    func swipe(ID: Int) {
        if !(ID == 2 && player1.direction == 4) && !(ID == 4 && player1.direction == 2) {
            if !(ID == 1 && player1.direction == 3) && !(ID == 3 && player1.direction == 1) {
                player1.direction = ID
            
                if player1.direction != 0 {
                    player1.direction = ID
                }

            }
        }
    }
    
    //Sets colors of the snakes and 'food'
    func renderChange() {
        for (node, x, y) in scene.gameArray {
            if contains(a: player1.position, v: (x,y)) {
                if(player1.hit){
                    player1.color = SKColor.green
                }else{
                    player1.color = SKColor.orange;
                }
                node.fillColor = player1.color;
                
            }else if contains(a: player2.position, v: (x,y)) {
                
                if(player2.hit){
                    player2.color = SKColor.purple
                }else{
                    player2.color = SKColor.cyan;
                }
                node.fillColor = player2.color;
            } else {
                node.fillColor = SKColor.clear
             
                if scene.scorePos != nil {
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
        
    }
    
    //Implementation of function to check if a point is contained within an array. In practice, this is for checking if the head of a snake is inside the body of another, or in its own.
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
    
    //Makes the snake move in the direction of its 'direction' member in its struct. Updates all the positions of its body.
    //Direction is modified earlier on in the 'setDirection' function
    private func updatePlayerPosition(player: inout Snake) {
    
        var xChange = -1
        var yChange = 0
        //Sets the xChange and yChange variables based on the direction of the snake
        switch player.direction {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        //Starts at the end of the array of positions the snake occupies and makes an element equal to the one in front of it. ie: The last block moves to where the second last block is and so on ... the head moves in the direction of 'xChange' and 'yChange' which is based on the direction set by the user input
        if player.position.count > 0 {
            var start = player.position.count - 1
            while start > 0 {
                player.position[start] = player.position[start - 1]
                start -= 1
            }
            player.position[0] = (player.position[0].0 + yChange, player.position[0].1 + xChange)
        }
        
        //Allows the snake to travel through the edges and move from one end to the other. ie: When it goes into the left 'wall' it comes out the right 'wall', similarly for the top and bottom.
        if player.position.count > 0 {
            let x = player.position[0].1
            let y = player.position[0].0
            if y > 14 {
                player.position[0].0 = 0
            } else if y < 0 {
                player.position[0].0 = 14
            } else if x > 24 {
                player.position[0].1 = 0
            } else if x < 0 {
                player.position[0].1 = 24
            }
        }
        renderChange()
    }
}
