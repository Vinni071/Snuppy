import org.jetbrains.kotlin.gradle.dsl.JvmTarget

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
        outputs.dir(jniLibsDir)

        doLast {
            val androidHome =
                System.getenv("ANDROID_HOME")
                    ?: System.getenv("ANDROID_SDK_ROOT")
                    ?: error("ANDROID_HOME or ANDROID_SDK_ROOT must be set")
            val ndkHome = file("$androidHome/ndk/27.0.12077973")
            val ndkBin = ndkHome.resolve("toolchains/llvm/prebuilt/linux-x86_64/bin")
            check(ndkBin.isDirectory) { "Android NDK toolchain not found at $ndkBin" }

            rustTargets.forEach { (target, _, clang) ->
                exec {
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
                    commandLine("cargo", "build", "--release", "--target", target)
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
    ndkVersion = "27.0.12077973"

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
        versionCode = flutter.versionCode()
        versionName = flutter.versionName()
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
