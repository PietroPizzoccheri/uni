package com.evaluation22;

import akka.actor.AbstractActor;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import com.evaluation22.messages.NotifyMsg;
import com.evaluation22.messages.SubscribeMsg;
import com.evaluation22.messages.ConfigMsg;

import java.util.ArrayList;
import java.util.List;

public class SubscriberActor extends AbstractActor {
    private ActorRef broker;

    List<String> values = new ArrayList<>();

    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(ConfigMsg.class, this::configure)
                .match(SubscribeMsg.class, this::onSubscribe)
                .match(NotifyMsg.class, this::onNotify).build();
    }

    private void configure(ConfigMsg msg) {
        //System.out.println("SUBSCRIBER: Received configuration message!");
        broker = msg.getBrokerRef();
    }

    private void onSubscribe(SubscribeMsg msg) {
        //System.out.println("SUBSCRIBER: Received subscribe command!");
        broker.tell(msg, self());
    }

    private void onNotify(NotifyMsg msg) {
        //System.out.println("SUBSCRIBER: Received notify message!");
        System.out.println("Received value: " + msg.getValue());
        values.add(msg.getValue());
    }

    static Props props() {
        return Props.create(SubscriberActor.class);
    }
}


