//
//  ApplePay+Factory.swift
//  myfatoorah_flutter
//
//  Created by Muhammad Bassiouny on 7/31/23.
//

import Foundation
import Flutter
import UIKit
import MFSDK

class ApplePayFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return ApplePayButton(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class ApplePayButton: NSObject, FlutterPlatformView {
    static var applePayButton = MFApplePayButton()
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        super.init()
        
        guard let receivedData = args as? Dictionary<String, Any>,
              let props = receivedData[MFHelper.applePayStyle] as? String,
              let applePayStyle = try? JSONDecoder().decode(MFApplePayStyle.self, from: Data(props.utf8)) else { return }
        applyViewProps(applePayStyle: applePayStyle)
    }
    
    func view() -> UIView {
        return ApplePayButton.applePayButton
    }
    
    private func applyViewProps(applePayStyle: MFApplePayStyle) {
        let applePayConfigure = MFInApplePayConfigureBuilder.default
        
        if let height = applePayStyle.height {
            applePayConfigure.setHeight(height)
        }
        if let borderRadius = applePayStyle.borderRadius {
            applePayConfigure.setBorderRadius(borderRadius)
        }
        if let buttonText = applePayStyle.buttonText {
            applePayConfigure.setButtonText(buttonText)
        }
        if let hideLoadingIndicator = applePayStyle.hideLoadingIndicator {
            applePayConfigure.hideLoadingIndicator(hideLoadingIndicator)
        }
        
        if let vendorName = applePayStyle.vendorName, !vendorName.isEmpty {
            applePayConfigure.setVendorame(vendorName)
        }
        
        ApplePayButton.applePayButton.configure = applePayConfigure.build()
    }
}
