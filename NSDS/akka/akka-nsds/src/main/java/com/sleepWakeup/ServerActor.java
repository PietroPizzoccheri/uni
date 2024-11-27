package com.sleepWakeup;

import akka.actor.*;
import akka.japi.pf.ReceiveBuilder;

import java.util.LinkedList;
import java.util.Queue;

public class ServerActor extends AbstractActorWithStash {
    private final Queue<Object> messageQueue = new LinkedList<>();
    private boolean isSleeping = false;

    public static Props props() {
        return Props.create(ServerActor.class);
    }

    @Override
    public Receive createReceive() {
        return ReceiveBuilder.create()
                .matchEquals("Sleep", msg -> {
                    isSleeping = true;
                })
                .matchEquals("Wakeup", msg -> {
                    isSleeping = false;
                    while (!messageQueue.isEmpty()) {
                        getSender().tell(messageQueue.poll(), getSelf());
                    }
                    unstashAll();
                })
                .matchAny(msg -> {
                    if (isSleeping) {
                        messageQueue.add(msg);
                        stash();
                    } else {
                        getSender().tell(msg, getSelf());
                    }
                })
                .build();
    }
}
