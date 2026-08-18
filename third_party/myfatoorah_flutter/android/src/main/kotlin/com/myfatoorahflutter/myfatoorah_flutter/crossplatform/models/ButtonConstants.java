package com.myfatoorahflutter.myfatoorah_flutter.crossplatform.models;

public final class ButtonConstants {
    private ButtonConstants() {
    }

    public @interface ButtonTheme {
        int DARK = 1;
        int LIGHT = 2;
    }

    public @interface ButtonType {
        int BUY = 1;
        int BOOK = 2;
        int CHECKOUT = 3;
        int DONATE = 4;
        int ORDER = 5;
        int PAY = 6;
        int SUBSCRIBE = 7;
        int PLAIN = 8;
    }
}