// Copyright (c) 2021 Proton Technologies AG
//
// This file is part of ProtonMail.
//
// ProtonMail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ProtonMail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ProtonMail. If not, see https://www.gnu.org/licenses/.

import ProtonCore_Services

enum FeatureFlagKey: String, CaseIterable {
    case threading = "ThreadingIOS"
    case inAppFeedback = "InAppFeedbackIOS"
}

protocol FeatureFlagsSubscribeProtocol: AnyObject {
    func handleNewFeatureFlags(_ featureFlags: [String: Any])
}

protocol FeatureFlagsDownloadServiceProtocol {
    var subscribers: [FeatureFlagsSubscribeProtocol] { get }
    var cachedFeatureFlags: [String: Any] { get }
    var lastFetchingTime: Date? { get }

    typealias FeatureFlagsDownloadCompletion =
        (Result<FeatureFlagsResponse, FeatureFlagsDownloadService.FeatureFlagFetchingError>) -> Void

    func register(newSubscriber: FeatureFlagsSubscribeProtocol)
    func getFeatureFlags(completion: (FeatureFlagsDownloadCompletion)?)
}

/// This class is used to download the feature flags from the BE and send the flags to the subscribed objects.
class FeatureFlagsDownloadService: FeatureFlagsDownloadServiceProtocol {

    private let apiService: APIService
    private let subscribersTable: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    var subscribers: [FeatureFlagsSubscribeProtocol] {
        subscribersTable.allObjects.compactMap { $0 as? FeatureFlagsSubscribeProtocol }
    }
    private(set) var cachedFeatureFlags: [String: Any] = [:]
    private(set) var lastFetchingTime: Date?

    init(apiService: APIService) {
        self.apiService = apiService
    }

    func register(newSubscriber: FeatureFlagsSubscribeProtocol) {
        subscribersTable.add(newSubscriber)
    }

    enum FeatureFlagFetchingError: Error {
        case fetchingTooOften
        case networkError(Error)
    }

    func getFeatureFlags(completion: (FeatureFlagsDownloadCompletion)?) {
        if let time = self.lastFetchingTime,
            Date().timeIntervalSince1970 - time.timeIntervalSince1970 > 300.0 {
            completion?(.failure(.fetchingTooOften))
            return
        }

        let request = FeatureFlagsRequest()
        apiService.exec(route: request) { [unowned self] (task, response: FeatureFlagsResponse) in
            if let error = task?.error {
                completion?(.failure(.networkError(error)))
                return
            }

            self.lastFetchingTime = Date()
            self.cachedFeatureFlags = response.result

            if !response.result.isEmpty {
                self.subscribers.forEach { $0.handleNewFeatureFlags(response.result) }
            }
            completion?(.success(response))
        }
    }

    #if DEBUG
    func setLastFetchedTime(date: Date) {
        self.lastFetchingTime = date
    }
    #endif
}