package com.regnosys.rosetta.blueprints.runner;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import com.regnosys.rosetta.blueprints.runner.data.GroupableData;

public class CaptureDownstream<O, K extends Comparable<K>> implements Downstream<O, K> {
	private final Map<K, GroupableData<? extends O, K>> results = new HashMap<>();

	@Override
	public String getURI() {
		return null;
	}

	@Override
	public String getLabel() {
		return null;
	}

	@Override
	public <I2 extends O> void process(GroupableData<I2, K> input) {
		results.put(input.getKey(), input);
	}

	public static <I2, K extends Comparable<K>> boolean isTruthy(GroupableData<I2, K> input) {
		if (input==null) {
			return false;
		}
		return input.getData() instanceof Boolean ? (Boolean) input.getData() 
				: input.getData()!=null;
	}

	@Override
	public void terminate() {			
	}

	@Override
	public void addUpstream(Upstream<? extends O, K> upstream) {
		
	}

	@Override
	public Collection<Upstream<? extends O, K>> getUpstreams() {
		return null;
	}

	public GroupableData<? extends O, K> getResult(K key) {
		return results.get(key);
	}
	
	public boolean isTruthy(K key) {
		return isTruthy(getResult(key));
	}
	
}