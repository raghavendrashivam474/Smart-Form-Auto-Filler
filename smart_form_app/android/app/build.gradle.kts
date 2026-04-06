// ===================================
// ADDED THIS AT THE TOP
// ===================================
import java.util.Properties
import java.io.FileInputStream

// In android/build.gradle.kts
plugins {
    id("com.android.application") version "8.2.0" apply false // Keep this from our last attempt
    // CHANGE THE VERSION ON THE LINE BELOW
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false 
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

// ===================================
// ADDED THIS BLOCK
// ===================================
val keyPropertiesFile = rootProject.file("android/key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.example.smart_form_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_form_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ===================================
    // ADDED THIS BLOCK
    // ===================================
    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(keyProperties["storeFile"] as String)
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // ===================================
            // CHANGED THIS LINE
            // ===================================
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}