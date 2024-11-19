package eval_lab;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

public class PopularTopicConsumer2 {
    public static void main(String[] args) {
        // Consumer configuration
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "popular-topic-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        // Create KafkaConsumer
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);

        // Subscribe to all topics using a regex pattern
        consumer.subscribe(Pattern.compile(".*")); // Subscribe to all topics

        // Message counts per topic
        Map<String, Integer> topicMessageCount = new ConcurrentHashMap<>();

        try {
            while (true) {
                // Poll for new messages
                ConsumerRecords<String, String> records = consumer.poll(Duration.of(5, ChronoUnit.MINUTES));


                for (ConsumerRecord<String, String> record : records) {
                    String topic = record.topic();

                    // Update the message count for the topic
                    topicMessageCount.merge(topic, 1, Integer::sum);

                    // Determine the topic(s) with the highest count
                    int maxCount = topicMessageCount.values().stream().max(Integer::compare).orElse(0);
                    System.out.print("Most popular topic(s): ");
                    topicMessageCount.forEach((key, value) -> {
                        if (value == maxCount) {
                            System.out.print(key + " ");
                        }
                    });
                    System.out.println();
                }
            }
        } finally {
            consumer.close();
        }
    }
}

