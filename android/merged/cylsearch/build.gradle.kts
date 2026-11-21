// The CYL search API that matches the iOS library (docs/android-api-alignment.md, docs/search-core-merge.md).
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    `maven-publish`
}

android {
    // Published as a Maven artifact (docs/licenses.md): the release AAR with its sources.
    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
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
    // No animation engine in the core (docs/animated-icon-component.md): the placeholders' Lottie animator
    // (through :cylanimateditem) and the animation libraries are added by the app; the still images show otherwise.
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

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                from(components["release"])
                groupId = "com.cyl"
                artifactId = "cylsearch"
                // The version of the iOS pod (CYLSearchViewController.podspec).
                version = "0.1.0"
                // The AAR carries META-INF/cylsearch/LICENSE (MIT) and the notices of the icons it ships
                // (LICENSE.material-design-icons, Apache-2.0); AGENTS.md, "Licenses in published packages".
                pom {
                    name.set("CYLSearchViewController for Android")
                    description.set("The CYL search core for Android: CYLSearchBarView, CYLSearchView and CYLSearchResources, with the iOS API.")
                    url.set("https://github.com/ChenYilong/CYLSearchViewController")
                    licenses {
                        license {
                            name.set("MIT License")
                            url.set("https://opensource.org/licenses/MIT")
                        }
                        license {
                            name.set("The Apache License, Version 2.0")
                            url.set("https://www.apache.org/licenses/LICENSE-2.0.txt")
                            comments.set("The Material Design icons in the resources (META-INF/cylsearch/LICENSE.material-design-icons)")
                        }
                    }
                    scm {
                        url.set("https://github.com/ChenYilong/CYLSearchViewController")
                    }
                    // CYLTableViewPlaceHolder's modules are included from its checkout (settings.gradle.kts), but their
                    // publishing is set up in its own root build, which this build does not evaluate; so the POM would
                    // name them by this build's defaults. These are the coordinates its owner chose (its
                    // docs/Android-Port.md, "Maven publication coordinates").
                    withXml {
                        val coordinates = mapOf(
                            "placeholder" to "cyltableviewplaceholder",
                            "placeholder-refresh" to "cyltableviewplaceholder-refresh",
                        )
                        val dependencies = asNode().children()
                            .filterIsInstance<groovy.util.Node>()
                            .firstOrNull { it.name().toString().endsWith("dependencies") } ?: return@withXml
                        dependencies.children().filterIsInstance<groovy.util.Node>().forEach { dependency ->
                            fun field(name: String) = dependency.children().filterIsInstance<groovy.util.Node>()
                                .first { it.name().toString().endsWith(name) }
                            val artifactId = coordinates[field("artifactId").text()] ?: return@forEach
                            field("groupId").setValue("io.github.chenyilong")
                            field("artifactId").setValue(artifactId)
                            field("version").setValue("0.1.0")
                        }
                    }
                }
            }
        }
        repositories {
            // `publishReleasePublicationToBuildRepository` checks the artifact locally (build/repo); a Maven Central
            // repository with credentials is added here for a release.
            maven {
                name = "build"
                url = uri(layout.buildDirectory.dir("repo"))
            }
        }
    }
}
