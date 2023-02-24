//
//  main.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2/23/23.
//

import ArgumentParser
import Foundation

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

        // Required for asynchronous tasks like URLSession.
        // Otherwise main.swift will finish before the completion handler ever executes.
        RunLoop.current.run()
    }
}

KagiSuggestions.main()
