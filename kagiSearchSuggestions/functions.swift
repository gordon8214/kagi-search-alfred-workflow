//
//  functions.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2023-02-23.
//

import Foundation

/// Parse the Kagi suggestions JSON
/// - Parameter data: Data (as returned form URLSession) containing the JSON.
/// - Returns: Array of suggestion strings.
func parseSuggestions(data: Data) -> [String] {
    do {
        // Make sure this JSON is in the format we expect.
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
            // The Kagi JSON is an array with two values:
            // A string containing the original search term,
            // and an array of strings containing the suggestions for that term.
            // To parse, we ignore the search term and cast the search suggestions to [String].
            if var suggestions = json[1] as? [String] {
                if let initialSearchTerm = json[0] as? String {
                    suggestions.insert(initialSearchTerm, at: 0)
                    return suggestions
                }
            }
        }
    } catch let error as NSError {
        logger.error("Failed to load: \(error.localizedDescription)")
    }

    return []
}


func returnResults(data: Data) {
    let suggestionResults = parseSuggestions(data: data)
    var alfredResults = AlfredItems()

    for suggestion in suggestionResults {
        let item = AlfredItem(uid: suggestion, title: suggestion, subtitle: "Search \"\(suggestion)\" on Kagi", arg: suggestion, autocomplete: nil, icon: nil)
        alfredResults.items.append(item)
    }

    let encoder = JSONEncoder()

    do {
        let result = try encoder.encode(alfredResults)
        print(String(data: result, encoding: .utf8) ?? "", terminator: "")
        exit(0)
    } catch {
        logger.error("\(error.localizedDescription)")
        exit(1)
    }
}
