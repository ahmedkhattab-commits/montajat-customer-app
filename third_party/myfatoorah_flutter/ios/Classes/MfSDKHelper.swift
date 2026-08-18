import Foundation
import MFSDK

#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif


protocol MFSDKHelper {
    func initiatePayment(initiatePaymentRequest: MFInitiatePaymentRequest, lang: String, completion: @escaping (Result<MFInitiatePaymentResponse, Error>) -> Void)
    func loadConfig(apiKey: String, country: String, environment: String)
    func setUpActionBar(toolBarTitle: String, toolBarTitleColor: Int64, toolBarBackgroundColor: Int64, isShowToolBar: Bool)
    func sendPayment(sendPaymentRequest: MFSendPaymentRequest, lang: String, completion: @escaping (Result<MFSendPaymentResponse, Error>) -> Void)
    func getPaymentStatus(getPaymentStatusRequest: MFPaymentStatusRequest, lang: String, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func executePayment(executePaymentRequest: MFExecutePaymentRequest, lang: String, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func executeDirectPayment(directPaymentRequest: MFDirectPaymentContainer, lang: String, completion: @escaping (Result<MFDirectPaymentResponse, Error>) -> Void)
    func executeTokenPayment(tokenPaymentRequest: MFTokenPaymentContainer, lang: String, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func cancelToken(token: String, lang: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func cancelRecurringPayment(recurringId: String, lang: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func initSession(initiateSessionRequest: MFInitiateSessionRequest, lang: String, completion: @escaping (Result<MFInitiateSessionResponse, Error>) -> Void)
    func load(initiateSessionResponse: MFInitiateSessionResponse)
    func initiateSession(initiateSessionRequest: MFInitiateSessionRequest, completion: @escaping (Result<MFInitiateSessionResponse, Error>) -> Void)
    func pay(executePaymentRequest: MFExecutePaymentRequest, lang: String, currency: String?, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func validate(currency: String?, completion: @escaping (Result<String, Error>) -> Void)
    func applePayPayment(executePaymentRequest: MFExecutePaymentRequest, lang: String, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func load(session: MFInitiateSessionResponse, executePaymentRequest: MFExecutePaymentRequest, lang: String, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func displayApplePayButton(session: MFInitiateSessionResponse, executePaymentRequest: MFExecutePaymentRequest, lang: String, completion: @escaping (Result<MFCallbackResponse, Error>) -> Void)
    func executeApplePayButton(executePaymentRequest: MFExecutePaymentRequest?, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func setupApplePay(session: MFInitiateSessionResponse, executePaymentRequest: MFExecutePaymentRequest, lang: String, merchantName: String?, completion: @escaping (Result<Bool, Error>) -> Void)
    func openPaymentSheet(completion: @escaping (Result<MFCallbackResponse, Error>) -> Void)
    func executeApplePayPayment(executePaymentRequest: MFExecutePaymentRequest?, completion: @escaping (Result<MFPaymentStatusResponse, Error>) -> Void)
    func updateApplePayAmount(to newAmount: Double)
}

/// Generated setup class to handle messages through the `binaryMessenger`.
class MFSDKHelperSetup {
    static var codec: FlutterStandardMessageCodec { MFSDKHelperCodec.shared }
    
    static func setUp(binaryMessenger: FlutterBinaryMessenger, api: MFSDKHelper?) {
        let loadConfigChannel = FlutterBasicMessageChannel(name: ChannelName.loadConfig, binaryMessenger: binaryMessenger, codec: codec)
        guard let api = api else {
            loadConfigChannel.setMessageHandler(nil)
            return
        }
        
        loadConfigChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let apiKey = args[0] as? String,
                  let country = args[1] as? String,
                  let environment = args[2] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.loadConfig(apiKey: apiKey, country: country, environment: environment)
        }
        
        
        let setUpActionBarChannel = FlutterBasicMessageChannel(name: ChannelName.setUpActionBar, binaryMessenger: binaryMessenger, codec: codec)
        setUpActionBarChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let toolBarTitle = args[0] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            let toolBarTitleColor = args[1] as? Int64 ?? Int64(4294967295)
            let toolBarBackgroundColor = args[2] as? Int64 ?? Int64(4278358988)
            let isShowToolBar = args[3] as? Bool ?? true
            api.setUpActionBar(toolBarTitle: toolBarTitle, toolBarTitleColor: toolBarTitleColor, toolBarBackgroundColor: toolBarBackgroundColor, isShowToolBar: isShowToolBar)
        }
        
        
        let initiatePaymentChannel = FlutterBasicMessageChannel(name: ChannelName.initiatePayment, binaryMessenger: binaryMessenger, codec: codec)
        initiatePaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let initiatePaymentRequest = args[0] as? MFInitiatePaymentRequest,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.initiatePayment(initiatePaymentRequest: initiatePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let sendPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.sendPayment, binaryMessenger: binaryMessenger, codec: codec)
        sendPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let sendPaymentRequest = args[0] as? MFSendPaymentRequest,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.sendPayment(sendPaymentRequest: sendPaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let getPaymentStatusChannel = FlutterBasicMessageChannel(name: ChannelName.getPaymentStatus, binaryMessenger: binaryMessenger, codec: codec)
        getPaymentStatusChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let getPaymentStatusRequest = args[0] as? MFPaymentStatusRequest,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.getPaymentStatus(getPaymentStatusRequest: getPaymentStatusRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let executePaymentChannel = FlutterBasicMessageChannel(name: ChannelName.executePayment, binaryMessenger: binaryMessenger, codec: codec)
        executePaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let executePaymentRequest = args[0] as? MFExecutePaymentRequest,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.executePayment(executePaymentRequest: executePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let executeDirectPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.executeDirectPayment, binaryMessenger: binaryMessenger, codec: codec)
        executeDirectPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let directPaymentRequest = args[0] as? MFDirectPaymentContainer,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.executeDirectPayment(directPaymentRequest: directPaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let executeTokenPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.executePaymentWithSavedToken, binaryMessenger: binaryMessenger, codec: codec)
        executeTokenPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let executePaymentRequest = args[0] as? MFTokenPaymentContainer,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.executeTokenPayment(tokenPaymentRequest: executePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let cancelTokenChannel = FlutterBasicMessageChannel(name: ChannelName.cancelToken, binaryMessenger: binaryMessenger, codec: codec)
        cancelTokenChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let token = args[0] as? String,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.cancelToken(token: token, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let cancelRecurringPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.cancelRecurringPayment, binaryMessenger: binaryMessenger, codec: codec)
        cancelRecurringPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let recurringId = args[0] as? String,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.cancelRecurringPayment(recurringId: recurringId, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let initSessionChannel = FlutterBasicMessageChannel(name: ChannelName.initSession, binaryMessenger: binaryMessenger, codec: codec)
        initSessionChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            let initiateSessionRequest = args[0] as? MFInitiateSessionRequest ?? MFInitiateSessionRequest(customerIdentifier: "")
            api.initSession(initiateSessionRequest: initiateSessionRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }

        let loadChannel = FlutterBasicMessageChannel(name: ChannelName.load, binaryMessenger: binaryMessenger, codec: codec)
        loadChannel.setMessageHandler { message, _ in
            guard let args = message as? [Any?],
                  let session = args[0] as? MFInitiateSessionResponse
            else {
                return
            }
            api.load(initiateSessionResponse: session)
        }

        let initiateSessionChannel = FlutterBasicMessageChannel(name: ChannelName.initiateSession, binaryMessenger: binaryMessenger, codec: codec)
        initiateSessionChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?]
            else {
                reply(MFHelper.parsingError)
                return
            }
            let initiateSessionRequest = args[0] as? MFInitiateSessionRequest ?? MFInitiateSessionRequest(customerIdentifier: "")
            api.initiateSession(initiateSessionRequest: initiateSessionRequest) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let payChannel = FlutterBasicMessageChannel(name: ChannelName.pay, binaryMessenger: binaryMessenger, codec: codec)
        payChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let executePaymentRequest = args[0] as? MFExecutePaymentRequest,
                  let lang = args[1] as? String,
                  let currency = args[2] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.pay(executePaymentRequest: executePaymentRequest, lang: lang, currency: currency) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let validateChannel = FlutterBasicMessageChannel(name: ChannelName.validate, binaryMessenger: binaryMessenger, codec: codec)
        validateChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                let currency = args[0] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.validate(currency: currency) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        
        let applePayPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.applePayPayment, binaryMessenger: binaryMessenger, codec: codec)
        applePayPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let executePaymentRequest = args[0] as? MFExecutePaymentRequest,
                  let lang = args[1] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.applePayPayment(executePaymentRequest: executePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let applePayLoadChannel = FlutterBasicMessageChannel(name: ChannelName.applePayLoad, binaryMessenger: binaryMessenger, codec: codec)
        applePayLoadChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let session = args[0] as? MFInitiateSessionResponse,
                  let executePaymentRequest = args[1] as? MFExecutePaymentRequest,
                  let lang = args[2] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.load(session: session, executePaymentRequest: executePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }


        let displayApplePayButtonChannel = FlutterBasicMessageChannel(name: ChannelName.displayApplePayButton, binaryMessenger: binaryMessenger, codec: codec)
        displayApplePayButtonChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let session = args[0] as? MFInitiateSessionResponse,
                  let executePaymentRequest = args[1] as? MFExecutePaymentRequest,
                  let lang = args[2] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.displayApplePayButton(session: session, executePaymentRequest: executePaymentRequest, lang: lang) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }

        let executeApplePayButtonChannel = FlutterBasicMessageChannel(name: ChannelName.executeApplePayButton, binaryMessenger: binaryMessenger, codec: codec)
        executeApplePayButtonChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?]
            else {
                reply(MFHelper.parsingError)
                return
            }
            let executePaymentRequest: MFExecutePaymentRequest? = args[0] as? MFExecutePaymentRequest
            api.executeApplePayButton(executePaymentRequest: executePaymentRequest) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let setupApplePayChannel = FlutterBasicMessageChannel(name: ChannelName.setupApplePay, binaryMessenger: binaryMessenger, codec: codec)
        setupApplePayChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let session = args[0] as? MFInitiateSessionResponse,
                  let executePaymentRequest = args[1] as? MFExecutePaymentRequest,
                  let lang = args[2] as? String
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.setupApplePay(session: session, executePaymentRequest: executePaymentRequest, lang: lang, merchantName: args[3] as? String) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let openPaymentSheetChannel = FlutterBasicMessageChannel(name: ChannelName.openPaymentSheet, binaryMessenger: binaryMessenger, codec: codec)
        openPaymentSheetChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?]
            else {
                reply(MFHelper.parsingError)
                return
            }
            api.openPaymentSheet() { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let executeApplePayPaymentChannel = FlutterBasicMessageChannel(name: ChannelName.executeApplePayPayment, binaryMessenger: binaryMessenger, codec: codec)
        executeApplePayPaymentChannel.setMessageHandler { message, reply in
            guard let args = message as? [Any?]
            else {
                reply(MFHelper.parsingError)
                return
            }
            let executePaymentRequest: MFExecutePaymentRequest? = args[0] as? MFExecutePaymentRequest
            api.executeApplePayPayment(executePaymentRequest: executePaymentRequest) { result in
                switch result {
                case .success(let res):
                    reply([res])
                case .failure(let error):
                    reply(MFHelper.wrapError(error))
                }
            }
        }
        
        let updateApplePayAmount = FlutterBasicMessageChannel(name: ChannelName.updateApplePayAmount, binaryMessenger: binaryMessenger, codec: codec)
        updateApplePayAmount.setMessageHandler { message, reply in
            guard let args = message as? [Any?],
                  let amout = args[0] as? Double
            else {
                reply(MFHelper.parsingError)
                return
            }

            api.updateApplePayAmount(to: amout)
        }
    }
}


private class MFSDKHelperCodecReaderWriter: FlutterStandardReaderWriter {
    override func reader(with data: Data) -> FlutterStandardReader {
        return MFSDKHelperCodecReader(data: data)
    }
    
    override func writer(with data: NSMutableData) -> FlutterStandardWriter {
        return MFSDKHelperCodecWriter(data: data)
    }
}


class MFSDKHelperCodec: FlutterStandardMessageCodec {
    static let shared = MFSDKHelperCodec(readerWriter: MFSDKHelperCodecReaderWriter())
}


private class MFSDKHelperCodecReader: FlutterStandardReader {
    override func readValue(ofType type: UInt8) -> Any? {
        switch type {
        case 130:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFTokenPaymentContainer.self, from: data)
        case 131:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFDirectPaymentContainer.self, from: data)
        case 133:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFExecPaymentContainer.self, from: data).MFExecPayRequest
        case 134:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFGetPaymentStatusContainer.self, from: data).MFGetPaymentRequest
        case 136:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFInitiatePaymentContainer.self, from: data).MFInitiatePayRequest
        case 138:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFInitiateSessionContainer.self, from: data).MFInitiateSessionReq
        case 139:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFInitiateSessionResponse.self, from: data)
        case 144:
            let data = MFHelper.toData(from: self.readValue())
            return try? JSONDecoder().decode(MFSendPaymentContainer.self, from: data).MFSendPayRequest
        default:
            return super.readValue(ofType: type)
        }
    }
}


private class MFSDKHelperCodecWriter: FlutterStandardWriter {
    override func writeValue(_ value: Any) {
        if let value = value as? MFDirectPaymentResponse {
            super.writeByte(132)
            super.writeValue(value.toJSONString as Any)
        }  else if let value = value as? MFPaymentStatusResponse {
            super.writeByte(135)
            super.writeValue(value.toJSONString as Any)
        }  else if let value = value as? MFInitiatePaymentResponse {
            super.writeByte(137)
            super.writeValue(value.toJSONString as Any)
        }  else if let value = value as? MFInitiateSessionResponse {
            super.writeByte(139)
            super.writeValue(value.toJSONString as Any)
        }  else if let value = value as? MFSendPaymentResponse {
            super.writeByte(145)
            super.writeValue(value.toJSONString as Any)
        }  else if let value = value as? MFCallbackResponse {
            super.writeByte(146)
            super.writeValue(value.toJSONString as Any)
        } else {
            super.writeValue(value)
        }
    }
}


