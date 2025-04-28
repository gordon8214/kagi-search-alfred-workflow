//
//  functions.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2023-02-23.
//

import Foundation

/// Request suggestions from the Kagi API using the provided search string.
/// - Parameter searchString: The string to request suggestions for.
func requestSuggestions(for searchString: String) {

    let session = URLSession.shared

    guard
        let encodedString = searchString.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        )
    else {
        logger.error("Failed to URL-encode search string")
        return
    }

    guard
        let suggestURL = URL(
            string: "https://kagi.com/api/autosuggest?q=\(encodedString)"
        )
    else {
        logger.error("Failed to create URL object from suggestions string")
        return
    }

    let httpRequest = session.dataTask(with: suggestURL) {
        data,
        response,
        error in
        // Check for Error.
        if let error = error {
            logger.error("Error took place \(error.localizedDescription)")
            return
        }

        guard response is HTTPURLResponse else {
            logger.error("Error: Invalid response.")
            return
        }

        guard let data else {
            logger.error("No result returned from HTTP request")
            return
        }

        // Parse suggestions.
        let suggestions = parseSuggestions(data: data)

        fileLogger.log("Returning API Results!")
        // Print suggestions to stdout.
        returnResults(
            suggestions: suggestions,
            previousSearchString: searchString,
        )
    }

    // Start the http request.
    httpRequest.resume()
}

/// Parse the Kagi suggestions JSON
/// - Parameter data: Data (as returned form URLSession) containing the JSON.
/// - Returns: Array of suggestion strings.
func parseSuggestions(data: Data) -> [String] {
    do {
        // Make sure this JSON is in the format we expect.
        if let json = try JSONSerialization.jsonObject(with: data, options: [])
            as? [Any]
        {
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

/// Return JSON to Alfred.
/// - Parameter data: Data returned from the HTTP request to the Kagi Search Suggestions API.
func returnResults(
    suggestions: [String],
    previousSearchString: String,
    rerun: Double? = nil
) {

    if rerun != nil {
        fileLogger.log("\n*** Rerun Requested! ***")

    } else {
        fileLogger.log("\n*** NO Rerun Requested! ***")
    }

    var alfredResults = AlfredItems(
        rerun: rerun,
        skipknowledge: true,
        variables: [
            "previousResults": suggestions.joined(separator: "\n"),
            "previousSearchString": previousSearchString,
        ],
    )

    for suggestion in suggestions {
        let item = AlfredItem(
            title: suggestion,
            arg: suggestion,
            autocomplete: nil,
            icon: nil
        )
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
