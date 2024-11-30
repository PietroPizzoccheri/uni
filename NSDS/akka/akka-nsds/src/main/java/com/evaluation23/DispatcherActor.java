package com.lab.evaluation23;

import akka.actor.AbstractActor;
import akka.actor.AbstractActorWithStash;
import akka.actor.Props;

public class DispatcherActor extends AbstractActorWithStash {

	private final static int NO_PROCESSORS = 2;

	public DispatcherActor() {
	}


	@Override
	public AbstractActor.Receive createReceive() {
		return null; // TO CHANGE
	}

	private void dispatchDataLoadBalancer(TemperatureMsg msg) {

		// ...
	}

	private void dispatchDataRoundRobin(TemperatureMsg msg) {
		// ...
	}

	static Props props() {
		return Props.create(DispatcherActor.class);
	}
}
