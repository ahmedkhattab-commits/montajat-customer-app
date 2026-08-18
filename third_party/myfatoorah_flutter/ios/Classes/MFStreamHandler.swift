//
//  MFStreamHandler.swift
//  myfatoorah_flutter
//
//  Created by Muhammad Bassiouny on 8/2/23.
//

import Foundation
import Flutter

class MFStreamHandler: NSObject, FlutterStreamHandler {
    private static var eventSink: FlutterEventSink? = nil

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        MFStreamHandler.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    static func sendStream(data: String?) {
        guard let eventSink = eventSink, let data = data else { return }
        eventSink(data)
    }
}
