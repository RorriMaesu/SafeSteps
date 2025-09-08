package expo.modules.gradle

import org.gradle.api.Plugin
import org.gradle.api.Project

class ExpoModuleGradlePlugin implements Plugin<Project> {
  void apply(Project project) {
    // Apply Kotlin Android if available and not yet applied
    try {
      if (!project.plugins.hasPlugin('org.jetbrains.kotlin.android') && !project.plugins.hasPlugin('kotlin-android')) {
        project.plugins.apply('org.jetbrains.kotlin.android')
      }
    } catch (Throwable ignored) {
      try { project.plugins.apply('kotlin-android') } catch (Throwable ignored2) {}
    }

    // Configure Android defaults akin to expo-module-gradle-plugin
    project.plugins.withId('com.android.library') { p ->
      def android = project.extensions.findByName('android')
      if (android != null) {
        def rootExt = project.rootProject.ext
        def compileSdk = rootExt.has('compileSdkVersion') ? rootExt.compileSdkVersion : 34
        def minSdk = rootExt.has('minSdkVersion') ? rootExt.minSdkVersion : 23
        def targetSdk = rootExt.has('targetSdkVersion') ? rootExt.targetSdkVersion : 34

        try { android.compileSdkVersion compileSdk } catch (Throwable ignored) { try { android.compileSdk = compileSdk } catch (Throwable ignored2) {} }
        android.defaultConfig { 
          try { minSdkVersion minSdk } catch (Throwable ignored) { minSdk = minSdk }
          try { targetSdkVersion targetSdk } catch (Throwable ignored) { targetSdk = targetSdk }
        }

        // Lint DSL varies across AGP
        try { android.lintOptions { abortOnError false } } catch (Throwable ignored) {
          try { android.lint { abortOnError = false } } catch (Throwable ignored2) {}
        }

        // Ensure publishing singleVariant exists for AAR components
        try {
          android.publishing { singleVariant('release') { withSourcesJar() } }
        } catch (Throwable ignored) {}
      }
    }

    // Provide kotlinVersion getter similar to Expo plugin
    project.ext.kotlinVersion = {
      def rootExt = project.rootProject.ext
      return rootExt.has('kotlinVersion') ? rootExt.get('kotlinVersion') : '1.9.23'
    }

    // Add core dependencies expected by Expo modules
    project.afterEvaluate {
      try {
        project.dependencies { deps ->
          // Avoids cyclic dependency if already in core
          if (!project.name.startsWith('expo-modules-core')) {
            implementation project.project(':expo-modules-core')
          }
          implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:${project.ext.kotlinVersion()}"
          implementation "org.jetbrains.kotlin:kotlin-reflect:${project.ext.kotlinVersion()}"
        }
      } catch (Throwable ignored) {}
    }

    // Apply maven-publish and wire up release publication from components.release
    try { project.plugins.apply('maven-publish') } catch (Throwable ignored) {}
    project.afterEvaluate {
      try {
        project.extensions.configure(org.gradle.api.publish.PublishingExtension) { pub ->
          pub.publications { container ->
            if (!container.findByName('release')) {
              container.create('release', org.gradle.api.publish.maven.MavenPublication) { m ->
                try { from project.components.release } catch (Throwable ignored) {}
              }
            }
          }
        }
      } catch (Throwable ignored) {}
    }

    project.logger.lifecycle("Applied expo-module-gradle-plugin defaults to ${project.path}")
  }
}
