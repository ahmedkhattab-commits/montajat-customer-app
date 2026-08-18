//
//  CardViewFactory.swift
//  myfatoorah_flutter
//
//  Created by Muhammad Bassiouny on 7/31/23.
//

import Foundation
import Flutter
import UIKit
import MFSDK

class CardViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return CardView(
            frame: frame,
            viewId: viewId,
            args: args,
            messenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}


class CardView: NSObject, FlutterPlatformView {
    static var cardView = MFPaymentCardView()
    
    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        super.init()
        guard let receivedData = args as? Dictionary<String, Any>,
              let props = receivedData[MFHelper.cardViewStyle] as? String,
              let cardViewStyle = try? JSONDecoder().decode(MFCardViewStyle.self, from: Data(props.utf8)) else { return }
        applyViewProps(cardViewStyle: cardViewStyle)
    }
    
    func view() -> UIView {
        return CardView.cardView
    }
    
    private func applyViewProps(cardViewStyle: MFCardViewStyle) {
        let configure = MFCardConfigureBuilder.default
        
        if let height = cardViewStyle.cardHeight {
            configure.setCardHeight(height)
        }
        let nameLabel = cardViewStyle.label?.text?.holderName ?? ""
        let cardNumberLabel = cardViewStyle.label?.text?.cardNumber ?? ""
        let expiryDateLabel = cardViewStyle.label?.text?.expiryDate ?? ""
        let cvvLabel = cardViewStyle.label?.text?.securityCode ?? ""
        let showLabels = cardViewStyle.label?.display ?? true
        let fontWeight = cardViewStyle.label?.fontWeight ?? .normal
        configure.setLabel(MFCardLabel(cardHolderNameLabel: nameLabel, cardNumberLabel: cardNumberLabel, expiryDateLabel: expiryDateLabel, cvvLabel: cvvLabel, showLabels: showLabels, fontWeight: fontWeight))
        
        let cardHolderNamePlaceholder = cardViewStyle.input?.placeHolder?.holderName ?? ""
        let cardNumberPlaceholder = cardViewStyle.input?.placeHolder?.cardNumber ?? ""
        let expiryDatePlaceholder = cardViewStyle.input?.placeHolder?.expiryDate ?? ""
        let cvvPlaceholder = cardViewStyle.input?.placeHolder?.securityCode ?? ""
        configure.setPlaceholder(MFCardPlaceholder(cardHolderNamePlaceholder: cardHolderNamePlaceholder, cardNumberPlaceholder: cardNumberPlaceholder, expiryDatePlaceholder: expiryDatePlaceholder, cvvPlaceholder: cvvPlaceholder))
        
        if let setHideCardIcon = cardViewStyle.hideCardIcons{
            configure.setHideCardIcon(setHideCardIcon)
        }
        
        var inputColor: UIColor = .black
        var labelColor: UIColor = .black
        var errorColor: UIColor = .red
        var borderColor: UIColor = .black
        var backgroundColor: UIColor = .white

        
        if let inputColorNumber = cardViewStyle.input?.color {
            inputColor = MFHelper.getColor(number: inputColorNumber)
        }
        if let labelColorNumber = cardViewStyle.label?.color {
            labelColor = MFHelper.getColor(number: labelColorNumber)
        }
        if let errorColorNumber = cardViewStyle.error?.borderColor {
            errorColor = MFHelper.getColor(number: errorColorNumber)
        }
        if let borderColorNumber = cardViewStyle.input?.borderColor {
            borderColor = MFHelper.getColor(number: borderColorNumber)
        }
        if let backgroundColorNumber = cardViewStyle.backgroundColor {
            backgroundColor = MFHelper.getColor(number: backgroundColorNumber)
        }
        
        let theme = MFCardTheme(inputColor: inputColor, labelColor: labelColor, errorColor: errorColor, borderColor: borderColor)
        
        if let direction = cardViewStyle.direction,
           direction.lowercased() == "rtl" {
            theme.language = .arabic
        }
        
        configure.setTheme(theme)
        
        let inputHeight = cardViewStyle.input?.inputHeight ?? 32
        let inputMargin = cardViewStyle.input?.inputMargin ?? 0
        configure.setCardInput(MFCardInput(inputHeight: inputHeight, inputMargin: inputMargin))
        
        let hOffset = cardViewStyle.input?.boxShadow?.hOffset ?? 0
        let vOffset = cardViewStyle.input?.boxShadow?.vOffset ?? 0
        let blur = cardViewStyle.input?.boxShadow?.blur ?? 0
        let spread = cardViewStyle.input?.boxShadow?.spread ?? 0
        var boxShadowColor: UIColor = .gray
        if let boxShadowColorNumber = cardViewStyle.input?.boxShadow?.color {
            boxShadowColor = MFHelper.getColor(number: boxShadowColorNumber)
        }
        configure.setBoxShadow(MFBoxShadow(hOffset: hOffset, vOffset: vOffset, blur: blur, spread: spread, color: boxShadowColor))
        
        if let fontSize = cardViewStyle.input?.fontSize{
            configure.setFontSize(fontSize)
        }
        
        if let borderRadius = cardViewStyle.input?.borderRadius{
            configure.setBorderRadius(borderRadius)
        }
        
        if let fontFamily = cardViewStyle.input?.fontFamily {
            configure.setFontFamily(fontFamily)
        }
        
        configure.setBackgroundColor(backgroundColor)
        
        if let saveCardText = cardViewStyle.savedCardText, let deleteCardText = saveCardText.deleteAlertText {
            configure.setSaveCardText(
                MFSavedCardText(
                    saveCardText: saveCardText.saveCardText ?? "Save card no. for future payments",
                    addCardText: saveCardText.addCardText ?? "Use Another Card",
                    deleteAlertText: MFDeleteAlert(
                        title: deleteCardText.title ?? "Delete Card",
                        message: deleteCardText.message ?? "Are you sure you want to remove this Card?",
                        confirm: deleteCardText.confirm ?? "Yes",
                        cancel: deleteCardText.cancel ?? "No"
                    )
                )
            )
        }
        
        CardView.cardView.configure = configure.build()
    }
}
