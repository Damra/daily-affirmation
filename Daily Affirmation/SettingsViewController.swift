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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var datePickerView: UIView!
    @IBOutlet var datePickerViewHeight: NSLayoutConstraint!
    
    var notificationHour = UserDefaults.standard.integer(forKey: "notificationHour") {
        didSet{
            UserDefaults.standard.set(notificationHour, forKey: "notificationHour")
        }
    }
    var notificationMinute = UserDefaults.standard.integer(forKey: "notificationMinute"){
        didSet{
            UserDefaults.standard.set(notificationMinute, forKey: "notificationMinute")
        }
    }
    var notificationTimeManuallySet = UserDefaults.standard.bool(forKey: "notificationTimeManuallySet")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !notificationTimeManuallySet {
            notificationHour = 7
            notificationMinute = 0
            
            tableView.reloadData()
        }
        
        datePicker.date.hour = notificationHour
        datePicker.date.minute = notificationMinute
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
                
                let cell = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
                cell.secondLabel.text = ""
                cell.secondLabel.alpha = 0.0
                
                self.datePickerViewHeight.constant = 0
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                })
            } else if indexPath.row == 1 {
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
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let url = URL(string: "itms-apps://itunes.apple.com/app/id1202851636")
                UIApplication.shared.openURL(url!)
            }
            
            self.datePickerViewHeight.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as? SettingsTableViewCell {
            
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.mainLabel.text = NSLocalizedString("SettingsCell1", comment: "setCell1")
                    cell.icon.image = UIImage(named: "NotificationSettings")
                    
                    cell.secondLabel.text = ""
                    cell.secondLabel.alpha = 0.0
                    cell.onOffSwitch.isHidden = true
                    
                    if #available(iOS 10, *) {
                        let center = UNUserNotificationCenter.current()

                        center.getNotificationSettings(completionHandler: {settings in
                            if settings.authorizationStatus == .authorized {
                                cell.secondLabel.text = NSLocalizedString("On", comment: "notifOn")
                                cell.secondLabel.alpha = 1.0
                            } else {
                                cell.secondLabel.text = NSLocalizedString("Off", comment: "notifOff")
                                cell.secondLabel.alpha = 1.0
                            }
                        })
                    }
                } else if indexPath.row == 1 {
                    cell.mainLabel.text = NSLocalizedString("SettingsCell2", comment: "setCell2")
                    cell.icon.image = UIImage(named: "TimeSettings")
                    
                    var hour : String
                    var minute : String
                    
                    notificationMinute < 10 ? (minute = "0\(notificationMinute)") : (minute = "\(notificationMinute)")
                    notificationHour < 10 ? (hour = "0\(notificationHour)") : (hour = "\(notificationHour)")
                    
                    cell.secondLabel.text = hour + "." + minute
                    cell.secondLabel.alpha = 1.0
                    cell.onOffSwitch.isHidden = true
                }
            } else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.mainLabel.text = NSLocalizedString("TextToSpeech", comment: "texttospeech")
                    cell.icon.image = UIImage(named: "Ear")
                    cell.secondLabel.text = ""
                    cell.secondLabel.alpha = 0.0
                    cell.onOffSwitch.isHidden = false

                    if UserDefaults.standard.bool(forKey: "textToSpeechSet") {
                        cell.onOffSwitch.isOn = !UserDefaults.standard.bool(forKey: "textToSpeechDisabled")
                    }
                }
            } else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell.mainLabel.text = NSLocalizedString("SettingsCell3", comment: "setCell3")
                    cell.icon.image = UIImage(named: "RateUsSettings")
                    cell.secondLabel.text = ""
                    cell.secondLabel.alpha = 0.0
                    cell.onOffSwitch.isHidden = true
                }
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 2}
        else {return 1}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {return ""}
        else if section == 1 {return NSLocalizedString("SettingsSection2", comment: "setSect2")}
        else {return NSLocalizedString("SettingsSection3", comment: "setSect3")}
    }
    
    @IBAction func setButtonClicked(_ sender: Any) {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        
        let dateString = dateFormatter.string(from: datePicker.date)
        
        cell.secondLabel.text = dateString
        
        dateFormatter.dateFormat = "HH"
        notificationHour = Int(dateFormatter.string(from: datePicker.date))!
        
        dateFormatter.dateFormat = "mm"
        notificationMinute = Int(dateFormatter.string(from: datePicker.date))!
        
        let appDelegate = AppDelegate()
        
        if #available(iOS 10, *) {
            appDelegate.setDailyNotification10(hour: notificationHour, minute: notificationMinute)
        } else {
            appDelegate.setDailyNotifications9(application: UIApplication.shared, hour: notificationHour, minute: notificationMinute)
        }
        
        if !notificationTimeManuallySet {
            notificationTimeManuallySet = true
            UserDefaults.standard.set(true, forKey: "notificationTimeManuallySet")
        }
        
        self.datePickerViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
        FTIndicator.showToastMessage(NSLocalizedString("NotificationSetToast", comment: "notifSetToast"))
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.datePickerViewHeight.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
