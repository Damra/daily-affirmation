//
//  SettingsViewController.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 12/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit
import UserNotifications
import FTIndicator

enum SettingsAction {
    case NotificationPermission
    case NotificationTime
    case AccessibilityTextToSpeech
    case RateUs
}

enum SettingsItem {
    case Basic(action: SettingsAction, primaryText: String, secondaryText: String?, icon: UIImage?)
    case Switch(action: SettingsAction, primaryText: String, switchInitialStatus: Bool, icon: UIImage?)
}

class SettingsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerView: UIView!
    @IBOutlet var datePickerViewHeight: NSLayoutConstraint!
    
    var options = Options.shared
    
    fileprivate var settingsItems: [SettingsItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSettings()
        
        datePicker.date.hour = options.notificationTime.hour
        datePicker.date.minute = options.notificationTime.minute
        
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name.OptionsUpdate , object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setSettings() {
        let notificationPermissionStatus = options.notificationPermissionStatus == .Authorized ? NSLocalizedString("On", comment: "") : NSLocalizedString("Off", comment: "")
        
        let hour = options.notificationTime.hour < 10 ? "0\(options.notificationTime.hour)" : "\(options.notificationTime.hour)"
        let minute = options.notificationTime.minute < 10 ? "0\(options.notificationTime.minute)" : "\(options.notificationTime.minute)"
        
        let notificationTimeStatus = hour + "." + minute
        
        settingsItems = [
            SettingsItem.Basic(action: .NotificationPermission,
                               primaryText: NSLocalizedString("SettingsCell1", comment: ""),
                               secondaryText: notificationPermissionStatus,
                               icon: UIImage(named: "NotificationSettings")),
            
            SettingsItem.Basic(action: .NotificationTime,
                               primaryText: NSLocalizedString("SettingsCell2", comment: ""),
                               secondaryText: notificationTimeStatus,
                               icon: UIImage(named: "TimeSettings")),
            
            SettingsItem.Switch(action: .AccessibilityTextToSpeech,
                                primaryText: NSLocalizedString("TextToSpeech", comment: ""),
                                switchInitialStatus: options.isTextToSpeechEnabled,
                                icon: UIImage(named: "Ear")),
            
            SettingsItem.Basic(action: .RateUs,
                               primaryText: NSLocalizedString("SettingsCell3", comment: ""),
                               secondaryText: nil,
                               icon: UIImage(named: "RateUsSettings"))
        ]
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.OptionsUpdate, object: nil)
    }
    
    @IBAction func setButtonClicked(_ sender: Any) {
        
        let hour = datePicker.date.hour
        let minute = datePicker.date.minute
        
        Options.setNotificationTime(NotificationTime(hour: hour, minute: minute))
        
        update()
        
        self.datePickerViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        FTIndicator.showToastMessage(NSLocalizedString("NotificationSetToast", comment: ""))
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.datePickerViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func update() {
        DispatchQueue.main.async {
            self.options = Options.shared
            self.setSettings()
            
            self.tableView.reloadData()
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as? SettingsTableViewCell {
            var beforeTotal: Int = 0
            for i in 0..<indexPath.section {
                beforeTotal += tableView.numberOfRows(inSection: i)
            }
            
            cell.settingsItem = settingsItems[beforeTotal + indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1, 2:
            return 1
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("SettingsSection2", comment: "")
        case 2:
            return NSLocalizedString("SettingsSection3", comment: "")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell,
           let action = cell.action {
            
            switch action {
            case .AccessibilityTextToSpeech:
                cell.onOffSwitch.setOn(!cell.onOffSwitch.isOn, animated: true)
                cell.onOffSwitch.sendActions(for: .valueChanged)
                
                break
            case .NotificationPermission:
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
                
                break
            case .NotificationTime:
                if self.datePickerViewHeight.constant == 0 {
                    self.datePickerViewHeight.constant = 200
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    })
                } else {
                    self.datePickerViewHeight.constant = 0
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
                
                break
            case .RateUs:
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id1202851636") {
                    UIApplication.shared.openURL(url)
                }
                
                break
            }
        }
    }
}
