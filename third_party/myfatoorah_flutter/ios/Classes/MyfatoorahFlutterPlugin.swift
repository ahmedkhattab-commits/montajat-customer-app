import Flutter
import MFSDK
import UIKit

public class MyfatoorahFlutterPlugin: NSObject, FlutterPlugin, MFSDKHelper {
    override init() {
        super.init()
        MFSettings.shared.delegate = self
    }
    
    static let applePay = MFApplePay()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let api : MFSDKHelper & NSObjectProtocol = MyfatoorahFlutterPlugin.init()
        MFSDKHelperSetup.setUp(binaryMessenger: messenger, api: api);
        
        let eventChannel = FlutterEventChannel(name: MFHelper.MFEventChannelName, binaryMessenger: messenger)
        eventChannel.setStreamHandler(MFStreamHandler())
        
        let cardViewFactory = CardViewFactory(messenger: messenger)
        registrar.register(cardViewFactory, withId: MFHelper.cardViewModule)
        
        let applePayFactory = ApplePayFactory(messenger: messenger)
        registrar.register(applePayFactory, withId: MFHelper.applePayModule)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    //MARK: MFSDF Functions
    func loadConfig(apiKey: String,
                    country: String,
                    environment: String) {
        let country = MFHelper.toMFCountry(code: country)
        if let env = MFEnvironment(rawValue: environment.lowercased()) {
            MFSettings.shared.configure(token: apiKey, country: country, environment: env)
        }
    }
    
