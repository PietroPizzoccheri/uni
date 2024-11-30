package com.lab.evaluation23.solution;

import java.util.LinkedList;
import java.util.List;

import akka.actor.AbstractActor;
import akka.actor.Props;

public class SensorProcessorActor extends AbstractActor {

	private List<Integer> readings;
	private double currentAverage;

	@Override
	public Receive createReceive() {
		return receiveBuilder().match(TemperatureMsg.class, this::gotData).build();
	}

	private void gotData(TemperatureMsg msg) throws Exception {
		
		System.out.println("SENSOR PROCESSOR " + self() + ": Got data from " + msg.getSender());

		if (msg.getTemperature()<0) {
			System.out.println("SENSOR PROCESSOR " + self() + ": Failing!");
			throw new Exception("Actor fault!"); 
		}
		
		readings.add(msg.getTemperature());
		int sum = 0;
		for (Integer i : readings) {
			sum = sum + i;
		}
		currentAverage = sum / (double)readings.size();
		System.out.println("SENSOR PROCESSOR " + self() + ": Current avg is " + currentAverage);
	}

	static Props props() {
		return Props.create(SensorProcessorActor.class);
	}

	public SensorProcessorActor() {
		this.readings = new LinkedList<Integer>();
	}
}
