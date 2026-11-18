// The merged Android project of CYLSearchViewController (docs/android-and-cross-platform.md): the five search projects
// translated in ../, the CYL search API that matches iOS, and one example app with CYLTabBarController's tab bar.
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        // SVGAPlayer-Android (com.github.yyued) is only on JitPack: the SVGA tab icons (CYLTabBarController issue #415).
        maven("https://jitpack.io") { content { includeGroup("com.github.yyued") } }
    }
}
rootProject.name = "CYLSearchAndroid"

// CYLTabBarController's, CollectionViewClassifyMenu's and CYLTableViewPlaceHolder's Android libraries are not on Maven, and Gradle cannot pin a git
// dependency to a commit. So the commits in gradle.properties (`cyl.tabbar.commit`, `cyl.classifymenu.commit`: the
// newest commit on any branch of each repository) are checked out into .cyl-deps/ and their library modules are built
// from source. `-Pcyl.tabbar.dir=<checkout>` / `-Pcyl.classifymenu.dir=<checkout>` (or CYL_TABBAR_DIR /
// CYL_CLASSIFYMENU_DIR) use a local checkout instead, for development only.
fun pinnedCheckout(name: String, url: String, commitProperty: String, dirProperty: String, environment: String): File {
    val commit = providers.gradleProperty(commitProperty).get()
    (providers.gradleProperty(dirProperty).orNull ?: System.getenv(environment))?.let { return File(it) }
    val dir = File(settingsDir, ".cyl-deps/$name")
    // Each step has a time limit and one retry: a checkout of the partial clone downloads its blobs lazily and once hung
    // for 28 minutes on Windows (2026-11-19, OneDrive syncing the folder); long paths are on for deep example folders.
    fun git(vararg args: String) {
        repeat(2) { attempt ->
            val process = ProcessBuilder(listOf("git", "-c", "core.longpaths=true") + args).directory(dir.parentFile).inheritIO().start()
            if (process.waitFor(10, java.util.concurrent.TimeUnit.MINUTES)) {
                check(process.exitValue() == 0) { "git ${args.joinToString(" ")} failed" }
                return
            }
            process.destroyForcibly()
            File(dir, ".git/index.lock").delete()
            check(attempt == 0) { "git ${args.joinToString(" ")} timed out twice" }
        }
    }
    dir.parentFile.mkdirs()
    if (!File(dir, ".git").exists()) {
        git("clone", "--filter=blob:none", "--no-checkout", url, dir.name)
    }
    val head = ProcessBuilder("git", "rev-parse", "HEAD").directory(dir).start().inputStream.bufferedReader().readText().trim()
    if (head != commit) {
        git("-C", dir.name, "fetch", "--filter=blob:none", "origin", commit)
        git("-C", dir.name, "checkout", "--force", commit)
    }
    return dir
}

val cylTabBarDir = pinnedCheckout("CYLTabBarController", "https://github.com/ChenYilong/CYLTabBarController.git",
    "cyl.tabbar.commit", "cyl.tabbar.dir", "CYL_TABBAR_DIR")
include(":tabpages", ":cylanimateditem", ":cyltabbar")
project(":tabpages").projectDir = File(cylTabBarDir, "Example-Android/tabpages")
// The shared animated icon + title component (CYLAnimatedItemView and the animation engine, no animation library):
// :cyltabbar depends on it, and CollectionViewClassifyMenu's CYLTagButton (the search bar items) subclasses it through
// the Maven coordinate io.github.chenyilong:cyltabbarcontroller-animateditem, substituted by this project in
// build.gradle.kts. Guide: https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Animated-Item.md
project(":cylanimateditem").projectDir = File(cylTabBarDir, "Example-Android/cylanimateditem")
project(":cyltabbar").projectDir = File(cylTabBarDir, "Example-Android/cyltabbar")

// CollectionViewClassifyMenu's merged Android library: the tag views of the tag suggestion style (CYLTagListView).
val cylClassifyMenuDir = pinnedCheckout("CollectionViewClassifyMenu", "https://github.com/ChenYilong/CollectionViewClassifyMenu.git",
    "cyl.classifymenu.commit", "cyl.classifymenu.dir", "CYL_CLASSIFYMENU_DIR")
include(":classifymenu")
project(":classifymenu").projectDir = File(cylClassifyMenuDir, "android/merged/library")

// CYLTableViewPlaceHolder's Android placeholder module: the empty search results placeholder (CYLPlaceholderStackView).
val cylPlaceholderDir = pinnedCheckout("CYLTableViewPlaceHolder", "https://github.com/ChenYilong/CYLTableViewPlaceHolder.git",
    "cyl.placeholder.commit", "cyl.placeholder.dir", "CYL_PLACEHOLDER_DIR")
include(":placeholder")
project(":placeholder").projectDir = File(cylPlaceholderDir, "android/placeholder")
// Its animations play through CYLTabBarController's :cylanimateditem engine (included above); since CYLTableViewPlaceHolder
// moved onto CYLAnimatedItem it has no Lottie module of its own: the app adds the Lottie library.
// Its pull-to-refresh (package com.cyl.refresh, depends on :placeholder only): CYLSearchView's refresh API calls it.
include(":placeholder-refresh")
project(":placeholder-refresh").projectDir = File(cylPlaceholderDir, "android/merged/library")

// The five translated projects, as library modules (each keeps its own resources and package).
include(":search-lapism", ":search-materialsearchview", ":search-multisearchview")
// The upstream samples that run as activities.
include(":sample-materialsearchview", ":sample-multisearchview", ":sample-yechaoa", ":sample-reveal")
// The CYL API that matches the iOS library, and the example app.
include(":cylsearch", ":app")
