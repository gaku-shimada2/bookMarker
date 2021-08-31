//
//  ConfigViewController.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/30.
//

import UIKit
import RealmSwift
import HTMLReader
import MBProgressHUD


class ConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var urlTextField: UITextView!
    @IBOutlet weak var urlTableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let realm = try! Realm()
    
    var bookMark = BookMark()
    var bookMarkArray = try! Realm().objects(BookMark.self).sorted(byKeyPath: "date", ascending: false)
    var items: [Item] = []
    
    
    func textViewDidEndEditing(_ URLTextField: UITextView){
        // 入力チェック（textViewDidEndEditing）
        let text = URLTextField.text
        // 空文字チェック
        if text!.isEmpty {
            errorLabel.text = "httpまたはhttpsから始まるURLを入力してください。"
            URLTextField.layer.borderWidth = 1
            URLTextField.layer.borderColor = UIColor.red.cgColor
            

        }else {
            errorLabel.text = ""
        }
    }
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        // 入力チェック（登録ボタン押下時）
        let text = urlTextField.text
        
        // 空文字チェック
        if text!.isEmpty {
            errorLabel.text = "httpまたはhttpsから始まるURLを入力してください。"
            urlTextField.layer.borderColor = UIColor.red.cgColor
            urlTextField.layer.borderWidth = 1
            // UIAlertControllerの生成
            let alert = UIAlertController(title: "httpまたはhttpsから始まるURLを入力してください。", message: "", preferredStyle: .alert)
            // アクションの生成
            let yesAction = UIAlertAction(title: "OK", style: .default) { action in
                print("tapped yes")
            }
            // アクションの追加
            alert.addAction(yesAction)
            // UIAlertControllerの表示
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        // URL チェック
        if !(text!.starts(with: "http://") || text!.starts(with: "https://")){
            errorLabel.text = "httpまたはhttpsから始まるURLを入力してください。"
            urlTextField.layer.borderColor = UIColor.red.cgColor
            urlTextField.layer.borderWidth = 1
            // UIAlertControllerの生成
            let alert = UIAlertController(title: "httpまたはhttpsから始まるURLを入力してください。", message: "", preferredStyle: .alert)
            // アクションの生成
            let yesAction = UIAlertAction(title: "OK", style: .default) { action in
                print("tapped yes")
            }
            // アクションの追加
            alert.addAction(yesAction)
            // UIAlertControllerの表示
            present(alert, animated: true, completion: nil)
            
            return

        }
        
        // URL作成処理
        let url = URL(string: text!)
        let host = url!.host
        let rssUrl:String!

        if host!.contains("ameblo.jp") {
            let blogId = url!.pathComponents[1]
            rssUrl = Const.amebloURL + blogId + Const.amebloRssPath
        } else if host!.contains("lineblog.me"){
            let blogId = url!.pathComponents[1]
            rssUrl = Const.lineBlogMeURL + blogId + Const.lineBlogMeRssPath
        } else if host!.contains("exblog.jp"){
            rssUrl = Const.exblogURL + host! + Const.exblogRssPath
        } else if host!.contains("plaza.rakuten"){
            let blogId = url!.pathComponents[1]
            rssUrl = Const.rakutenBlogURL + blogId + Const.rakutenBlogRssPath
        } else{
            rssUrl = Const.otherBlogURL + host! + Const.otherBlogRssPath
        }
        
        
        // URL生成処理
        let urlString = Const.apiURL + rssUrl!
        print("DEBUG:" + urlString)
            
        // HUDの表示
        MBProgressHUD.showAdded(to: view, animated: true)
        
        RssClient.fetchItems(urlString: urlString, completion: { (response) in
            switch response {
            case .success(let articlelist):

                DispatchQueue.main.async() { () -> Void in
                    // HUDの非表示
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    // アプリDBに書き込み
                    let insertRealm = try! Realm()
                    // todo エラー制御がない
                    try! insertRealm.write {
                        self.bookMark = BookMark()
                        self.bookMark.bookMarkURL = articlelist.feed.url
                        self.bookMark.date = Date()
                        self.bookMark.pageTitle = articlelist.feed.title
                        insertRealm.add(self.bookMark, update: .modified)
                    }

                    // アプリDBに書き込み
                    for item in articlelist.items{
                        let insertRealmForArticle = try! Realm()
                        // todo エラー制御がない
                        try! insertRealmForArticle.write {
                            let article = Article()
                            article.link = item.link
                            article.bookMarkURL = articlelist.feed.url
                            article.title = item.title
                            article.description1 = item.description
                            article.pubDate = item.pubDate
                            insertRealmForArticle.add(article, update: .modified)
                        }
                        
                       
                        ImageClient.fetchImages(urlString: item.link, completion: { response in
                            switch response{
                            case .success(let imageURLList):
                                for imageURL in imageURLList {
                                    
                                    let insertRealmForimageUrl = try! Realm()
                                    try! insertRealmForimageUrl.write {
                                        let imageUrl = ImageUrl()
                                        imageUrl.imageURL = imageURL
                                        imageUrl.link = item.link
                                        insertRealmForimageUrl.add(imageUrl, update: .modified)
                                    }
                                    
                                }
                                
                            case .failure(let error):
                                print("画像の取得に失敗しました: reason(\(error))")
                            }
                        })
                        
                        
                    }
                  
                    self.urlTableView.reloadData()
                }
            case .failure(let err):
                DispatchQueue.main.async() { () -> Void in
                    print("記事の取得に失敗しました: reason(\(err))")
                    // HUDの非表示
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.errorLabel.text = "記事の取得に失敗しました"
                    self.urlTextField.layer.borderWidth = 1
                    self.urlTextField.layer.borderColor = UIColor.red.cgColor
                }
                
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTableView.delegate = self
        urlTableView.dataSource = self
        urlTextField.delegate = self
        
        errorLabel.text = ""
        errorLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        
        // ナビゲーションバーのタイトル設定
        self.navigationItem.title = "BLOG READER"
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor(red: 30/255.0, green: 161/255.0, blue: 150/255.0, alpha:1),
            // フォント
            NSAttributedString.Key.font: UIFont(name: "ArialRoundedMTBold", size: 25)!
        ]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "ConfigTableViewCell", bundle: nil)
        urlTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookMarkArray = try! Realm().objects(BookMark.self).sorted(byKeyPath: "date", ascending: false)
        
        return bookMarkArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = urlTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConfigTableViewCell
        cell.setBookMarkData(bookMarkArray[indexPath.row])
        return cell
        
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除対象のarticleを取得する
            let articleArray = try! Realm().objects(Article.self).sorted(byKeyPath: "link", ascending: false).filter("bookMarkURL == %@", self.bookMarkArray[indexPath.row].bookMarkURL)
            
            // articleArray分繰り返して、imageUrlテーブルを削除する
            for article in articleArray{
                let imageUrlArray = try! Realm().objects(ImageUrl.self).sorted(byKeyPath: "link", ascending: false).filter("link == %@", article.link)
                try! realm.write {
                    self.realm.delete(imageUrlArray)
                }
            }
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.bookMarkArray[indexPath.row])
                self.realm.delete(articleArray)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } // --- ここまで追加 ---
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    
    
}
