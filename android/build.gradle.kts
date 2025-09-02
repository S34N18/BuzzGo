allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    val kotlinVersion by extra("1.7.10")
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:4.3.15")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Only set evaluation dependency on :app for projects that need it
    // This ensures proper ordering of configuration but avoids unnecessary dependencies
    // Skip for the app project itself to avoid circular dependency
    if (project.name != "app") {
        try {
            project.evaluationDependsOn(":app")
        } catch (e: Exception) {
            // If app project doesn't exist or other issues, continue without dependency
            logger.warn("Could not set evaluation dependency on :app for project ${project.name}: ${e.message}")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}