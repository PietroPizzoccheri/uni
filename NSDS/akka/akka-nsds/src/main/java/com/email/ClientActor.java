package com.email;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import akka.actor.Cancellable;
import akka.pattern.Patterns;
import com.email.messages.GetMsg;
import com.email.messages.ReplyMsg;
import scala.concurrent.Future;
import scala.concurrent.duration.Duration;

import java.util.concurrent.TimeUnit;

public class ClientActor extends AbstractActor {

    private final ActorRef server;
    private final String[] names;
    private final String[] additionalNames = {
            "Liam", "Noah", "Oliver", "Elijah", "William",
            "James", "Benjamin", "Lucas", "Henry", "Alexander"
    };
    private Cancellable cancellable;

    public ClientActor(ActorRef server, String[] names) {
        this.server = server;
        this.names = names;
    }

    @Override
    public void preStart() {
        // Schedule periodic GetMsg messages
        cancellable = getContext().system().scheduler().schedule(
                Duration.Zero(),
                Duration.create(1, TimeUnit.SECONDS),
                self(),
                new GetMsg(""),
                getContext().dispatcher(),
                self()
        );
    }

    @Override
    public void postStop() {
        // Cancel the periodic task when the actor stops
        cancellable.cancel();
    }

    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(GetMsg.class, this::onGetMsg)
                .build();
    }

    private void onGetMsg(GetMsg msg) {
        // Generate a new random name each time
        String randomName = getRandomName();
        Future<Object> future = Patterns.ask(server, new GetMsg(randomName), 5000);
        future.onComplete(result -> {
            if (result.isSuccess()) {
                ReplyMsg reply = (ReplyMsg) result.get();
                System.out.println("Received email for " + randomName + ": " + reply.getEmail());
            } else {
                System.out.println("Failed to get email for: " + randomName);
            }
            return null;
        }, getContext().getDispatcher());
    }

    private String getRandomName() {
        if (Math.random() < 0.5) {
            return names[(int) (Math.random() * names.length)];
        } else {
            return additionalNames[(int) (Math.random() * additionalNames.length)];
        }
    }

    static Props props(ActorRef server, String[] names) {
        return Props.create(ClientActor.class, () -> new ClientActor(server, names));
    }
}

