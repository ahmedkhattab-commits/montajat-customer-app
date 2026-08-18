package com.myfatoorahflutter.myfatoorah_flutter.crossplatform;

import android.app.Activity;
import android.util.Log;
import android.view.View;

import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.myfatoorah.sdk.entity.MFError;
import com.myfatoorah.sdk.entity.executepayment.MFExecutePaymentRequest;
import com.myfatoorah.sdk.entity.googlepay.GooglePayRequest;
import com.myfatoorah.sdk.entity.paymentstatus.MFGetPaymentStatusResponse;
import com.myfatoorah.sdk.views.MFResult;
import com.myfatoorah.sdk.views.embeddedpayment.googlepay.MFGooglePayButton;
import com.myfatoorah.sdk.views.embeddedpayment.googlepay.MFGooglePayLauncher;
import com.myfatoorah.sdk.views.embeddedpayment.googlepay.ExecutionMode;
import com.myfatoorahflutter.myfatoorah_flutter.GooglePayButtonFactory;
import com.myfatoorahflutter.myfatoorah_flutter.MfGPayHelper;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.utils.MFExtentionsKt;

import kotlin.Unit;

public class MFGPayModule implements MfGPayHelper.MFGPayHelper {

    public Activity activity = null;
    public GooglePayButtonFactory googlePayButtonFactory;
    public MFGooglePayLauncher mfGooglePayLauncher = null;
    private final String TAG = "MyfatoorahModule";

