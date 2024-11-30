package com.evaluation22;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;

public class PublisherActor extends AbstractActor {

    @Override
    public Receive createReceive() {
        return null;
    }

    public static Props props() {
        return Props.create(PublisherActor.class, PublisherActor::new);
    }


}
