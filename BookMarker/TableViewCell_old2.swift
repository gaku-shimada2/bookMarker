//
//  TableViewCell.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/31.
//

import UIKit
import SDWebImage


class TableViewCell: UITableViewCell, UIScrollViewDelegate  {
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
    
   var imageCount = 0
   
    
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
            
            // スクロールビューの初期化
            // 最初の状態をつくる
            scrHeight.constant = 480
            scrView.isHidden = false
            scrView.isPagingEnabled = true
            scrView.contentOffset = CGPoint(x: 0, y: 0);
            pageControl.numberOfPages = displayArticleList.imageURL.count
            pageControlHeight.constant = 28
            
            // 画面の幅を取得
            let screenWidth = UIScreen.main.bounds.size.width
            // 再利用されるので、毎回コンテンツサイズは1つの幅にする
            scrView.contentSize = CGSize(width: screenWidth, height: 480)
            // 再利用されるので、毎回スクロールビューはセットしている画像を消しておく
            let subViews = self.scrView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            
            // セットした画像の数をカウント
            imageCount = 0
            
            // 画像のセット
            for imageURL in displayArticleList.imageURL{
                let imageWork: UIImageView! = UIImageView.init()
                imageWork.clipsToBounds = true
                imageWork.contentMode = .scaleAspectFill
                imageWork.frame = CGRect(x: screenWidth * CGFloat(self.imageCount), y: 0, width: screenWidth, height: 480)
                // 画像取得(非同期処理なので、完了時にスクロールビューを更新する
                imageWork.sd_setImage(with: URL(string: imageURL), completed:{image,b,c,d in
                    print("get image :" + imageURL)
                    // 取得完了時、表示に関わる部分なので念の為メインスレッドで処理
                    DispatchQueue.main.async {
                        imageWork.image = image
                        self.scrView.addSubview(imageWork)
                        // スクロールビューのコンテンツサイズの調整
                        self.scrView.contentSize = CGSize(width: screenWidth * CGFloat(self.imageCount) , height: 480)
                    }
                    // 取得したらカウントアップ
                    self.imageCount += 1
                })
            }
            
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
