//
//  ChatMessageTableViewCell.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 20/12/2020.
//

import UIKit

struct Message {
    let text: String
    let sender: Player
}

class ChatMessageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cornerView: DesignableView!
    @IBOutlet weak var bubbleView: DesignableView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: DesignableImage!
    
    @IBOutlet weak var profileImageTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cornerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cornerViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleViewLeadingConstraint: NSLayoutConstraint!
    func configure(message: Message) {
        label.text = message.text
        profileImage.image = message.sender.image
        // if the message is sent by the user then make the message bubble back ground color green and if not then make it blue
        if message.sender.direction == .down {
            usernameLabel.text = ""
            usernameLabel.isHidden = true
            
            cornerView.backgroundColor = #colorLiteral(red: 0, green: 0.3812633753, blue: 0.4686275125, alpha: 1)
            bubbleView.backgroundColor = #colorLiteral(red: 0, green: 0.3812633753, blue: 0.4686275125, alpha: 1)
            
            profileImageLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
            profileImageTrailingConstraint.priority = UILayoutPriority(rawValue: 1000)
            
            cornerViewLeadingConstraint.priority = UILayoutPriority(rawValue: 250)
            cornerViewTrailingConstraint.priority = UILayoutPriority(rawValue: 1000)
            
            bubbleViewLeadingConstraint.constant = 5
            bubbleViewTrailingConstraint.constant = 35
            
        } else {
            usernameLabel.text = message.sender.name
            usernameLabel.isHidden = false
            
            cornerView.backgroundColor = #colorLiteral(red: 0.5702038407, green: 0, blue: 0.3068133593, alpha: 1)
            bubbleView.backgroundColor = #colorLiteral(red: 0.5702038407, green: 0, blue: 0.3068133593, alpha: 1)
            
            profileImageLeadingConstraint.priority = UILayoutPriority(rawValue: 1000)
            profileImageTrailingConstraint.priority = UILayoutPriority(rawValue: 250)
            
            cornerViewLeadingConstraint.priority = UILayoutPriority(rawValue: 1000)
            cornerViewTrailingConstraint.priority = UILayoutPriority(rawValue: 250)
            
            bubbleViewLeadingConstraint.constant = 35
            bubbleViewTrailingConstraint.constant = 5
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
