package com.counter;

import akka.actor.AbstractActor;
import akka.actor.AbstractActorWithStash;
import akka.actor.Props;

public class CounterActor extends AbstractActorWithStash {

	private int counter;

	public CounterActor() {
		this.counter = 0;
	}

	@Override
	public Receive createReceive() {
		return receiveBuilder()
				.match(IncrementMessage.class, this::onMessage)
				.match(DecrementMessage.class, this::onMessage)
				.build();
	}

	void onMessage(IncrementMessage msg) {
		++counter;
		System.out.println("Counter increased to " + counter);
		if(counter > 0){
			unstash();
		}
	}

	void onMessage(DecrementMessage msg){
		if(counter <= 0){
			stash();
			System.out.println("stashed with counter: " + counter);
		} else{
			counter--;
			System.out.println("Counter decreased to " + counter);
		}
	}

	static Props props() {
		return Props.create(CounterActor.class);
	}

}
