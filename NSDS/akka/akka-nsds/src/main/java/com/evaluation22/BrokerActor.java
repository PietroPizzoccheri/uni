package com.evaluation22;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import com.sleepWakeup.ClientActor;

public class BrokerActor extends AbstractActor {

    @Override
    public Receive createReceive() {
        return null;
    }

    public static Props props() {
        return Props.create(BrokerActor.class, BrokerActor::new);
    }


}
