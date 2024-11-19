package utils;

import org.apache.kafka.clients.admin.*;

import java.util.Collections;
import java.util.Properties;
import java.util.Set;

public class TopicManager {
    private static final String defaultTopicName = "inputTopic";
    private static final int defaultTopicPartitions = 4;
    private static final short defaultReplicationFactor = 1;

    private static final String serverAddr = "localhost:9092";

    /**
     * The TopicManager class is responsible for managing Kafka topics.
     *
     * It performs the following operations:
     * 1. Connects to a Kafka server using the specified server address.
     * 2. Lists all available topics and prints them.
     * 3. Deletes a topic if it already exists.
     * 4. Creates a new topic with the specified name, number of partitions, and replication factor.
     *
     * Inputs:
     * - args[0] (optional): The name of the topic to be managed. Defaults to "topicA".
     * - args[1] (optional): The number of partitions for the new topic. Defaults to 4.
     * - args[2] (optional): The replication factor for the new topic. Defaults to 1.
     *
     * If no arguments are provided, the default values are used.
     */
    public static void main(String[] args) throws Exception {
        final String topicName = args.length >= 1 ? args[0] : defaultTopicName;
        final int topicPartitions = args.length >= 2 ? Integer.parseInt(args[1]) : defaultTopicPartitions;
        final short replicationFactor = args.length >= 3 ? Short.parseShort(args[2]) : defaultReplicationFactor;

        Properties props = new Properties();
        props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, serverAddr);
        AdminClient adminClient = AdminClient.create(props);

        ListTopicsResult listResult = adminClient.listTopics();
        Set<String> topicsNames = listResult.names().get();
        System.out.println("Available topics: " + topicsNames);

        for (String topic : topicsNames){
            System.out.println("Deleting topic " + topic);
            DeleteTopicsResult delResult = adminClient.deleteTopics(Collections.singletonList(topic));
            delResult.all().get();
            System.out.println("Done!");
            // Wait for the deletion
            Thread.sleep(1000);
        }

//        if (topicsNames.contains(topicName)) {
//            System.out.println("Deleting topic " + topicName);
//            DeleteTopicsResult delResult = adminClient.deleteTopics(Collections.singletonList(topicName));
//            delResult.all().get();
//            System.out.println("Done!");
//            // Wait for the deletion
//            Thread.sleep(5000);
//        }

//        System.out.println("Adding topic " + topicName + " with " + topicPartitions + " partitions");
//        NewTopic newTopic = new NewTopic(topicName, topicPartitions, replicationFactor);
//        CreateTopicsResult createResult = adminClient.createTopics(Collections.singletonList(newTopic));
//        createResult.all().get();
//        System.out.println("Done!");
    }
}
