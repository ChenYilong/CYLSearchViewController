// The MultiSearchView sample (Kotlin, Apache 2.0): android/iammert-MultiSearchView/app.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.kapt)
}

android {
    namespace = "com.iammert.library.ui.multisearchview"
    compileSdk = 35

    defaultConfig {
        minSdk = 23
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

    sourceSets {
        getByName("main") {
            java.srcDirs("../../iammert-MultiSearchView/app/src/main/java")
            res.srcDirs("../../iammert-MultiSearchView/app/src/main/res")
        }
    }
}

dependencies {
    implementation(project(":search-multisearchview"))
    implementation(libs.androidx.appcompat)
}
