//
//  ArticleList.swift
//  BookMarker
//
//  Created by 島田岳 on R 3/08/02.
//

import Foundation

/// RSSから取得する記事リスト
struct ArticleList: Codable {
    let status: String
    let feed: Feed
    let items: [Item]
}
/// フィード
struct Feed: Codable {
    let url: String
    let title: String
    let link: String
    let author: String
    let description: String
}
/// 記事詳細
struct Item: Codable {
    let title: String
    let pubDate: String
    let link: String
    let guid: String
    let description: String
}
