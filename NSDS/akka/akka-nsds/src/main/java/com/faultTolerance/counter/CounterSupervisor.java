package com.faultTolerance.counter;

import static akka.pattern.Patterns.ask;
import static java.util.concurrent.TimeUnit.SECONDS;

import java.util.concurrent.TimeoutException;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;

public class CounterSupervisor {

	public static final int NORMAL_OP = 0;
	public static final int FAULT_OP = -1;

	public static final int FAULTS = 1;

	public static void main(String[] args) {
		scala.concurrent.duration.Duration timeout = scala.concurrent.duration.Duration.create(5, SECONDS);

		final ActorSystem sys = ActorSystem.create("System");
		final ActorRef supervisor = sys.actorOf(CounterSupervisorActor.props(), "supervisor");

		ActorRef counter;
		try {
			
			// Asks the supervisor to create the child actor and returns a reference
			scala.concurrent.Future<Object> waitingForCounter = ask(supervisor, Props.create(CounterActor.class), 5000);
			counter = (ActorRef) waitingForCounter.result(timeout, null);

			counter.tell(new DataMessage(NORMAL_OP), ActorRef.noSender());

			for (int i = 0; i < FAULTS; i++)
				counter.tell(new DataMessage(FAULT_OP), ActorRef.noSender());

			counter.tell(new DataMessage(NORMAL_OP), ActorRef.noSender());

			sys.terminate();

		} catch (TimeoutException | InterruptedException e1) {
		
			e1.printStackTrace();
		}

	}

}
