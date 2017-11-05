//
//  ViewController.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 05/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit
import SwifterSwift
import FTIndicator
import Async
import AVFoundation
import Firebase
import BulletinBoard

class MainViewController: UIViewController {

    @IBOutlet var affirmationLabel: UILabel!
    @IBOutlet var beforeImage: UIImageView!
    @IBOutlet var afterImage: UIImageView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var reportButton: UIButton!
    
    var dailyAffirmation: Affirmation! {
        didSet {
            affirmationLabel.text = dailyAffirmation.clause

            speech = AVSpeechUtterance(string: dailyAffirmation.clause)
            
            dailyAffirmation.isSeen = true
        }
    }
    
    var speech: AVSpeechUtterance! {
        didSet {
            setSpeechUtterance()
        }
    }
    let synthesizer = AVSpeechSynthesizer()
    var isAffirmationSuccessfullyShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = button.frame.size.width / 2.0
        
        // Double tap for like action
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        button.addGestureRecognizer(tap)
        
        instructionLabel.isHidden = UserDefaults.standard.bool(forKey: "didShowInstruction")
        
        hailTheTraveller()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAffirmation), name: Notification.Name.NSCalendarDayChanged, object: nil)
        
        updateAffirmation()
    }
    
    @objc func updateAffirmation() {
        DispatchQueue.main.async {
            // Report button will be shown after affirmation has been seen.
            self.reportButton.isHidden = true
            
            self.dailyAffirmation = Affirmation.daily()
        }
    }
    
    func setSpeechUtterance() {
        let localLanguage = NSLocale.preferredLanguages[0]
        
        if localLanguage.starts(with: "tr") {
            speech.voice = AVSpeechSynthesisVoice(language: "tr-US")
            speech.rate = 0.45
        } else {
            speech.voice = AVSpeechSynthesisVoice(language: "en-IE")
            speech.rate = 0.39
        }
    }

    @IBAction func startedPressing(_ sender: Any) {
        showAffirmation()
    }
    
    @IBAction func stoppedPressing(_ sender: Any) {
        hideAffirmation()
    }
    
    @IBAction func stoppedPressing2(_ sender: Any) {
        hideAffirmation()
    }

    @IBAction func stoppedPressing3(_ sender: Any) {
        hideAffirmation()
    }
    
    @IBAction func favoritesButtonClicked(_ sender: Any) {
        if let favoritesTableVC = storyboard?.instantiateViewController(withIdentifier: "FavoritesTableVC") as? FavoritesTableViewController {
            favoritesTableVC.modalPresentationStyle = .pageSheet
            
            present(favoritesTableVC, animated: true, completion: nil)
        }
    }

    @IBAction func settingsButtonClicked(_ sender: Any) {
        if let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController {
            settingsVC.modalPresentationStyle = .pageSheet
            
            present(settingsVC, animated: true, completion: nil)
        }
    }

    @IBAction func reportAffirmationButtonClicked(_ sender: Any) {
        if let reportViewController = storyboard?.instantiateViewController(withIdentifier: "ReportAffirmationVC") as? ReportAffirmationViewController {
            reportViewController.modalPresentationStyle = .popover
            reportViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width - 32 , height: 290)
            
            let popoverController = reportViewController.popoverPresentationController
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverController?.delegate = self
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            reportViewController.delegate = self
            
            self.present(reportViewController, animated: true, completion: nil)
        }
    }
    
    func showAffirmation() {
        
        if Options.shared.isTextToSpeechEnabled {
            Async.main(after: 1, {
                if !self.synthesizer.isSpeaking && self.affirmationLabel.alpha != 0 {
                    self.synthesizer.speak(self.speech)
                }
            })
        }

        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
            self.beforeImage.alpha = 0
            self.afterImage.alpha = 1.0
            self.affirmationLabel.alpha = 1.0
            self.instructionLabel.alpha = 0
        }, completion: { (success: Bool) in
            if success && self.affirmationLabel.alpha >= 1.0 {
                if self.reportButton.isHidden {
                    self.reportButton.isHidden = false
                    self.reportButton.shake()
                }
                
                if self.isAffirmationSuccessfullyShown == false {
                    Options.increaseApplicationLaunchCount()
                    
                    self.isAffirmationSuccessfullyShown = true
                    
                    if self.instructionLabel.isHidden == false {
                        self.instructionLabel.isHidden = true
                        UserDefaults.standard.set(true, forKey: "didShowInstruction")
                    }
                }
            }
        })
    }
    
    func hideAffirmation() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.beforeImage.alpha = 1.0
            self.afterImage.alpha = 0
            self.affirmationLabel.alpha = 0
            self.instructionLabel.alpha = 1.0
        }, completion: { (success: Bool) in
            if success && self.isAffirmationSuccessfullyShown {
                self.checkNotification()
            }
        })
    }
    
    @objc func doubleTapped() {
        dailyAffirmation.isFavorite = true
        
        self.heart.alpha = 1.0
        UIView.animate(withDuration: 0.2, animations: {
            self.heart.bounds.size = CGSize(width: 160, height: 160 )
        }, completion: {_ in
            Async.main(after: 0.7, {
                UIView.animate(withDuration: 0.2, animations: {
                    self.heart.bounds.size = CGSize(width: 10, height: 10)
                    self.heart.alpha = 0
                }, completion: nil)
            })
        })
    }
    
    func hailTheTraveller() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        let hailMessage = NSLocalizedString("HailMessage", comment: "hail message")
        
        Async.main{
            if let hour = Int(dateFormatter.string(from: Date())) {
                if hour > 6 && hour < 11 {
                    let hailMorning = NSLocalizedString("HailMorning", comment: "hail morning")
                    FTIndicator.showNotification(with: UIImage(named: "RainbowDay"), title: hailMorning, message: hailMessage)
                } else if hour >= 11 && hour < 18 {
                    let hailAfternoon = NSLocalizedString("HailAfternoon", comment: "hail afternoon")
                    FTIndicator.showNotification(with: UIImage(named: "RainbowDay"), title: hailAfternoon, message: hailMessage)
                } else if hour >= 18 && hour < 23 {
                    let hailEvening = NSLocalizedString("HailEvening", comment: "hail evening")
                    FTIndicator.showNotification(with: UIImage(named: "RainbowNight"), title: hailEvening, message: hailMessage)
                } else {
                    let hailNight = NSLocalizedString("HailNight", comment: "hail night")
                    FTIndicator.showNotification(with: UIImage(named: "RainbowNight"), title: hailNight, message: hailMessage)
                }
            }
        }
    }
    
    func checkNotification() {
        if let notificationStatus = Options.shared.notificationPermissionStatus, notificationStatus == .NotDetermined {
            DispatchQueue.main.async {
                Bulletin.generateNotificationBulletin(shouldAskLikeFirst: true).presentBulletin(above: self)
            }
        }
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension MainViewController: ReportAffirmationDelegate {
    func reportAffirmation(withCause cause: String) {
        Analytics.logEvent("report", parameters: [ "affirmation" : dailyAffirmation.clause,
                                                   "cause" : cause,
                                                   "affirmation_id": dailyAffirmation.id])

        dailyAffirmation.isBanned = true
        
        dailyAffirmation = Affirmation.daily()
        
        FTIndicator.showNotification(withTitle: NSLocalizedString("ReportNotificationTitle", comment: "ReportNotificationTitle"),
                                     message: NSLocalizedString("ReportNotificationMessage", comment: "ReportNotificationMessage"))
    }
}
