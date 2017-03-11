//
//  ReportAffirmationVC.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 08/03/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit
import Firebase
import FTIndicator

class ReportAffirmationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var affirmation = ""
    var affirmationNumber = 0
    var mainPage : ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportOptionCell") as? ReportTableViewCell {
            switch indexPath.row {
            case 0:
                cell.label.text = NSLocalizedString("ReportOption1", comment: "Report Option 1")
                break
            case 1:
                cell.label.text = NSLocalizedString("ReportOption2", comment: "Report Option 2")
                break
            case 2:
                cell.label.text = NSLocalizedString("ReportOption3", comment: "Report Option 3")
                break
            default:
                cell.label.text = ""
                break
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reportName = "affirmation_report"
        
        switch indexPath.row {
        case 0:
            reportName = "\(affirmationNumber)_irrelevant_affirmation_report"
            break
        case 1:
            reportName = "\(affirmationNumber)_harrassing_affirmation_report"
            break
        case 2:
            reportName = "\(affirmationNumber)_noReason_affirmation_report"
            break
        default:
            break
        }
        
        FIRAnalytics.logEvent(withName: reportName, parameters: [
            "affirmation" : affirmation as NSObject,
            ])
        
        var bannedAffirmationNumbers = (UserDefaults.standard.array(forKey: "bannedAffirmations") as? [Int]) ?? [Int]()
        bannedAffirmationNumbers.append(affirmationNumber)
        UserDefaults.standard.set(bannedAffirmationNumbers, forKey: "bannedAffirmations")
        
        mainPage.getAffirmation(new: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true, completion: {
            FTIndicator.showNotification(withTitle: NSLocalizedString("ReportNotificationTitle", comment: "ReportNotificationTitle"),
                                         message: NSLocalizedString("ReportNotificationMessage", comment: "ReportNotificationMessage"))
        })
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
