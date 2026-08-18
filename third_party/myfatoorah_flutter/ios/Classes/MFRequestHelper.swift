//
//  MFRequestHelper.swift
//  myfatoorah_flutter
//
//  Created by Muhammad Bassiouny on 7/26/23.
//

import Foundation
import MFSDK

//MARK: - Conform to Decodable
class MFInitiatePaymentContainer: Decodable {
    let MFInitiatePayRequest: MFInitiatePaymentRequest
    
    init(MFIPR: MFInitiatePaymentRequest) {
        self.MFInitiatePayRequest = MFIPR
    }
    
    enum CodingKeys: String, CodingKey {
        case invoiceValue = "InvoiceAmount"
        case currencyIso = "CurrencyIso"
    }
    
    required init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let invoiceValue = try? container.decode(Decimal.self, forKey: .invoiceValue),
           let currencyIso = try? container.decode(MFCurrencyISO.self, forKey: .currencyIso) {
            MFInitiatePayRequest = MFInitiatePaymentRequest(invoiceAmount: invoiceValue, currencyIso: currencyIso)
        } else {
            MFInitiatePayRequest = MFInitiatePaymentRequest()
        }
    }
}


class MFInitiateSessionContainer: Decodable {
    let MFInitiateSessionReq: MFInitiateSessionRequest?
    
    init(MFISR: MFInitiateSessionRequest) {
        self.MFInitiateSessionReq = MFISR
    }
    
    enum CodingKeys: String, CodingKey {
        case customerIdentifier = "CustomerIdentifier"
        case saveToken = "SaveToken"
        case isRecurring = "IsRecurring"
    }
    
    required init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let customerIdentifier = try? container.decode(String.self, forKey: .customerIdentifier) {
            let savetoken = try? container.decode(Bool.self, forKey: .saveToken)
            let isRecurring = try? container.decode(Bool.self, forKey: .isRecurring)

            MFInitiateSessionReq = MFInitiateSessionRequest(customerIdentifier: customerIdentifier, saveToken: savetoken, isRecurring: isRecurring)
        } else {
            MFInitiateSessionReq = nil
        }
    }
}


class MFGetPaymentStatusContainer: Decodable {
    let MFGetPaymentRequest: MFPaymentStatusRequest?
    
    init(MFGPSR: MFPaymentStatusRequest) {
        self.MFGetPaymentRequest = MFGPSR
    }
    
    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case keyType = "KeyType"
    }
    
    required init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           let keyType = try? container.decode(String.self, forKey: .keyType),
           let key = try? container.decode(String.self, forKey: .key) {
            if keyType.lowercased() == "invoiceid" {
                MFGetPaymentRequest = MFPaymentStatusRequest(invoiceID: key)
            } else if keyType.lowercased() == "paymentid"  {
                MFGetPaymentRequest = MFPaymentStatusRequest(paymentId: key)
            } else {
                MFGetPaymentRequest = nil
            }
        } else {
            MFGetPaymentRequest = nil
        }
    }
}


class MFSendPaymentContainer: Decodable {
    let MFSendPayRequest: MFSendPaymentRequest?
    
    init(MFSPR: MFSendPaymentRequest) {
        self.MFSendPayRequest = MFSPR
    }
    
    enum CodingKeys: String, CodingKey {
        case invoiceValue = "InvoiceValue"
        case notificationOption = "NotificationOption"
        case customerName = "CustomerName"
        case customerEmail = "CustomerEmail"
        case customerMobile = "CustomerMobile"
        case customerAddress = "CustomerAddress"
        case customerReference = "CustomerReference"
        case invoiceItems = "InvoiceItems"
        case customerCivilId = "CustomerCivilId"
        case language = "Language"
        case expiryDate = "ExpiryDate"
        case displayCurrencyIso = "DisplayCurrencyIso"
        case mobileCountryIsoCode = "MobileCountryCode"
        case userDefinedField = "UserDefinedField"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            MFSendPayRequest = nil
            return
        }
        
