package it.polimi.middleware.kafka.utils;

import org.apache.kafka.clients.admin.*;

import java.util.Properties;
import java.util.Set;

public class TopicsDisplayer {
    private static final String serverAddr = "localhost:9092";

    public static void main(String[] args) throws Exception {

        Properties props = new Properties();
        props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, serverAddr);
        AdminClient adminClient = AdminClient.create(props);

        ListTopicsResult listResult = adminClient.listTopics();
        Set<String> topicsNames = listResult.names().get();
        System.out.println("Available topics: " + topicsNames);
    }
}
