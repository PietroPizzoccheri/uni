package com.evaluation22.messages;

import akka.actor.ActorRef;

public class ConfigMsg {

    private final ActorRef brokerRef;

    public ConfigMsg(ActorRef brokerRef) {
        this.brokerRef = brokerRef;
    }

    public ActorRef getBrokerRef() {
        return brokerRef;
    }
}
