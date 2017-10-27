//
//  SettingsTableViewCell.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 12/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var onOffSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        if !UserDefaults.standard.bool(forKey: "textToSpeechSet") {
            UserDefaults.standard.set(true, forKey: "textToSpeechSet")
        }
        
        UserDefaults.standard.set(!onOffSwitch.isOn, forKey: "textToSpeechDisabled")
    }
}
