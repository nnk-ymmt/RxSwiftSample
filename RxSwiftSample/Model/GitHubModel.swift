//
//  GitHubModel.swift
//  RxSwiftSample
//
//  Created by 山本ののか on 2020/12/17.
//

import Foundation

struct GitHubModel: Codable {
    let name: String
    private let fullName: String
    var urlStr: String { "https://github.com/\(fullName)" }

    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
    }
}

struct GitHubResponse: Codable {
    let items: [GitHubModel]?
}
