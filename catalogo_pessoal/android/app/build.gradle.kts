import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releasePropertiesFile = rootProject.file("key.properties")
val releaseProperties = Properties().apply {
    if (releasePropertiesFile.exists()) {
        releasePropertiesFile.inputStream().use { load(it) }
    }
}
val releaseStorePath = System.getenv("ANDROID_KEYSTORE_PATH")
    ?: releaseProperties.getProperty("storeFile")
val releaseStorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
    ?: releaseProperties.getProperty("storePassword")
val releaseKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
    ?: releaseProperties.getProperty("keyAlias")
val releaseKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")
    ?: releaseProperties.getProperty("keyPassword")
val hasReleaseSigning = listOf(
    releaseStorePath,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.example.catalogo_pessoal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.catalogo_pessoal"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseSigning) {
        signingConfigs.create("release") {
            storeFile = file(requireNotNull(releaseStorePath))
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        release {
            // A debug key keeps local release builds installable. Set all four
            // environment variables to sign a distributable release.
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
