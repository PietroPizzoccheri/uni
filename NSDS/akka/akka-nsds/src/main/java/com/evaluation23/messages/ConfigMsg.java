package com.evaluation23.messages;

import akka.actor.ActorRef;

public class ConfigMsg {

    private ActorRef dispatcher;

    public ConfigMsg(ActorRef dispatcher) {
        this.dispatcher = dispatcher;
    }

    public ActorRef getDispatcher() {
        return dispatcher;
    }
}
