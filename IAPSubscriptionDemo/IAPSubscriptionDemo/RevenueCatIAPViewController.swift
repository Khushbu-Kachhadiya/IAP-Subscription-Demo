//
//  RevenueCatIAPViewController.swift
//  IAPSubscriptionDemo
//
//  Created by Developer1 on 14/03/24.
//

import UIKit
import RevenueCat

class RevenueCatIAPViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Purchases.shared.getOfferings {  Offerings, error in
            if let err = error{
                print(err.localizedDescription)
            }else{
                if let currentOffer = Offerings?.current{
                    let productPackage = currentOffer.availablePackages
                    let purchaseProductPkg = productPackage.first(where: {$0.storeProduct.productIdentifier == "prospect_player_120_1y_non_renewable"})
                    
                    if let storeProduct = purchaseProductPkg?.storeProduct{
                        print("***************************")
                        print("Store product detail =")
                        print("subscriptionPeriod : \(storeProduct.subscriptionPeriod)")
                        print("localizedPriceString : \(storeProduct.localizedPriceString)")
                        print("localizedTitle : \(storeProduct.localizedTitle)")
                        print("price : \(storeProduct.price)")
                        print("productIdentifier : \(storeProduct.productIdentifier)")
                        print("localizedDescription : \(storeProduct.localizedDescription)")
                    }
                }
            }
        }
    }
}
