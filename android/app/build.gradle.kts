import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.gradle.process.ExecOperations
import java.util.Properties
import javax.inject.Inject

abstract class RustBuildServices {
    @get:Inject abstract val execOperations: ExecOperations
}

val rustNdkVersion = flutter.ndkVersion
val rustBuildServices = objects.newInstance(RustBuildServices::class.java)

val rustTargets =
    listOf(
        Triple("aarch64-linux-android", "arm64-v8a", "aarch64-linux-android21-clang"),
        Triple("armv7-linux-androideabi", "armeabi-v7a", "armv7a-linux-androideabi21-clang"),
        Triple("x86_64-linux-android", "x86_64", "x86_64-linux-android21-clang"),
    )

val buildRustAndroid =
    tasks.register("buildRustAndroid") {
        val rustProjectDir = rootProject.projectDir.resolve("../rust_core").canonicalFile
        val jniLibsDir = layout.buildDirectory.dir("rustJniLibs")
        inputs.dir(rustProjectDir.resolve("src"))
        inputs.file(rustProjectDir.resolve("Cargo.toml"))
        inputs.file(rustProjectDir.resolve("Cargo.lock"))
        inputs.property("ndkVersion", rustNdkVersion)
        outputs.dir(jniLibsDir)

        doLast {
            val sdkProperties = Properties().apply {
                val localProperties = rootProject.file("local.properties")
                if (localProperties.isFile) localProperties.inputStream().use { load(it) }
            }
            val androidHome =
                sdkProperties.getProperty("sdk.dir")
                    ?: System.getenv("ANDROID_HOME")
                    ?: System.getenv("ANDROID_SDK_ROOT")
                    ?: error("Set sdk.dir in local.properties, ANDROID_HOME, or ANDROID_SDK_ROOT")
            val ndkHome = file("$androidHome/ndk/$rustNdkVersion")
            val ndkBin = ndkHome.resolve("toolchains/llvm/prebuilt/linux-x86_64/bin")
            check(ndkBin.isDirectory) { "Android NDK toolchain not found at $ndkBin" }

            rustTargets.forEach { (target, _, clang) ->
                rustBuildServices.execOperations.exec {
                    workingDir = rustProjectDir
                    environment("PATH", "$ndkBin:${System.getenv("PATH")}")
                    environment(
                        "CARGO_TARGET_${target.uppercase().replace('-', '_')}_LINKER",
                        ndkBin.resolve(clang).absolutePath,
                    )
                    environment(
                        "CC_${target.replace('-', '_')}",
                        ndkBin.resolve(clang).absolutePath,
                    )
                    commandLine("cargo", "build", "--release", "--lib", "--target", target)
                }
            }

            rustTargets.forEach { (target, abi, _) ->
                copy {
                    from(rustProjectDir.resolve("target/$target/release/libide_engine.so"))
                    into(jniLibsDir.get().asFile.resolve(abi))
                }
            }
        }
    }

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ide.ide"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = rustNdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ide.ide"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    sourceSets {
        getByName("main") {
            jniLibs.srcDir(layout.buildDirectory.dir("rustJniLibs"))
        }
    }
}

flutter {
    source = "../.."
}

tasks.matching { it.name == "preBuild" }.configureEach {
    dependsOn(buildRustAndroid)
}
