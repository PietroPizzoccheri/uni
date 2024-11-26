package com.counter;

import akka.actor.AbstractActor;
import akka.actor.Props;

public class CounterActor extends AbstractActor {

	private int counter;

	public CounterActor() {
		this.counter = 0;
	}

	@Override
	public Receive createReceive() {
		return receiveBuilder().match(SimpleMessage.class, this::onMessage).build();
	}

	void onMessage(SimpleMessage msg) {
		++counter;
		System.out.println("Counter increased to " + counter);
	}

	static Props props() {
		return Props.create(CounterActor.class);
	}

}