        if let invoiceValue = try? container.decode(Decimal.self, forKey: .invoiceValue),
           let notificationOption = try? container.decode(MFNotificationOption.self, forKey: .notificationOption),
           let customerName = try? container.decode(String.self, forKey: .customerName) {
            MFSendPayRequest = MFSendPaymentRequest(invoiceValue: invoiceValue, notificationOption: notificationOption, customerName: customerName)
            if let customerAddress = try? container.decode(MFCustomerAddressContainer.self, forKey: .customerAddress){
                MFSendPayRequest?.customerAddress = customerAddress.MFAddress
            }
            if let currencyIsoSTRING = try? container.decode(String.self, forKey: .displayCurrencyIso) {
                print(currencyIsoSTRING)
                
            }
            if let currencyIso = try? container.decode(MFCurrencyISO.self, forKey: .displayCurrencyIso) {
                MFSendPayRequest?.displayCurrencyIso = currencyIso
            }
            if let items = try? container.decode([MFInvoiceItemContainer].self, forKey: .invoiceItems){
                MFSendPayRequest?.invoiceItems = items.compactMap({ $0.invoiceItem })
            }
            MFSendPayRequest?.customerEmail = (try? container.decode(String.self, forKey: .customerEmail)) ?? ""
            MFSendPayRequest?.customerMobile = (try? container.decode(String.self, forKey: .customerMobile)) ?? ""
            MFSendPayRequest?.customerReference = (try? container.decode(String.self, forKey: .customerReference)) ?? ""
            MFSendPayRequest?.customerCivilId = (try? container.decode(String.self, forKey: .customerCivilId)) ?? ""
            MFSendPayRequest?.language = (try? container.decode(MFLanguage.self, forKey: .language)) ?? MFLanguage.english
            MFSendPayRequest?.userDefinedField = (try? container.decode(String.self, forKey: .userDefinedField)) ?? ""
            MFSendPayRequest?.mobileCountryIsoCode = (try? container.decode(String.self, forKey: .mobileCountryIsoCode)) ?? ""
            if let dateString = try? container.decode(String.self, forKey: .expiryDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                MFSendPayRequest?.expiryDate = dateFormatter.date(from: dateString)
            }
        } else {
            MFSendPayRequest = nil
        }
    }
}


class MFExecPaymentContainer: Decodable {
    let MFExecPayRequest: MFExecutePaymentRequest?
    
    init(MFExecPayRequest: MFExecutePaymentRequest) {
        self.MFExecPayRequest = MFExecPayRequest
    }
    
    enum CodingKeys: String, CodingKey {
        case invoiceValue = "InvoiceValue"
        case paymentMethod = "PaymentMethodId"
        case customerName = "CustomerName"
        case customerEmail = "CustomerEmail"
        case customerMobile = "CustomerMobile"
        case customerAddress = "CustomerAddress"
        case customerReference = "CustomerReference"
        case suppliers = "Suppliers"
        case customerCivilId = "CustomerCivilId"
        case invoiceItems = "InvoiceItems"
        case language = "Language"
        case expiryDate = "ExpiryDate"
        case userDefinedField = "UserDefinedField"
        case displayCurrencyIso = "DisplayCurrencyIso"
        case mobileCountryCode = "MobileCountryCode"
        case sessionId = "SessionId"
        case recurringModel = "RecurringModel"
        case processingDetails = "ProcessingDetails"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            MFExecPayRequest = nil
            return
        }
        if let invoiceValue = try? container.decode(Decimal.self, forKey: .invoiceValue) {
            let paymentMethod = try? container.decode(Int.self, forKey: .paymentMethod)
            MFExecPayRequest = MFExecutePaymentRequest(invoiceValue: invoiceValue, paymentMethod: paymentMethod ?? -1)
            if let suppliers = try? container.decode([MFSupplierContainer].self, forKey: .suppliers){
                MFExecPayRequest?.suppliers = suppliers.compactMap({ $0.Supplier })
            }
            if let items = try? container.decode([MFInvoiceItemContainer].self, forKey: .invoiceItems){
                MFExecPayRequest?.invoiceItems = items.compactMap({ $0.invoiceItem })
            }
            if let address = try? container.decode(MFCustomerAddressContainer.self, forKey: .invoiceItems){
                MFExecPayRequest?.customerAddress = address.MFAddress
            }
            if let currencyIso = try? container.decode(MFCurrencyISO.self, forKey: .displayCurrencyIso) {
                MFExecPayRequest?.displayCurrencyIso = currencyIso
            }
            if let recurringModel = try? container.decode(MFRecurringContainer.self, forKey: .recurringModel) {
                MFExecPayRequest?.recurringModel = recurringModel.recurringModel
            }
            if let processingDetails = try? container.decode(MFProcessingDetailsContainer.self, forKey: .processingDetails) {
                MFExecPayRequest?.processingDetails = processingDetails.processingDetails
            }
            MFExecPayRequest?.customerName = (try? container.decode(String.self, forKey: .customerName)) ?? ""
            MFExecPayRequest?.customerEmail = (try? container.decode(String.self, forKey: .customerEmail)) ?? ""
            MFExecPayRequest?.customerMobile = (try? container.decode(String.self, forKey: .customerMobile)) ?? ""
            MFExecPayRequest?.customerReference = (try? container.decode(String.self, forKey: .customerReference)) ?? ""
            MFExecPayRequest?.customerCivilId = (try? container.decode(String.self, forKey: .customerCivilId)) ?? ""
            MFExecPayRequest?.language = (try? container.decode(MFLanguage.self, forKey: .language)) ?? MFLanguage.english
            MFExecPayRequest?.userDefinedField = (try? container.decode(String.self, forKey: .userDefinedField)) ?? ""
            MFExecPayRequest?.mobileCountryCode = (try? container.decode(String.self, forKey: .mobileCountryCode)) ?? ""
            MFExecPayRequest?.sessionId = (try? container.decode(String.self, forKey: .sessionId)) ?? ""
            if let dateString = try? container.decode(String.self, forKey: .expiryDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                MFExecPayRequest?.expiryDate = dateFormatter.date(from: dateString)
            }
        } else {
            MFExecPayRequest = nil
        }
    }
}


