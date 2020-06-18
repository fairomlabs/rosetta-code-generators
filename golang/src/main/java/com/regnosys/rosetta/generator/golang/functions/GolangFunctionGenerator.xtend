package com.regnosys.rosetta.generator.golang.functions

import com.regnosys.rosetta.generator.golang.object.GolangModelObjectBoilerPlate
import com.regnosys.rosetta.rosetta.RosettaCardinality
import com.regnosys.rosetta.rosetta.RosettaNamed
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.FunctionDispatch
import java.util.HashMap
import java.util.List
import java.util.Map
import javax.inject.Inject

import static com.regnosys.rosetta.generator.golang.util.GolangModelGeneratorUtil.*

import static extension com.regnosys.rosetta.generator.golang.util.GolangTranslator.toGOType

class GolangFunctionGenerator {
	@Inject extension GolangModelObjectBoilerPlate
	
	static final String FILENAME = 'functions.go'
		
	def Map<String, ? extends CharSequence> generate(Iterable<RosettaNamed> rosettaFunctions, String version) {
		val result = new HashMap
		val functions = rosettaFunctions.sortBy[name].generateFunctions(version).replaceTabsWithSpaces
		result.put(FILENAME,functions)
		return result;
	}
	
	private def generateFunctions(List<RosettaNamed> functions, String version)  '''
		
		«fileComment(version)»
		package functions	
		
		import . "cdm/enums"
		import . "cdm/types"
		
		//Pointer type args used when the latter are optional
		«FOR f : functions»
			«writeFunction(f)»			
		«ENDFOR»
	'''
	
	private def dispatch writeFunction(RosettaNamed f)''''''
	
	private def dispatch writeFunction(Function f)
	'''		
		func «f.name.toFirstUpper»(«FOR input : f.inputs SEPARATOR ","»«input.name» «input.toType» «ENDFOR») «f.output.toType» {		
		«classComment("Function definition for "+f.name)»			
		return «f.output.toZeroValOfGoType»
		}
	'''
	
	private def dispatch writeFunction(FunctionDispatch f)
	''''''
	
	private def toZeroValOfGoType(Attribute att) {
		switch att.toRawType.toString{
			case "bool": '''false'''
			case "int": '''0'''
			default : '''«att.toType»{}'''
			
		}
			
		
	}
	
	private def toType(Attribute att) {
		if (att.card!==null && att.card.sup>1)
			'''[«att.toRawType»]'''
		else
			att.toRawType.prefixSingleOptional(att.card)
	}
	
	private def toRawType(Attribute input) {
		input.type.name.toGOType	
	}
	//optional parameters are made into pointer types so that nil can be passed when the option is absent
	//perhaps a better approach is to pass lists as is done in Java CDM
	private def prefixSingleOptional(CharSequence type, RosettaCardinality card) {
		if (card!==null && card.inf<1)
			'''*«type»'''
		else
			type
	}
}