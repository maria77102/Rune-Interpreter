/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.tests

import com.google.inject.Inject
import com.regnosys.rosetta.tests.util.CodeGeneratorTestHelper
import com.regnosys.rosetta.tests.util.ModelHelper
import com.regnosys.rosetta.validation.RosettaIssueCodes
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static org.hamcrest.MatcherAssert.*
import static org.hamcrest.CoreMatchers.*

/**
 * A set of tests for all instances of RosettaExpression i.e. RosettaAdditiveExpression
 */
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class RosettaExpressionsTest {

	@Inject extension CodeGeneratorTestHelper
	@Inject extension ModelHelper
	@Inject extension ValidationTestHelper 
	
	
	@Test
	def void shouldParseQualifierWithAdditiveExpression() {
		'''
			class Test {
				one number (1..1);
				two number (1..1);
			}
			
			isProduct TestQualifier
				Test -> one + Test -> two = 42
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void shouldParseNoIssuesWhenDateSubtraction() {
		'''
			class Test {
				one date (1..1);
				two date (1..1);
			}
			
			isProduct TestQualifier
				Test -> one - Test -> two = 42
		'''.parseRosettaWithNoErrors.assertNoIssues
	}
	
	@Test
	def void shouldParseWithErrorWhenAddingDates() {
		'''
			class Test {
				one date (1..1);
				two date (1..1);
			}
			
			isProduct TestQualifier
				Test -> one + Test -> two = 42
		'''.parseRosetta.assertError(ROSETTA_BINARY_OPERATION, RosettaIssueCodes.TYPE_ERROR, "Incompatible types: cannot use operator '+' with date and date.")
	}
	
	/**
	 * The openjdk 11 compiler requires extra generics information for compilation. Eclipse compiler doesn't need this 
	 * so you will get a nice surprise when you build your generated code using javac compiler (Maven and IntelliJ).
	 */
	@Test
	def void shouldCodeGenerateWithMoreGenericsInformation() {
		val code = '''
			class Test {
				one date (1..1);
				two date (1..1);
			}
			
			isProduct TestQualifier
				Test -> one - Test -> two = 42
		'''.generateCode
		
		val qualifier = code.get(javaPackages.qualifyProduct.packageName + ".IsTestQualifier")
		assertThat(qualifier, containsString("MapperMaths.<BigDecimal, LocalDate, LocalDate>subtract"))
	}
	
	@Test
	def void shoudCodeGenerateAndCompileWhenSubtractingDates() {
		val code = '''
			class Test {
				one date (1..1);
				two date (1..1);
			}
			
			isProduct TestQualifier
				Test -> one - Test -> two = 42
		'''.generateCode
		
		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileWhenAddingNumbers() {
		val code = '''
			class Test {
				one number (1..1);
				two int (1..1);
			}
			
			isProduct TestQualifier
				Test -> one + Test -> two = 42
		'''.generateCode

		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessingMetaSimple() {
		val code = '''
			metaType reference string
			metaType scheme string
			metaType id string
			
			class Test {
				one string (1..1) scheme;
				two int (1..1);
			}
			
			isProduct TestQualifier
				Test -> one -> scheme = "scheme"
		'''.generateCode
		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessingMeta() {
		val code = '''
			metaType reference string
			metaType scheme string
			metaType id string
			
			class Test {
				one Foo (1..1) scheme;
				two int (1..1);
			}
			
			class Foo {
				one string (1..1) scheme;
				two int (1..1);
			}
			
			isProduct TestQualifier
				Test -> one -> scheme = "scheme"
		'''.generateCode

		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessingMetaWithGroup() {
		val code = '''
			metaType reference string
			metaType scheme string
			metaType id string
			
			class Test {
				one Foo (1..*) scheme;
				two int (1..1);
			}
			
			class Foo {
				one string (1..1) scheme;
				two int (1..1);
			}
			
			isProduct TestQualifier
				(Test -> one group by two) -> one = "scheme"
		'''.generateCode

		code.compileToClasses
	}
	
	@Test
	def void shoudCodeGenerateAndCompileAccessPastMeta() {
		val code = '''
			metaType reference string
			metaType scheme string
			metaType id string
			
			class Test {
				one Foo (1..1) scheme;
				two int (1..1);
			}
			
			class Foo {
				one string (1..1) scheme;
				two int (1..1);
			}
			
			isProduct TestQualifier
				Test -> one -> one = "scheme"
		'''.generateCode

		code.compileToClasses
	}
}