class MFDirectPaymentContainer: Decodable {
    var executePaymentRequest: MFExecPaymentContainer?
    var token: String?
    var saveToken: Bool?
    var bypass3DS: Bool?
    var card: MFCardInfoContainer?
}

class MFTokenPaymentContainer: Decodable {
    var executePaymentRequest: MFExecPaymentContainer?
    var token: String?
    var securityCode: String?
    
    enum CodingKeys: String, CodingKey {
        case executePaymentRequest = "ExecutePaymentRequest"
        case token = "Token"
        case securityCode = "SecurityCode"
    }
}


class MFCardInfoContainer: Decodable {
    var number: String
    var expiryMonth: String
    var expiryYear: String
    var securityCode: String
    var cardHolderName: String
}


class MFCustomerAddressContainer: Decodable {
    let MFAddress: MFCustomerAddress?
    
    init(MFAddress: MFCustomerAddress) {
        self.MFAddress = MFAddress
    }
    
    enum CodingKeys: String, CodingKey {
        case block = "Block"
        case street = "Street"
        case houseBuildingNo = "HouseBuildingNo"
        case addressInstructions = "AddressInstructions"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            MFAddress = nil
            return
        }
        let block = (try? container.decode(String.self, forKey: .block)) ?? ""
        let street = (try? container.decode(String.self, forKey: .street)) ?? ""
        let houseBuildingNo = (try? container.decode(String.self, forKey: .houseBuildingNo)) ?? ""
        let addressInstructions = (try? container.decode(String.self, forKey: .addressInstructions)) ?? ""
        MFAddress = MFCustomerAddress(block: block, street: street, houseBuildingNo: houseBuildingNo, address: "address", addressInstructions: addressInstructions)
    }
}


class MFSupplierContainer: Decodable {
    let Supplier: MFSupplier?
    
    init(Supplier: MFSupplier) {
        self.Supplier = Supplier
    }
    
    enum CodingKeys: String, CodingKey {
        case supplierCode = "SupplierCode"
        case proposedShare = "ProposedShare"
        case invoiceShare = "InvoiceShare"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            Supplier = nil
            return
        }
        if let supplierCode = try? container.decode(Int.self, forKey: .supplierCode),
           let invoiceShare = try? container.decode(Decimal.self, forKey: .invoiceShare) {
            if let proposedShare = try? container.decode(Decimal.self, forKey: .proposedShare) {
                Supplier = MFSupplier(supplierCode: supplierCode, proposedShare: proposedShare, invoiceShare: invoiceShare)
            } else {
                Supplier = MFSupplier(supplierCode: supplierCode, invoiceShare: invoiceShare)
            }
        } else {
            Supplier = nil
        }
    }
}


class MFInvoiceItemContainer: Decodable {
    let invoiceItem: MFProduct?
    
    init(invoiceItem: MFProduct) {
        self.invoiceItem = invoiceItem
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "ItemName"
        case unitPrice = "UnitPrice"
        case quantity = "Quantity"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            invoiceItem = nil
            return
        }
        if let name = try? container.decode(String.self, forKey: .name),
           let unitPrice = try? container.decode(Double.self, forKey: .unitPrice),
           let quantity = try? container.decode(Int.self, forKey: .quantity) {
            invoiceItem = MFProduct(name: name, unitPrice: unitPrice, quantity: quantity)
        } else {
            invoiceItem = nil
        }
    }
}


class MFRecurringContainer: Decodable {
    let recurringModel: MFRecurringModel?
    static var intervalDays: Int?
    
    init(recurringModel: MFRecurringModel) {
        self.recurringModel = recurringModel
    }
    
