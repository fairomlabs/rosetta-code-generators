package com.regnosys.rosetta.generator.golang.object

import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.rosetta.RosettaClass
import com.regnosys.rosetta.rosetta.RosettaMetaType
import java.util.List

import static com.regnosys.rosetta.generator.golang.util.GolangModelGeneratorUtil.*

import static extension com.regnosys.rosetta.generator.util.RosettaAttributeExtensions.*
import java.util.Map
import java.util.HashMap
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.generator.object.ExpandedAttribute
import java.util.Set
import com.google.common.collect.Lists

class GolangModelObjectGenerator {

	@Inject extension RosettaExtensions
	@Inject extension GolangModelObjectBoilerPlate
	@Inject extension GolangMetaFieldGenerator
	
	static final String CLASSES_FILENAME = 'types.go'
	static final String META_FILENAME = 'metatypes.go'
	
	def Map<String, ? extends CharSequence> generate(Iterable<Data> rosettaClasses, Iterable<RosettaMetaType> metaTypes, String version) {
		val result = new HashMap		
		val enumImports = rosettaClasses
				.map[allExpandedAttributes].flatten
				.map[type]
				.filter[isEnumeration]
				.map[name]
				.toSet
		
		val classes = rosettaClasses.sortBy[name].generateClasses(enumImports, version).replaceTabsWithSpaces
		result.put(CLASSES_FILENAME, classes)
		val metaFields = generateMetaFields(metaTypes, version).replaceTabsWithSpaces
		result.put(META_FILENAME, metaFields)
		result;
	}
	
	def Map<String, ? extends CharSequence> generate2(Iterable<Data> rosettaClasses, Iterable<RosettaMetaType> metaTypes, String version) {
		val result = new HashMap		
		val enumImports = rosettaClasses
				.map[allExpandedAttributes].flatten
				.map[type]
				.filter[isEnumeration]
				.map[name]
				.toSet
		
		val classes = rosettaClasses.sortBy[name].generateClasses2(enumImports, version).replaceTabsWithSpaces
		result.put(CLASSES_FILENAME, classes)
		val metaFields = generateMetaFields(metaTypes, version).replaceTabsWithSpaces
		result.put(META_FILENAME, metaFields)
		result;
	}

	private def generateClasses(List<Data> rosettaClasses, Set<String> importedEnums,  String version) {
	'''	
	package types
	
	«fileComment(version)»	
	
	import . "cdm/metatypes";
	import . "cdm/enums";
	
	
	«FOR c : rosettaClasses»
		«classComment(c.definition)»
		type «c.name» struct {
			«FOR attribute : c.allExpandedAttributes»				
				«methodComment(attribute.definition)»
				«IF (c.name.toString == "Pric" && attribute.toType.toString == "Pric") || (c.name.toString == "New" && attribute.toType.toString == "Tx")»
				«attribute.toAttributeName» *«attribute.toType»;
				«ELSE»
				«attribute.toAttributeName» «attribute.toType»;
				«ENDIF»
			«ENDFOR»
		}
			
	«ENDFOR»
	'''}
	
	private def generateClasses2(List<Data> rosettaClasses, Set<String> importedEnums,  String version) {
	'''	
	package types
	
	«fileComment(version)»	
	
	import . "cdm/metatypes";
	import . "cdm/preenums";
	import . "cdm/enums";
	
	
«««	«FOR importLine : Lists.partition(importedEnums.toList, 10) SEPARATOR "\n"»
«««		«FOR imported : importLine SEPARATOR "\n "»import "cdm/«imported»"«ENDFOR»
«««	«ENDFOR»
				
	
	«FOR c : rosettaClasses»
		«classComment(c.definition)»
		type «c.name» struct {
			«FOR attribute : c.allExpandedAttributes»				
				«methodComment(attribute.definition)»
				«attribute.toAttributeName» «attribute.toType»;
			«ENDFOR»
		}
			
	«ENDFOR»
	'''}
	
	
	def dispatch Iterable<ExpandedAttribute> allExpandedAttributes(RosettaClass type) {
		type.allSuperTypes.expandedAttributes
	}
	
	def dispatch Iterable<ExpandedAttribute> allExpandedAttributes(Data type){
		type.allSuperTypes.map[it.expandedAttributes].flatten
	}
	
	def dispatch String definition(RosettaClass element) {
		element.definition
	}
	def dispatch String definition(Data element){
		element.definition
	}

}