    //#region MFGooglePayLauncher Methods
    @Override
    public void SetupGooglePayHelperAuto(@NonNull String sessionId, @NonNull GooglePayRequest googlePayRequest, @NonNull IMFCallBack promise) {
        MFGooglePayButton googlePayButton = googlePayButtonFactory.mfGooglePayButton;

        if (IfGoogleButtonIsMissing(googlePayButton, promise)) return;
        if (IfActivityIsMissing(promise)) return;
        if (IfGooglePayLauncherIsMissing(promise)) return;

        ExecutionMode autoExecutePayment = new ExecutionMode.Auto(
                (String invoiceId) -> {
                    OnGPayInvoiceCreated(invoiceId);
                    return Unit.INSTANCE;
                },
                (String invoiceId, MFGetPaymentStatusResponse getPaymentStatusResponse) -> {
                    OnGPayExecutePaymentSuccess(invoiceId, getPaymentStatusResponse);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.config(
                googlePayRequest,
                autoExecutePayment,
                sessionId,
                (MFError error) -> {
                    OnGPayError(error);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.setGooglePayButton(googlePayButton);
        googlePayButton.setVisibility(View.VISIBLE);

        OnSuccess(promise, "MFGooglePay is Configured.");
    }

    @Override
    public void SetupGooglePayHelperManual(@NonNull String sessionId, @NonNull GooglePayRequest googlePayRequest, @NonNull IMFCallBack promise) {
        MFGooglePayButton googlePayButton = googlePayButtonFactory.mfGooglePayButton;

        if (IfGoogleButtonIsMissing(googlePayButton, promise)) return;
        if (IfActivityIsMissing(promise)) return;
        if (IfGooglePayLauncherIsMissing(promise)) return;


        ExecutionMode manualExecutionMode = new ExecutionMode.Manual(
                (String updatedSessionId) -> {
                    OnGPaySessionUpdated(updatedSessionId);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.config(
                googlePayRequest,
                manualExecutionMode,
                sessionId,
                (MFError error) -> {
                    OnGPayError(error);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.setGooglePayButton(googlePayButton);
        googlePayButton.setVisibility(View.VISIBLE);

        OnSuccess(promise, "MFGooglePay is Configured.");
    }

    @Override
    public void SetupGooglePayLauncherTokenOnly(@NonNull GooglePayRequest googlePayRequest, @NonNull IMFCallBack promise) {
        MFGooglePayButton googlePayButton = googlePayButtonFactory.mfGooglePayButton;

        if (IfGoogleButtonIsMissing(googlePayButton, promise)) return;
        if (IfActivityIsMissing(promise)) return;
        if (IfGooglePayLauncherIsMissing(promise)) return;

        ExecutionMode tokenOnlyMode = new ExecutionMode.TokenOnly(
                (String token) -> {
                    Log.d(TAG, "Token received: " + token);
                    OnGPayReceivedToken(token);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.config(
                googlePayRequest,
                tokenOnlyMode,
                null,
                (MFError error) -> {
                    OnGPayError(error);
                    return Unit.INSTANCE;
                }
        );

        mfGooglePayLauncher.setGooglePayButton(googlePayButton);
        googlePayButton.setVisibility(View.VISIBLE);

        OnSuccess(promise, "MFGooglePay is Configured.");
    }

    @Override
    public void IsGooglePayAvailable(@NonNull IMFCallBack promise) {
        MFGooglePayButton googlePayButton = googlePayButtonFactory.mfGooglePayButton;
        if (IfGoogleButtonIsMissing(googlePayButton, promise)) return;
        if (IfActivityIsMissing(promise)) return;
        if (IfGooglePayLauncherIsMissing(promise)) return;
        try {
            mfGooglePayLauncher.isGooglePayAvailable((Boolean isAvailable) -> {
                OnSuccess(promise, isAvailable);
                return Unit.INSTANCE;
            });
        } catch (Exception e) {
            OnError(promise, new MFError(
                    MFErrorCodes.CHECK_AVAILABILITY_FAILED.getCode(),
                    MFErrorCodes.CHECK_AVAILABILITY_FAILED.getUserMessage() + " Details: " + e.getMessage()
            ));
        }
    }

    @Override
    public void UpdateGooglePayRequestAmount(@NonNull String amount, @NonNull IMFCallBack promise) {
        if (mfGooglePayLauncher == null) {
            OnError(promise, new MFError(
                    MFErrorCodes.LAUNCHER_NOT_READY.getCode(),
                    MFErrorCodes.LAUNCHER_NOT_READY.getUserMessage()
            ));
            return;
        }

        mfGooglePayLauncher.updateRequestAmount(amount);
        OnSuccess(promise, "Amount updated");
    }

    @Override
    public void OpenGooglePaySheet(@NonNull IMFCallBack promise) {
        MFGooglePayButton googlePayButton = googlePayButtonFactory.mfGooglePayButton;
        if (IfGoogleButtonIsMissing(googlePayButton, promise)) return;
        if (IfActivityIsMissing(promise)) return;
        if (IfGooglePayLauncherIsMissing(promise)) return;

        mfGooglePayLauncher.openGooglePaySheet();
        OnSuccess(promise, "Sheet opened");
    }

    @Override
    public void ExecuteGooglePayPayment(@NonNull MFExecutePaymentRequest executePaymentRequest, @NonNull String lang, @NonNull IMFCallBack promise) {
        if (IfActivityIsMissing(promise)) return;

        mfGooglePayLauncher.executePayment(
                activity,
                executePaymentRequest,
                lang,
                (String invoiceId) -> {
                    OnGPayInvoiceCreated(invoiceId);
                    Log.d("Tag", invoiceId);
                    return Unit.INSTANCE;
                },
                (String invoiceId, MFResult<MFGetPaymentStatusResponse> result) -> {
                    if (result instanceof MFResult.Success) {
                        MFGetPaymentStatusResponse response = ((MFResult.Success<MFGetPaymentStatusResponse>) result).getResponse();
                        OnSuccess(promise, response);
                    } else if (result instanceof MFResult.Fail) {
                        MFError mfError = ((MFResult.Fail) result).getError();
                        OnError(promise, mfError);
                    }
                    return Unit.INSTANCE;
                });
    }
    //#endregion

    //#region EventEmitter Methods
    public IMFGPayListener mfGPayListener;

    private void OnGPayInvoiceCreated(String invoiceId) {
        if (mfGPayListener != null) {
            mfGPayListener.OnGPayInvoiceCreated(invoiceId);
        } else {
            Log.w(TAG, "OnGPayInvoiceCreated called but mfGPayListener is null");
        }
    }

    private void OnGPayReceivedToken(String token) {
        if (mfGPayListener != null) {
            mfGPayListener.OnGPayReceivedToken(token);
        } else {
            Log.w(TAG, "OnGPayReceivedToken called but mfGPayListener is null");
        }
    }

    private void OnGPaySessionUpdated(String sessionId) {
        if (mfGPayListener != null) {
            mfGPayListener.OnGPaySessionUpdated(sessionId);
        } else {
            Log.w(TAG, "OnGPaySessionUpdated called but mfGPayListener is null");
        }
    }

    private void OnGPayExecutePaymentSuccess(String invoiceId, MFGetPaymentStatusResponse getPaymentStatusResponse) {
        if (mfGPayListener != null) {
            String response = new Gson().toJson(getPaymentStatusResponse);
            mfGPayListener.OnGPayExecutePaymentSuccess(invoiceId, response);
        } else {
            Log.w(TAG, "OnGPayExecutePaymentSuccess called but mfGPayListener is null");
        }
    }

    private void OnGPayError(MFError error) {
        if (mfGPayListener != null) {
            mfGPayListener.OnGPayError(error);
        } else {
            Log.w(TAG, "OnGPayError called but mfGPayListener is null");
        }
    }

    @Override
    public void addListener(String eventName) {

    }

    @Override
    public void removeListeners(Integer count) {

    }
    //#endregion

    //#region Helpers Methods
    private void OnError(IMFCallBack promise, MFError mfError) {
        Log.e(TAG, "Error: " + mfError.getMessage());
        promise.error(mfError);
    }

    private <T> void OnSuccess(IMFCallBack promise, T response) {
        Log.d(TAG, "Success: " + response.toString());
        promise.success(response);
    }

    private <T> T HandleReadableMap(String requestMap, Class<T> classOfT) {
        return MFExtentionsKt.handleReadableMap(requestMap, classOfT);
    }

    private boolean IfActivityIsMissing(IMFCallBack promise) {
        if (activity == null) {
            OnError(promise, new MFError(
                    MFErrorCodes.ACTIVITY_NULL.getCode(),
                    MFErrorCodes.ACTIVITY_NULL.getUserMessage()
            ));
            return true;
        } else return false;
    }

    private boolean IfGoogleButtonIsMissing(MFGooglePayButton googlePayButton, IMFCallBack promise) {
        if (googlePayButton == null) {
            OnError(promise, new MFError(
                    MFErrorCodes.GPAY_BUTTON_NOT_INITIALIZED.getCode(),
                    MFErrorCodes.GPAY_BUTTON_NOT_INITIALIZED.getUserMessage()
            ));
            return true;
        } else return false;
    }

    private boolean IfGooglePayLauncherIsMissing(IMFCallBack promise) {
        if (mfGooglePayLauncher != null) return false;

        if (!(activity instanceof ActivityResultCaller)) {
            OnError(promise, new MFError(
                    MFErrorCodes.NOT_ACTIVITY_RESULT_CALLER.getCode(),
                    MFErrorCodes.NOT_ACTIVITY_RESULT_CALLER.getUserMessage()
            ));
            return true;
        }

        try {
            mfGooglePayLauncher = new MFGooglePayLauncher((ActivityResultCaller) activity, activity);
            return false;
        } catch (IllegalStateException e) {
            OnError(promise, new MFError(
                    MFErrorCodes.INIT_TOO_LATE.getCode(),
                    MFErrorCodes.INIT_TOO_LATE.getUserMessage() + " Details: " + e.getMessage()
            ));
            return true;
        } catch (Exception e) {
            OnError(promise, new MFError(
                    MFErrorCodes.LAUNCHER_NOT_READY.getCode(),
                    MFErrorCodes.LAUNCHER_NOT_READY.getUserMessage() + " Details: " + e.getMessage()
            ));
            return true;
        }
    }
    //#endregion
}