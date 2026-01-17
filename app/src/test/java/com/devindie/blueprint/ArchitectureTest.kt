/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.devindie.blueprint

import com.tngtech.archunit.core.domain.JavaClasses
import com.tngtech.archunit.core.importer.ClassFileImporter
import com.tngtech.archunit.core.importer.ImportOption
import com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes
import com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses
import org.junit.Before
import org.junit.Test

/**
 * ArchUnit tests to enforce POM (Project Operating Manual) architecture boundaries.
 */
class ArchitectureTest {

    private lateinit var importedClasses: JavaClasses

    @Before
    fun setup() {
        importedClasses = ClassFileImporter()
            .withImportOption(ImportOption.DoNotIncludeTests())
            .withImportOption(ImportOption.DoNotIncludeJars())
            .importPackages("com.devindie.blueprint..")
    }

    @Test
    fun `ViewModels should not depend on NavController`() {
        noClasses()
            .that().haveSimpleNameEndingWith("ViewModel")
            .should().dependOnClassesThat().haveNameMatching(".*NavController.*")
            .because("ViewModels must not handle navigation directly")
            .allowEmptyShould(true)
            .check(importedClasses)
    }

    @Test
    fun `ViewModels should be annotated with HiltViewModel`() {
        classes()
            .that().haveSimpleNameEndingWith("ViewModel")
            .and().resideInAPackage("..ui..")
            .should().beAnnotatedWith("dagger.hilt.android.lifecycle.HiltViewModel")
            .because("All ViewModels must use Hilt for dependency injection")
            .allowEmptyShould(true)
            .check(importedClasses)
    }

    @Test
    fun `Data layer should not depend on UI layer`() {
        noClasses()
            .that().resideInAPackage("..data..")
            .should().dependOnClassesThat().resideInAPackage("..ui..")
            .because("Data layer must not depend on UI layer")
            .allowEmptyShould(true)
            .check(importedClasses)
    }

    @Test
    fun `DI modules should be properly annotated`() {
        classes()
            .that().resideInAPackage("..di..")
            .and().haveSimpleNameEndingWith("Module")
            .should().beAnnotatedWith("dagger.Module")
            .because("All DI modules must use Hilt @Module annotation")
            .allowEmptyShould(true)
            .check(importedClasses)
    }
}
