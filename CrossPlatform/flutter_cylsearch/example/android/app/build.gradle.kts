plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Rive tab icons: CYLTabBarController's icons.riv, fetched at build time from the commit flutter_cyltabbar is pinned to in
// pubspec.yaml (not committed here: the file has no licence of its own; see CYLTabBarController
// Example-SwiftUI-Rive/README.md, "Source and license"). It goes to generated assets, read by name ("icons.riv").
val cylTabBarCommit: String = Regex("ref: ([0-9a-f]{40})").find(file("../../pubspec.yaml").readText())?.groupValues?.get(1)
    ?: error("flutter_cyltabbar ref not found in pubspec.yaml")
val cylRiveAssets = layout.buildDirectory.dir("generated/cyl-rive-assets")
val fetchCylRiveIcons by tasks.registering {
    val output = cylRiveAssets.map { it.file("icons.riv") }
    inputs.property("commit", cylTabBarCommit)
    outputs.file(output)
    doLast {
        val target = output.get().asFile
        target.parentFile.mkdirs()
        val url = "https://raw.githubusercontent.com/ChenYilong/CYLTabBarController/$cylTabBarCommit/" +
            "Example-SwiftUI-Rive/AnimatedApp/RiveAssets/icons.riv"
        uri(url).toURL().openStream().use { input -> target.outputStream().use { input.copyTo(it) } }
    }
}

android {
    namespace = "com.cyl.search.flutter_cylsearch_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // The example's own application ID.
        applicationId = "com.cyl.search.flutter_cylsearch_example"
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

    sourceSets {
        getByName("main") {
            // A plain directory (AGP 9 refuses a Provider here); fetchCylRiveIcons runs before preBuild.
            assets.srcDir(cylRiveAssets.get().asFile)
        }
    }

    buildTypes {
        release {
            // The example signs release builds with the debug key; it is not published.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

dependencies {
    // CYLTabBarController plays SVGA tab icons through SVGAPlayer-Android, found by reflection.
    implementation("com.github.yyued:SVGAPlayer-Android:2.6.1")
    // ... and Rive tab icons through rive-android (it calls Rive.init itself).
    implementation("app.rive:rive-android:10.3.0")
}

tasks.named("preBuild") {
    dependsOn(fetchCylRiveIcons)
}
