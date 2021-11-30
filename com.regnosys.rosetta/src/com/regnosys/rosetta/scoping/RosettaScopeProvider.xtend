/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.util.RosettaFunctionExtensions
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalEnum
import com.regnosys.rosetta.rosetta.RosettaExternalEnumValue
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.RosettaGroupByExpression
import com.regnosys.rosetta.rosetta.RosettaGroupByFeatureCall
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.simple.AnnotationRef
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Condition
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.FunctionDispatch
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.Segment
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.types.RDataType
import com.regnosys.rosetta.types.REnumType
import com.regnosys.rosetta.types.RFeatureCallType
import com.regnosys.rosetta.types.RRecordType
import com.regnosys.rosetta.types.RType
import com.regnosys.rosetta.types.RosettaTypeProvider
import com.regnosys.rosetta.utils.RosettaConfigExtension
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.impl.AliasedEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider
import org.eclipse.xtext.scoping.impl.SimpleScope

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static com.regnosys.rosetta.rosetta.simple.SimplePackage.Literals.*
import com.regnosys.rosetta.rosetta.simple.ListOperation

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class RosettaScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	
	public val static LIB_NAMESPACE = 'com.rosetta.model'
	
	static Logger LOGGER = Logger.getLogger(RosettaScopeProvider)
	
	@Inject RosettaTypeProvider typeProvider
	@Inject extension RosettaExtensions
	@Inject extension RosettaConfigExtension configs
	@Inject extension RosettaFunctionExtensions

	override getScope(EObject context, EReference reference) {
		try {
			switch reference {
				case ROSETTA_GROUP_BY_EXPRESSION__ATTRIBUTE:
					if (context instanceof RosettaGroupByFeatureCall) {
						val featureCall = context.call
						if (featureCall instanceof RosettaFeatureCall) {
							val receiverType = typeProvider.getRType(featureCall.feature)
							val featureScope = receiverType.createFeatureScope
							if (featureScope !== null)
								return featureScope
						}
						return IScope.NULLSCOPE
					} else if (context instanceof RosettaGroupByExpression) {
						val container = context.eContainer
						if (container instanceof RosettaGroupByFeatureCall) {
							val featureCall = container.call
							if (featureCall instanceof RosettaFeatureCall) {
								val receiverType = typeProvider.getRType(featureCall.feature)
								val featureScope = receiverType.createFeatureScope
								if (featureScope !== null)
									return featureScope
							}
						}
						else if (container instanceof RosettaGroupByExpression) {
							val parentType = typeProvider.getRType(container.attribute)
							val featureScope = parentType.createFeatureScope
								if (featureScope !== null)
									return featureScope
						}
						return IScope.NULLSCOPE
					}
				case ROSETTA_FEATURE_CALL__FEATURE: {
					if (context instanceof RosettaFeatureCall) {
						val receiverType = typeProvider.getRType(context.receiver)
						val featureScope = receiverType.createFeatureScope
						var allPosibilities = newArrayList
						
						if (featureScope!==null) {
							allPosibilities.addAll(featureScope.allElements);
						}
						//if an attribute has metafields then then the meta names are valid in a feature call e.g. -> currency -> scheme
						val receiver = context.receiver;
						if (receiver instanceof RosettaFeatureCall) {
							val feature = receiver.feature
							switch(feature) {
								Attribute: {
									val metas = feature.metaAnnotations.map[it.attribute?.name].filterNull.toList
									// TODO check that we can use QualifiedName here 
									if (metas !== null && !metas.isEmpty) {
										allPosibilities.addAll(configs.findMetaTypes(feature).filter[
											metas.contains(it.name.lastSegment.toString)
										].map[new AliasedEObjectDescription(QualifiedName.create(it.name.lastSegment), it)])
									}
								}
							}
						}
						return new SimpleScope(allPosibilities)
					}
					return IScope.NULLSCOPE
				}
				case OPERATION__ASSIGN_ROOT: {
					if (context instanceof Operation) {
						val outAndAliases = newArrayList
						val out = getOutput(context.function)
						if (out !== null) {
							outAndAliases.add(out)
						}
						outAndAliases.addAll(context.function.shortcuts)
						return Scopes.scopeFor(outAndAliases)
					}
					return IScope.NULLSCOPE
				}
				case SEGMENT__ATTRIBUTE: {
					switch (context) {
						Operation: {
							val receiverType = typeProvider.getRType(context.assignRoot)
							val featureScope = receiverType.createFeatureScope
							if (featureScope !== null) {
								return featureScope;
							}
							return IScope.NULLSCOPE
						}
						Segment: {
							val prev = context.prev
							if (prev !== null) {
								if (prev.attribute !== null && !prev.attribute.eIsProxy) {
									val receiverType = typeProvider.getRType(prev.attribute)
									val featureScope = receiverType.createFeatureScope
									if (featureScope !== null) {
										return featureScope;
									}
									return IScope.NULLSCOPE
								}
							}
							if (context.eContainer instanceof Operation) {
								return getScope(context.eContainer, reference)
							}
							return defaultScope(context, reference)
						}
						default:
							return defaultScope(context, reference)
					}
				}
				case ROSETTA_CALLABLE_CALL__CALLABLE: {
					if (context instanceof Operation) {
						val function = context.function
						val inputsAndOutputs = newArrayList
						if(!function.inputs.nullOrEmpty)
							inputsAndOutputs.addAll(function.inputs)
						if(function.output!==null)
							inputsAndOutputs.add(function.output)
						return Scopes.scopeFor(inputsAndOutputs)
					} else {
						val listOp = EcoreUtil2.getContainerOfType(context, ListOperation)
						if(listOp !== null) {
							return getParentScope(context, reference, IScope.NULLSCOPE)
						}
						val container = EcoreUtil2.getContainerOfType(context, Function)
						if(container !== null) {
							return filteredScope(getParentScope(context, reference, IScope.NULLSCOPE), [
								descr | descr.EClass !== DATA
							])
						}
						
					}
					return getParentScope(context, reference, defaultScope(context, reference))
				}
				case ROSETTA_CALLABLE_WITH_ARGS_CALL__CALLABLE: {
					return filteredScope(defaultScope(context, reference), [EClass !== FUNCTION_DISPATCH])
				}
				case ROSETTA_ENUM_VALUE_REFERENCE__VALUE: {
					if (context instanceof RosettaEnumValueReference) {
						return Scopes.scopeFor(context.enumeration.allEnumValues)
					}
					return IScope.NULLSCOPE
				}
				case ROSETTA_EXTERNAL_REGULAR_ATTRIBUTE__ATTRIBUTE_REF: {
					if (context instanceof RosettaExternalRegularAttribute) {
						val classRef = (context.eContainer as RosettaExternalClass).typeRef
						if(classRef instanceof Data)
							return Scopes.scopeFor(classRef.allAttributes)
					}
					return IScope.NULLSCOPE
				}			
				case ROSETTA_EXTERNAL_ENUM_VALUE__ENUM_REF: {
					if (context instanceof RosettaExternalEnumValue) {
						val enumRef = (context.eContainer as RosettaExternalEnum).typeRef
						if(enumRef instanceof RosettaEnumeration)
							return Scopes.scopeFor(enumRef.allEnumValues)
					}
					return IScope.NULLSCOPE
				}
				case ANNOTATION_REF__ATTRIBUTE: {
					if (context instanceof AnnotationRef) {
						val annoRef = context.annotation
						return Scopes.scopeFor(annoRef.attributes)
					}
					return IScope.NULLSCOPE
				}
				case FUNCTION_DISPATCH__ATTRIBUTE: {
					if(context instanceof FunctionDispatch) {
						return Scopes.scopeFor(getInputs(context))
					}
					return IScope.NULLSCOPE
				}
				case CONSTRAINT__ATTRIBUTES: {
					return context.getParentScope(reference, IScope.NULLSCOPE)
				}
			}
			defaultScope(context, reference)
		}
		catch (Exception e) {
			LOGGER.error ("Error scoping rosetta - \"" + e.message + "\" see debug logging for full trace");
			LOGGER.debug("Full trace of error ", e);
			//Any exception that is thrown here is going to have been caused by invalid grammar
			//However invalid grammar is checked as the next step of the process - after scoping
			//so just return an empty scope here and let the validator do its thing afterwards
			return IScope.NULLSCOPE;
		}
	}
	
	override protected getImplicitImports(boolean ignoreCase) {
		#[createImportedNamespaceResolver(LIB_NAMESPACE + ".*", ignoreCase)]
	}
	
	override protected internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		return if (context instanceof RosettaModel) {
			val imports = super.internalGetImportedNamespaceResolvers(context, ignoreCase)
			imports.add(
				doCreateImportNormalizer(getQualifiedNameConverter.toQualifiedName(context.name), true, ignoreCase)
			)
			return imports
		} else
			emptyList
	}
	
	private def IScope defaultScope(EObject object, EReference reference) {
		filteredScope(super.getScope(object,reference), [it.EClass !== FUNCTION_DISPATCH])
	}
	
	private def IScope getParentScope(EObject object, EReference reference, IScope outer) {
		if (object === null) {
			return IScope.NULLSCOPE
		}
		val parentScope = getParentScope(object.eContainer, reference, outer)
		switch (object) {
			ListOperation: {
				return Scopes.scopeFor(#[object.parameter], parentScope)
			}
			Data: {
				return Scopes.scopeFor(object.allAttributes, outer)
			}
			Function: {
				val features = newArrayList
				features.addAll(getInputs(object))
				val out = getOutput(object)
				if (out !== null)
					features.add(getOutput(object))
				features.addAll(object.shortcuts)
				return Scopes.scopeFor(features, filteredScope(parentScope)[ descr |
					descr.EClass == ROSETTA_ENUMERATION
				])
			}
			ShortcutDeclaration: {
				filteredScope(parentScope, [descr|
					descr.qualifiedName.toString != object.name // TODO use qnames
				])
			}
			Condition: {
				filteredScope(parentScope, [ descr |
					object.isPostCondition || descr.EObjectOrProxy.eContainingFeature !== FUNCTION__OUTPUT
				])
			}
			RosettaModel:
				defaultScope(object, reference)
			default:
				parentScope
		}
	}
	
	def private IScope filteredScope(IScope scope, Predicate<IEObjectDescription> filter) {
		new FilteringScope(scope,filter)
	}

	private def IScope createFeatureScope(RType receiverType) {
		switch receiverType {
			RDataType:
				Scopes.scopeFor(receiverType.data.allAttributes)
			REnumType:
				Scopes.scopeFor(receiverType.enumeration.allEnumValues)
			RRecordType:
				Scopes.scopeFor(receiverType.record.features)
			RFeatureCallType:
				receiverType.featureType.createFeatureScope
			default:
				null
		}
	}
}