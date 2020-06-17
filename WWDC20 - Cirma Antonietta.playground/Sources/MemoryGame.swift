import AVFoundation
import UIKit

public struct MemoryGame {
    
    // It must be public, otherwise the user interface cannot display the cards.
    public var cards = [Card]()
    
    private var indexFaceUp: Int? {
        get {
            return cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    public var matches = 0
    public var score = 0
    
    public init(numbersCard: Int) {
        for _ in  1...numbersCard{
            let card = Card()
            cards += [card, card]
        }
        cards.shuffle()
    }
    
    // Core of the game
    public mutating func chooseCard(at index: Int){
        if !cards[index].isMatched {
            if let cardIndex = indexFaceUp, cardIndex != index {
                // check if the cards match
                if cards[cardIndex] == cards[index] {
                    cards[cardIndex].isMatched = true
                    cards[index].isMatched = true
                    matches += 2
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AudioServicesPlaySystemSound (1111)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        AudioServicesPlaySystemSound (1112)
                    }
                }
                cards[index].isFaceUp = true
            } else {
                indexFaceUp = index
            }
        }
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
