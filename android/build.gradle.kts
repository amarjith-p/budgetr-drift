allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        val androidExtension = project.extensions.findByName("android") as? com.android.build.gradle.LibraryExtension
        if (androidExtension != null) {
            // 1. Inject missing namespaces for older plugins
            if (androidExtension.namespace == null) {
                androidExtension.namespace = "com.amarjith.budgetr." + project.name.replace("-", "_")
            }
            
            // 2. Force Java 17 on the plugin's internal Android configurations
            androidExtension.compileOptions {
                sourceCompatibility = org.gradle.api.JavaVersion.VERSION_17
                targetCompatibility = org.gradle.api.JavaVersion.VERSION_17
            }
        }
        
        // 3. MOVED INSIDE AFTER-EVALUATE: Force Kotlin & Java compilers to 17
        // This guarantees we override workmanager's hardcoded settings
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}