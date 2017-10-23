//
//  ReportAffirmationVC.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 08/03/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit

protocol ReportAffirmationDelegate {
    func reportAffirmation(withCause cause: String)
}

class ReportAffirmationViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var delegate: ReportAffirmationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ReportAffirmationViewController: UITableViewDelegate, UITableViewDataSource {
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
        tableView.deselectRow(at: indexPath, animated: true)
        
        var reportCause = "Not Specified"
        
        switch indexPath.row {
        case 0:
            reportCause = "Irrelevant"
            break
        case 1:
            reportCause = "Harrassing"
            break
        case 2:
            reportCause = "No Reason"
            break
        default:
            break
        }
        
        delegate?.reportAffirmation(withCause: reportCause)
        
        dismiss(animated: true, completion: nil)
    }
}
