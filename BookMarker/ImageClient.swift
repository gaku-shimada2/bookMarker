//
//  ImageClient.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/09.
//

import UIKit
import SwiftSoup
import Combine

/// RSS取得用クラス
class ImageClient {
    /// 記事のイメージリストを取得します。
    /// - Parameter urlString: 取得元RSSのurl
    /// - Parameter completion: 完了時の処理
    static func fetchImages(urlString: String, completion: @escaping (Result<Array<String>,Error>) -> ()) {
        let targetURL: URL = URL(string: urlString)!;
        do {
            // 入力したURLのページから、HTMLのソースを取得する。
            let sourceHTML: String = try String(contentsOf: targetURL, encoding: String.Encoding.utf8);
            let doc: SwiftSoup.Document = try SwiftSoup.parse(sourceHTML)
            // let item: SwiftSoup.Elements = try doc.select("article").select("[data-uranus-component=entryBody]").select("a")
            var imageURLList: [String] = []
            let maxLoop = 2
            print(targetURL.host!)
            
            // アメーバブログのimage取得
            if targetURL.host!.contains("ameblo.jp"){
                let item: SwiftSoup.Elements = try doc.select("article").select("img")
                
                for element: Element in item.array() {
                    let imageURL: String = try! element.attr("src")
                    if imageURL.starts(with: "http") && (imageURL.contains("jpg") || imageURL.contains("png") || imageURL.contains("jpeg")) && !imageURLList.contains(imageURL){
                        imageURLList.append(imageURL)
                    }
                    if imageURLList.count > maxLoop {
                        break
                    }
                    
                }
            // lineblogのimage取得
            } else if targetURL.host!.contains("lineblog.me"){
                let item: SwiftSoup.Elements = try doc.select("article").select("img")
                
                for element: Element in item.array() {
                    let imageURL: String = try! element.attr("src")
                    if imageURL.starts(with: "http") && !imageURLList.contains(imageURL){
                        imageURLList.append(imageURL)
                    }
                    if imageURLList.count > maxLoop {
                        break
                    }
                    
                }
                
            // エキサイトブログのimage取得
            } else if targetURL.host!.contains("exblog"){
                let item: SwiftSoup.Elements = try doc.select("body").select("img")
                
                for element: Element in item.array() {
                    let imageURL: String = try! element.attr("src")
                    if imageURL.starts(with: "http") && (imageURL.contains("jpg") || imageURL.contains("png") || imageURL.contains("jpeg")) && !imageURLList.contains(imageURL){
                        imageURLList.append(imageURL)
                    }
                    if imageURLList.count > (maxLoop + 1) {
                        imageURLList.removeFirst()
                        break
                    }
                    
                }

            // 楽天ブログのimage取得
            } else if targetURL.host!.contains("plaza.rakuten"){
                let item: SwiftSoup.Elements = try doc.select("table").select("img")
                
                for element: Element in item.array() {
                    let imageURL: String = try! element.attr("src")
                    if imageURL.starts(with: "http") && (imageURL.contains("jpg") || imageURL.contains("png") || imageURL.contains("jpeg")) && !imageURLList.contains(imageURL){
                        imageURLList.append(imageURL)
                    }
                    if imageURLList.count > (maxLoop) {
                        imageURLList.removeFirst()
                        break
                    }
                    
                }


            // その他ブログのimege取得
            } else {
                let item: SwiftSoup.Elements = try doc.select("article").select("img")
                
                for element: Element in item.array() {
                    let imageURL: String = try! element.attr("src")
                    if imageURL.starts(with: "http") && (imageURL.contains("jpg") || imageURL.contains("png") || imageURL.contains("jpeg")) && !imageURLList.contains(imageURL){
                        imageURLList.append(imageURL)
                    }
                    if imageURLList.count > maxLoop {
                        break
                    }
                    
                }
                
            }
            

            completion(.success(imageURLList))
                        
        }
        catch {
            // 何かしらのエラーが発生した。
            print("エラーが発生しました。");
            completion(.failure(error))
        }
        
    }
    
    /// 記事のプロフィールイメージを取得します。
    /// - Parameter urlString: 取得元RSSのurl
    /// - Parameter completion: 完了時の処理
    static func fetchProfileImages(urlString: String, completion: @escaping (Result<String,Error>) -> ()) {
        let targetURL: URL = URL(string: urlString)!;
        do {
            // 入力したURLのページから、HTMLのソースを取得する。
            let sourceHTML: String = try String(contentsOf: targetURL, encoding: String.Encoding.utf8);
            let doc: SwiftSoup.Document = try SwiftSoup.parse(sourceHTML)
            let item: SwiftSoup.Elements = try doc.select("[class=user-header__content]").select("[class=user-header__img js--user-header__img]")
            
            var imageURL: String = ""
            for element: Element in item.array() {
                print(element)
                imageURL = try! element.attr("url")
                print(imageURL)
            }
            
            completion(.success(imageURL))
                        
        }
        catch {
            // 何かしらのエラーが発生した。
            print("エラーが発生しました。");
            print(error)
            completion(.failure(error))
        }
        
    }

    
}
