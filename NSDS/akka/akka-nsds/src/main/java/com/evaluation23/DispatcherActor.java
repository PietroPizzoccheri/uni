package com.evaluation23;
import akka.actor.ActorRef;
import com.evaluation23.*;
import com.evaluation23.messages.*;

import akka.actor.AbstractActor;
import akka.actor.AbstractActorWithStash;
import akka.actor.Props;

import java.util.Map;

public class DispatcherActor extends AbstractActorWithStash {

	private final static int NO_PROCESSORS = 2;
	private final ActorRef processor1;
	private final ActorRef processor2;

	private boolean useRoundRobin = false;
	private boolean roundRobinSwitch = false;

	private boolean loadBalancerSwitch = false;

	private Map<ActorRef , ActorRef> processorMap;

	public DispatcherActor(ActorRef processor1, ActorRef processor2) {
		this.processor1 = processor1;
		this.processor2 = processor2;
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
			toSend.tell(msg, ActorRef.noSender());
		}else {
			if(loadBalancerSwitch){
				processorMap.put(msg.getSender(), processor1);
			} else {
				processorMap.put(msg.getSender(), processor2);
			}
		}
	}

	private void dispatchDataRoundRobin(TemperatureMsg msg) {
		if(roundRobinSwitch) {
			processor1.tell(msg, ActorRef.noSender());
		} else {
			processor2.tell(msg, ActorRef.noSender());
		}
		roundRobinSwitch = !roundRobinSwitch;
	}

	static Props props(ActorRef processor1, ActorRef processor2) {
		return Props.create(DispatcherActor.class , () -> new DispatcherActor(processor1, processor2));
	}
}
