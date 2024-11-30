package com.lab.evaluation23;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;

public class SensorDataProcessor {

	public static void main(String[] args) {

		// Number of sensors for testing
		final int NO_SENSORS = 4;
		
		// Number of sensor readings to generate
		final int SENSING_ROUNDS = 1;
		
		final ActorSystem sys = ActorSystem.create("System");

		// Create sensor actors
		List<ActorRef> sensors = new LinkedList<ActorRef>();
		for (int i = 0; i < NO_SENSORS; i++) {
			sensors.add(sys.actorOf(TemperatureSensorActor.props(), "t" + i));
		}

		// Create dispatcher
		// final ActorRef dispatcher = ....

		// Waiting until system is ready
		try {
			TimeUnit.SECONDS.sleep(1);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		// Generate some temperature data
		for (int i = 0; i < SENSING_ROUNDS; i++) {
			for (ActorRef t : sensors) {
				t.tell(new GenerateMsg(), ActorRef.noSender());
			}
		}

		// Waiting for temperature messages to arrive
		try {
			TimeUnit.SECONDS.sleep(1);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		// Re-configure dispatcher to use Round Robin
		// ...
		
		// Waiting for dispatcher reconfiguration
		try {
			TimeUnit.SECONDS.sleep(1);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		// Generate some more temperature data
		for (int i = 0; i < SENSING_ROUNDS+1; i++) {
			for (ActorRef t : sensors) {
				t.tell(new GenerateMsg(), ActorRef.noSender());
			}
		}
		
		// A new (faulty) sensor joins the system
		ActorRef faultySensor = sys.actorOf(TemperatureSensorFaultyActor.props(), "tFaulty");
		sensors.add(0, faultySensor);
		
		// ...
		
		// Wait until system is ready again
		try {
			TimeUnit.SECONDS.sleep(1);
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}

		// Generate some more temperature data
		for (int i = 0; i < SENSING_ROUNDS+1; i++) {
			for (ActorRef t : sensors) {
				t.tell(new GenerateMsg(), ActorRef.noSender());
			}
		}
	}
}
