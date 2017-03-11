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
import FirebaseAnalytics

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var affirmationLabel: UILabel!
    @IBOutlet var beforeImage: UIImageView!
    @IBOutlet var afterImage: UIImageView!
    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var button: UIButton!
    @IBOutlet var heart: UIImageView!
    @IBOutlet var reportButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var favorites = [String]()
    var today : String!
    var randomNumber = 0
    
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
        
        if let savedFavorites = UserDefaults.standard.array(forKey: "favoriteAffirmations") {
            favorites = savedFavorites as! [String]
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        today = dateFormatter.string(from: Date())
        let lastAffirmationDate = defaults.string(forKey: "lastAffirmationDate")
        
        if today == lastAffirmationDate {
            getAffirmation(new: false)
        } else {
            getAffirmation(new: true)
        }
        
        let localLang = NSLocale.preferredLanguages[0]
        
        if localLang.firstCharacter! == "t" {
            speech.voice = AVSpeechSynthesisVoice(language: "tr-US")
            speech.rate = 0.48
        } else {
            speech.voice = AVSpeechSynthesisVoice(language: "en-IE")
            speech.rate = 0.39
            
        }
        
        if !defaults.bool(forKey: "didShowInstruction") {
            instructionLabel.isHidden = false
            defaults.set(true, forKey: "didShowInstruction")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startedPressing(_ sender: Any) {
        print("Started pressing")
        
        if !instructionLabel.isHidden {
            instructionLabel.isHidden = true
        }
        
        showAffirmation()
    }
    
    @IBAction func stoppedPressing(_ sender: Any) {
        print("Stopped pressing")
        hideAffirmation()
    }
    
    @IBAction func stoppedPressing2(_ sender: Any) {
        print("Stopped pressing")
        hideAffirmation()
    }

    @IBAction func stoppedPressing3(_ sender: Any) {
        print("Stopped pressing")
        hideAffirmation()
    }
    
    @IBAction func favoritesButtonClicked(_ sender: Any) {
        let favoritesTableVC = storyboard?.instantiateViewController(withIdentifier: "FavoritesTableVC") as! FavoritesTableVC
        favoritesTableVC.modalPresentationStyle = .pageSheet
        
        present(favoritesTableVC, animated: true, completion: nil)
    }

    @IBAction func settingsButtonClicked(_ sender: Any) {
        let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.modalPresentationStyle = .pageSheet
        
        present(settingsVC, animated: true, completion: nil)
    }

    @IBAction func reportAffirmationButtonClicked(_ sender: Any) {
        if let reportVC = storyboard?.instantiateViewController(withIdentifier: "ReportAffirmationVC") as? ReportAffirmationVC {
            reportVC.modalPresentationStyle = .popover
            reportVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width - 32 , height: 290)
            
            let popoverController = reportVC.popoverPresentationController
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverController?.delegate = self
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            reportVC.affirmation = self.affirmationLabel.text!
            reportVC.affirmationNumber = self.randomNumber
            reportVC.mainPage = self
            
            self.present(reportVC, animated: true, completion: nil)
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

        UIView.animate(withDuration: 2, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.beforeImage.alpha = 0
            self.afterImage.alpha = 1.0
            self.affirmationLabel.alpha = 1.0
        }, completion: { _ in
            if self.reportButton.isHidden {
                self.reportButton.isHidden = false
                self.reportButton.shake()
            }
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
        if !favorites.contains(affirmationLabel.text!) {
            favorites.append(affirmationLabel.text!)
            
            UserDefaults.standard.set(favorites, forKey: "favoriteAffirmations")
        }
        
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
    
    func getAffirmation(new: Bool) {
        if new {
            let bannedAffirmationNumbers = (defaults.array(forKey: "bannedAffirmations") as? [Int]) ?? [Int]()
            var seenAffirmationNumbers = (defaults.array(forKey: "seenAffirmations") as? [Int]) ?? [Int]()
            
            // If all affirmations are banned, random number will stay as zero.
            if bannedAffirmationNumbers.count < affirmations.count {
                if seenAffirmationNumbers.count < (affirmations.count - bannedAffirmationNumbers.count) {
                    var continueSearch = true
                    
                    repeat{
                        self.randomNumber = Int.randomBetween(min: 0, max: affirmations.count-1)
                        
                        if (!bannedAffirmationNumbers.contains(randomNumber) && !seenAffirmationNumbers.contains(randomNumber)){continueSearch = false}
                    } while continueSearch
                } else {
                    UserDefaults.standard.removeObject(forKey: "seenAffirmations")
                    
                    getAffirmation(new: true)
                    return
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "bannedAffirmations")
                
                getAffirmation(new: true)
                return
            }
            
            affirmationLabel.text = NSLocalizedString(affirmations[self.randomNumber], comment: "Quote")
            
            speech = AVSpeechUtterance(string: NSLocalizedString(affirmations[self.randomNumber], comment: "Quote"))
            
            seenAffirmationNumbers.append(self.randomNumber)
            
            defaults.set(seenAffirmationNumbers, forKey: "seenAffirmations")
            defaults.set(today, forKey: "lastAffirmationDate")
            defaults.set(affirmations[self.randomNumber], forKey: "lastAffirmation")
        } else {
            if let affirmation = defaults.string(forKey: "lastAffirmation"){
                affirmationLabel.text = NSLocalizedString(affirmation, comment: "QuoteRepeat")
                
                self.randomNumber = affirmations.index(of: affirmation) ?? -1
                
                speech = AVSpeechUtterance(string: NSLocalizedString(affirmation, comment: "QuoteRepeat"))
            }
        }
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
