// Define versions in a central place for consistency
val kotlinVersion = "1.8.22"
val agpVersion = "7.4.2" // Android Gradle Plugin version

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Use the versions defined above
        classpath("com.android.tools.build:gradle:$agpVersion")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = File("../build")
subprojects {
    project.buildDir = File("${rootProject.buildDir}/${project.name}")
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}