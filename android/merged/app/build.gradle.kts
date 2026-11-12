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
}

dependencies {
    implementation(project(":cyltabbar"))
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
}
