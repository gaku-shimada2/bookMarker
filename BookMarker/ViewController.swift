//
//  ViewController.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/30.
//

import UIKit
import RealmSwift
import MBProgressHUD

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var displayArticleList: [DisplayArticleList] = []
    var bookMarkArray = try! Realm().objects(BookMark.self).sorted(byKeyPath: "date", ascending: false)
    var pathString: String!
    var isFirst = true
    let semaphore = DispatchSemaphore(value: 1)
    var reloading = true
    var refreshControl:UIRefreshControl!
    var inputSegueDisplayArticle = DisplayArticleList()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // ナビゲーションバーのタイトル設定
        self.navigationItem.title = "BookMarker"
        
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
        
 
        // 次の画面のBackボタンを「戻る」に変更
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title:  "",
            style:  .plain,
            target: nil,
            action: nil
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "再読み込み中")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    @objc func refresh() {
        bookMarkArray = try! Realm().objects(BookMark.self).sorted(byKeyPath: "date", ascending: false)
        if bookMarkArray.count > 0{
            getArticle()
        } else{
            displayArticleList = []
            self.tableView.reloadData()
        }
        
        semaphore.wait()
        semaphore.signal()
        // データ更新関数が終了したら、リフレッシュの表示も終了する
        refreshControl.endRefreshing()
    }
    
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayArticleList.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 初回表示の場合
        if isFirst && self.bookMarkArray.count > 0{
            isFirst = false
            // HUDの表示
            MBProgressHUD.showAdded(to: view, animated: true)
            getArticle()
            
            // 初回表示以外
        }else {
            self.tableView.reloadData()
        }
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.setItem(self.displayArticleList[indexPath.row],self)
        
        return cell
    }
    
    @objc func handleButton(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        // 後続のprepareでindexPathがnilとなるため、退避
        self.inputSegueDisplayArticle = self.displayArticleList[indexPath!.row]
        tableView(self.tableView,didSelectRowAt: indexPath!)
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // cellSegueの場合、WebView表示する。（画像タップとタイトルエリアタップの２方向から遷移される）
        if  segue.identifier == "cellSegue" {
            let WebViewController:WebViewController = segue.destination as! WebViewController
            let indexpath = self.tableView.indexPathForSelectedRow
            // 画像タップの場合、indexpathがnilになる
            if indexpath == nil{
                WebViewController.displayArticleList = self.inputSegueDisplayArticle
            // タイトルエリアタップ
            } else{
                WebViewController.displayArticleList = self.displayArticleList[indexpath!.row]
            }
        }
    }
        
    func getArticle() {
        // 並列処理用
        let dispatchGroup = DispatchGroup()
        // 表示用記事リスト初期化
        self.displayArticleList = []
        // 非同期処理の場合、Realmが別スレッドを参照できないため、値を退避する
        for bookMark in self.bookMarkArray {
            
            // URL作成処理
            guard let inputURL = URL(string: bookMark.bookMarkURL) else {
               return
            }
            pathString = inputURL.pathComponents[1]
            let urlString = Const.apiURL + Const.amebloURL + pathString + Const.amebloRssPath
            
            // 並列処理 enter()
            dispatchGroup.enter()
            // RSS取得処理
            RssClient.fetchItems(urlString: urlString, completion: { (response) in
                // 並列処理 leave()
                defer { dispatchGroup.leave() }
                
                switch response {
                case .success(let articlelist):
                    DispatchQueue.main.async() { () -> Void in
                        for item in articlelist.items{
                            var displayArticle = DisplayArticleList()
                            displayArticle.pageTitle = bookMark.pageTitle
                            displayArticle.title = item.title
                            displayArticle.link = item.link
                            displayArticle.pubDate = DateUtils.dateFromString(string: item.pubDate, format: "yyyy-MM-dd HH:mm:ss")
                            displayArticle.description = item.description
                            // 並列処理 enter()
                            dispatchGroup.enter()
                            ImageClient.fetchImages(urlString: displayArticle.link, completion: { response in
                                // 並列処理　leave()
                                defer { dispatchGroup.leave() }
                                switch response {
                                case .success(let imageURLList):
                                    displayArticle.imageURL = imageURLList
                                case .failure(let error):
                                    print("画像の取得に失敗しました: reason(\(error))")
                                }
                            })
                            self.displayArticleList.append(displayArticle)
                        }
                    }
                case .failure(let err):
                    print("記事の取得に失敗しました: reason(\(err))")
                }
            })
            
        }
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async() { () -> Void in
                // HUDの非表示
                MBProgressHUD.hide(for: self.view, animated: true)
                self.displayArticleList.sort{$0.pubDate > $1.pubDate}
                self.tableView.reloadData()
            }
            
        }
    
    }
    
}


