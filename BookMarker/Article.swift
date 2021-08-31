//
//  Article.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/28.
//

import RealmSwift

class Article: Object {
    // 記事リンク
    @objc dynamic var link = ""

    // RSSURL
    @objc dynamic var bookMarkURL = ""

    // 記事タイトル
    @objc dynamic var title = ""

    // 説明
    @objc dynamic var description1 = ""

    // 日時
    @objc dynamic var pubDate = ""

    // ブックマークURL をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "link"
    }
}
