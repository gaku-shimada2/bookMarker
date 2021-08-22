//
//  TableViewCell.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/31.
//

import UIKit
import SDWebImage


class old_TableViewCell: UITableViewCell, UIScrollViewDelegate  {
    @IBOutlet weak var PageTitleLabel: UILabel!
    @IBOutlet weak var BlogArticleTitleLabel: UILabel!
    @IBOutlet weak var CreatedDateTimeLabel: UILabel!
    @IBOutlet weak var HowManyDateTimeLabel: UILabel!
    @IBOutlet weak var URLImage: UIImageView!
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var scrHeight: NSLayoutConstraint!
    // @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeight: NSLayoutConstraint!
    
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
        // descriptionLabel.text = displayArticleList.description
        let howManyhours = DateUtils.calcHowManyhours(date: displayArticleList.pubDate)
        if howManyhours! > 25 {
            HowManyDateTimeLabel.text = String(DateUtils.calcHowManyDate(date: displayArticleList.pubDate)) + "日前"
        } else{
            HowManyDateTimeLabel.text = String(howManyhours!) + "時間前"
        }
        
        if displayArticleList.imageURL.count >= 1 {
            scrHeight.constant = 480
            scrView.isHidden = false
            
            
            var imageView01: [UIImageView?] = []
            
            for imageURL in displayArticleList.imageURL{
                let imageWork: UIImageView! = UIImageView.init()
                imageWork.sd_setImage(with: URL(string: imageURL))
                imageView01.append(imageWork)
            }
            
            // 全体のサイズ ScrollViewフレームサイズ取得
            let SVSize = scrView.frame.size
            // 画像サイズ x 3　高さ CGSizeMake(240*3, 240)
            scrView.contentSize = CGSize(width: SVSize.width * CGFloat(imageView01.count), height: SVSize.height)
            
            //UIImageViewのサイズと位置を決めます
            //左右に並べる
            var i = 0
            for imageView in imageView01 {
                
                // for i in 0...imageView01.count {
                var x:CGFloat = 0
                let y:CGFloat = 0
                let width:CGFloat = SVSize.width
                let height:CGFloat = SVSize.height
                
                if i == 0 {
                    x = 0
                } else{
                    x = CGFloat(i) * SVSize.width
                }
                imageView01[i]!.frame = CGRect(x: x, y: y, width: width, height: height)
                // Scrollviewに追加
                scrView.addSubview(imageView01[i]!)
                i += 1
            }
            // １ページ単位でスクロールさせる
            scrView.isPagingEnabled = true
            
            //scroll画面の初期位置
            scrView.contentOffset = CGPoint(x: 0, y: 0);
            
            pageControl.numberOfPages = imageView01.count
            pageControlHeight.constant = 28
            
        } else{
            scrHeight.constant = 0
            scrView.isHidden = true
            pageControl.numberOfPages = 0
            pageControlHeight.constant = 0
        }
    }
    
    func scrollViewDidScroll(_ scrView: UIScrollView) {
        pageControl.currentPage = Int(scrView.contentOffset.x / scrView.frame.size.width)
    }
}
