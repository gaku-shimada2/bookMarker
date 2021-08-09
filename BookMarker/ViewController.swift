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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(displayArticleList)
        return self.displayArticleList.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayArticleList = []
        // 非同期処理の場合、Realmが別スレッドを参照できないため、値を退避する
        var bookMarkRooopNum = 0
        let roop = self.bookMarkArray.count - 1
        
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        // HUDの表示
        MBProgressHUD.showAdded(to: view, animated: true)
        
        for bookMark in bookMarkArray {
            
            // URL作成処理
            if let inputURL = URL(string: bookMark.bookMarkURL) {
                pathString = inputURL.pathComponents[1]
            }
            let urlString = Const.apiURL + Const.amebloURL + pathString + Const.amebloRssPath
            
            // RSS取得処理
            RssClient.fetchItems(urlString: urlString, completion: { (response) in
                switch response {
                case .success(let articlelist):
                    DispatchQueue.main.async() { () -> Void in
                        for item in articlelist.items{
                            var displayArticle = DisplayArticleList()
                            displayArticle.pageTitle = bookMark.pageTitle
                            displayArticle.title = item.title
                            displayArticle.link = item.link
                            displayArticle.pubDate = DateUtils.dateFromString(string: item.pubDate, format: "yyyy-MM-dd HH:mm:ss")
                            self.displayArticleList.append(displayArticle)
                        }
                    }
                case .failure(let err):
                    print("記事の取得に失敗しました: reason(\(err))")
                }
                if bookMarkRooopNum == roop{
                    DispatchQueue.main.async() { () -> Void in
                        // HUDの非表示
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.displayArticleList.sort{$0.pubDate > $1.pubDate}
                        self.tableView.reloadData()
                    }
                }
                bookMarkRooopNum += 1
                
            })
            
        }
        
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.setItem(self.displayArticleList[indexPath.row])
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if  segue.identifier == "cellSegue" {
            let WebViewController:WebViewController = segue.destination as! WebViewController
            let indexpath = self.tableView.indexPathForSelectedRow
            WebViewController.displayArticleList = self.displayArticleList[indexpath!.row]
        }
    }
    
    
}

