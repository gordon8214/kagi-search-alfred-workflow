//
//  main.swift
//  kagiSearchSuggestions
//
//  Created by Gordon Byrnes on 2/23/23.
//

import ArgumentParser
import Foundation

struct KagiSuggestions: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kagi-suggestions",
        abstract: "Get Kagi search suggestions (JSON) for your search terms."
    )
    @Argument() var searchString: String

    func run() {

        fileLogger.log("\nStarting Run!")

        let environmentVariables = ProcessInfo.processInfo.environment

        var previousResults: [String] =
            environmentVariables["previousResults"]?.components(
                separatedBy: .newlines
            ) ?? []
        let previousSearchString =
            environmentVariables["previousSearchString"] ?? ""

        // Should only be triggered the very first time the binary is run in a session.
        guard !previousSearchString.isEmpty else {
            fileLogger.log("\nEmpty previous search string. Returning early…")
            returnResults(
                suggestions: [searchString],
                previousSearchString: searchString,
                rerun: 0.1
            )
            return
        }

        // If the user is typing, return early and don't query the Kagi API. Otherwise,
        // input will be lost if the user types faster than the API can return.
        if previousSearchString != searchString {
            fileLogger.log(
                "\nPrevious Search String: \(previousSearchString)\n Current Search String: \(searchString)\nUser typed new characters. Returning early…"
            )

            if previousResults.first != searchString {
                previousResults.insert(searchString, at: 0)
            }

            returnResults(
                suggestions: previousResults,
                previousSearchString: searchString,
                rerun: 0.1
            )
            return
        }

        fileLogger.log(
            "\nPrevious Search String: \(previousSearchString)\n Current Search String: \(searchString)\nCalling Kagi Suggestions API as a result of 'rerun' request…"
        )
        // Make the Kagi API call and print results to stdout.
        requestSuggestions(for: searchString)

        // Required for asynchronous tasks like URLSession.
        // Otherwise main.swift will finish before the completion handler ever executes.
        RunLoop.current.run()
    }
}

KagiSuggestions.main()
