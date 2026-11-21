plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.kotlin.kapt) apply false
}

// CollectionViewClassifyMenu's library (:classifymenu) depends on the Maven coordinate of CYLTabBarController's
// animated icon + title component; this build compiles it from the pinned checkout (:cylanimateditem, settings.gradle.kts).
subprojects {
    configurations.configureEach {
        resolutionStrategy.dependencySubstitution {
            substitute(module("io.github.chenyilong:cyltabbarcontroller-animateditem")).using(project(":cylanimateditem"))
        }
    }
}
