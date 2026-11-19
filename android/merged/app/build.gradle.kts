// The example app: the iOS example ported to Android, with CYLTabBarController's tab bar from a configuration file
// (pinned commit, settings.gradle.kts).
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    // MultiSearchView uses data binding: the app module must generate DataBinderMapperImpl, or inflating the view
    // fails with NoClassDefFoundError (upstream iammert/MultiSearchView issue #10).
    alias(libs.plugins.kotlin.kapt)
}

android {
    namespace = "com.cyl.search.example"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.cyl.search.example"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        dataBinding = true
    }

    // The example's unit tests read its assets (the contact tags bundle).
    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

dependencies {
    implementation(project(":cyltabbar"))
    // CYLTabBarController plays SVGA tab icons through SVGAPlayer-Android, found by reflection.
    implementation(libs.svgaplayer)
    // The animation libraries the example plays, never in the core (docs/animated-icon-component.md): the shared
    // animated icon + title engine (cyltabbarcontroller-animateditem, under CYLTagButton and CYLTableViewPlaceHolder's
    // placeholders) reaches Lottie and SVGAPlayer above by reflection (iOS: the CYLAnimatedItem/LottieSwift and /SVGA
    // subspecs).
    implementation(libs.lottie)
    implementation(project(":cylsearch"))
    implementation(project(":sample-materialsearchview"))
    implementation(project(":sample-multisearchview"))
    implementation(project(":sample-yechaoa"))
    implementation(project(":sample-reveal"))
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.fragment.ktx)
    implementation(libs.androidx.recyclerview)
    implementation(libs.material)
    implementation(libs.androidx.swiperefreshlayout)
    implementation(libs.androidx.activity.ktx)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}
