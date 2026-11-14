// An independent implementation of android-cjj/MaterialSearchView's sample behavior (that project has no license).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.search.reveal"
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

    sourceSets {
        getByName("main") {
            java.srcDirs("../../android-cjj-MaterialSearchView/app/src/main/java")
            res.srcDirs("../../android-cjj-MaterialSearchView/app/src/main/res")
        }
    }
}

dependencies {
    implementation(libs.material)
    implementation(libs.androidx.cardview)
}
