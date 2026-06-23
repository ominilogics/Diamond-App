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
    afterEvaluate {
        project.extensions.findByName("android")?.let { androidExt ->
            val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" }
            val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
            if (setNamespace != null && getNamespace != null) {
                val currentNamespace = getNamespace.invoke(androidExt) as? String
                if (currentNamespace == null || currentNamespace.isEmpty()) {
                    val newNamespace = "${project.group}.${project.name}".replace("-", "_")
                    setNamespace.invoke(androidExt, newNamespace)
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
