//
//  TipManager.swift
//  BabyWize
//
//  Created by Noam Efergan on 05/01/2023.
//

import Foundation
import StoreKit

// MARK: - TipsError
public enum TipsError: LocalizedError {
    case failedVerification
    case system(Error)

    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "User transaction verification failed"
        case .system(let err):
            return err.localizedDescription
        }
    }
}

// MARK: - TipsAction
public enum TipsAction: Equatable {
    case successful
    case failed(TipsError)

    public static func == (lhs: TipsAction, rhs: TipsAction) -> Bool {
        switch (lhs, rhs) {
        case (.successful, .successful):
            return true
        case (let .failed(lhsErr), let .failed(rhsErr)):
            return lhsErr.localizedDescription == rhsErr.localizedDescription
        default:
            return false
        }
    }
}

typealias PurchaseResult = Product.PurchaseResult
typealias TransactionListener = Task<Void, Error>

// MARK: - TipManager
@MainActor
public final class TipManager: ObservableObject {
    @Published public var items = [Product]()
    @Published public var action: TipsAction? {
        didSet {
            switch action {
            case .failed:
                hasError = true
            default:
                hasError = false
            }
        }
    }

    @Published public var hasError = false

    public var error: TipsError? {
        switch action {
        case .failed(let err):
            return err
        default:
            return nil
        }
    }

    private var transactionListener: TransactionListener?

    public init() {
        transactionListener = configureTransactionListener()

        Task { [weak self] in
            await self?.retrieveProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    public func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()

            try await handlePurchase(from: result)

        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }

    public func reset() {
        action = nil
    }
}

private extension TipManager {
    func configureTransactionListener() -> TransactionListener {
        Task.detached(priority: .background) { @MainActor [weak self] in

            do {
                for await result in Transaction.updates {
                    let transaction = try self?.checkVerified(result)

                    self?.action = .successful

                    await transaction?.finish()
                }

            } catch {
                self?.action = .failed(.system(error))
                print(error)
            }
        }
    }

    func retrieveProducts() async {
        do {
            let products = try await Product.products(for: myTipProductIdentifiers).sorted(by: { $0.price < $1.price })
            items = products
        } catch {
            action = .failed(.system(error))
            print(error)
        }
    }

    func handlePurchase(from result: PurchaseResult) async throws {
        switch result {
        case .success(let verification):
            print("Purchase was a success, now it's time to verify their purchase")

            let transaction = try checkVerified(verification)

            action = .successful

            await transaction.finish()

        case .pending:
            print("The user needs to complete some action on their account before they can complete purchase")

        case .userCancelled:
            print("The user hit cancel before their transaction started")

        default:
            break
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            print("The verification of the user failed")
            throw TipsError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

