package com.evaluation22;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.*;
import com.evaluation22.messages.BatchMsg;
import com.evaluation22.messages.NotifyMsg;
import com.evaluation22.messages.PublishMsg;
import com.evaluation22.messages.SubscribeMsg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WorkerActor extends AbstractActor {

    List<String> subscribedTopics = new ArrayList<>();
    Map<String , ActorRef> subscriptionData = new HashMap<>();

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(SubscribeMsg.class, this::onSubscribeMessage)
                .match(PublishMsg.class, this::onPublishMessage)
                .build();
    }

    private void onPublishMessage(PublishMsg publishMsg) throws Exception {
        //System.out.println("worker received topic: " + publishMsg.getTopic());
        if(subscribedTopics.contains(publishMsg.getTopic())) {
            subscriptionData.get(publishMsg.getTopic()).tell(new NotifyMsg(publishMsg.getValue()), getSender());
        } else {
            throw new Exception("Unsubscribed topic: " + publishMsg.getTopic());
        }
    }

    private void onSubscribeMessage(SubscribeMsg subscribeMsg) {
        //System.out.println("worker adding topic: " + subscribeMsg.getTopic());
        subscribedTopics.add(subscribeMsg.getTopic());
        subscriptionData.put(subscribeMsg.getTopic() , getSender());
    }


    static Props props() {
        return Props.create(WorkerActor.class , WorkerActor::new);
    }
}
