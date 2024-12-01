package com.evaluation22;

import akka.actor.*;
import akka.japi.pf.DeciderBuilder;
import com.evaluation22.messages.BatchMsg;
import com.evaluation22.messages.PublishMsg;
import com.evaluation22.messages.SubscribeMsg;

import java.util.HashMap;
import java.util.Map;

import static akka.actor.SupervisorStrategy.resume;


public class BrokerActor extends AbstractActorWithStash {

    private final ActorRef workerEven;
    private final ActorRef workerOdd;

    @Override
    public Receive createReceive() {
        return batchedOff();
    }

    public Receive batchedOn() {
        return receiveBuilder()
                .match(SubscribeMsg.class, this::onSubscribeMessage)
                .match(PublishMsg.class, this::onPublishBatched)
                .match(BatchMsg.class, this::onBatchedMessage)
                .build();
    }


    public Receive batchedOff() {
        return receiveBuilder()
                .match(SubscribeMsg.class, this::onSubscribeMessage)
                .match(PublishMsg.class, this::onPublishMessage)
                .match(BatchMsg.class, this::onBatchedMessage)
                .build();
    }

    private void onBatchedMessage(BatchMsg batchMsg) {
        if(batchMsg.isOn()) {
            System.out.println("WorkerActor: Batching is on!");
            getContext().become(batchedOn());
        } else {
            System.out.println("WorkerActor: Batching is off!");
            getContext().become(batchedOff());
            unstashAll();
        }
    }

    private void onPublishBatched(PublishMsg publishMsg) {
        //System.out.println("WorkerActor: batching publish command!");
        stash();
    }


    public BrokerActor() {
        workerEven = getContext().actorOf(WorkerActor.props(), "worker1");
        workerOdd = getContext().actorOf(WorkerActor.props(), "worker2");
    }

    private static final SupervisorStrategy strategy =
            new OneForOneStrategy(
                    10,
                    java.time.Duration.ofMinutes(1),
                    DeciderBuilder
                            .matchAny(o -> {
                                System.out.println("BrokerActor: Restarting on unknown exception");
                                return resume();
                            })
                            .build());

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }


    private void onPublishMessage(PublishMsg publishMsg) {
        //System.out.println("Sending publish message to workers" + publishMsg);
        workerEven.tell(publishMsg, getSender());
        workerOdd.tell(publishMsg, getSender());
    }

    private void onSubscribeMessage(SubscribeMsg subscribeMsg) {
        //System.out.println("Sending subscribe message to workers" + subscribeMsg);
        if (subscribeMsg.getKey() % 2 == 0) {
            workerEven.tell(subscribeMsg, getSender());
        } else {
            workerOdd.tell(subscribeMsg, getSender());
        }
    }

    public static Props props() {
        return Props.create(BrokerActor.class, BrokerActor::new);
    }
}
