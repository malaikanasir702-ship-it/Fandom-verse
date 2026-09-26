import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin for Firebase
    id("com.google.gms.google-services")
}

// ── Load key.properties ────────────────────────────────────────────────────
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.fandomverse.fandom_verse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // ── Signing Configs ────────────────────────────────────────────────────
    signingConfigs {
        create("release") {
            keyAlias     = keyProperties["keyAlias"]     as String? ?: "androiddebugkey"
            keyPassword  = keyProperties["keyPassword"]  as String? ?: "android"
            storeFile    = file(keyProperties["storeFile"] as String? ?: (System.getProperty("user.home") + "/.android/debug.keystore"))
            storePassword = keyProperties["storePassword"] as String? ?: "android"
        }
    }

    defaultConfig {
        applicationId = "com.fandomverse.fandom_verse"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            // Debug keeps its own keystore for SHA-1 fingerprint
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
