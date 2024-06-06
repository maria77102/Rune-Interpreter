package com.regnosys.rosetta.interpreternew.values;

import java.util.stream.Stream;

import com.regnosys.rosetta.rosetta.interpreter.RosettaInterpreterValue;

public class RosettaInterpreterZonedDateTimeValue extends RosettaInterpreterBaseValue {

	private RosettaInterpreterDateValue date;
	private RosettaInterpreterTimeValue time;
	private RosettaInterpreterStringValue timeZone;
	
	/**
	 * Constructor method for zonedDateTime value.
	 *
	 * @param date		date value
	 * @param time		time value
	 * @param timeZone	timezone value
	 */
	public RosettaInterpreterZonedDateTimeValue(RosettaInterpreterDateValue date, RosettaInterpreterTimeValue time,
			RosettaInterpreterStringValue timeZone) {
		super();
		this.date = date;
		this.time = time;
		this.timeZone = timeZone;
	}

	public RosettaInterpreterDateValue getDate() {
		return date;
	}

	public RosettaInterpreterTimeValue getTime() {
		return time;
	}

	public RosettaInterpreterStringValue getTimeZone() {
		return timeZone;
	}

	@Override
	public Stream<Object> toElementStream() {
		return Stream.of(date, time, timeZone);
	}
	
	@Override
	public Stream<RosettaInterpreterValue> toValueStream() {
		return Stream.of(this);
	}
}