# Flutter basic rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep public class * extends io.flutter.embedding.android.FlutterActivity
-keep public class * extends io.flutter.embedding.android.FlutterFragmentActivity
-keep public class * implements io.flutter.plugin.common.PluginRegistry$PluginRegistrantCallback
-keep class io.flutter.util.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers enum * { *; }
-dontwarn io.flutter.**

# Preserve annotations
-keepattributes *Annotation*

# Preserve serialized class members
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    private void readObjectNoData();
}

# Ignore warnings
-dontnote
-dontwarn

# Gson rules
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*
-dontwarn com.google.gson.**

# Prevent obfuscation of Flutter-generated code
-keep class io.flutter.plugins.** { *; }
-keepclassmembers class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepclassmembers class io.flutter.embedding.** { *; }

