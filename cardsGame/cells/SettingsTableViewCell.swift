//
//  SettingsTableViewCell.swift
//  cardsGame
//
//  Created by Azzam R Alrashed on 21/12/2020.
//

import UIKit

struct Setting {
    let name: String
    let icon: UIImage
}

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: DesignableImage!
    
    func configure(setting: Setting) {
        name.text  = setting.name
        icon.image = setting.icon
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
