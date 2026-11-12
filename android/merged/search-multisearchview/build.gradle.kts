// iammert/MultiSearchView (Kotlin, Apache 2.0): the sources in android/iammert-MultiSearchView/multisearchviewlib.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.kapt)
}

android {
    namespace = "com.iammert.library.ui.multisearchviewlib"
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
            java.srcDirs("../../iammert-MultiSearchView/multisearchviewlib/src/main/java")
            res.srcDirs("../../iammert-MultiSearchView/multisearchviewlib/src/main/res")
        }
    }
}

dependencies {
    api(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
    // Its upstream build also declared com.daasuu:EasingInterpolator (jcenter only), which no source uses.
}
