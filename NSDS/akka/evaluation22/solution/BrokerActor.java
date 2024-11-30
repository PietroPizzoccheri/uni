package com.lab.evaluation22.solution;

import akka.actor.*;
import akka.japi.pf.DeciderBuilder;

import java.time.Duration;

public class BrokerActor extends AbstractActorWithStash {

    private ActorRef workerEven;
    private ActorRef workerOdd;

    private static SupervisorStrategy strategy =
            new OneForOneStrategy(
                    1,
                    Duration.ofMinutes(1),
                    DeciderBuilder.match(Exception.class, e -> SupervisorStrategy.resume()).build()
            );

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }

    @Override
    public AbstractActor.Receive createReceive() {
        return batchedOff();
    }

    private final Receive batchedOff() {
        return receiveBuilder()
                .match(SubscribeMsg.class, this::onSubscribe)
                .match(PublishMsg.class, this::onPublish)
                .match(BatchMsg.class, this::onBatching).build();
    }

    private final Receive batchedOn() {
        return receiveBuilder() // TODO change
                .match(SubscribeMsg.class, this::onSubscribe)
                .match(PublishMsg.class, this::onPubBatch)
                .match(BatchMsg.class, this::onBatching).build();
    }

    public BrokerActor() {
        workerEven = getContext().actorOf(WorkerActor.props());
        workerOdd = getContext().actorOf(WorkerActor.props());
    }

    private void onSubscribe(SubscribeMsg msg) {
        if (msg.getKey() % 2== 1) {
            System.out.println("BROKER: Subscribed to odd worker");
            workerOdd.tell(msg, self());
        } else {
            System.out.println("BROKER: Subscribed to even worker");
            workerEven.tell(msg, self());
        }
    }

    private void onPublish(PublishMsg msg) {
        workerOdd.tell(msg, self());
        workerEven.tell(msg, self());
    }

    private void onBatching(BatchMsg msg) {
        if (msg.isOn()) {
            System.out.println("BROKER: batching turned on");
            getContext().become(batchedOn());
        } else {
            System.out.println("BROKER: batching turned off");
            getContext().become(batchedOff());
            unstashAll();
        }
    }

    private void onPubBatch(PublishMsg msg) {
        System.out.println("BROKER: publish message stashed");
        stash();
    }

    static Props props() {
        return Props.create(BrokerActor.class);
    }
}
