//
//  GameFieldViewController.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 15/12/2020.
//

import UIKit

enum ContentPage {
    case leaderboard
    case settings
    case offers
}

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

class Player: Hashable {
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    let id: String
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
    var hasTopBet = false
    
    init(id: String,name: String, image: UIImage, direction: Direction, isPlaying: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.isPlaying = isPlaying
        self.direction = direction
    }
    
    func seperateEqlueCards() {
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
        
        for combination in eqlueCards {
            playerPoints += combination.first!.name.rawValue
        }
        
        for card in unEqlueCards {
            playerPoints += (card.first?.name.rawValue)! / 10
        }
        
        return playerPoints
    }
    
    func determinePossibleBets(highestPreviousBet: Int = 100) {
        var possibleBets = [Int]()
        let minimumBet: Int
        if coins <= highestPreviousBet { minimumBet = 100 } else { minimumBet = highestPreviousBet + 100 }
        var bet = coins
        while bet >= minimumBet {
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
    @IBOutlet weak var cancelBetPickerButton: UIButton!
    
    
    @IBAction func cancelBetPickerView(_ sender: Any) {
        betPickerView.isHidden = true
        cancelBetPickerButton.isHidden = true
        actionsStackView.isHidden = false
    }
    
    @IBAction func enterRoundAction(_ sender: Any) {
        //present the bidding picker View
        player1!.determinePossibleBets(highestPreviousBet: highestPreviousBet)
        betPickerView.reloadAllComponents()
        betPickerView.selectRow(0, inComponent: 0, animated: false)
        betPickerView.isHidden = false
        cancelBetPickerButton.isHidden = false
        actionsStackView.isHidden = true
        
    }
    
    @IBAction func withdrawalFromRoundAction(_ sender: Any) {
        actionsStackView.isHidden = true
        withdrawalAnimation(for: player1!)
        print("You have withdrawn from the round")
    }
    
    @IBOutlet weak var offerPickerView: UIPickerView!
    @IBOutlet weak var cancelOffersPickerButton: UIButton!
    
    @IBOutlet weak var sendOfferButton: DesignableButton!
    @IBAction func sendOffer(_ sender: Any) {
        sendOfferButton.isHidden = true
        offerPickerView.selectRow(0, inComponent: 0, animated: false)
        offerPickerView.isHidden = false
        cancelOffersPickerButton.isHidden = false
        //present the offer picker View
    }
    
    @IBAction func cancelOffersPickerView(_ sender: Any) {
        sendOfferButton.isHidden = false
        offerPickerView.isHidden = true
        cancelOffersPickerButton.isHidden = true
    }
    
    
    fileprivate func determineTopBettor() -> Player {
        var players = [player1,player2,player3,player4].sorted { return $0!.currentRoundBet > $1!.currentRoundBet }
        
        players[0]!.hasTopBet = true
        players[1]!.hasTopBet = false
        players[2]!.hasTopBet = false
        players[3]!.hasTopBet = false
        
        return players[0]!
    }
    
    var possibleOffers = [Int]()
    fileprivate func determinePossibleOffers() {
        var possibleOffers = [Int]()
        var offer = determineTopBettor().currentRoundBet
        while offer >= 100 {
            possibleOffers.append(offer)
            offer -= 100
        }
        self.possibleOffers = possibleOffers.reversed()
        offerPickerView.reloadAllComponents()
    }
    
    func calculateRoundWinner(from players: [Player]) {
        var playersPoints = [Player:Int]()
        for player in players {
            player.seperateEqlueCards()
            playersPoints.updateValue(player.calculateRoundPoints(), forKey: player)
            print(player.name, player.calculateRoundPoints())
        }
        
        let theWinner = playersPoints.sorted{ return $0.value > $1.value }.first!.key
        for player in players {
            if player == theWinner {
                player.coins += self.highestPreviousBet
                self.highestPreviousBet = 0
            } else {
                player.coins -= player.currentRoundBet
            }
            player.currentRoundBet = 0
        }
        
        self.leaderboardTableView.reloadData()
    }
    
    
    fileprivate func endTheRound() {
        let players = [
            player1!,
            player2!,
            player3!,
            player4!
        ].filter { $0!.currentRoundBet > 0 }
        
        // if no player entered the round then start the new round immediate
        guard players.count != 0 else {
            self.startTheRound(self)
            return
        }
        
        hideAllCardsAndBetBubbelsAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentAllCardsAnimation(for: players)
            
            
            self.calculateRoundWinner(from: players)
            
            //... after all that allow the next round to begin
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                self.startTheRound(self)
            }
        }
    }
    
