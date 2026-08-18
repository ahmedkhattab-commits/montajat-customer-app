package com.myfatoorahflutter.myfatoorah_flutter.crossplatform;

import com.myfatoorah.sdk.entity.MFError;

public interface IMFGPayListener {
    void OnGPayReceivedToken(String token);

    void OnGPaySessionUpdated(String sessionId);

    void OnGPayInvoiceCreated(String invoiceId);

    void OnGPayExecutePaymentSuccess(String invoiceId, String getPaymentStatusResponse);

    void OnGPayError(MFError error);
}
