//
//  HomeTableViewCell.swift
//  weather_app_test
//
//  Created by Dilshod Iskandarov on 3/17/22.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet var viewBack: UIView!
    @IBOutlet var img: UIImageView!
    @IBOutlet var maxLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBack.layer.shadowColor = UIColor.green.cgColor
        viewBack.layer.shadowOpacity = 0.5
        viewBack.layer.shadowOffset = .zero
        viewBack.layer.shadowRadius = 10
        viewBack.layer.cornerRadius = 15
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

