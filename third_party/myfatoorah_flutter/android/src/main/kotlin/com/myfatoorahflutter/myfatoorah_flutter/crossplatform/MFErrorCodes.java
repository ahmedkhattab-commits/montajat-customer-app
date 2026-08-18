package com.myfatoorahflutter.myfatoorah_flutter.crossplatform;

/**
 * Error codes for MyFatoorah Flutter SDK
 * <p>
 * Provides standardized error codes and messages for better error handling
 * and debugging across the Flutter SDK.
 */
public enum MFErrorCodes {
    // Activity and Lifecycle Errors (011-014)
    GPAY_BUTTON_NOT_INITIALIZED("010", "Google Pay Button not initialized", "GooglePayButton must be initialized"),
    ACTIVITY_NULL("011", "Activity is not attached", "Ensure the plugin is properly attached to an activity"),
    LAUNCHER_NOT_READY("012", "Google Pay launcher not initialized", "Initialize the launcher before use"),
    NOT_ACTIVITY_RESULT_CALLER("013", "Invalid activity type", "Host Activity must extend FlutterFragmentActivity or ComponentActivity"),
    INIT_TOO_LATE("014", "Initialization failed", "Initialize launcher before Activity.STARTED"),
    CHECK_AVAILABILITY_FAILED("015", "Check availability failed", "Failed to check Google Pay availability"),

    // Unknown Errors (900-999)
    UNKNOWN_ERROR("900", "Unknown error", "An unknown error occurred");

    private final String code;
    private final String title;
    private final String description;

    MFErrorCodes(String code, String title, String description) {
        this.code = code;
        this.title = title;
        this.description = description;
    }

    public String getCode() {
        return code;
    }

    public String getUserMessage() {
        return title + ": " + description;
    }
}
