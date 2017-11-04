//
//  FavoritesTableViewController.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 12/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit
import TBEmptyDataSet

class FavoritesTableViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var favorites = [Affirmation]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetDataSource = self
        
        favorites = Affirmation.favorites
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension FavoritesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell") as? FavoritesTableViewCell {
            cell.affirmation = favorites[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
}

extension FavoritesTableViewController: TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return favorites.isEmpty
    }
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "HeartFull")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let title = NSAttributedString(string: NSLocalizedString("NoFavoritesTitle", comment: ""),
                                       attributes: [.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)])
        
        return title
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let description = NSAttributedString(string: NSLocalizedString("NoFavoritesMessage", comment: ""),
                                             attributes: [.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)])
        
        return description
    }
}
