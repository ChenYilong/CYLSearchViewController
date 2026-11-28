// MiguelCatalan/MaterialSearchView translated to Kotlin (Apache 2.0): the sources in android/MiguelCatalan-MaterialSearchView/library.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.miguelcatalan.materialsearchview"
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
            java.srcDirs("../../MiguelCatalan-MaterialSearchView/library/src/main/java")
            res.srcDirs("../../MiguelCatalan-MaterialSearchView/library/src/main/res")
        }
    }
}

dependencies {
    api(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
}
