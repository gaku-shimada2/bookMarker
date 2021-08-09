//
//  BookMark.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/07/31.
//

import RealmSwift

class BookMark: Object {
    // ブックマークURL
    @objc dynamic var bookMarkURL = ""

    // ページタイトル
    @objc dynamic var pageTitle = ""

    // 日時
    @objc dynamic var date = Date()

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "bookMarkURL"
    }
}
