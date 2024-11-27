package com.email;

import akka.actor.AbstractActor;
import akka.actor.Props;
import com.email.messages.GetMsg;
import com.email.messages.PutMsg;
import com.email.messages.ReplyMsg;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;

public class ServerActor extends AbstractActor {

    Map<String, String> contactList;
    Random r = new Random();

    public ServerActor() {
        this.contactList = new HashMap<>();
    }

    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(PutMsg.class, this::onMessage)
                .match(GetMsg.class, this::onMessage)
                .build();
    }

    @Override
    public void preRestart(Throwable reason, Optional<Object> message) throws Exception {
        super.preRestart(reason, message);
        System.out.println("ServerActor is about to restart with map: " + (contactList.isEmpty() ? "empty map" : contactList));
    }

    @Override
    public void postRestart(Throwable reason) throws Exception {
        super.postRestart(reason);
        System.out.println("ServerActor restarted with map: " + (contactList.isEmpty() ? "empty map" : contactList));

    }

    void onMessage(PutMsg msg) throws Exception {
        //System.out.println("ServerActor received PutMsg: " + msg.getName() + " -> " + msg.getEmail());
        if ("Fail!".equals(msg.getName())) {
            System.out.println("ServerActor forced failure for name: " + msg.getName());
            int random = r.nextInt(100);
            if(random>50){
                throw new RuntimeException("forced failure to resume");
            } else {
                throw new Exception("forced failure to restart");
            }

        }
        contactList.put(msg.getName(), msg.getEmail());
    }

    void onMessage(GetMsg msg) {
        //System.out.println("ServerActor received GetMsg: " + msg.getName());
        sender().tell(new ReplyMsg(contactList.get(msg.getName())), self());
    }

    static Props props() {
        return Props.create(ServerActor.class);
    }
}