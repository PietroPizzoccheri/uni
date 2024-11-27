package com.sleepWakeup;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;

public class Launch {
    public static void main(String[] args) throws InterruptedException {
        ActorSystem system = ActorSystem.create("SleepWakeupSystem");
        ActorRef serverActor = system.actorOf(ServerActor.props(), "serverActor");
        ActorRef clientActor = system.actorOf(ClientActor.props(serverActor), "clientActor");

        // Example usage
        clientActor.tell("Hello", ActorRef.noSender());
        Thread.sleep(2000);
        clientActor.tell("Sleep", ActorRef.noSender());
        Thread.sleep(2000);
        clientActor.tell("Message 1", ActorRef.noSender());
        Thread.sleep(2000);
        clientActor.tell("Message 2", ActorRef.noSender());
        Thread.sleep(2000);
        clientActor.tell("Wakeup", ActorRef.noSender());
        Thread.sleep(2000);
        clientActor.tell("Message 3", ActorRef.noSender());
    }
}
