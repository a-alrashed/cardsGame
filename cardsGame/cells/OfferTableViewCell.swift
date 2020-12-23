//
//  OfferTableViewCell.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 20/12/2020.
//

import UIKit

enum offerState: String {
    case accepted = "Accepted"
    case rejected = "Rejected"
}

struct Offer {
    let coins: Int
    let sender: Player
    var state: offerState?
}

class OfferTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: DesignableImage!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var offerAmountLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    
    func configure(offer: Offer) {
        profileImage.image = offer.sender.image
        usernameLabel.text = offer.sender.name
        offerAmountLabel.text = String(offer.coins)
        if let offerState = offer.state {
            stateLabel.isHidden = false
            stateLabel.text = offerState.rawValue
            switch offerState {
            case .accepted:
                stateLabel.textColor = UIColor.systemGreen
            case .rejected:
                stateLabel.textColor = UIColor.systemRed
            }
        } else {
            stateLabel.isHidden = true
            stateLabel.text = ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
