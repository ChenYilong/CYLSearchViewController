// lapism/search (Kotlin, Apache 2.0): the sources in android/lapism-search, built as a library module.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.lapism.search"
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
            java.srcDirs("../../lapism-search/src/main/kotlin")
            res.srcDirs("../../lapism-search/src/main/res")
        }
    }
}

dependencies {
    api(libs.material)
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
}
