package com.evaluation23;
import com.evaluation23.*;
import com.evaluation23.messages.*;

import java.util.concurrent.ThreadLocalRandom;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;

public class TemperatureSensorActor extends AbstractActor {

	private ActorRef dispatcher;
	private final static int MIN_TEMP = 0;
	private final static int MAX_TEMP = 50;

	@Override
	public AbstractActor.Receive createReceive() {
		return receiveBuilder()
				.match(ConfigMsg.class, this::onConfig)
				.match(GenerateMsg.class, this::onGenerate)
				.build();
	}

	private void onGenerate(GenerateMsg msg) {
		int temp = ThreadLocalRandom.current().nextInt(MIN_TEMP, MAX_TEMP + 1);
		System.out.println("TEMPERATURE SENSOR: Sensing temperature! " + temp + " from " + self());
		dispatcher.tell(new TemperatureMsg(temp,self()), self());
	}

	private void onConfig(ConfigMsg msg) {
		dispatcher = msg.getDispatcher();
	}

	static Props props() {
		return Props.create(TemperatureSensorActor.class);
	}

}