    func initiatePayment(initiatePaymentRequest: MFInitiatePaymentRequest,
                         lang: String,
                         completion: @escaping (Result<MFInitiatePaymentResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        MFPaymentRequest.shared.initiatePayment(request: initiatePaymentRequest, apiLanguage: language) { response in
            switch response {
            case .success(let initiatePaymentResponse):
                completion(.success(initiatePaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setUpActionBar( toolBarTitle: String,
                         toolBarTitleColor: Int64,
                         toolBarBackgroundColor: Int64,
                         isShowToolBar: Bool) {
        let titleColor = MFHelper.getColor(number: Int(toolBarTitleColor))
        let backgroundColor = MFHelper.getColor(number: Int(toolBarBackgroundColor))
        
        let them = MFTheme(navigationTintColor: titleColor, navigationBarTintColor: backgroundColor, navigationTitle: toolBarTitle as String, cancelButtonTitle: "cancel", showNavigationBar: isShowToolBar)
        MFSettings.shared.setTheme(theme: them)
    }
    
    func sendPayment(sendPaymentRequest: MFSendPaymentRequest,
                     lang: String,
                     completion: @escaping (Result<MFSendPaymentResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.sendPayment(request: sendPaymentRequest, apiLanguage: language) { response in
            switch response {
            case .success(let sendPaymentResponse):
                completion(.success(sendPaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executePayment(executePaymentRequest: MFExecutePaymentRequest,
                        lang: String,
                        completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.executePayment(request: executePaymentRequest, apiLanguage: language) { (response, invoiceId) in
            switch response {
            case .success(let executePaymentResponse):
                completion(.success(executePaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executeDirectPayment(directPaymentRequest: MFDirectPaymentContainer,
                              lang: String,
                              completion: @escaping (Result<MFDirectPaymentResponse, Error>) -> Void) {
        guard let executePayReq = directPaymentRequest.executePaymentRequest?.MFExecPayRequest else {
            completion(.failure(NSError(domain: "Error In Parsing Data: Incomplete Request", code: 400)))
            return
        }
        var card: MFCardInfo
        if let cardInfo = directPaymentRequest.card {
            card = MFCardInfo(cardNumber: cardInfo.number, cardExpiryMonth: cardInfo.expiryMonth, cardExpiryYear: cardInfo.expiryYear, cardHolderName: cardInfo.cardHolderName, cardSecurityCode: cardInfo.securityCode, saveToken: directPaymentRequest.saveToken ?? false)
            card.bypass = directPaymentRequest.bypass3DS ?? false
        } else if let token =  directPaymentRequest.token {
            card = MFCardInfo(cardToken: token)
            card.bypass = directPaymentRequest.bypass3DS ?? false
        } else {
            completion(.failure(NSError(domain: "Error In Parsing Data: Incomplete Request", code: 400)))
            return
        }
        MFPaymentRequest.shared.executeDirectPayment(request: executePayReq, cardInfo: card, apiLanguage: .english) { (response, invoiceId) in
            switch response {
            case .success(let directPaymentResponse):
                completion(.success(directPaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executeTokenPayment(tokenPaymentRequest: MFTokenPaymentContainer,
                              lang: String,
                              completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english

        guard let executePayReq = tokenPaymentRequest.executePaymentRequest?.MFExecPayRequest else {
            completion(.failure(NSError(domain: "Error In Parsing Data: Incomplete Request", code: 400)))
            return
        }
        
        let updateSessionRequest = MFUpdateSessionRequest(
            sessionId: executePayReq.sessionId,
            tokenType: .mfToken,
            token: tokenPaymentRequest.token ?? "",
            securityCode: tokenPaymentRequest.securityCode
        )
        
        MFPaymentRequest.shared.executeTokenPayment(
            updateSessionRequest: updateSessionRequest,
            paymentRequest: executePayReq,
            apiLanguage: language) { (response, invoiceId) in
                switch response {
                case .success(let executePaymentResponse):
                    completion(.success(executePaymentResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getPaymentStatus(getPaymentStatusRequest: MFPaymentStatusRequest,
                          lang: String,
                          completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.getPaymentStatus(paymentStatus: getPaymentStatusRequest, apiLanguage: language) { response in
            switch response {
            case .success(let paymentStatusResponse):
                completion(.success(paymentStatusResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelToken( token: String,
                      lang: String,
                      completion: @escaping (Result<Bool, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.cancelToken(token: token as String, apiLanguage: language) { result in
            switch result {
            case .success(let tokenResult):
                completion(.success(tokenResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelRecurringPayment(recurringId: String,
                                lang: String,
                                completion: @escaping (Result<Bool, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.cancelRecurringPayment(recurringId: recurringId, apiLanguage: language) { result in
            switch result {
            case .success(let recurringResult):
                completion(.success(recurringResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func initSession(initiateSessionRequest: MFInitiateSessionRequest,
                     lang: String,
                     completion: @escaping (Result<MFInitiateSessionResponse, Error>) -> Void) {
        MFPaymentRequest.shared.initiateSession(request: initiateSessionRequest, apiLanguage: .english) { response in
            switch response {
            case .success(let session):
                completion(.success(session))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func load(initiateSessionResponse: MFInitiateSessionResponse) {
        CardView.cardView.load(initiateSession: initiateSessionResponse) { bin in
            MFStreamHandler.sendStream(data: bin)
        }
    }
    
    func initiateSession(initiateSessionRequest: MFInitiateSessionRequest,
                         completion: @escaping (Result<MFInitiateSessionResponse, Error>) -> Void) {
        MFPaymentRequest.shared.initiateSession(request: initiateSessionRequest, apiLanguage: .english) { response in
            switch response {
            case .success(let session):
                CardView.cardView.load(initiateSession: session) { bin in
                    MFStreamHandler.sendStream(data: bin)
                }
                completion(.success(session))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func pay(executePaymentRequest: MFExecutePaymentRequest,
             lang: String,
             currency: String?,
             completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        let currency = MFCurrencyISO(rawValue: currency ?? "")

        CardView.cardView.pay(executePaymentRequest, language, currency) { response, invoiceId in
            switch response {
            case .success(let paymentStatus):
                completion(.success(paymentStatus))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validate(currency: String?, completion: @escaping (Result<String, Error>) -> Void) {
        let currency = MFCurrencyISO(rawValue: currency ?? "")
        CardView.cardView.submit(currency) { result in
            switch result {
            case .success(let response):
                completion(.success(response.cardBrand ?? ""))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func applePayPayment(executePaymentRequest: MFExecutePaymentRequest,
                         lang: String,
                         completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        MFPaymentRequest.shared.initiateSession(apiLanguage: language) { response in
            switch response {
            case .success(let session):
                ApplePayButton.applePayButton.load(session, executePaymentRequest, language) { response, invoiceId in
                    switch response {
                    case .success(let executePaymentResponse):
                        completion(.success(executePaymentResponse))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func load(session: MFInitiateSessionResponse,
              executePaymentRequest: MFExecutePaymentRequest,
              lang: String,
              completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        ApplePayButton.applePayButton.load(session, executePaymentRequest, language) {
            MFStreamHandler.sendStream(data: "Appl Pay Start Session")
        } completion: { response, invoiceId in
            switch response {
            case .success(let executePaymentResponse):
                completion(.success(executePaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func displayApplePayButton(session: MFInitiateSessionResponse,
                               executePaymentRequest: MFExecutePaymentRequest,
                               lang: String,
                               completion: @escaping (Result<MFCallbackResponse, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        ApplePayButton.applePayButton.display(session, executePaymentRequest, language) { response in
            switch response {
            case .success(let callback):
                completion(.success(callback))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executeApplePayButton(executePaymentRequest: MFExecutePaymentRequest?,
                               completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        ApplePayButton.applePayButton.executePayment(request: executePaymentRequest) { response, invoiceId in
            switch response {
            case .success(let executePaymentResponse):
                completion(.success(executePaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setupApplePay(session: MFInitiateSessionResponse,
                       executePaymentRequest: MFExecutePaymentRequest,
                       lang: String,
                       merchantName: String?,
                       completion: @escaping (Result<Bool, Error>) -> Void) {
        let language = MFAPILanguage(rawValue: lang) ?? .english
        
        if let merchantName = merchantName {
            MyfatoorahFlutterPlugin.applePay.merchantName = merchantName
        }

        MyfatoorahFlutterPlugin.applePay.didLoad = {
            MFStreamHandler.sendStream(data: "Button Loaded")
        }
        
        MyfatoorahFlutterPlugin.applePay.setupApplePay(session, executePaymentRequest, language){ response in
            switch response {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func openPaymentSheet(completion: @escaping (Result<MFCallbackResponse, Error>) -> Void) {
        MyfatoorahFlutterPlugin.applePay.openPaymentSheet { response in
            switch response {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func executeApplePayPayment(executePaymentRequest: MFExecutePaymentRequest?,
                        completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void) {
        MyfatoorahFlutterPlugin.applePay.executePayment(request: executePaymentRequest) { response, invoiceId in
            switch response {
            case .success(let executePaymentResponse):
                completion(.success(executePaymentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateApplePayAmount(to newAmount: Double) {
        guard newAmount > 0 else { return }
        MyfatoorahFlutterPlugin.applePay.update(amount: newAmount)
    }
}

extension MyfatoorahFlutterPlugin: MFPaymentDelegate {
    public func didInvoiceCreated(invoiceId: String) {
        MFStreamHandler.sendStream(data: invoiceId)
    }
}
