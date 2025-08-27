plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Read key.properties (android/key.properties)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (!keystorePropertiesFile.exists()) {
    throw GradleException("key.properties bulunamadı: ${keystorePropertiesFile.absolutePath}")
}

keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    namespace = "com.litusware.linguess"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.litusware.linguess"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        // pubspec.yaml -> version: 1.0.0+1
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val alias = (keystoreProperties["keyAlias"] as String?) ?: throw GradleException("keyAlias boş")
            val keyPass = (keystoreProperties["keyPassword"] as String?) ?: throw GradleException("keyPassword boş")
            val storePass = (keystoreProperties["storePassword"] as String?) ?: throw GradleException("storePassword boş")
            val storePath = (keystoreProperties["storeFile"] as String?) ?: throw GradleException("storeFile boş")

            keyAlias = alias
            keyPassword = keyPass
            storePassword = storePass

            val f = file(storePath) // path app modülüne göre çözümlenir
            if (!f.exists()) {
                throw GradleException("Keystore bulunamadı: ${f.absolutePath}")
            }
            storeFile = f
        }
    }

    buildTypes {
        release {
            // Now using release signing instead of debug
            signingConfig = signingConfigs.getByName("release")

            // Closed for first version
            isMinifyEnabled = false
            isShrinkResources = false

            // If want to open it in the future:
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
        debug {
            // Default debug signing is sufficient
        }
    }
}

flutter {
    source = "../.."
}
