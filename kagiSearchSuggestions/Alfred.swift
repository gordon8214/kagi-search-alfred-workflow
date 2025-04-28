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
    var uid: String? = nil
    var type: String = "default"
    let title: String
    var subtitle: String? = nil
    let arg: String
    let autocomplete: String?
    let icon: AlfredIcon?
}

/// [Script Filter JSON Format](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)
struct AlfredItems: Codable {
    /// Scripts can be set to re-run automatically after an interval using the rerun key with a value from `0.1` to `5.0` seconds. The script will only be re-run if the script filter is still active and the user hasn't changed the state of the filter by typing and triggering a re-run.
    var rerun: Double?

    /// Prevent Alfred from sorting results based on previous user behavior.
    var skipknowledge: Bool = false

    var variables: [String: String] = [:]
    var items: [AlfredItem] = []
}
