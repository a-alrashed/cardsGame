//
//  LeaderboardTableViewCell.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 20/12/2020.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    @IBOutlet weak var crownImage: DesignableImage!
    @IBOutlet weak var profileImage: DesignableImage!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var coinsLeabel: UILabel!
    
    func configure(player: Player) {
        //if the player has the most coins
        crownImage.isHidden = false
        profileImage.image = player.image
        usernameLabel.text  = player.name
        coinsLeabel.text = String(player.coins)
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
