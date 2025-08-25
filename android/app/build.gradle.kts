plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.coffee_tracker"
    compileSdk = flutter.compileSdkVersion

    // Dynamically use the highest available NDK version
    val ndkDir = File("${System.getenv("ANDROID_HOME")}/ndk")
    if (ndkDir.exists()) {
        val availableNdks = ndkDir.listFiles()?.filter { it.isDirectory }?.map { it.name }?.sorted()
        val highestNdk = availableNdks?.lastOrNull()
        if (highestNdk != null) {
            ndkVersion = highestNdk
        } else {
            ndkVersion = flutter.ndkVersion  // fallback
        }
    } else {
        ndkVersion = flutter.ndkVersion  // fallback
    }
   
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.coffee_tracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

     externalNativeBuild {
        cmake {
            // Set the path to your CMake version here
            version = "4.1.0"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.biometric:biometric-ktx:1.4.0-alpha02")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.fragment:fragment:1.8.9")
}