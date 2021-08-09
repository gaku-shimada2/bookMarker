//
//  TableViewCell.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/31.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var PageTitleLabel: UILabel!
    @IBOutlet weak var BlogArticleTitleLabel: UILabel!
    @IBOutlet weak var CreatedDateTimeLabel: UILabel!
    @IBOutlet weak var HowManyDateTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItem(_ displayArticleList: DisplayArticleList){
        PageTitleLabel.text = displayArticleList.pageTitle
        BlogArticleTitleLabel.text = displayArticleList.title
        CreatedDateTimeLabel.text = DateUtils.stringFromDate(date: displayArticleList.pubDate, format: "yyyy-MM-dd HH:mm")
        let howManyhours = DateUtils.calcHowManyhours(date: displayArticleList.pubDate)
        if howManyhours! > 25 {
            HowManyDateTimeLabel.text = String(DateUtils.calcHowManyDate(date: displayArticleList.pubDate)) + "日前"
        } else{
            HowManyDateTimeLabel.text = String(howManyhours!) + "時間前"
        }
    }
    
}
