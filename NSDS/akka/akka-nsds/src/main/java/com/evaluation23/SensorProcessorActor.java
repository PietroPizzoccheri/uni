package com.lab.evaluation23;

import akka.actor.AbstractActor;
import akka.actor.Props;

public class SensorProcessorActor extends AbstractActor {

	private double currentAverage;

	@Override
	public Receive createReceive() {
		return receiveBuilder().match(TemperatureMsg.class, this::gotData).build();
	}

	private void gotData(TemperatureMsg msg) throws Exception {

		System.out.println("SENSOR PROCESSOR " + self() + ": Got data from " + msg.getSender());

		// ...
		
		System.out.println("SENSOR PROCESSOR " + self() + ": Current avg is " + currentAverage);
	}

	static Props props() {
		return Props.create(SensorProcessorActor.class);
	}

	public SensorProcessorActor() {
	}
}
