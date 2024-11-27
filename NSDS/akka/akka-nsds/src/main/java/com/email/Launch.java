package com.email;

import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import com.email.messages.PutMsg;

import java.io.IOException;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Launch {

    private static final int numThreads = 10;

    private static final String[] NAMES = {
            "Alice", "Bob", "Charlie", "David", "Eve",
            "Frank", "Grace", "Hank", "Ivy", "Jack"
    };

    public static void main(String[] args) {

        final ActorSystem sys = ActorSystem.create("System");
        final ActorRef supervisor = sys.actorOf(SupervisorActor.props(), "supervisor");
        sys.actorOf(ClientActor.props(supervisor, NAMES), "client");

        String[] EMAILS = new String[NAMES.length];

        int j = 0;
        for (String name : NAMES) {
            String email = name.toLowerCase() + "@example.com";
            EMAILS[j] = email;
            j++;
        }

        // send messages from multiple threads in parallel
        final ExecutorService exec = Executors.newFixedThreadPool(numThreads);

        Random r = new Random(100);

        for (int k = 0; k < 10; k++) {
            int finalK = k;
            exec.submit(() -> supervisor.tell(new PutMsg(NAMES[finalK], EMAILS[finalK]), ActorRef.noSender()));
        }

        // forcing failure
        try {
            Thread.sleep(r.nextInt(20000));
            exec.submit(() -> supervisor.tell(new PutMsg("Fail!", ""), ActorRef.noSender()));
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        // wait for all messages to be sent and received
        try {
            System.in.read();
        } catch (IOException e) {
            e.printStackTrace();
        }
        exec.shutdown();
        sys.terminate();
    }
}
