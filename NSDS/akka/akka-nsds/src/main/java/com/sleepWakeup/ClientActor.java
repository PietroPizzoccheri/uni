package com.sleepWakeup;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import akka.japi.pf.ReceiveBuilder;

public class ClientActor extends AbstractActor {
    private final ActorRef serverActor;

    public ClientActor(ActorRef serverActor) {
        this.serverActor = serverActor;
    }

    public static Props props(ActorRef serverActor) {
        return Props.create(ClientActor.class, () -> new ClientActor(serverActor));
    }

    @Override
    public Receive createReceive() {
        return ReceiveBuilder.create()
            .matchAny(msg -> {
                serverActor.tell(msg, getSelf());
            })
            .match(String.class, msg -> {
                System.out.println("Received from server: " + msg);
            })
            .build();
    }
}
