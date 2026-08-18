package com.myfatoorahflutter.myfatoorah_flutter;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.myfatoorah.sdk.entity.MFError;
import com.myfatoorah.sdk.entity.executepayment.MFExecutePaymentRequest;
import com.myfatoorah.sdk.entity.googlepay.GooglePayRequest;
import com.myfatoorah.sdk.entity.initiatesession.MFInitiateSessionRequest;
import com.myfatoorah.sdk.entity.initiatesession.MFInitiateSessionResponse;
import com.myfatoorah.sdk.entity.paymentstatus.MFGetPaymentStatusRequest;
import com.myfatoorah.sdk.entity.paymentstatus.MFGetPaymentStatusResponse;
import com.myfatoorah.sdk.entity.updatesession.MFUpdateSessionRequest;
import com.myfatoorah.sdk.entity.updatesession.MFUpdateSessionResponse;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.IMFCallBack;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.IMFGPayModule;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.models.MFGooglePayRequest;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.utils.MFConstants;
import com.myfatoorahflutter.myfatoorah_flutter.crossplatform.utils.MFExtentionsKt;

import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;

import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;

public class MfGPayHelper {
    @NonNull
    protected static ArrayList<Object> wrapError(@NonNull MFError error) {
        ArrayList<Object> errorList = new ArrayList<>(3);
        errorList.add(error.getCode());
        errorList.add(error.getMessage());
        errorList.add("MF ERROR");
        return errorList;
    }

    private static class MFGPayHelperCodec extends StandardMessageCodec {
        public static final MFGPayHelperCodec INSTANCE = new MFGPayHelperCodec();

        private MFGPayHelperCodec() {
        }

        @Override
        protected Object readValueOfType(byte type, @NonNull ByteBuffer buffer) {
            switch (type) {
                 case (byte) MFConstants.BufferType.MFExecutePaymentRequest:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFExecutePaymentRequest.class);
                case (byte) MFConstants.BufferType.MFGetPaymentStatusRequest:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFGetPaymentStatusRequest.class);
                case (byte) MFConstants.BufferType.MFInitiateSessionRequest:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFInitiateSessionRequest.class);
                case (byte) MFConstants.BufferType.MFInitiateSessionResponse:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFInitiateSessionResponse.class);
                case (byte) MFConstants.BufferType.MFUpdateSessionRequest:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFUpdateSessionRequest.class);
                case (byte) MFConstants.BufferType.MFUpdateSessionResponse:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFUpdateSessionResponse.class);
                case (byte) MFConstants.BufferType.MFGooglePayRequest:
                    return MFExtentionsKt.handleReadableMap((String) readValue(buffer), MFGooglePayRequest.class);
                default:
                    return super.readValueOfType(type, buffer);
            }
        }

        @Override
        protected void writeValue(@NonNull ByteArrayOutputStream stream, Object value) {
            if (value instanceof MFGetPaymentStatusResponse) {
                stream.write(MFConstants.BufferType.MFGetPaymentStatusResponse);
                writeValue(stream, MFExtentionsKt.toJson(value));
            }   else if (value instanceof MFInitiateSessionResponse) {
                stream.write(MFConstants.BufferType.MFInitiateSessionResponse);
                writeValue(stream, MFExtentionsKt.toJson(value));
            } else if (value instanceof MFUpdateSessionResponse) {
                stream.write(MFConstants.BufferType.MFUpdateSessionResponse);
                writeValue(stream, MFExtentionsKt.toJson(value));
            }  else if (value instanceof MFError) {
                stream.write(MFConstants.BufferType.MFError);
                writeValue(stream, MFExtentionsKt.toJson(value));
            } else {
                super.writeValue(stream, value);
            }
        }
    }

    /**
     * Generated interface that represents a handler of messages from Flutter.
     */
    public interface MFGPayHelper extends IMFGPayModule {
        /**
         * The codec used by MFGPayHelper.
         */
        static @NonNull MessageCodec<Object> getCodec() {
            return MFGPayHelperCodec.INSTANCE;
        }

        /**
         * Sets up an instance of `MFGPayHelper` to handle messages through the `binaryMessenger`.
         */
        static void setup(@NonNull BinaryMessenger binaryMessenger, @Nullable MFGPayHelper api) {
            // MFGooglePayLauncher channel handlers
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayLauncherAuto, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                ArrayList<Object> args = (ArrayList<Object>) message;
                                String sessionId = (String) args.get(0);
                                MFGooglePayRequest request = (MFGooglePayRequest) args.get(1);
                                GooglePayRequest googlePayRequest = new GooglePayRequest(
                                        request.TotalPrice,
                                        request.MerchantId,
                                        request.MerchantName,
                                        request.CountryCode,
                                        request.CurrencyIso
                                );
                                api.SetupGooglePayHelperAuto(sessionId, googlePayRequest, resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayLauncherManual, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                ArrayList<Object> args = (ArrayList<Object>) message;
                                String sessionId = (String) args.get(0);
                                MFGooglePayRequest request = (MFGooglePayRequest) args.get(1);
                                GooglePayRequest googlePayRequest = new GooglePayRequest(
                                        request.TotalPrice,
                                        request.MerchantId,
                                        request.MerchantName,
                                        request.CountryCode,
                                        request.CurrencyIso
                                );
                                api.SetupGooglePayHelperManual(sessionId, googlePayRequest, resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayLauncherTokenOnly, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                ArrayList<Object> args = (ArrayList<Object>) message;
                                MFGooglePayRequest request = (MFGooglePayRequest) args.get(0);
                                GooglePayRequest googlePayRequest = new GooglePayRequest(
                                        request.TotalPrice,
                                        request.MerchantId,
                                        request.MerchantName,
                                        request.CountryCode,
                                        request.CurrencyIso
                                );
                                api.SetupGooglePayLauncherTokenOnly(googlePayRequest, resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayAvailable, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                api.IsGooglePayAvailable(resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayUpdateAmount, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                ArrayList<Object> args = (ArrayList<Object>) message;
                                String amount = (String) args.get(0);
                                api.UpdateGooglePayRequestAmount(amount, resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayOpenSheet, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                api.OpenGooglePaySheet(resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
            {
                BasicMessageChannel<Object> channel =
                        new BasicMessageChannel<>(binaryMessenger, MFConstants.ChannelGPayName.googlePayExecutePayment, getCodec());
                if (api != null) {
                    channel.setMessageHandler(
                            (message, reply) -> {
                                ArrayList<Object> args = (ArrayList<Object>) message;
                                MFExecutePaymentRequest executePaymentRequest = (MFExecutePaymentRequest) args.get(0);
                                String lang = (String) args.get(1);
                                api.ExecuteGooglePayPayment(executePaymentRequest, lang, resultCallback(reply));
                            });
                } else {
                    channel.setMessageHandler(null);
                }
            }
        }

        static <T> IMFCallBack<T> resultCallback(BasicMessageChannel.Reply<Object> reply) {
            return new IMFCallBack<T>() {
                public void success(T result) {
                    ArrayList<Object> wrapped = new ArrayList<>();
                    wrapped.add(0, result);
                    reply.reply(wrapped);
                }

                public void error(MFError error) {
                    ArrayList<Object> wrappedError = wrapError(error);
                    reply.reply(wrappedError);
                }
            };
        }
    }
}
