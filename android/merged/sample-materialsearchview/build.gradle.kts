// The MaterialSearchView sample translated to Kotlin: its activities, opened from the example's MaterialSearchView tab.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.miguelcatalan.materialsearchview.sample"
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
            java.srcDirs("../../MiguelCatalan-MaterialSearchView/sample/src/main/java")
            res.srcDirs("../../MiguelCatalan-MaterialSearchView/sample/src/main/res", "src/main/res")
        }
    }
}

dependencies {
    implementation(project(":search-materialsearchview"))
    implementation(libs.material)
    implementation(libs.androidx.viewpager)
    implementation(libs.androidx.activity.ktx)
}
