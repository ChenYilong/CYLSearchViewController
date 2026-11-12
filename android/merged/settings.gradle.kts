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

// CYLTabBarController's Android library is not on Maven, and Gradle cannot pin a git dependency to a commit. So the
// commit in gradle.properties (`cyl.tabbar.commit`, the newest commit on any branch from
// CYLTabBarController/scripts/latest-cyl-commit.sh) is checked out into .cyl-deps/ and its two library modules are
// built from source. `-Pcyl.tabbar.dir=<checkout>` (or CYL_TABBAR_DIR) uses a local checkout instead.
val cylTabBarCommit = providers.gradleProperty("cyl.tabbar.commit").get()
val cylTabBarDir: File = (providers.gradleProperty("cyl.tabbar.dir").orNull ?: System.getenv("CYL_TABBAR_DIR"))
    ?.let { File(it) }
    ?: File(settingsDir, ".cyl-deps/CYLTabBarController").also { dir ->
        fun git(vararg args: String) {
            val process = ProcessBuilder(listOf("git") + args).directory(dir.parentFile).inheritIO().start()
            check(process.waitFor() == 0) { "git ${args.joinToString(" ")} failed" }
        }
        dir.parentFile.mkdirs()
        if (!File(dir, ".git").exists()) {
            git("clone", "--filter=blob:none", "--no-checkout", "https://github.com/ChenYilong/CYLTabBarController.git", dir.name)
        }
        val head = ProcessBuilder("git", "rev-parse", "HEAD").directory(dir).start().inputStream.bufferedReader().readText().trim()
        if (head != cylTabBarCommit) {
            git("-C", dir.name, "fetch", "--filter=blob:none", "origin", cylTabBarCommit)
            git("-C", dir.name, "checkout", "--force", cylTabBarCommit)
        }
    }
include(":tabpages", ":cyltabbar")
project(":tabpages").projectDir = File(cylTabBarDir, "Example-Android/tabpages")
project(":cyltabbar").projectDir = File(cylTabBarDir, "Example-Android/cyltabbar")

// The five translated projects, as library modules (each keeps its own resources and package).
include(":search-lapism", ":search-materialsearchview", ":search-multisearchview")
// The upstream samples that run as activities.
include(":sample-materialsearchview", ":sample-multisearchview", ":sample-yechaoa", ":sample-reveal")
// The CYL API that matches the iOS library, and the example app.
include(":cylsearch", ":app")
