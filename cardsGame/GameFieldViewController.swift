//
//  GameFieldViewController.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 15/12/2020.
//

import UIKit


enum Direction {
    case right
    case left
    case up
    case down
}

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

enum PlayerOrder {
    case first
    case second
    case third
    case fourth
}

struct Player {
    let name: String
    let image: UIImage
    var isPlaying: Bool
    let order: PlayerOrder
    var presentedCardsCounter = 0
    
    var cards: [Card]
    var eqlueCards = [[Card]]()
    var unEqlueCards = [[Card]]()
    var combination = CardsCombination.none
    
    init(name: String, image: UIImage, order: PlayerOrder, cards: [Card], isPlaying: Bool = false) {
        self.name = name
        self.image = image
        self.order = order
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
    
    
    
    @IBOutlet var centreCardsImages: [DesignableImage]!
    
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
    
    
    @IBOutlet weak var startTheRoundButton: UIButton!
    @IBAction func startTheRound(_ sender: Any) {
        //start the game
        //...
        startTheRoundButton.isEnabled = false
        shuffleCards()
        
        print(player1!.name, player1!.calculatePoints())
        print(player2!.name, player2!.calculatePoints())
        print(player3!.name, player3!.calculatePoints())
        print(player4!.name, player4!.calculatePoints())
        
        print("the winner is:", calculateWinner())
    }
    
    func presentCardAnimation(player: Player) {
        guard player.presentedCardsCounter < 4 else { return }
        UIView.animate(withDuration: 0.3) {
            switch player.order {
            case .first:
                self.player1CardsImages[player.presentedCardsCounter].center.y -= 200
            case .second:
                self.player2CardsImages[player.presentedCardsCounter].center.x -= 100
            case .third:
                self.player3CardsImages[player.presentedCardsCounter].center.y += 100
            case .fourth:
                self.player4CardsImages[player.presentedCardsCounter].center.x += 100
            }
        }
    }
    
    var numberOfCardsInTheRound = 15
    fileprivate func throwCardAnimation(to direction: Direction?) {
        //animation
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            if let direction = direction {
                self.centreCardsImages[0].rotation = 180
                switch direction {
                case .down:
                    self.centreCardsImages[0].center = CGPoint(x: self.view.frame.midX , y: self.view.frame.maxY * 1.3)
                    self.presentCardAnimation(player: self.player1!)
                    self.player1!.presentedCardsCounter += 1
                case .right:
                    self.centreCardsImages[0].center = CGPoint(x: self.view.frame.maxX * 1.5, y: self.view.frame.midY)
                    self.presentCardAnimation(player: self.player2!)
                    self.player2!.presentedCardsCounter += 1
                case .up:
                    self.centreCardsImages[0].center = CGPoint(x: self.view.frame.midX , y: -self.view.frame.maxY * 1.3)
                    self.presentCardAnimation(player: self.player3!)
                    self.player3!.presentedCardsCounter += 1
                case .left:
                    self.centreCardsImages[0].center = CGPoint(x: -self.view.frame.maxX * 1.5, y: self.view.frame.midY)
                    self.presentCardAnimation(player: self.player4!)
                    self.player4!.presentedCardsCounter += 1
                }
            }
        } completion: { _ in
            self.centreCardsImages[0].transform = .identity
            self.centreCardsImages[0].center = self.view.center
            
            switch self.numberOfCardsInTheRound % 4 {
            case 0:
                self.throwCardAnimation(to: .down)
            case 1:
                self.throwCardAnimation(to: .left)
            case 2:
                self.throwCardAnimation(to: .up)
            case 3:
                self.throwCardAnimation(to: .right)
            default:
                print(" completed throwing all cards")
                self.numberOfCardsInTheRound = 15
                self.startTheRoundButton.isEnabled = true
            }
            self.numberOfCardsInTheRound -= 1
            
        }
    }
    
    fileprivate func throwingCardsAnimation() {
        
        throwCardAnimation(to: nil)
        

    }
    
    fileprivate func shuffleCards() {
        
        //cards shuffling
        gameCards.shuffle()
        
        // cards distribution
        let player1Cards = Array(gameCards[0...3])
        let player2Cards = Array(gameCards[4...7])
        let player3Cards = Array(gameCards[8...11])
        let player4Cards = Array(gameCards[12...15])
        
        player1 = Player(name: "Azzam", image: #imageLiteral(resourceName: "profile-image"), order: .first, cards: player1Cards, isPlaying: true)
        player2 = Player(name: "Ahmad", image: #imageLiteral(resourceName: "profile-image"), order: .second, cards: player2Cards)
        player3 = Player(name: "Omar", image: #imageLiteral(resourceName: "profile-image"), order: .third, cards: player3Cards)
        player4 = Player(name: "Ammar", image: #imageLiteral(resourceName: "profile-image"), order: .fourth, cards: player4Cards)
        
        
        for i in 0...3 {
            player1CardsImages[i].image = (player1?.cards[i].image)!
            player2CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
            player3CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
            player4CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
        }
        
        throwingCardsAnimation()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

