package com.regnosys.rosetta.interpreternew.visitors;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;


import com.regnosys.rosetta.interpreternew.RosettaInterpreterVisitor;
import com.regnosys.rosetta.interpreternew.values.RosettaInterpreterListValue;
import com.regnosys.rosetta.rosetta.expression.ListLiteral;
import com.regnosys.rosetta.rosetta.expression.RosettaExpression;
import com.regnosys.rosetta.rosetta.expression.RosettaInterpreterValue;

public class RosettaInterpreterListLiteralInterpreter extends RosettaInterpreterConcreteInterpreter {

	public RosettaInterpreterListLiteralInterpreter() {
		super();
	}
	
	public RosettaInterpreterListValue interp(ListLiteral exp) {
		List<RosettaExpression> expressions = exp.getElements();
		List<RosettaInterpreterValue> interpretedExpressions = new ArrayList<>();
		
		for(RosettaExpression e : expressions) {
			interpretedExpressions.add(e.accept(visitor));
		}
		
		return new RosettaInterpreterListValue(interpretedExpressions);
	}

}