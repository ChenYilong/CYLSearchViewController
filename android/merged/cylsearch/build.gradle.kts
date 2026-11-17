// The CYL search API that matches the iOS library (docs/android-api-alignment.md, docs/search-core-merge.md).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.search"
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

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
            res.srcDirs("src/main/res")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }
}

dependencies {
    // CYLSearch is the only search kernel: it depends on no other search library (the sample modules that show the
    // upstream libraries keep their own dependencies).
    // The tag suggestion style (CYLSearchSuggestionStyle.Tags) uses CollectionViewClassifyMenu's CYLTagListView.
    api(project(":classifymenu"))
    // The empty search results placeholder (CYLSearchView.emptyResultsScenario) is CYLTableViewPlaceHolder's.
    api(project(":placeholder"))
    // Plays the placeholders' Lottie animations, the still image as the fallback (iOS depends on the Lottie subspec).
    api(project(":placeholder-lottie"))
    implementation(libs.androidx.appcompat)
    api(libs.androidx.fragment.ktx)
    api(libs.androidx.recyclerview)
    // The pull-to-refresh of CYLSearchView (refreshHandler, setRefreshHandler) is CYLTableViewPlaceHolder's CYLRefresh
    // (CYLRefreshLayout, CYLRefreshNormalHeader, cyl_header): its android/merged/library module, included by
    // settings.gradle.kts as `:placeholder-refresh` from the same pinned checkout as `:placeholder`.
    api(project(":placeholder-refresh"))
    implementation(libs.androidx.core.ktx)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}
