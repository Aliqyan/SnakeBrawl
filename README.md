# Snake Brawl


An adaptation of the classic game "Snake", "Snake Brawl" is a joystick controlled iOS game in which two snakes fight against each other! 

### Gameplay Instructions
Press the red button to start the game. Use the joysticks to control your snake. Eat some ‘food’ to grow in size, this gives you more health. When you hit the other snake head on, they lose one ‘health’ and become momentarily invulnerable. When a snake is hit at 3 health or runs into itself at any health, it dies.

### Trailer
<img src="https://github.com/Aliqyan/SnakeBrawl/blob/master/Assets/SnakeGif.gif" width="60%" height="60%">

### Arduino and Bluetooth Joysticks
<img src="https://github.com/Aliqyan/SnakeBrawl/blob/master/Assets/Arduino_BLE_Controller.jpg" width="60%" height="60%">

## Description of Files

In this README you will find a brief description of the files contained in our repository along with a reminder of the information we described in our final demo. 

The most important folders would be **'Snake-Tutorial'**, our completed app. Inside of the 'Snake-Tutorial' folder you will find **'GameScene.swift'** and **'GameManager.swift'**, these contain the large majority of the code we wrote for the game. In the folder **'Arduino_Prototype'** under **'JoyStickBLE'**, you will find the code on our arduino.

1. 'Arduino' contains the program that is running on our arduino. The most up to date version can be found under 'JoystickBLE'. The other programs were simply our original tests on writing information via bluetooth.
2. 'Snake-Brawl' is our final Swift app, it contains everything up-to-date.

## The Full Detailing of Our Development Process

**What Is The Project:** Our project is a bluetooth joystick controlled iOS game in which two snakes fight against each other to the death! Press the red button to start the game. Use the joysticks to control your snake. Eat some ‘food’ to grow in size, this gives you more health. When you hit the other snake head on, they lose one ‘health’. When a snake is hit at 3 health, it dies or if it runs into itself at any health, it dies. Be the last snake rattling!

**Changes Since The Prototype:** Our prototype was a simple small app that displayed the orientation of the joystick and whether or not the arduino was connected to the app.  This was used as a proof of concept aka an experimental prototype, that we could connect a joystick to an app and read data.

We scrapped the prototype and moved on to our game. We started off by making a simple snake game with only one snake. The snake was controlled by touch. This was to learn about how to make an app. After making the first iteration of the game, we moved on to adding bluetooth controls to the game. We then were able to control the snake with a joystick.

At this point we had incorporated most of the technologies we wanted to into our game and had them working together well. We added another snake, which was not too difficult as we had already implemented one. Added another joystick, again, we had experience in doing so. With not too much more struggle, we had two snakes that could be controlled separately with two joysticks.

From there we worked on increasing the complexity of our game. Originally we intended on each snake dying after 1 hit, but we found that we were able to implement quite a bit more into our game. We added health from the ‘food’, losing life, temporary invulnerability after being hit, and being able to move ‘through’ the walls.

Lastly, we implemented the great red button which allows for endless replayability without ever needing to actually touch the screen. The vision for our project is something that the kids can play while  on a road trip or even only using one joystick but with a game that has more complicated controls, think games with abilities that are aided by buttons and more fluid movement from a joystick. 

**Challenges We Faced:** Our first challenge was deciding whether we wanted to create our game using Swift or React Native. We each tried using language separately and seeing whether we could connect the arduino to an app and we were first successful in doing so with Swift, so that is what we ended up using. 
Connecting the joysticks to the app was another hurdle. We had to learn about the Core Bluetooth Framework, a framework which allowed us to connect with bluetooth devices in swift. We then needed to figure out how we wanted to send data. In the end this was done by sending character arrays over bluetooth that had markers like ‘x’ and ‘y’  followed by numbers in them to denote things like x-coordinates and y- coordinates in them.

**Aha Moments:** Overall, there weren’t too many big aha moments. Our whole project was made up of of many small ahas that culminated in our end result. Most of our ahas were the things described in how we overcame our various challenges.
