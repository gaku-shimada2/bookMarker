//
//  ImageUrl.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/28.
//

import RealmSwift

class ImageUrl: Object {
    // imageURL
    @objc dynamic var imageURL = ""

    // link
    @objc dynamic var link = ""

    // ブックマークURL をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "imageURL"
    }
}
