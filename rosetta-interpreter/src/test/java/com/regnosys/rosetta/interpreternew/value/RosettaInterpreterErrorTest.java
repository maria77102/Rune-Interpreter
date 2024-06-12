package com.regnosys.rosetta.interpreternew.value;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

import com.regnosys.rosetta.interpreternew.values.RosettaInterpreterError;

public class RosettaInterpreterErrorTest {

	@Test
	void hashTest() {
		RosettaInterpreterError e1 = new RosettaInterpreterError("error1");
		RosettaInterpreterError e2 = new RosettaInterpreterError("error1");
		RosettaInterpreterError e3 = new RosettaInterpreterError("error3");
		
		assertEquals(e1.hashCode(), e2.hashCode());
		assertNotEquals(e1.hashCode(), e3.hashCode());
	}
	
	@Test
	void equalsGoodWeatherTest() {
		RosettaInterpreterError e1 = new RosettaInterpreterError("error1");
		RosettaInterpreterError e2 = new RosettaInterpreterError("error1");
		
		assertTrue(e1.equals(e1));
		assertTrue(e1.equals(e2));
	}
	
	@Test
	void equalsBadWeatherTest() {
		RosettaInterpreterError e1 = new RosettaInterpreterError("error1");
		RosettaInterpreterError e2 = new RosettaInterpreterError("error2");
		
		assertFalse(e1.equals(e2));
		assertFalse(e1.equals(null));
		assertFalse(e1.equals("notAnError"));
	}
	
	@Test
	void toStringTest() {
		RosettaInterpreterError e1 = new RosettaInterpreterError("error1");		
		
		assertEquals("RosettaInterpreterError [errorMessage=error1]", e1.toString());
	}
}