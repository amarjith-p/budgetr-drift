# Flutter Local Notifications Rules
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.gson.** { *; }

# Keep generic type signatures (Crucial for "Missing type parameter" error)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Prevent R8 from stripping the specific models used for scheduling
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }