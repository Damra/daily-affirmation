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
    
    var affirmation: Affirmation! {
        didSet {
            label.text = affirmation.clause
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        affirmation.isFavorite = !affirmation.isFavorite
        
        let image = affirmation.isFavorite ? UIImage(named: "HeartFull") : UIImage(named: "HeartEmpty")
        favoriteButton.setImage(image, for: .normal)
    }

}
