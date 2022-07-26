// tag::use-war-plugin[]
// tag::use-gretty-plugin[]
plugins {
    // end::use-gretty-plugin[]
    war
// end::use-war-plugin[]
// tag::use-gretty-plugin[]
    id("org.gretty") version "2.2.0"
// tag::use-war-plugin[]
}
// end::use-war-plugin[]
// end::use-gretty-plugin[]

repositories {
    jcenter()
}

dependencies {
    implementation(group = "commons-io", name = "commons-io", version = "1.4")
    implementation(group = "log4j", name = "log4j", version = "1.2.15", ext = "jar")
}

gretty {
    httpPort = 8080
}
