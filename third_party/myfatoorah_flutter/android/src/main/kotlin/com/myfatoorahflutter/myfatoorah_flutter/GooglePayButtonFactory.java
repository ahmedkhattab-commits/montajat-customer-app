package com.myfatoorahflutter.myfatoorah_flutter;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.myfatoorah.sdk.views.embeddedpayment.googlepay.MFGooglePayButton;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class GooglePayButtonFactory extends PlatformViewFactory {
    public MFGooglePayButton mfGooglePayButton;

    GooglePayButtonFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        return new GooglePayButton(context, id, creationParams);
    }

    class GooglePayButton implements PlatformView {
        GooglePayButton(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
            mfGooglePayButton = new MFGooglePayButton(context, null);

            // Apply configuration from Flutter if provided
            if (creationParams != null) {
                updateFromFlutterParams(creationParams);
            }
        }

        /**
         * Update button properties from Flutter parameters
         */
        private void updateFromFlutterParams(Map<String, Object> params) {
            try {
                // Update button type
                if (params.containsKey("buttonType")) {
                    Object buttonTypeObj = params.get("buttonType");
                    if (buttonTypeObj instanceof Number) {
                        int buttonTypeValue = ((Number) buttonTypeObj).intValue();
                        mfGooglePayButton.setType(buttonTypeValue);
                    }
                }

                // Update button theme
                if (params.containsKey("buttonTheme")) {
                    Object buttonThemeObj = params.get("buttonTheme");
                    if (buttonThemeObj instanceof Number) {
                        int buttonThemeValue = ((Number) buttonThemeObj).intValue();
                        mfGooglePayButton.setTheme(buttonThemeValue);
                    }
                }

                // Update corner radius
                if (params.containsKey("cornerRadius")) {
                    Object cornerRadiusObj = params.get("cornerRadius");
                    if (cornerRadiusObj instanceof Number) {
                        int cornerRadius = ((Number) cornerRadiusObj).intValue();
                        mfGooglePayButton.setCornerRadius(cornerRadius);
                    }
                }
            } catch (Exception e) {
                // Log error but don't crash - button will use defaults
                android.util.Log.e("MFGooglePayButton", "Error applying Flutter params: " + e.getMessage(), e);
            }
        }

        @NonNull
        @Override
        public View getView() {
            return mfGooglePayButton;
        }

        @Override
        public void dispose() {
            if (mfGooglePayButton != null) {
                mfGooglePayButton = null;
            }
        }
    }
}