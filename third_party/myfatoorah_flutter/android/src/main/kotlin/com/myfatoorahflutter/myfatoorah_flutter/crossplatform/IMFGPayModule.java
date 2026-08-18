package com.myfatoorahflutter.myfatoorah_flutter.crossplatform;

import com.myfatoorah.sdk.entity.executepayment.MFExecutePaymentRequest;
import com.myfatoorah.sdk.entity.googlepay.GooglePayRequest;

public interface IMFGPayModule {
    // MFGooglePayLauncher methods
    void SetupGooglePayHelperAuto(String sessionId, GooglePayRequest googlePayRequest, IMFCallBack promise);

    void SetupGooglePayHelperManual(String sessionId, GooglePayRequest googlePayRequest, IMFCallBack promise);

    void SetupGooglePayLauncherTokenOnly(GooglePayRequest googlePayRequest, IMFCallBack promise);

    void IsGooglePayAvailable(IMFCallBack promise);

    void UpdateGooglePayRequestAmount(String amount, IMFCallBack promise);

    void OpenGooglePaySheet(IMFCallBack promise);

    void ExecuteGooglePayPayment(MFExecutePaymentRequest executePaymentRequest, String lang, IMFCallBack promise);

    void addListener(String eventName);

    void removeListeners(Integer count);
}
