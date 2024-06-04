// Copyright (c) 2024 Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import ProtonCorePayments

struct PurchasePlan {
    typealias Dependencies = AnyObject & HasPurchaseManagerProtocol & HasUpsellTelemetryReporter

    private unowned let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func execute(storeKitProductId: InAppPurchasePlan.ProductId) async -> Output {
        guard let plan = InAppPurchasePlan(storeKitProductId: storeKitProductId) else {
            return .error(PurchasePlanError.productNotFound(storeKitProductId: storeKitProductId))
        }

        await dependencies.upsellTelemetryReporter.upgradeAttempt(storeKitProductId: storeKitProductId)

        let output = await withCheckedContinuation { continuation in
            dependencies.purchaseManager.buyPlan(plan: plan) { purchaseResult in
                if let output = mapPurchaseResultToUseCaseOutput(purchaseResult) {
                    continuation.resume(returning: output)
                }
            }
        }

        switch output {
        case .planPurchased:
            await dependencies.upsellTelemetryReporter.upgradeSuccess(storeKitProductId: storeKitProductId)
        default:
            break
        }

        return output
    }

    private func mapPurchaseResultToUseCaseOutput(_ purchaseResult: PurchaseResult) -> Output? {
        switch purchaseResult {
        case .purchasedPlan:
            return .planPurchased
        case .toppedUpCredits:
            return .cancelled
        case .planPurchaseProcessingInProgress:
            return .error(PurchasePlanError.purchaseAlreadyInProgress)
        case .purchaseError(let error, _):
            return .error(error)
        case .apiMightBeBlocked(_, let originalError, _):
            return .error(originalError)
        case .purchaseCancelled:
            return .cancelled
        case .renewalNotification:
            return nil
        }
    }
}

extension PurchasePlan {
    enum Output {
        case planPurchased
        case error(Error)
        case cancelled
    }
}

enum PurchasePlanError: LocalizedError {
    case productNotFound(storeKitProductId: String)
    case purchaseAlreadyInProgress

    var errorDescription: String? {
        switch self {
        case .productNotFound(let storeKitProductId):
            return String(format: L10n.Upsell.invalidProductID, storeKitProductId)
        case .purchaseAlreadyInProgress:
            return L10n.Upsell.purchaseAlreadyInProgress
        }
    }
}
