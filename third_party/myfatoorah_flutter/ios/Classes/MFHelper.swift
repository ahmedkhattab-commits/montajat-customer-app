//
//  MFHelper.swift
//  myfatoorah_flutter
//
//  Created by Muhammad Bassiouny on 7/26/23.
//

import Foundation
import MFSDK

struct MFHelper {
    static let MFEventChannelName = "onEventChannel"
    static let cardViewModule = "MFCardView"
    static let applePayModule = "MFApplePay"
    static let cardViewStyle = "cardViewStyle"
    static let applePayStyle = "applePayStyle"
    
    static let parsingError = ["Error Occurred", "Cannot Parse Data", "Error"]
    
    static func getColor(number: Int) -> UIColor {
        let cgColor = UInt32(number)
        
        let red = CGFloat((cgColor & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((cgColor & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(cgColor & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static func toData(from value: Any?) -> Data {
        let stringData = value as? String ?? ""
        return Data(stringData.utf8)
    }
    
    static func wrapError(_ error: Error) -> [String] {
        if let flutterError = error as? MFFailResponse {
            return [
                flutterError.statusCode,
                flutterError.errorDescription,
                "MF ERROR"
            ]
        }
        return [
            "\(error)",
            "\(error.localizedDescription))",
            "ERROR"
        ]
    }
    
    static func toMFCountry(code: String?) -> MFCountry {
        switch code {
        case "KWT":
            return .kuwait
        case "SAU":
            return .saudiArabia
        case "BHR":
            return .bahrain
        case "ARE":
            return .unitedArabEmirates
        case "QAT":
            return .qatar
        case "OMN":
            return .oman
        case "JOD":
            return .jordan
        case "EGY":
            return .egypt
        default:
            return .kuwait
        }
    }
}

enum ChannelName {
    static let loadConfig = "MF.MFSDKHelper.loadConfig"
    static let setUpActionBar = "MF.MFSDKHelper.setUpActionBar"
    static let initiatePayment = "MF.MFSDKHelper.initiatePayment"
    static let sendPayment = "MF.MFSDKHelper.sendPayment"
    static let getPaymentStatus = "MF.MFSDKHelper.getPaymentStatus"
    static let executePayment = "MF.MFSDKHelper.executePayment"
    static let executeDirectPayment = "MF.MFSDKHelper.executeDirectPayment"
    static let cancelToken = "MF.MFSDKHelper.cancelToken"
    static let cancelRecurringPayment = "MF.MFSDKHelper.cancelRecurringPayment"
    static let initSession = "MF.MFSDKHelper.initSession"
    static let load = "MF.MFSDKHelper.load"
    static let initiateSession = "MF.MFSDKHelper.initiateSession"
    static let pay = "MF.MFSDKHelper.pay"
    static let validate = "MF.MFSDKHelper.validate"
    static let applePayPayment = "MF.MFSDKHelper.applePayPayment"
    static let applePayLoad = "MF.MFSDKHelper.applePayLoad"
    static let displayApplePayButton = "MF.MFSDKHelper.displayApplePayButton"
    static let executeApplePayButton = "MF.MFSDKHelper.executeApplePayButton"
    static let setupApplePay = "MF.MFSDKHelper.setupApplePay"
    static let openPaymentSheet = "MF.MFSDKHelper.openPaymentSheet"
    static let executeApplePayPayment = "MF.MFSDKHelper.executeApplePayPayment"
    static let updateApplePayAmount = "MF.MFSDKHelper.updateApplePayAmount"
    static let executePaymentWithSavedToken =
        "MF.MFSDKHelper.executePaymentWithSavedToken";
}

