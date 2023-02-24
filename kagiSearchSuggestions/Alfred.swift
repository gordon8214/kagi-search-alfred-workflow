//
//  Alfred.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2023-02-23.
//

import Foundation

struct AlfredIcon: Codable {
    let type: String
    let path: String
}

struct AlfredItem: Codable {
    let uid: String?
    var type: String = "default"
    let title: String
    let subtitle: String?
    let arg: String
    let autocomplete: String?
    let icon: AlfredIcon?
}

struct AlfredItems: Codable {
    var items: [AlfredItem] = []
}
