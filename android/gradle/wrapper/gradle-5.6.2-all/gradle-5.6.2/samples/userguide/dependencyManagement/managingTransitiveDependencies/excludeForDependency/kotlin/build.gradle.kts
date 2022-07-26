plugins {
    java
}

repositories {
    mavenCentral()
}

// tag::exclude-transitive-dependencies[]
dependencies {
    implementation("log4j:log4j:1.2.15") {
        exclude(group = "javax.jms", module = "jms")
        exclude(group = "com.sun.jdmk", module = "jmxtools")
        exclude(group = "com.sun.jmx", module = "jmxri")
    }
}
// end::exclude-transitive-dependencies[]

tasks.register<Copy>("copyLibs") {
    from(configurations.compileClasspath)
    into("$buildDir/libs")
}
