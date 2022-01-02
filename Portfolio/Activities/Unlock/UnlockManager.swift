//
//  UnlockManager.swift
//  Portfolio
//
//  Created by MacBook Pro on 02/01/2022.
//

import Combine
import StoreKit
import SwiftUI

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    /// Current state of purchase
    enum RequestState {
        case loading // Request started but no response yet
        case loaded(SKProduct) // successful response from Apple desribing avaiable products
        case failed(Error?) // something went wrong
        case purchased  // the user successfully purchased or restored purchase
        case deferred // the user can't make the purchase (the transaction has to be approved by guardian)

    }

    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }

    private let dataController: DataController
    /// Responsible for fetching available products from App Store Connect
    private let request: SKProductsRequest
    private var loadedProducts = [SKProduct]()

    /// Returns failse if user has a device with App Store purchasing disabled
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    @Published var requestState = RequestState.loading

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        DispatchQueue.main.async { [self] in
            // loop is used to handle multiple transactions (we only have one here)
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }

                    queue.finishTransaction(transaction)
                case .deferred:
                    self.requestState = .deferred

                default:
                    break
                }
            }
        }
    }

    // Called when our SKProductsRequest finishes successfully
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        // modifies requestState which is a @Published property, so has to be done
        // on a main thread
        DispatchQueue.main.async {
            // Store the returned products for later, if we need them.
            self.loadedProducts = response.products

            guard let unlock = self.loadedProducts.first else {
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Received invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }

            self.requestState = .loaded(unlock)

        }
    }

    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    init(dataController: DataController) {
        // Store the data controller we were sent.
        self.dataController = dataController

        // Prepare to look for our unlock product.
        let productIDs = Set(["iam.mrnoone.Portfolio.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)

        // NSObject init
        super.init()

        // Start watching the payment queue
        SKPaymentQueue.default().add(self)

        // Checking if premium is already unlocked
        guard dataController.fullVersionUnlocked == false else { return }

        // Set objects as delegate to be notified when the product request completes
        request.delegate = self

        // Start the request
        request.start()
    }

    deinit {
        // remove our object from the payment queue observer when our application is being terminated
        SKPaymentQueue.default().remove(self)
    }
}
