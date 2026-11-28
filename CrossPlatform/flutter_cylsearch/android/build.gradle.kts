// The Android side of flutter_cylsearch. It depends on the `cylsearch` module of android/merged by its coordinates
// (com.cyl.search:cylsearch); the app's settings.gradle.kts includes android/merged as a composite build that
// substitutes it (see example/android/settings.gradle.kts), so the core is built from source with its pinned
// sub-repositories. A composite build allows one Android Gradle plugin version: AGP 9.2.1 here, in android/merged and in React Native 0.88 (built-in
// Kotlin here, as flutter_cyltabbar needs; android/merged turns it off for its Kotlin-plugin modules).
group = "com.cyl.search.flutter_cylsearch"
version = "0.1.0"

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.2.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.cyl.search.flutter_cylsearch"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}

dependencies {
    implementation("com.cyl.search:cylsearch:0.1.0")
    implementation("androidx.appcompat:appcompat:1.7.0")
}