    enum CodingKeys: String, CodingKey {
        case recurringType = "RecurringType"
        case intervalDays = "IntervalDays"
        case iteration = "Iteration"
    }
    
    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            recurringModel = nil
            return
        }
        if let intervalDays = try? container.decode(Int.self, forKey: .intervalDays) {
            MFRecurringContainer.intervalDays = intervalDays
        }
        if let recurringType = try? container.decode(MFRecurringType.self, forKey: .recurringType) {
            let iteration = try? container.decode(Int.self, forKey: .iteration)
            recurringModel = MFRecurringModel(recurringType: recurringType, iteration: iteration ?? 0)
        } else {
            recurringModel = nil
        }
    }
}

class MFProcessingDetailsContainer: Decodable {
    let processingDetails: MFProcessingDetails?

    init(processingDetails: MFProcessingDetails) {
        self.processingDetails = processingDetails
    }

    enum CodingKeys: String, CodingKey {
        case autoCapture = "AutoCapture"
    }

    required init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else {
            processingDetails = nil
            return
        }
        if let autoCapture = try? container.decode(Bool.self, forKey: .autoCapture) {
            processingDetails = MFProcessingDetails(autoCapture: autoCapture)
        } else {
            processingDetails = nil
        }
    }
}


extension MFRecurringType: Decodable {
    enum DecodingError: Error {
        case invalidValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "Daily":
            self = .daily
        case "Weekly":
            self = .weekly
        case "Monthly":
            self = .monthly
        case "Custom":
            self = .custom(intervalDays: MFRecurringContainer.intervalDays ?? 0)
        default:
            throw DecodingError.invalidValue
        }
    }
}

extension MFDirectPaymentResponse: Encodable {
    private enum CodingKeys: String, CodingKey {
        case cardInfoResponse
        case getPaymentStatusResponse = "mfPaymentStatusResponse"
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardInfoResponse, forKey: .cardInfoResponse)
        try container.encode(getPaymentStatusResponse, forKey: .getPaymentStatusResponse)
    }
}


class MFCardViewStyle: Decodable {
    var hideCardIcons: Bool?
    var direction: String?
    var backgroundColor: Int?
    var cardHeight: CGFloat?
    var input: MFCardViewInput?
    var label: MFCardViewLabel?
    var error: MFCardViewError?
    var savedCardText: MFSavedCardMessageText?
}

class MFCardViewInput: Decodable {
    var color: Int?
    var fontSize: CGFloat?
    var fontFamily: MFFontFamily?
    var inputHeight: CGFloat?
    var inputMargin: CGFloat?
    var borderColor: Int?
    var borderWidth: CGFloat?
    var borderRadius: CGFloat?
    var boxShadow: MFBoxShadowStyle?
    var placeHolder: MFCardViewPlaceHolder?
}

class MFCardViewLabel: Decodable {
    var display: Bool?
    var color: Int?
    var fontSize: CGFloat?
    var fontFamily: MFFontFamily?
    var fontWeight: MFFontWeight?
    var text: MFCardViewText?
}

class MFCardViewPlaceHolder: Decodable {
    var holderName: String?
    var cardNumber: String?
    var expiryDate: String?
    var securityCode: String?
}

class MFCardViewError: Decodable {
    var borderColor: Int?
    var borderRadius: CGFloat?
    var boxShadow: MFBoxShadowStyle?
}

class MFBoxShadowStyle: Decodable {
    var hOffset: CGFloat?
    var vOffset: CGFloat?
    var blur: CGFloat?
    var spread: CGFloat?
    var color: Int?
}

class MFCardViewText: Decodable {
    var holderName: String?
    var cardNumber: String?
    var expiryDate: String?
    var securityCode: String?
}

class MFSavedCardMessageText: Decodable {
    var saveCardText: String?
    var addCardText: String?
    var deleteAlertText: MFDeleteAlertText?
}

class MFDeleteAlertText: Decodable {
    var title: String?
    var message: String?
    var confirm: String?
    var cancel: String?
}

extension MFNotificationOption: Decodable {}
extension MFCurrencyISO: Decodable {}
extension MFLanguage: Decodable {}
extension MFFontFamily: Decodable {}
extension MFFontWeight: Decodable {}

class MFApplePayStyle: Decodable {
    var height: CGFloat?
    var borderRadius: CGFloat?
    var buttonText: String?
    var hideLoadingIndicator: Bool?
    var vendorName: String?
}


//MARK: - Encodable Extension
extension Encodable {
    var toJSONString: String? {
        let encoder = JSONEncoder()
        
        guard let encoded = try? encoder.encode(self),
              let object = try? JSONSerialization.jsonObject(with: encoded, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: []),
              let printedString = String(data: data, encoding: .utf8) else { return nil }
        return printedString
    }
}

