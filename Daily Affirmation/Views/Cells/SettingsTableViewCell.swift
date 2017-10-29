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
    
    var action: SettingsAction!
    var settingsItem: SettingsItem! {
        willSet{
            switch newValue! {
            case .Basic(let action, let primaryText, let secondaryText, let icon):
                secondLabel.isHidden = false
                onOffSwitch.isHidden = true
                
                self.action = action
                self.mainLabel.text = primaryText
                self.secondLabel.text = secondaryText
                self.icon.image = icon
                
                break
            case .Switch(let action, let primaryText, let switchInitialStatus, let icon):
                secondLabel.isHidden = true
                onOffSwitch.isHidden = false
                
                self.action = action
                self.mainLabel.text = primaryText
                self.onOffSwitch.isOn = switchInitialStatus
                self.icon.image = icon
                
                break
            }
        }
    }

    @IBAction func switchValueChanged(_ sender: Any) {

        switch action! {
        case .AccessibilityTextToSpeech :
            Options.setTextToSpeech(onOffSwitch.isOn)
            break
        default:
            break
        }
    }
}
