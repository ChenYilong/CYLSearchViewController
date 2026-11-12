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
    }
}
rootProject.name = "CYLSearchAndroid"

// CYLTabBarController's Android library and CollectionViewClassifyMenu's are not on Maven, and Gradle cannot pin a git
// dependency to a commit. So the commits in gradle.properties (`cyl.tabbar.commit`, `cyl.classifymenu.commit`: the
// newest commit on any branch of each repository) are checked out into .cyl-deps/ and their library modules are built
// from source. `-Pcyl.tabbar.dir=<checkout>` / `-Pcyl.classifymenu.dir=<checkout>` (or CYL_TABBAR_DIR /
// CYL_CLASSIFYMENU_DIR) use a local checkout instead, for development only.
fun pinnedCheckout(name: String, url: String, commitProperty: String, dirProperty: String, environment: String): File {
    val commit = providers.gradleProperty(commitProperty).get()
    (providers.gradleProperty(dirProperty).orNull ?: System.getenv(environment))?.let { return File(it) }
    val dir = File(settingsDir, ".cyl-deps/$name")
    fun git(vararg args: String) {
        val process = ProcessBuilder(listOf("git") + args).directory(dir.parentFile).inheritIO().start()
        check(process.waitFor() == 0) { "git ${args.joinToString(" ")} failed" }
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
include(":tabpages", ":cyltabbar")
project(":tabpages").projectDir = File(cylTabBarDir, "Example-Android/tabpages")
project(":cyltabbar").projectDir = File(cylTabBarDir, "Example-Android/cyltabbar")

// CollectionViewClassifyMenu's merged Android library: the tag views of the tag suggestion style (CYLTagListView).
val cylClassifyMenuDir = pinnedCheckout("CollectionViewClassifyMenu", "https://github.com/ChenYilong/CollectionViewClassifyMenu.git",
    "cyl.classifymenu.commit", "cyl.classifymenu.dir", "CYL_CLASSIFYMENU_DIR")
include(":classifymenu")
project(":classifymenu").projectDir = File(cylClassifyMenuDir, "android/merged/library")

// The five translated projects, as library modules (each keeps its own resources and package).
include(":search-lapism", ":search-materialsearchview", ":search-multisearchview")
// The upstream samples that run as activities.
include(":sample-materialsearchview", ":sample-multisearchview", ":sample-yechaoa", ":sample-reveal")
// The CYL API that matches the iOS library, and the example app.
include(":cylsearch", ":app")
