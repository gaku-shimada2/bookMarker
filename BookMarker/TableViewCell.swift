//
//  TableViewCell.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/31.
//

import UIKit
import SDWebImage


class TableViewCell: UITableViewCell, UIScrollViewDelegate  {
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var blogArticleTitleLabel: UILabel!
    @IBOutlet weak var createdDateTimeLabel: UILabel!
    @IBOutlet weak var howManyDateTimeLabel: UILabel!
    @IBOutlet weak var urlImage: UIImageView!
    @IBOutlet weak var scrView: UIScrollView!
    @IBOutlet weak var scrHeight: NSLayoutConstraint!
    // @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageControlHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrView.delegate = self
        
        // Initialization code
    }
            
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setItem(_ displayArticleList: DisplayArticleList,_ viewController: ViewController){
        pageTitleLabel.text = displayArticleList.pageTitle
        blogArticleTitleLabel.text = displayArticleList.title
        createdDateTimeLabel.text = DateUtils.stringFromDate(date: displayArticleList.pubDate, format: "yyyy-MM-dd HH:mm")
        // descriptionLabel.text = displayArticleList.description
        let howManyhours = DateUtils.calcHowManyhours(date: displayArticleList.pubDate)
        if howManyhours! > 25 {
            howManyDateTimeLabel.text = String(DateUtils.calcHowManyDate(date: displayArticleList.pubDate)) + "日前"
        } else{
            howManyDateTimeLabel.text = String(howManyhours!) + "時間前"
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
            pageControl.currentPage = 0
            
            // 画面の幅を取得
            let screenWidth = UIScreen.main.bounds.size.width
            // 再利用されるので、毎回コンテンツサイズは1つの幅にする
            scrView.contentSize = CGSize(width: screenWidth, height: 480)
            // 再利用されるので、毎回スクロールビューはセットしている画像を消しておく
            let subViews = self.scrView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            
            // 画像数カウンタ
            var imageCount = 0
            
            // 画像セット
            for imageURL in displayArticleList.imageURL{
                let imageWork: UIImageView! = UIImageView.init()
                imageWork.clipsToBounds = true
                imageWork.contentMode = .scaleAspectFill
                imageWork.frame = CGRect(x: screenWidth * CGFloat(imageCount), y: 0, width: screenWidth, height: 480)
                imageWork.isUserInteractionEnabled = true
                imageWork.addGestureRecognizer(UITapGestureRecognizer(target: viewController, action: #selector(ViewController.handleButton)))
                self.scrView.addSubview(imageWork)
                // 画像数をカウントアップ
                imageCount += 1
                // スクロールビューのコンテンツサイズの調整
                self.scrView.contentSize = CGSize(width: screenWidth * CGFloat(imageCount) , height: 480)
                // 画像取得
                imageWork.sd_setImage(with: URL(string: imageURL))
            }
        } else{
            scrHeight.constant = 0
            scrView.isHidden = true
            pageControl.numberOfPages = 0
            pageControlHeight.constant = 0
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrView: UIScrollView) {
        pageControl.currentPage = Int(scrView.contentOffset.x / scrView.frame.size.width)
    }

    @objc func tapped() {
           print("tap")
       }

}
