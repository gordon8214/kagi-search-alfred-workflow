//
//  main.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2/23/23.
//

import ArgumentParser
import Foundation
import Logging

let logger = Logger(label: "com.gordonbyrnes.kagiSearchSuggestions.main")

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

struct KagiSuggestions: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "kagi-suggestions", abstract: "Get Kagi search suggestions (JSON) for your search terms.")
    @Argument() var searchString: String

    func run() {
        let session = URLSession.shared

        guard let encodedString = searchString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            logger.error("Failed to URL-encode search string")
            return
        }

        guard let suggestURL = URL(string: "https://kagi.com/api/autosuggest?q=\(encodedString)") else {
            logger.error("Failed to create URL object from suggestions string")
            return
        }

        let httpRequest = session.dataTask(with: suggestURL) { data, response, error in
            // Check for Error.
            if let error = error {
                logger.error("Error took place \(error.localizedDescription)")
                return
            }

            guard response is HTTPURLResponse else {
                logger.error("Error: Invalid response.")
                return
            }

            guard let data = data else {
                logger.error("No result returned from HTTP request")
                return
            }
            returnResults(data: data)
        }

        httpRequest.resume()
        RunLoop.current.run()
    }
}

KagiSuggestions.main()
