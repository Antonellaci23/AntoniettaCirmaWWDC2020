
/*:
# Memory game
 
 I chose this Memory Game because it was my favorite when I was a child and it reminds me of the good moments spent with family and friends.
 
 Memory is a cards game to train memory. This game consists of matching the same cards. The game starts with all the cards face down and will be turned two at a time, if the turned cards are the same, the player earns 50 points, for each wrong pair he loses one point and, based on the time spent, the player loses as many points as there are the seconds passed.
 
 In this playground emojis were used as images for the cards.
 
 # Enjoy!
*/
import PlaygroundSupport
import UIKit

let gameView = GameView()
gameView.preferredContentSize = CGSize(width: 600, height: 600)
PlaygroundPage.current.liveView = gameView

//: [Next](@next)
