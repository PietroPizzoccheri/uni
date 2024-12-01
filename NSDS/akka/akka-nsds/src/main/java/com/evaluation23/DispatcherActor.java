package com.evaluation23;
import akka.actor.*;
import akka.japi.pf.DeciderBuilder;
import com.evaluation23.messages.*;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import static akka.actor.SupervisorStrategy.resume;

public class DispatcherActor extends AbstractActor {

	private final static int NO_PROCESSORS = 2;
	private final List<ActorRef> processorList = new LinkedList<ActorRef>();

	private boolean useRoundRobin = false;
	private boolean roundRobinSwitch = false;

	private boolean loadBalancerSwitch = false;

	private final Map<ActorRef , ActorRef> processorMap = new HashMap<>();

	public DispatcherActor() {
		for (int i = 0; i < NO_PROCESSORS; i++) {
			processorList.add(getContext().actorOf(SensorProcessorActor.props(), "p" + i));
		}
	}

	private static final SupervisorStrategy strategy =
			new OneForOneStrategy(
					10,
					java.time.Duration.ofMinutes(1),
					DeciderBuilder
							.matchAny(o -> {
								System.out.println("SupervisorActor: Restarting on unknown exception");
								return resume();
							})
							.build());

	@Override
	public SupervisorStrategy supervisorStrategy() {
		return strategy;
	}




	@Override
	public AbstractActor.Receive createReceive() {
		return receiveBuilder()
				.match(DispatchLogicMsg.class, this::onDispatchLogic)
				.match(TemperatureMsg.class, this::onTemperatureMsg)
				.build();
	}


	private void onDispatchLogic(DispatchLogicMsg msg) {
		if(msg.getLogic() == 0) {
			System.out.println("DispatcherActor: Using Round Robin");
			useRoundRobin = true;
		} else {
			useRoundRobin = false;
		}
	}

	private void onTemperatureMsg(TemperatureMsg msg) {
		if(useRoundRobin) {
			dispatchDataRoundRobin(msg);
		} else {
			dispatchDataLoadBalancer(msg);
		}
	}

	private void dispatchDataLoadBalancer(TemperatureMsg msg) {
		if(processorMap.containsKey(msg.getSender())){
			ActorRef sender = msg.getSender();
			ActorRef toSend = processorMap.get(sender);
			toSend.tell(msg, self());
		}else {

			loadBalancerSwitch = !loadBalancerSwitch;
		}
	}

	private void dispatchDataRoundRobin(TemperatureMsg msg) {
		if(roundRobinSwitch) {

		}
		roundRobinSwitch = !roundRobinSwitch;
	}

	static Props props() {
		return Props.create(DispatcherActor.class , DispatcherActor::new);
	}
}
