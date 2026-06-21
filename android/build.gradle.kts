allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    plugins.withId("com.android.library") {
        val android = project.extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val currentNamespace = getNamespace.invoke(android)
                if (currentNamespace == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val cleanName = project.name.replace(Regex("[^a-zA-Z0-9_]"), "_")
                    val nameSpace = "com.hestandard.$cleanName"
                    setNamespace.invoke(android, nameSpace)
                    println("Injected namespace $nameSpace for project ${project.name}")
                }
            } catch (e: Exception) {
                println("Failed to inject namespace for ${project.name}: ${e.message}")
            }
        }
    }

    tasks.whenTaskAdded {
        if (name.contains("processDebugManifest") || name.contains("processReleaseManifest")) {
            doFirst {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    var content = manifestFile.readText(Charsets.UTF_8)
                    if (content.contains("package=")) {
                        content = content.replace(Regex("""package="[^"]*""""), "")
                        manifestFile.writeText(content, Charsets.UTF_8)
                        println("Successfully stripped package attribute from manifest for project ${project.name}")
                    }
                }
            }
        }
    }
}




tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
