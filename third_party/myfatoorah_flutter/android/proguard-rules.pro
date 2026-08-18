-dontwarn org.slf4j.impl.**
-dontwarn java.lang.invoke.StringConcatFactory
-dontwarn com.google.android.play.core.**
-dontwarn android.content.res.**

-keep class org.xmlpull.** { *; }
-keepclassmembers class org.xmlpull.** { *; }

-keepattributes *Annotation*
-keep class * { *; }
#-keepclassmembers class * { *; }
#-dontwarn *


# Keep MyFatoorah SDK and Flutter components
-keep class com.myfatoorah.sdk.** { *; }
-keep class com.myfatoorah.** { *; }
-keep class com.myfatoorahflutter.** { *; }
-keep class io.flutter.** { *; }

# Keep Android and AndroidX components
-keep class androidx.** { *; }
-keep class android.** { *; }
-keep class com.google.** { *; }
-keep class org.apache.http.** { *; }