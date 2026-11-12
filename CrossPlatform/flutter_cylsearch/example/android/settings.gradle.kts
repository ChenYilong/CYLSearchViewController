pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// CYLSearchViewController's Android core (android/merged, module `cylsearch`) built from source: the plugin asks for
// com.cyl.search:cylsearch and this composite build substitutes the module, with its sub-repositories pinned by
// commit in android/merged/gradle.properties.
includeBuild("../../../../android/merged") {
    dependencySubstitution {
        substitute(module("com.cyl.search:cylsearch")).using(project(":cylsearch"))
    }
}
