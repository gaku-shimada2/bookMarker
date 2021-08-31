//
//  WebViewController.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/08.
//

import UIKit
import WebKit


class WebViewController: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var displayArticleList: DisplayArticleList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openUrl(urlString: displayArticleList!.link)
        webView.navigationDelegate = self
        // ナビゲーションバーのタイトル設定
        self.navigationItem.title = displayArticleList!.title
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [
            // 文字の色
            .foregroundColor: UIColor(red: 30/255.0, green: 161/255.0, blue: 150/255.0, alpha:1),
            // フォント
            NSAttributedString.Key.font: UIFont(name: "Arial-BoldMT", size: 20)!
        ]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
 
   
        // Do any additional setup after loading the view.
    }
    
    // 文字列で指定されたURLをWeb Viewを開く
    func openUrl(urlString: String) {
        let url = URL(string: urlString)
        let request = NSURLRequest(url: url!)
        webView.load(request as URLRequest)
    }
    
    // Web Veiwが読み込みを開始した時に実行されるメソッド
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        // backButton.isEnabled = false
        // reloadButton.isEnabled = false
        // stopButton.isEnabled = true
    }
    
    // Web Viewが読み込みを終了した時に実行されるメソッド
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
        // canGoBackは戻ることが可能であれば活性化、不可能であれば非活性にする設定
        // backButton.isEnabled = webView.canGoBack
        // reloadButton.isEnabled = true
        // stopButton.isEnabled = false
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