    func presentOffersView() {
        presentContentView(with: .offers)
        
        // determine Possible offers
        determinePossibleOffers()
        
        if !player1!.hasTopBet && player1?.currentRoundBet != 0 {
            // if player entered the round but dose not have the top bet
            // then allow hem to send an offer
            sendOfferButton.isHidden = false
        }
        
        aiOffers()
        
        //do some logic to determen the winner
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.endTheRound()
        }
        
        
        
    }
    
    fileprivate func aiOfferDecision(_ player: Player) {
        let aiLuckyNumber = Int.random(in: 0..<possibleOffers.count)
        let randomNumber = Int.random(in: 2...3)
        if aiLuckyNumber % randomNumber == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.offersArray.append(Offer(coins: self.possibleOffers[aiLuckyNumber], sender: player))
                self.offersTableView.reloadData()
            }
        }
    }
    
    fileprivate func aiOffers() {
        let aiPlayers = [player2,player3,player4].filter { $0!.hasTopBet == false && $0!.currentRoundBet != 0 }
        for player in aiPlayers {
            aiOfferDecision(player!)
        }
        
    }
    
    fileprivate func aiPlayerAction(for player: inout Player) {
        player.determinePossibleBets(highestPreviousBet: highestPreviousBet)
        //if there is no possibleBets than let the player withdraw AKA withdrawalAnimation
        guard player.possibleBets.count != 0 else {
            withdrawalAnimation(for: player)
            return
        }
        let aiLuckyNumber = Int.random(in: 0..<player.possibleBets.count)
        let randomNumber = Int.random(in: 2...4)
        if aiLuckyNumber % randomNumber == 0 {
            player.currentRoundBet = player.possibleBets[aiLuckyNumber]
            if highestPreviousBet < player.currentRoundBet { highestPreviousBet = player.currentRoundBet }
            presentBetAnimation(for: player)
        } else {
            withdrawalAnimation(for: player)
        }
    }
    
    fileprivate func nextTurn(from player: Player, newRound: Bool = false) {
        switch player.order {
        case .fourth where newRound == false:
            print("start the negotiations")
            presentOffersView()
        case .first,.second,.third, .fourth:
            print("its the next players turn")
            switch player.direction {
            case .down:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.aiPlayerAction(for: &self.player2!)
                }
            case .right:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.aiPlayerAction(for: &self.player3!)
                }
            case .up:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.aiPlayerAction(for: &self.player4!)
                }
            case .left:
                self.actionsStackView.isHidden = false
            }
        default:
            print("### something is not right with the player order that was passed to nextTurn function")
        }
    }
    
    // 0 = down , 1 = right, 2 = up, 3 = left
    @IBOutlet var betBubbleViews: [UIView]!
    @IBOutlet var betBubbleLabels: [UILabel]!
    @IBOutlet var betBubbleViewsWidthConstraint: [NSLayoutConstraint]!
    
    func presentBetAnimation(for player: Player) {
        let playerIndex = player.direction.rawValue
        betBubbleLabels[playerIndex].text = String(player.currentRoundBet)
        betBubbleViews[playerIndex].isHidden = false
        UIView.animate(withDuration: 1, delay: 0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.betBubbleViews[playerIndex].alpha = 1
            self.betBubbleViewsWidthConstraint[playerIndex].constant = 170
            self.betBubbleLabels[playerIndex].font = self.betBubbleLabels[playerIndex].font.withSize(20)
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.betBubbleViewsWidthConstraint[playerIndex].constant = 100
                self.betBubbleLabels[playerIndex].font = self.betBubbleLabels[playerIndex].font.withSize(15)
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.nextTurn(from: player)
            }
        }
    }
    
    func withdrawalAnimation(for player: Player) {
        player.currentRoundBet = 0
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
        } completion: { _ in
            self.nextTurn(from: player)
        }
    }
    
    
    @IBOutlet var player1CardsImagesBottomConstraint: [NSLayoutConstraint]!
    @IBOutlet var player2CardsImagesTraillingConstraint: [NSLayoutConstraint]!
    @IBOutlet var player3CardsImagesTopConstraint: [NSLayoutConstraint]!
    @IBOutlet var player4CardsImagesLeadingConstraint: [NSLayoutConstraint]!
    
    func hideAllCardsAndBetBubbelsAnimation() {
        
        player1!.presentedCardsCounter = 0
        player2!.presentedCardsCounter = 0
        player3!.presentedCardsCounter = 0
        player4!.presentedCardsCounter = 0
        
        UIView.animate(withDuration: 0.3) {
            self.player1CardsImagesBottomConstraint[0].constant = -240
            self.player1CardsImagesBottomConstraint[1].constant = -240
            self.player1CardsImagesBottomConstraint[2].constant = -240
            self.player1CardsImagesBottomConstraint[3].constant = -240
            
            self.player2CardsImagesTraillingConstraint[0].constant = -120
            self.player2CardsImagesTraillingConstraint[1].constant = -120
            self.player2CardsImagesTraillingConstraint[2].constant = -120
            self.player2CardsImagesTraillingConstraint[3].constant = -120
            
            self.player3CardsImagesTopConstraint[0].constant = -120
            self.player3CardsImagesTopConstraint[1].constant = -120
            self.player3CardsImagesTopConstraint[2].constant = -120
            self.player3CardsImagesTopConstraint[3].constant = -120
            
            self.player4CardsImagesLeadingConstraint[0].constant = -120
            self.player4CardsImagesLeadingConstraint[1].constant = -120
            self.player4CardsImagesLeadingConstraint[2].constant = -120
            self.player4CardsImagesLeadingConstraint[3].constant = -120
            
            self.betBubbleViews[0].alpha = 0
            self.betBubbleViews[1].alpha = 0
            self.betBubbleViews[2].alpha = 0
            self.betBubbleViews[3].alpha = 0

            self.view.layoutIfNeeded()
        } completion: { _ in
            self.betBubbleViews[0].isHidden = true
            self.betBubbleViews[1].isHidden = true
            self.betBubbleViews[2].isHidden = true
            self.betBubbleViews[3].isHidden = true
        }
    }
    
    func presentAllCardsAnimation(for players: [Player]){
        for i in 0...3 {
            self.player1CardsImages[i].image = (self.player1?.cards[i].image)!
            self.player2CardsImages[i].image = (self.player2?.cards[i].image)!
            self.player3CardsImages[i].image = (self.player3?.cards[i].image)!
            self.player4CardsImages[i].image = (self.player4?.cards[i].image)!
        }
        
        for player in players {
            for _ in 0...3 {
                self.presentCardAnimation(player: player)
                player.presentedCardsCounter += 1
            }
        }
    }
    
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
    
    @IBOutlet var centreCardsXConstraint: [NSLayoutConstraint]!
    @IBOutlet var centreCardsYConstraint: [NSLayoutConstraint]!
    
    var numberOfCardsInTheRound = 16
    fileprivate func throwCardAnimation(to order: PlayerOrder?) {
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
                    print("### something is not right with the players order or the value that was passed to the throwCardAnimation function")
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
                print("completed throwing all cards")
                self.numberOfCardsInTheRound = 16
                //this will start the round from the player after the last
                self.nextTurn(from: self.lastPlayerInRound!,newRound: true)
            }
            
            
        }
    }
    
    
    /* be careful when passes this value
    because it's a struct and it will be
     passed by Value not by reference */
    var lastPlayerInRound: Player?
    var roundCounter = 0
    var highestPreviousBet = 0
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
            
            lastPlayerInRound = player4!
        case 1:
            player1!.order = .fourth
            player2!.order = .first
            player3!.order = .second
            player4!.order = .third
            
            lastPlayerInRound = player1!
        case 2:
            player1!.order = .third
            player2!.order = .fourth
            player3!.order = .first
            player4!.order = .second
            
            lastPlayerInRound = player2!
        case 3:
            player1!.order = .second
            player2!.order = .third
            player3!.order = .fourth
            player4!.order = .first
            
            lastPlayerInRound = player3!
        default:
            print("### something is not right with the roundCounter")
        }
        
        hideAllCardsAndBetBubbelsAnimation()
        throwCardAnimation(to: nil)
        
        roundCounter += 1

    }
    
    @IBOutlet weak var startTheRoundButton: UIButton!
    @IBAction func startTheRound(_ sender: Any) {
        //start the game
        //...
        startTheRoundButton.isEnabled = false
        
        //remove the old offers
        offersArray.removeAll()
        offersTableView.reloadData()
        
        shuffleCards()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            offersTableView.register(UINib(nibName: "OfferTableViewCell", bundle: nil), forCellReuseIdentifier: "offerCell")
        
        player1 = Player(id: "A", name: "Azzam", image: #imageLiteral(resourceName: "image6"), direction: .down)
        player2 = Player(id: "B", name: "Ahmad", image: #imageLiteral(resourceName: "image1"), direction: .right)
        player3 = Player(id: "C", name: "Omar", image: #imageLiteral(resourceName: "image5"), direction: .up)
        player4 = Player(id: "D", name: "Ammar", image: #imageLiteral(resourceName: "image2"), direction: .left)
        
        leaderboardArray = [player1!,player2!,player3!,player4!]
        contentViewTopConstraint.constant = view.frame.size.height
        
    }
    
    
    // MARK: home button
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var fingerTrackerView: UIView!
    @IBOutlet var navigationImages: [UIImageView]!
    @IBOutlet weak var homeButtonView: DesignableView!
    
    @IBOutlet weak var navigationViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    
    @IBAction func handleHomeButtonPanGestur(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: navigationView)
        let navigationViewOriginalCenterPoint = navigationView.center
        
        switch sender.state {
        case .began, .changed:
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn) {
                self.fingerTrackerView.alpha = 0.7
                self.navigationViewWidthConstraint.constant = 200
                self.navigationView.cornerRadius = self.navigationViewWidthConstraint.constant / 2
                self.navigationView.center = navigationViewOriginalCenterPoint
                self.view.layoutIfNeeded()
            }
            fingerTrackerView.center = CGPoint(x: fingerTrackerView.center.x + translation.x, y: fingerTrackerView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: navigationView)
        case .ended:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if fingerTrackerView.frame.intersects(navigationImages[0].frame) {
                presentContentView(with: .offers)
            } else if fingerTrackerView.frame.intersects(navigationImages[1].frame) {
                presentContentView(with: .settings)
            } else if fingerTrackerView.frame.intersects(navigationImages[2].frame) {
                presentContentView(with: .leaderboard)
            }
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn) {
                self.fingerTrackerView.alpha = 0
                self.navigationViewWidthConstraint.constant = 10
                self.navigationView.layer.cornerRadius = self.navigationViewWidthConstraint.constant / 2
                self.navigationView.center = navigationViewOriginalCenterPoint
                self.view.layoutIfNeeded()
            }
        default:
            break
        }
    }
    
    @IBAction func didTapHomeButton(_ sender: Any) {
        navigationImages[0].alpha = 0.5
        navigationImages[1].alpha = 0.5
        navigationImages[2].alpha = 0.5
        print("did Tap Home Button")
        // hide the contentView and navigationView
        let navigationViewOriginalCenterPoint = navigationView.center
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        UIView.animate(withDuration: 0.2) {
            self.homeButtonView.alpha = 0.8
            self.fingerTrackerView.alpha = 0
            self.contentViewTopConstraint.constant = self.view.frame.size.height
            self.navigationViewWidthConstraint.constant = 10
            self.navigationView.layer.cornerRadius = self.navigationViewWidthConstraint.constant / 2
            self.navigationView.center = navigationViewOriginalCenterPoint
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.homeButtonView.alpha = 1
            }
        }
        
    }
    
    
    @IBAction func didLongPressHomeButton(_ sender: Any) {
        let navigationViewOriginalCenterPoint = navigationView.center
        UIView.animate(withDuration: 0.2) {
            self.homeButtonView.alpha = 0.8
            self.navigationViewWidthConstraint.constant = 200
            self.navigationView.layer.cornerRadius = self.navigationViewWidthConstraint.constant / 2
            self.navigationView.center = navigationViewOriginalCenterPoint
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.homeButtonView.alpha = 1
            }
        }
    }
    
    
    @IBAction func didTapNavimage(_ sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
        case 0:
            presentContentView(with: .offers)
        case 1:
            presentContentView(with: .settings)
        case 2:
            presentContentView(with: .leaderboard)
        default:
            print("error: didTapNavimage function did not expect the value that was passed to the switch statement")
        }
        let navigationViewOriginalCenterPoint = navigationView.center
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.2) {
            self.fingerTrackerView.alpha = 0
            self.navigationViewWidthConstraint.constant = 10
            self.navigationView.layer.cornerRadius = self.navigationViewWidthConstraint.constant / 2
            self.navigationView.center = navigationViewOriginalCenterPoint
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var offersTableView: UITableView!
    
    var leaderboardArray = [Player]() //Player
    var settingsArray = [Setting]()   //Setting
    var offersArray = [Offer]()   //Offer
    
    func presentContentView(with page: ContentPage) {
        switch page {
        case .offers:
            print("present offers page")
            
            navigationImages[0].alpha = 1
            navigationImages[1].alpha = 0.5
            navigationImages[2].alpha = 0.5
            offersTableView.isHidden = false
            settingsTableView.isHidden = true
            leaderboardTableView.isHidden = true
        case .settings:
            print("present settings page")
            
            navigationImages[0].alpha = 0.5
            navigationImages[1].alpha = 1
            navigationImages[2].alpha = 0.5
            offersTableView.isHidden = true
            settingsTableView.isHidden = false
            leaderboardTableView.isHidden = true
        case .leaderboard:
            print("present leaderboard page")
            
            navigationImages[0].alpha = 0.5
            navigationImages[1].alpha = 0.5
            navigationImages[2].alpha = 1
            offersTableView.isHidden = true
            settingsTableView.isHidden = true
            leaderboardTableView.isHidden = false
        }
        UIView.animate(withDuration: 0.2) {
            self.contentViewTopConstraint.constant = 30
            self.view.layoutIfNeeded()
        }
    }
    

    
    @IBOutlet weak var recordingIndicatorView: DesignableView!
    @IBOutlet weak var recordingIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBAction func recordVoice(_ sender: Any) {
        isRecording.toggle()
        print(isRecording)
        if isRecording { recordingIndicatorAnimation() }
    }
    
    var isRecording = false
    func recordingIndicatorAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.recordingIndicatorViewWidthConstraint.constant = 70
            self.recordingIndicatorView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.recordingIndicatorViewWidthConstraint.constant = 50
            self.recordingIndicatorView.alpha = 1
            self.view.layoutIfNeeded()
            if self.isRecording {
                self.recordingIndicatorAnimation()
            }
        }
    }
    
    
}

