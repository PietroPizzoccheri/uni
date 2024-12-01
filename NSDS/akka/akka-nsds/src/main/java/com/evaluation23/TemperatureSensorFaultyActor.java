package com.evaluation23;
import com.evaluation23.*;
import com.evaluation23.messages.*;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;

public class TemperatureSensorFaultyActor extends TemperatureSensorActor {

	private ActorRef dispatcher;
	private final static int FAULT_TEMP = -50;

	@Override
	public AbstractActor.Receive createReceive() {
		return receiveBuilder()
				.match(GenerateMsg.class, this::onGenerate)
				.match(ConfigMsg.class, this::onConfig)
				.build();
	}

	private void onGenerate(GenerateMsg msg) {
		System.out.println("TEMPERATURE SENSOR "+self()+": Sensing temperature! (FAULTY)");
		dispatcher.tell(new TemperatureMsg(FAULT_TEMP,self()), self());
	}

	private void onConfig(ConfigMsg msg) {
		dispatcher = msg.getDispatcher();
	}

	static Props props() {
		return Props.create(TemperatureSensorFaultyActor.class);
	}

}
