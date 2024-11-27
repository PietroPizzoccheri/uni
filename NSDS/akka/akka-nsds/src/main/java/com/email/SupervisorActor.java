package com.email;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import akka.actor.SupervisorStrategy;
import akka.actor.OneForOneStrategy;
import akka.japi.pf.DeciderBuilder;

import static akka.actor.SupervisorStrategy.restart;
import static akka.actor.SupervisorStrategy.resume;

public class SupervisorActor extends AbstractActor {

    private final ActorRef serverActor = getContext().actorOf(ServerActor.props(), "serverActor");

    private static SupervisorStrategy strategy =
            new OneForOneStrategy(
                    10,
                    java.time.Duration.ofMinutes(1),
                    DeciderBuilder
                            .match(RuntimeException.class, e -> {
                                System.out.println("SupervisorActor: Resuming on RuntimeException");
                                return resume();
                            })
                            .matchAny(o -> {
                                System.out.println("SupervisorActor: Restarting on unknown exception");
                                return restart();
                            })
                            .build());

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .matchAny(msg -> {
                    //System.out.println("SupervisorActor forwarding message: " + msg);
                    serverActor.forward(msg, getContext());
                })
                .build();
    }

    public static Props props() {
        return Props.create(SupervisorActor.class);
    }
}