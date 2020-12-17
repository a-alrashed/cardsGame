//
//  GameFieldViewController.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 15/12/2020.
//

import UIKit


enum Direction: Int {
    case down = 0
    case right = 1
    case up = 2
    case left = 3
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
    var coins = 5000
    var currentRoundBet = 0
    var isPlaying: Bool
    var direction: Direction
    var order: PlayerOrder?
    var presentedCardsCounter = 0
    var cards = [Card]()
    var eqlueCards = [[Card]]()
    var unEqlueCards = [[Card]]()
    var combination = CardsCombination.none
    var possibleBets = [Int]()
    
    
    init(name: String, image: UIImage, direction: Direction, isPlaying: Bool = false) {
        self.name = name
        self.image = image
        self.isPlaying = isPlaying
        self.direction = direction
    }
    
    mutating func seperateEqlueCards() {
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
    
    func calculateRoundPoints() -> Int {
        var playerPoints = combination.rawValue
        if let cardPints = eqlueCards.first?.first?.name.rawValue {
            playerPoints += cardPints
        }
        
        for card in unEqlueCards {
            playerPoints += (card.first?.name.rawValue)! / 10
        }
        
        return playerPoints
    }
    
    mutating func determinePossibleBets(previousBit: Int = 0) {
        var possibleBets = [Int]()
        var bet = coins
        while bet > previousBit {
            possibleBets.append(bet)
            bet -= 100
        }
        self.possibleBets = possibleBets.reversed()
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
    
    @IBOutlet weak var actionsStackView: UIStackView!

    @IBOutlet weak var betPickerView: UIPickerView!
    @IBOutlet weak var cancelPickerButton: UIButton!
    
    
    @IBAction func didCancelPickerView(_ sender: Any) {
        betPickerView.isHidden = true
        cancelPickerButton.isHidden = true
        actionsStackView.isHidden = false
    }
    
    @IBAction func enterRoundAction(_ sender: Any) {
        //present the bidding picker View
        player1!.determinePossibleBets()
        betPickerView.reloadAllComponents()
        betPickerView.selectRow(0, inComponent: 0, animated: false)
        betPickerView.isHidden = false
        cancelPickerButton.isHidden = false
        actionsStackView.isHidden = true
        
    }
    
    @IBAction func withdrawalFromRoundAction(_ sender: Any) {
        actionsStackView.isHidden = true
        hideCardAnimation(player: player1!)
        player1!.presentedCardsCounter = 0
        print("You have withdrawn from the round")
        
        nextTurn(from: player1!)
    }
    
    @IBOutlet weak var startTheRoundButton: UIButton!
    @IBAction func startTheRound(_ sender: Any) {
        //start the game
        //...
        startTheRoundButton.isEnabled = false
        shuffleCards()
        
        
        player1!.seperateEqlueCards()
        player2!.seperateEqlueCards()
        player3!.seperateEqlueCards()
        player4!.seperateEqlueCards()
        print(player1!.name, player1!.calculateRoundPoints())
        print(player2!.name, player2!.calculateRoundPoints())
        print(player3!.name, player3!.calculateRoundPoints())
        print(player4!.name, player4!.calculateRoundPoints())
        
        print("the winner is:", calculateWinner())
    }
    
    func presentChatView() {
        //do some animation to present the chatView
    }
    
    fileprivate func nextTurn(from player: Player) {
        switch player.order {
        case .fourth:
            print("start the negotiations")
            presentChatView()
        case .first,.second,.third:
            print("its the next players turn")
            
        default:
            print("something is not right with the value that was passed to nextTurn function")
        }
    }
    
    // 0 = down , 1 = right, 2 = up, 3 = left
    @IBOutlet var betBubbleViews: [UIView]!
    @IBOutlet var betBubbleLabels: [UILabel]!
    
    func presentBetAnimation(for player: Player) {
        betBubbleLabels[0].text = "100"
        switch player.direction {
        case .down:
            print("player1 placed a bit")
            UIView.animate(withDuration: 0.3, delay: 0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                
            }
        case .right:
            print("player2 placed a bet")
        case .up:
            print("player3 placed a bet")
        case .left:
            print("player4 placed a bet")
        }
    }
    
    
    @IBOutlet var player1CardsImagesBottomConstraint: [NSLayoutConstraint]!
    @IBOutlet var player2CardsImagesTraillingConstraint: [NSLayoutConstraint]!
    @IBOutlet var player3CardsImagesTopConstraint: [NSLayoutConstraint]!
    @IBOutlet var player4CardsImagesLeadingConstraint: [NSLayoutConstraint]!
    
    func presentCardAnimation(player: Player) {
        guard player.presentedCardsCounter < 4 else { return }
        UIView.animate(withDuration: 0.3) {
            switch player.direction {
            case .down:
                self.player1CardsImagesBottomConstraint[player.presentedCardsCounter].constant = -20
            case .right:
                self.player2CardsImagesTraillingConstraint[player.presentedCardsCounter].constant = -20
            case .up:
                self.player3CardsImagesTopConstraint[player.presentedCardsCounter].constant = -30
            case .left:
                self.player4CardsImagesLeadingConstraint[player.presentedCardsCounter].constant = -20
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func hideCardAnimation(player: Player) {
        guard player.presentedCardsCounter == 4 else { return }
        UIView.animate(withDuration: 0.3) {
            switch player.direction {
            case .down:
                self.player1CardsImagesBottomConstraint[0].constant = -240
                self.player1CardsImagesBottomConstraint[1].constant = -240
                self.player1CardsImagesBottomConstraint[2].constant = -240
                self.player1CardsImagesBottomConstraint[3].constant = -240
            case .right:
                self.player2CardsImagesTraillingConstraint[0].constant = -120
                self.player2CardsImagesTraillingConstraint[1].constant = -120
                self.player2CardsImagesTraillingConstraint[2].constant = -120
                self.player2CardsImagesTraillingConstraint[3].constant = -120
            case .up:
                self.player3CardsImagesTopConstraint[0].constant = -120
                self.player3CardsImagesTopConstraint[1].constant = -120
                self.player3CardsImagesTopConstraint[2].constant = -120
                self.player3CardsImagesTopConstraint[3].constant = -120
            case .left:
                self.player4CardsImagesLeadingConstraint[0].constant = -120
                self.player4CardsImagesLeadingConstraint[1].constant = -120
                self.player4CardsImagesLeadingConstraint[2].constant = -120
                self.player4CardsImagesLeadingConstraint[3].constant = -120
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBOutlet var centreCardsXConstraint: [NSLayoutConstraint]!
    @IBOutlet var centreCardsYConstraint: [NSLayoutConstraint]!
    
    var numberOfCardsInTheRound = 16
    fileprivate func throwCardAnimation(to order: PlayerOrder?) {
        //animation
        
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseOut) {
            if let order = order {
                self.centreCardsImages[0].rotation = 180
                switch order {
                case self.player1!.order:
                    self.centreCardsYConstraint[0].constant = self.view.frame.maxY * 1.3
                    self.presentCardAnimation(player: self.player1!)
                    self.player1!.presentedCardsCounter += 1
                case self.player2!.order:
                    self.centreCardsXConstraint[0].constant = self.view.frame.maxX * 1.5
                    self.presentCardAnimation(player: self.player2!)
                    self.player2!.presentedCardsCounter += 1
                case self.player3!.order:
                    self.centreCardsYConstraint[0].constant = -self.view.frame.maxY * 1.3
                    self.presentCardAnimation(player: self.player3!)
                    self.player3!.presentedCardsCounter += 1
                case self.player4!.order:
                    self.centreCardsXConstraint[0].constant = -self.view.frame.maxX * 1.5
                    self.presentCardAnimation(player: self.player4!)
                    self.player4!.presentedCardsCounter += 1
                default:
                    print("something is not right with the players order or the value that was passed to the throwCardAnimation function")
                }
            }
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.centreCardsImages[0].transform = .identity
            self.centreCardsXConstraint[0].constant = 0
            self.centreCardsYConstraint[0].constant = 0
            self.view.layoutIfNeeded()
            self.numberOfCardsInTheRound -= 1
            switch self.numberOfCardsInTheRound % 4 {
            case 0:
                self.throwCardAnimation(to: .fourth)
            case 1:
                self.throwCardAnimation(to: .third)
            case 2:
                self.throwCardAnimation(to: .second)
            case 3:
                self.throwCardAnimation(to: .first)
            default:
                print(" completed throwing all cards")
                self.numberOfCardsInTheRound = 16
                self.startTheRoundButton.isEnabled = true
                self.actionsStackView.isHidden = false
            }
            
            
        }
    }
    
    var roundCounter = 0
    fileprivate func shuffleCards() {
        
        //cards shuffling
        gameCards.shuffle()
        
        // cards distribution
        player1!.cards = Array(gameCards[0...3])
        player2!.cards = Array(gameCards[4...7])
        player3!.cards = Array(gameCards[8...11])
        player4!.cards = Array(gameCards[12...15])
        
        for i in 0...3 {
            player1CardsImages[i].image = (player1?.cards[i].image)!
            player2CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
            player3CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
            player4CardsImages[i].image = #imageLiteral(resourceName: "back🟥")
        }
        
        switch roundCounter % 4 {
        case 0:
            player1!.order = .first
            player2!.order = .second
            player3!.order = .third
            player4!.order = .fourth
        case 1:
            player1!.order = .fourth
            player2!.order = .first
            player3!.order = .second
            player4!.order = .third
        case 2:
            player1!.order = .third
            player2!.order = .fourth
            player3!.order = .first
            player4!.order = .second
        case 3:
            player1!.order = .second
            player2!.order = .third
            player3!.order = .fourth
            player4!.order = .first
        default:
            print("something is not right with the roundCounter")
        }
        
        roundCounter += 1
        
        
        throwCardAnimation(to: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player1 = Player(name: "Azzam", image: #imageLiteral(resourceName: "profile-image"), direction: .down)
        player2 = Player(name: "Ahmad", image: #imageLiteral(resourceName: "profile-image"), direction: .right)
        player3 = Player(name: "Omar", image: #imageLiteral(resourceName: "profile-image"), direction: .up)
        player4 = Player(name: "Ammar", image: #imageLiteral(resourceName: "profile-image"), direction: .left)
        
    }

    
    func calculateWinner() -> String {
        let playersPoints = [
            player1!.name: player1!.calculateRoundPoints(),
            player2!.name: player2!.calculateRoundPoints(),
            player3!.name: player3!.calculateRoundPoints(),
            player4!.name: player4!.calculateRoundPoints()
        ]
        return playersPoints.sorted{ return $0.value > $1.value }.first!.key
    }
}

extension GameFieldViewController: UIPickerViewAccessibilityDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return player1!.possibleBets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(player1!.possibleBets[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //do some animation to hide the picker and play the bet that the user selected
        betPickerView.isHidden = true
        cancelPickerButton.isHidden = true
        player1!.currentRoundBet = player1!.possibleBets[row]
        presentBetAnimation(for: player1!)
        print("you entered the round with :",player1!.currentRoundBet)
        nextTurn(from: player1!)
    }
    
    
}

