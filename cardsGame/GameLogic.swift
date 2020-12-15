//
//  GameLogic.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 15/12/2020.
//

import UIKit

/*
 
 Top combinations
 A♠️ A♣️ A♥️ A♦️
 K♠️ K♣️ K♥️ K♦️
 Q♠️ Q♣️ Q♥️ Q♦️
 J♠️ J♣️ J♥️ J♦️
 A♠️ A♣️ A♥️
 K♠️ K♣️ K♥️
 Q♠️ Q♣️ Q♥️
 J♠️ J♣️ J♥️
 A♠️ A♣️  K♠️ K♣️
 A♥️ A♦️ K♥️ K♦️
 ...

 
 4 eqlue cards -> plyerPints += 4000
 3 eqlue cards -> plyerPints += 3000
 2&2 eqlue cards -> plyerPints += 2400
 2 eqlue cards -> plyerPints += 2000

 eqlue cards of  type: A -> plyerPints += 400
 eqlue cards of  type: K -> plyerPints += 300
 eqlue cards of  type: Q -> plyerPints += 200
 eqlue cards of  type: J -> plyerPints += 100
 
 other cards of type : A -> plyerPints += 40
 other cards of type : K -> plyerPints += 30
 other cards of type : Q -> plyerPints += 20
 other cards of type : J -> plyerPints += 10
 
 Examples:-
 - 4 eqlue cards of type A -> 4400
 - 4 eqlue cards of type K -> 4300
 - 4 eqlue cards of type Q -> 4200
 - 4 eqlue cards of type J -> 4100
 
 - 3 eqlue cards of type A and 1 of type K  -> 3430
 - 3 eqlue cards of type A and 1 of type Q  -> 3420
 - 3 eqlue cards of type A and 1 of type J  -> 3410
 
 - 3 eqlue cards of type K and 1 of type A  -> 3340
 - 3 eqlue cards of type K and 1 of type Q  -> 3320
 - 3 eqlue cards of type K and 1 of type J  -> 3310

 - 3 eqlue cards of type Q and 1 of type A  -> 3240
 - 3 eqlue cards of type Q and 1 of type K  -> 3230
 - 3 eqlue cards of type Q and 1 of type J  -> 3210
 
 - 3 eqlue cards of type J and 1 of type A  -> 3140
 - 3 eqlue cards of type J and 1 of type K  -> 3130
 - 3 eqlue cards of type J and 1 of type Q  -> 3120
 
 - 2 eqlue cards of type A & 2 eqlue cards of type K -> (2400 + 400 + 300) = 3100
 - 2 eqlue cards of type A & 2 eqlue cards of type Q -> (2400 + 400 + 200) = 3000
 
 - 2 eqlue cards of type A & 2 eqlue cards of type J -> (2400 + 400 + 100) = 2900 ✴️
 - 2 eqlue cards of type K & 2 eqlue cards of type Q -> (2400 + 300 + 200) = 2900 ✴️ ( having 2 of A&J is eqlue to having 2 of K&Q)
 
 - 2 eqlue cards of type K & 2 eqlue cards of type J -> (2400 + 300 + 100) = 2800
 - 2 eqlue cards of type Q & 2 eqlue cards of type J -> (2400 + 200 + 100) = 2700
 
 - 2 eqlue cards of type A & 1 of type K & 1 of type Q -> (2000 + 400 + 30 + 20) = 2450
 - 2 eqlue cards of type A & 1 of type K & 1 of type J -> (2000 + 400 + 30 + 10) = 2440
 
 - 2 eqlue cards of type A & 1 of type Q & 1 of type J -> (2000 + 400 + 20 + 10) = 2430
 - 2 eqlue cards of type K & 1 of type A & 1 of type Q -> (2000 + 300 + 40 + 20) = 2360
 
 - 2 eqlue cards of type Q & 1 of type A & 1 of type K -> (2000 + 200 + 40 + 30) = 2270
 - 2 eqlue cards of type Q & 1 of type A & 1 of type J -> (2000 + 200 + 40 + 10) = 2250
 - 2 eqlue cards of type Q & 1 of type K & 1 of type J -> (2000 + 200 + 30 + 10) = 2240

 - 2 eqlue cards of type J & 1 of type A & 1 of type K -> (2000 + 100 + 40 + 30) = 2170
 - 2 eqlue cards of type J & 1 of type A & 1 of type Q -> (2000 + 100 + 40 + 20) = 2160
 - 2 eqlue cards of type J & 1 of type K & 1 of type Q -> (2000 + 100 + 30 + 20) = 2150
 
 - no eqlue cards AKA having a 🌈 A K Q J -> (40 + 30 + 20 + 10) = 100
 
 enum CardType {
 case ♠️
 case ♣️
 case ♥️
 case ♦️
 }
 
 enum CardName {
 case ace
 case king
 case queen
 case jack
 }
 
 struct Card {
 let type: CardType
 let name: CardName
 let image: UIImage
 let singleValue: Int
 }
 
 struct PlayerCards {
 let eqlueCards: [Card]
 let unEqlueCards: [Card]
 }
 
 
func calculatePlayerPoints(with cards: PlayerCards) -> Int {
 var plyerPints: Int
 switch cards.eqlueCards.count {
 case 4:
    plyerPints += 4000
 case 3:
    plyerPints += 3000
 case 2&2:
    plyerPints += 2500
 case 2:
    plyerPints += 2000
 }
 
 switch cards.eqlueCards[0].type {
 case A:
    plyerPints += 400
 case K:
    plyerPints += 300
 case Q:
    plyerPints += 200
 case J:
    plyerPints += 100
 }
 
 
 for card in cards.uneqlue {
    switch card.type {
     case A:
        plyerPints += 40
     case K:
        plyerPints += 30
     case Q:
        plyerPints += 20
     case J:
        plyerPints += 10
    }
 }
 
 return plyerPints
}
 
 */
