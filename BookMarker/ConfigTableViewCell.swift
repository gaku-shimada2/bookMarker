//
//  ConfigTableViewCell.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/07.
//

import UIKit

class ConfigTableViewCell: UITableViewCell {

    @IBOutlet weak var bookMarkURLLabel: UILabel!
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBookMarkData(_ BookMarkData: BookMark){
        self.pageTitleLabel.text = BookMarkData.pageTitle
        self.bookMarkURLLabel.text = BookMarkData.bookMarkURL
    }
    
}
