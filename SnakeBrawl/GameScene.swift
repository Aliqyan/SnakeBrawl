import CoreBluetooth
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // BLE
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral!
    var peripherals = Array<CBPeripheral>()
    let arduinoService = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
    let TXCharacteristicCBUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let RXCharacteristicCBUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    
    var gameLogo: SKLabelNode!
    var player1Score: SKLabelNode!
    var player2Score: SKLabelNode!
    var player1ScoreValue: Int =  0;
    var player2ScoreValue: Int = 0;
    var winningMessage: SKLabelNode!
    var playButton: SKShapeNode!

    var game: GameManager!

    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
    var scorePos: CGPoint?
    
    
    override func didMove(to view: SKView){
        initializeMenu()
        game = GameManager(scene: self)
        initializeGameView()
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }

    @objc func swipeR() {
        game.swipe(ID: 3)
    }
    @objc func swipeL() {
        game.swipe(ID: 1)

    }
    @objc func swipeU() {
        game.swipe(ID: 2)

    }
    @objc func swipeD() {
        game.swipe(ID: 4)

    }
    override func update(_ currentTime: TimeInterval){
        game.update(time: currentTime)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    private func initializeGameView() {
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

        player1Score = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        player1Score.zPosition = 1
        player1Score.position = CGPoint(x: -220, y: (self.view!.bounds.size.height / -2) +  160)
        player1Score.fontSize = 30
        player1Score.isHidden = true
        player1Score.text = "Player 1 Score: 0"
        player1Score.fontColor = SKColor.white
        self.addChild(player1Score)

        player2Score = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        player2Score.zPosition = 1
        player2Score.position = CGPoint(x: 220, y: (self.view!.bounds.size.height / -2) +  160)
        player2Score.fontSize = 30
        player2Score.isHidden = true
        player2Score.text = "Player 2 Score: 0"
        player2Score.fontColor = SKColor.white
        self.addChild(player2Score)
        
        let width = self.view!.bounds.size.width - 412
        let height = self.view!.bounds.size.height - 414
 
        // + 25 to slightly offset up
        let rect = CGRect(x: -width / 2, y: -height / 2 + 25, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)
        //6
        createGameBoard(width: Int(width), height: Int(height))
    }
    
    //create a game board, initialize array of cells
    private func createGameBoard(width: Int, height: Int) {
        let cellWidth: CGFloat = 28
        let numRows = 15
        let numCols = 25
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2) + 25
        //loop through rows and columns, create cells
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                //add to array of cells -- then add to game board
                gameArray.append((node: cellNode, x: i, y: j))
                gameBG.addChild(cellNode)
                //iterate x
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
 
    //4
    private func startGame() {
        print("start game")

        //1
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        //2
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        //3
        let bottomCorner = CGPoint(x: -200, y: (self.view!.bounds.size.height / -2) + 150)
        
        
        self.gameBG.setScale(0)
        self.player1Score.setScale(0)
        self.player2Score.setScale(0)

        self.gameBG.isHidden = false
        self.player1Score.isHidden = false
        self.player2Score.isHidden = false

        self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
        self.player1Score.run(SKAction.scale(to: 1, duration: 0.4))
        self.player2Score.run(SKAction.scale(to: 1, duration: 0.4))

        self.game.initGame()
        //}
    }
    
    
    private func initializeMenu() {
        //Create game title
        gameLogo = SKLabelNode()
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.width / 2) - 290)
        gameLogo.fontSize = 90
        gameLogo.text = "Snake Brawl"
        gameLogo.fontColor = SKColor.orange
        gameLogo.fontName = "Futura Bold"
        
        self.addChild(gameLogo)
        //Create best score label
        winningMessage = SKLabelNode(fontNamed: "Futura Bold")
        winningMessage.zPosition = 1
        winningMessage.position = CGPoint(x: 0, y: gameLogo.position.y - 20)
        winningMessage.fontSize = 60
        winningMessage.text = ""
        winningMessage.fontColor = SKColor.white
        self.addChild(winningMessage)
        //Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.width / -2) + 250)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    }
    
}

// Turn the ipad's bluetooth pairing capabilities on
extension GameScene: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            self.centralManager?.scanForPeripherals(withServices: [arduinoService], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        arduinoPeripheral = peripheral
        arduinoPeripheral.delegate = self
    
        centralManager.stopScan()
        centralManager.connect(arduinoPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Conection Success")
        arduinoPeripheral.discoverServices([arduinoService])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        self.centralManager?.scanForPeripherals(withServices: [arduinoService], options: nil)
        
    }
    
}

//once connected to the arduino read data from it
extension GameScene: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
                
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
                
            }
        }
    }
    
    func getSubstring(x: String, start: Int, end: Int) -> String{
        return String(x[x.index(x.startIndex, offsetBy: start) ..< x.index(x.startIndex, offsetBy: end)]);
    }
    
    
    private func convertToString(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return "error" }
        let byteArray = [UInt8](characteristicData)
        //convert the byte array into a string
        let directResultString = NSString(bytes: byteArray, length:
            byteArray.count, encoding: String.Encoding.utf8.rawValue)! as String
        
        return directResultString;
    }
    
    // process incoming data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case TXCharacteristicCBUUID:
            print("TX")
        case RXCharacteristicCBUUID:
            let data = convertToString(from: characteristic)
            // either 1, 2, or s
            let playerIdentifier = getSubstring(x: data, start: 0, end: 1);
            
            if(playerIdentifier == "s"){
                //the main button
                let beginGame = Int(getSubstring(x: data, start: 1, end: 2))!
                // only turn game on if game is off
                if(!self.game.gameOn && beginGame == 0 ){
                    startGame();
                }
            }else if(playerIdentifier == "1" || playerIdentifier == "2"){
                let xDigits = Int(getSubstring(x: data, start: 1, end: 2))!
                let xVal = Int(getSubstring(x: data, start: 2, end: 2 + xDigits))!
                let yStart = 2 + xDigits;
                let yDigits = Int(getSubstring(x: data, start: yStart, end: yStart+1))!
                let yVal = Int(getSubstring(x: data, start: yStart+1, end: yStart+1+yDigits))!
                
                if(xVal > 800){
                    // Down
                    game.setDirection(playerID: playerIdentifier, direction: 4);
                }else if(xVal<200){
                    // Up
                    game.setDirection(playerID: playerIdentifier, direction: 2);
                }
                if(yVal > 700){
                    // Left
                    game.setDirection(playerID: playerIdentifier, direction: 1);
                }else if(yVal < 300){
                    // Right
                    game.setDirection(playerID: playerIdentifier, direction: 3);
                }
            }
          
            
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
        
    }
    

    
    
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