extension GameFieldViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case leaderboardTableView:
            return leaderboardArray.count
        case settingsTableView:
            return settingsArray.count
        case offersTableView:
            return offersArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case leaderboardTableView:
            let cell = leaderboardTableView.dequeueReusableCell(withIdentifier: "leaderboardCell") as! LeaderboardTableViewCell
            cell.configure(player: leaderboardArray[indexPath.row])
            return cell
        case settingsTableView:
            let cell = settingsTableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
            cell.configure(setting: settingsArray[indexPath.row])
            return cell
        case offersTableView:
            let cell = offersTableView.dequeueReusableCell(withIdentifier: "offerCell") as! OfferTableViewCell
            cell.configure(offer: offersArray[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == offersTableView && player1!.hasTopBet {
            if offersArray[indexPath.row].state == nil {
                let acceptAction = UIContextualAction(style: .normal, title: "accept") { (action, view, completionHandler) in
                    //make the accepted cell background green
                    self.offersArray[indexPath.row].state = .accepted
                    self.withdrawalAnimation(for: self.offersArray[indexPath.row].sender)
                    // subtract the offer 
                    self.offersTableView.reloadData()
                }
                acceptAction.image = #imageLiteral(resourceName: "accept")
                acceptAction.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                return UISwipeActionsConfiguration(actions: [acceptAction])
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView == offersTableView && player1!.hasTopBet {
            if offersArray[indexPath.row].state == nil {
                let rejectAction = UIContextualAction(style: .normal, title: "reject") { (action, view, completionHandler) in
                    
                    // make the rejected cell background red
                    self.offersArray[indexPath.row].state = .rejected
                    self.offersTableView.reloadData()
                }
                rejectAction.image = #imageLiteral(resourceName: "reject")
                rejectAction.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                return UISwipeActionsConfiguration(actions: [rejectAction])
            }
        }
        return nil
    }
    
}

extension GameFieldViewController: UIPickerViewAccessibilityDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case betPickerView:
            return player1!.possibleBets.count
        case offerPickerView:
            return possibleOffers.count
        default:
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case betPickerView:
            return String(player1!.possibleBets[row])
        case offerPickerView:
            return String(possibleOffers[row])
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case betPickerView:
            //do some animation to hide the picker and play the bet that the user selected
            betPickerView.isHidden = true
            cancelBetPickerButton.isHidden = true
            player1!.currentRoundBet = player1!.possibleBets[row]
            if highestPreviousBet < player1!.currentRoundBet { highestPreviousBet = player1!.currentRoundBet }
            presentBetAnimation(for: player1!)
            print("you entered the round with :",player1!.currentRoundBet)
            
        case offerPickerView:
            offerPickerView.isHidden = true
            cancelOffersPickerButton.isHidden = true
            offersArray.append(Offer(coins: possibleOffers[row], sender: player1!))
            offersTableView.reloadData()
        default:
            break
        }
        
    }
    
    
}

