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
    
    var speech : AVSpeechUtterance!
    let synthesizer = AVSpeechSynthesizer()
    var speechEnabled : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        button.addGestureRecognizer(tap)
        
        hailTheTraveller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Report button will be shown after affirmation has been seen.
        reportButton.isHidden = true
        
        // Checking default setting for text to speech.
        speechEnabled = !UserDefaults.standard.bool(forKey: "textToSpeechDisabled")
        
        dailyAffirmation = Affirmation.daily()
        
        let localLang = NSLocale.preferredLanguages[0]
        
        if localLang.firstCharacter! == "t" {
            speech.voice = AVSpeechSynthesisVoice(language: "tr-US")
            speech.rate = 0.48
        } else {
            speech.voice = AVSpeechSynthesisVoice(language: "en-IE")
            speech.rate = 0.39
            
        }
        
        if !UserDefaults.standard.bool(forKey: "didShowInstruction") {
            instructionLabel.isHidden = false
            UserDefaults.standard.set(true, forKey: "didShowInstruction")
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
        
        if speechEnabled {
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
        }, completion: { _ in
            if self.reportButton.isHidden {
                self.reportButton.isHidden = false
                self.reportButton.shake()
            }
            
            self.instructionLabel.isHidden = true
        })
    }
    
    func hideAffirmation() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.beforeImage.alpha = 1
            self.afterImage.alpha = 0
            self.affirmationLabel.alpha = 0
        }, completion: nil)
    }
    
    func doubleTapped() {
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
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension MainViewController: ReportAffirmationDelegate {
    func reportAffirmation(withCause cause: String) {
        FIRAnalytics.logEvent(withName: "report", parameters: [ "affirmation" : dailyAffirmation.clause as NSObject,
                                                                "cause" : cause as NSObject,
                                                                "affirmation_id": dailyAffirmation.id as NSObject])
        
        dailyAffirmation.isBanned = true
        
        dailyAffirmation = Affirmation.daily()
        
        FTIndicator.showNotification(withTitle: NSLocalizedString("ReportNotificationTitle", comment: "ReportNotificationTitle"),
                                     message: NSLocalizedString("ReportNotificationMessage", comment: "ReportNotificationMessage"))
    }
}
