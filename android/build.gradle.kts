// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.0")
    }
}

plugins {
    base
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

// Redirect build output (optional, safe for CI/monorepo)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val subBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subBuildDir)

    // Apply common configuration after evaluation when plugins are available
    afterEvaluate {
        // Namespace injection for library modules
        if (project.plugins.hasPlugin("com.android.library")) {
            project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let { android ->
                android.namespace = "com.example.photon.${project.name}"
            }
        }

        // Java toolchain for Java-only modules
        if (project.plugins.hasPlugin("java")) {
            project.extensions.getByType(JavaPluginExtension::class.java).toolchain {
                languageVersion.set(JavaLanguageVersion.of(17))
            }
        }

        // Kotlin target setup
        if (project.plugins.hasPlugin("org.jetbrains.kotlin.jvm") ||
            project.plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                    freeCompilerArgs = freeCompilerArgs + listOf("-Xjvm-default=all", "-Xskip-prerelease-check")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}