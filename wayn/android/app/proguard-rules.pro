# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Stripe
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Mapbox
-keep class com.mapbox.** { *; }
-keep class com.mapbox.mapboxsdk.** { *; }
-dontwarn com.mapbox.**

# Agora
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# Twilio
-keep class com.twilio.** { *; }
-dontwarn com.twilio.**

# Background Location
-keep class com.example.background_location.** { *; }

# Hive
-keep class com.hive.** { *; }
-keep class hive.** { *; }

# Keep all native methods, their classes and any classes in their descriptors
-keepclasseswithmembers,includedescriptorclasses class * {
    native <methods>;
}

# Play Core
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**