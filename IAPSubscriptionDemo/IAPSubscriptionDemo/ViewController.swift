//
//  ViewController.swift
//  IAPSubscriptionDemo
//
//  Created by Developer1 on 25/08/23.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    var products:[SKProduct] = []
    @IBOutlet weak var lblPurchaseIdentifire: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSKPurchase()
    }
    
    @IBAction func btnpurchase(_ sender: UIButton) {
        if let purchaseProduct = products.filter({$0.productIdentifier == "com.karmascore.knoxweb.premium_plus_month"}).first{
            self.purchaseProduct(purchaseProduct: purchaseProduct)
        }
    }
}

extension ViewController{
    func setupSKPurchase(){
//        prospect_player_229_1y_v2
//        prospect_player_120_1y_non_renewable
        PKIAPHandler.shared.setProductIds(ids: ["com.karmascore.knoxweb.premium_plus_month"])
        PKIAPHandler.shared.fetchAvailableProducts { products in
            self.products = products
            if let purchaseProduct = products.filter({$0.productIdentifier == "com.karmascore.knoxweb.premium_plus_month"}).first{
//                DispatchQueue.main.async {
//                    print("Product Identifire = \(purchaseProduct.productIdentifier)")
//                    print("Product price = \(purchaseProduct.price)")
//                    self.lblPurchaseIdentifire.text = "\(purchaseProduct.productIdentifier) \n\(purchaseProduct.price ?? 0.0) for this year"
//                }
                
                DispatchQueue.main.async {
                    print("***************** Product and Intro offer details *******************")
                    print("Product Identifire = \(purchaseProduct.productIdentifier)")
                    print("Product price = \(purchaseProduct.price)")
                    print("Introductory offer price = \(purchaseProduct.introductoryPrice?.price ?? 0.0)")
                    print("Introductory Subscription Periods = \(purchaseProduct.introductoryPrice?.subscriptionPeriod.numberOfUnits ?? 0)")
                    print("Introductory Subscription Periods = \(String(describing: purchaseProduct.introductoryPrice?.priceLocale))")
                    _ = self.getIntroductoryOfferType(product: purchaseProduct)
                    print("************************************")

                    print("***************** Product and Promo offer details *******************")
                    print("Product Identifire = \(purchaseProduct.productIdentifier)")
                    print("Product price = \(purchaseProduct.price)")
                    print("Promo offer Identifire = \(purchaseProduct.discounts.map({$0.identifier}))")
                    print("Promo offer price = \(purchaseProduct.discounts.map({$0.price}))")
                    _ = self.getIntroductoryOfferType(product: purchaseProduct)
                    print("************************************")


                    self.lblPurchaseIdentifire.text = "\(purchaseProduct.productIdentifier) \n\(purchaseProduct.price)/per month"
                }
            }
        }
    }
    
    //    func eligibleForIntro(product: SKProduct) async throws -> Bool {
    //        guard let renewableSubscription = product.introductoryPrice else {
    //            // No renewable subscription is available for this product.
    //            return false
    //        }
    //        if await renewableSubscription. {
    //            // The product is eligible for an introductory offer.
    //            return true
    //        }
    //        return false
    //    }
    
    func purchaseProduct(purchaseProduct:SKProduct){
        PKIAPHandler.shared.purchase(product: purchaseProduct) { (alert, product, transaction) in
            if let tran = transaction, let prod = product {
                print(tran)
                print(prod)
                //use transaction details and purchased product as you want
            }else{
                print(alert)
            }
        }
    }
    
    func getIntroductoryOfferType(product: SKProduct) -> SKProductDiscount.PaymentMode? {
        if let introductoryOffer = product.introductoryPrice {
            let introductoryOfferPaymentMode = introductoryOffer.paymentMode
            switch introductoryOfferPaymentMode {
            case .payAsYouGo:
                debugPrint("Introductory offer type = getIntroductoryOfferType is pay as you go.")
                return .payAsYouGo
            case .payUpFront:
                debugPrint("Introductory offer type = getIntroductoryOfferType is pay up front.")
                return .payUpFront
            case .freeTrial:
                debugPrint("Introductory offer type = getIntroductoryOfferType is a free trial.")
                return .freeTrial
            default:
                fatalError("ERROR: YOU HAVE NOT CONSIDERED ALL INTRODUCTORY PAYMENT MODE TYPES.")
            }
        } else {
            debugPrint("Introductory offer type = getIntroductoryOfferType there is no introductory offer.")
            return nil
        }
    }
}




enum PKIAPHandlerAlertType {
    case setProductIds
    case disabled
    case restored
    case purchased
    
    var message: String{
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


class PKIAPHandler: NSObject {
    
    //MARK:- Shared Object
    //MARK:-
    static let shared = PKIAPHandler()
    private override init() { }
    
    //MARK:- Properties
    //MARK:- Private
    fileprivate var productIds = [String]()
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var fetchProductComplition: (([SKProduct])->Void)?
    
    fileprivate var productToPurchase: SKProduct?
    fileprivate var purchaseProductComplition: ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)?
    
    //MARK:- Public
    var isLogEnabled: Bool = true
    
    //MARK:- Methods
    //MARK:- Public
    
    //Set Product Ids
    func setProductIds(ids: [String]) {
        self.productIds = ids
    }
    
    //MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchase(product: SKProduct, complition: @escaping ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)) {
        
        self.purchaseProductComplition = complition
        self.productToPurchase = product
        
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            log("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        }
        else {
            complition(PKIAPHandlerAlertType.disabled, nil, nil)
        }
    }
    
    // RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(complition: @escaping (([SKProduct])->Void)){
        
        self.fetchProductComplition = complition
        // Put here your IAP Products ID's
        if self.productIds.isEmpty {
            log(PKIAPHandlerAlertType.setProductIds.message)
            fatalError(PKIAPHandlerAlertType.setProductIds.message)
        }
        else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    //MARK:- Private
    fileprivate func log <T> (_ object: T) {
        if isLogEnabled {
            NSLog("\(object)")
        }
    }
}

//MARK:- Product Request Delegate and Payment Transaction Methods
//MARK:-
extension PKIAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        
        if (response.products.count > 0) {
            if let complition = self.fetchProductComplition {
                complition(response.products)
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let complition = self.purchaseProductComplition {
            complition(PKIAPHandlerAlertType.restored, nil, nil)
        }
    }
    
    // IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    log("Product purchase done")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    if let complition = self.purchaseProductComplition {
                        complition(PKIAPHandlerAlertType.purchased, self.productToPurchase, trans)
                    }
                    break
                    
                case .failed:
                    log("Product purchase failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    log("Product restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
}

