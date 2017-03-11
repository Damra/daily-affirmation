//
//  FavoritesTableViewCell.swift
//  Daily Affirmation
//
//  Created by Efe Helvaci on 12/02/2017.
//  Copyright © 2017 efehelvaci. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var label: UILabel!
    var favorite : Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        if favorite {
            let favorites = UserDefaults.standard.array(forKey: "favoriteAffirmations")
            let newFavorites = favorites?.filter {
                ($0 as! String) != label.text!
            }
            UserDefaults.standard.set(newFavorites, forKey: "favoriteAffirmations")
            
            favoriteButton.setImage(UIImage(named: "HeartEmpty"), for: .normal)
            
            self.favorite = false
        } else {
            var favorites = UserDefaults.standard.array(forKey: "favoriteAffirmations")
            favorites?.append(label.text!)
            UserDefaults.standard.set(favorites, forKey: "favoriteAffirmations")
            
            favoriteButton.setImage(UIImage(named: "HeartFull"), for: .normal)
            
            self.favorite = true
        }
    }

}
