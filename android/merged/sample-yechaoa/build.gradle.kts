// The search screen of yechaoa/MaterialDesign (Kotlin, Apache 2.0).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.yechaoa.materialdesign"
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
        viewBinding = true
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("../../yechaoa-MaterialDesign/app/src/main/java")
            res.srcDirs("../../yechaoa-MaterialDesign/app/src/main/res", "src/main/res")
        }
    }
}

dependencies {
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
}
