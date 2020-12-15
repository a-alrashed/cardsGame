//
//  GameFieldViewController.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 15/12/2020.
//

import UIKit


enum CardType {
    case spades
    case clubs
    case hearts
    case diamonds
}

enum CardName: Int {
    case ace = 400
    case king = 300
    case queen = 200
    case jack = 100
}

enum CardsCombination: Int {
    case fourCards = 4000
    case threeCards = 3000
    case twoTwo = 2400
    case two = 2000
    case none = 0
}

struct Card {
    let type: CardType
    let name: CardName
    var image: UIImage
}

struct PlayerCards {
    
}

struct Player {
    let name: String
    let image: UIImage
    var isPlaying: Bool
    
    var cards: [Card]
    var eqlueCards = [[Card]]()
    var unEqlueCards = [[Card]]()
    var combination = CardsCombination.none
    
    init(name: String, image: UIImage, cards: [Card], isPlaying: Bool = false) {
        self.name = name
        self.image = image
        self.cards = cards
        self.isPlaying = isPlaying
        //seperat the eqlue and not eqlue cards
        let aceArray = cards.filter { $0.name == .ace}
        let kingArray = cards.filter { $0.name == .king}
        let queenArray = cards.filter { $0.name == .queen}
        let jackArray = cards.filter { $0.name == .jack}
        let cardsArray = [aceArray,kingArray,queenArray,jackArray] // the order of the arrays is critical to ensure that the bigger cards are entered first
        eqlueCards = cardsArray.filter { $0.count > 1}
        unEqlueCards = cardsArray.filter { $0.count == 1}
        
        switch eqlueCards.first?.count {
        case 4:
            combination = .fourCards
        case 3:
            combination = .threeCards
        case 2 where eqlueCards.count == 2:
            combination = .twoTwo
        case 2:
            combination = .two
        default:
            combination = .none
        }
    }
    
    
    func calculatePoints() -> Int {
        var playerPoints = combination.rawValue
        if let cardPints = eqlueCards.first?.first?.name.rawValue {
            playerPoints += cardPints
        }
        
        for card in unEqlueCards {
            playerPoints += (card.first?.name.rawValue)! / 10
        }
        
        return playerPoints
    }
}

class GameFieldViewController: UIViewController {

    @IBOutlet var player1CardsImages: [DesignableImage]!
    @IBOutlet var player2CardsImages: [DesignableImage]!
    @IBOutlet var player3CardsImages: [DesignableImage]!
    @IBOutlet var player4CardsImages: [DesignableImage]!
    
    var gameCards = [
        Card(type: .spades, name: .ace, image: #imageLiteral(resourceName: "ace♠️")),
        Card(type: .spades, name: .king, image: #imageLiteral(resourceName: "king♠️")),
        Card(type: .spades, name: .queen, image: #imageLiteral(resourceName: "queen♠️")),
        Card(type: .spades, name: .jack, image: #imageLiteral(resourceName: "jack♠️")),
        
        Card(type: .clubs, name: .ace, image: #imageLiteral(resourceName: "ace♣️")),
        Card(type: .clubs, name: .king, image: #imageLiteral(resourceName: "king♣️")),
        Card(type: .clubs, name: .queen, image: #imageLiteral(resourceName: "queen♣️")),
        Card(type: .clubs, name: .jack, image: #imageLiteral(resourceName: "jack♣️")),
        
        Card(type: .hearts, name: .ace, image: #imageLiteral(resourceName: "ace♥️")),
        Card(type: .hearts, name: .king, image: #imageLiteral(resourceName: "king♥️")),
        Card(type: .hearts, name: .queen, image: #imageLiteral(resourceName: "queen♥️")),
        Card(type: .hearts, name: .jack, image: #imageLiteral(resourceName: "jack♥️")),
        
        Card(type: .diamonds, name: .ace, image: #imageLiteral(resourceName: "ace♦️")),
        Card(type: .diamonds, name: .king, image: #imageLiteral(resourceName: "king♦️")),
        Card(type: .diamonds, name: .queen, image: #imageLiteral(resourceName: "queen♦️")),
        Card(type: .diamonds, name: .jack, image: #imageLiteral(resourceName: "jack♦️")),
    ]
    
    var player1: Player?
    var player2: Player?
    var player3: Player?
    var player4: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //start the game
        
        gameCards.shuffle()
        let player1Cards = Array(gameCards[0...3])
        let player2Cards = Array(gameCards[4...7])
        let player3Cards = Array(gameCards[8...11])
        let player4Cards = Array(gameCards[12...15])
        player1 = Player(name: "Azzam", image: #imageLiteral(resourceName: "profile-image"), cards: player1Cards, isPlaying: true)
        player2 = Player(name: "Ahmad", image: #imageLiteral(resourceName: "profile-image"), cards: player2Cards)
        player3 = Player(name: "Omar", image: #imageLiteral(resourceName: "profile-image"), cards: player3Cards)
        player4 = Player(name: "Ammar", image: #imageLiteral(resourceName: "profile-image"), cards: player4Cards)
        
        for i in 0...3 {
            player1CardsImages[i].image = (player1?.cards[i].image)!
            player2CardsImages[i].image = (player2?.cards[i].image)!
            player3CardsImages[i].image = (player3?.cards[i].image)!
            player4CardsImages[i].image = (player4?.cards[i].image)!
        }
        
        print(player1!.name, player1!.calculatePoints())
        print(player2!.name, player2!.calculatePoints())
        print(player3!.name, player3!.calculatePoints())
        print(player4!.name, player4!.calculatePoints())
        
        print("the winner is:", calculateWinner())
        
    }

    
    func calculateWinner() -> String {
        let playersPoints = [
            player1!.name: player1!.calculatePoints(),
            player2!.name: player2!.calculatePoints(),
            player3!.name: player3!.calculatePoints(),
            player4!.name: player4!.calculatePoints()
        ]
        return playersPoints.sorted{ return $0.value > $1.value }.first!.key
    }
    

}

