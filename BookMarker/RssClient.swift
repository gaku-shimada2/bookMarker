//
//  RssClient.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/02.
//

import Foundation
import HTMLReader

/// RSS取得用クラス
class RssClient {
    
    /// 記事の一覧を取得します。（非同期モード）
    /// - Parameter urlString: 取得元RSSのurl
    /// - Parameter completion: 完了時の処理
    static func fetchItems(urlString: String, completion: @escaping (Result<ArticleList,Error>) -> ()) {
        
         // URL型に変換できない文字列の場合は弾く
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.unknown))
                return
            }
            
            let decoder = JSONDecoder()
            guard let articleList = try?decoder.decode(ArticleList.self, from: data) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            completion(.success(articleList))
        })
        task.resume()
    }
}

/// ネットワークエラー
enum NetworkError: Error {
    // 不正なURLが指定されました。
    case invalidURL
    // 不正なレスポンスが返されました。
    case invalidResponse
    // 想定外のエラーです。
    case unknown
}
/// アプリケーションエラー
enum AppalicationError: Error {
    // 何かのパースに失敗しました。
    case parseFailed
    // 想定外のエラーです。
    case unknown
}
