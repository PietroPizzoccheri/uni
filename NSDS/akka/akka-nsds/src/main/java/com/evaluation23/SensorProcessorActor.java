package com.evaluation23;
import akka.actor.ActorRef;
import com.evaluation23.*;
import com.evaluation23.messages.*;

import akka.actor.AbstractActor;
import akka.actor.Props;

public class SensorProcessorActor extends AbstractActor {

	private double currentAverage;
	private double tot;
	private int count = 0;

	@Override
	public Receive createReceive() {
		return receiveBuilder().match(TemperatureMsg.class, this::gotData).build();
	}

	private void gotData(TemperatureMsg msg) throws Exception {

		System.out.println("SENSOR PROCESSOR " + self() + ": Got data from " + msg.getSender());

		if(count == 0) {
			tot = msg.getTemperature();
		} else {
			tot += msg.getTemperature();
			currentAverage = tot / (count + 1);
		}
		count++;

		System.out.println("SENSOR PROCESSOR " + self() + ": Current avg is " + currentAverage);
	}

	public ActorRef getSelf() {
		return self();
	}

	static Props props() {
		return Props.create(SensorProcessorActor.class);
	}

	public SensorProcessorActor() {
	}
}
