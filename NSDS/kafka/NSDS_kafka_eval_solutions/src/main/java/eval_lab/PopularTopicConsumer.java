package eval_lab;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.IntegerDeserializer;
import org.apache.kafka.common.serialization.IntegerSerializer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class PopularTopicConsumer {
    private static final String defaultGroupId = "groupB";
    private static final String defaultTopic = "inputTopic";

    private static final String serverAddr = "localhost:9092";

    public static void main(String[] args) {
        // If there are arguments, use the first as group
        // Otherwise, use default group
        String groupId = args.length >= 1 ? args[0] : defaultGroupId;

        final Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, serverAddr);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);

        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, IntegerDeserializer.class.getName());

        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, String.valueOf(true));

        KafkaConsumer<String, Integer> consumer = new KafkaConsumer<>(props);
        System.out.println("consumer sees: " +
                consumer.listTopics());

        consumer.subscribe(Collections.singletonList(defaultTopic));
        System.out.println("consumer subscribed to topic: "
                + defaultTopic
                + " with partitions: "
                + consumer.partitionsFor(defaultTopic).toString());

        Map<String, Integer> counts = new HashMap<>();

        while (true) {
            final ConsumerRecords<String, Integer> records = consumer.poll(Duration.of(5, ChronoUnit.MINUTES));
            System.out.println("\nnew iteration \n");
            for (final ConsumerRecord<String, Integer> record : records) {
                System.out.println("\nreading from partition:\n" + record.partition());
                String key = record.key();
                counts.compute(key, (k, v) -> v == null ? 1 : v + 1);
                int max = counts.values().stream()
                        .max(Integer::compareTo)
                        .orElse(0);
                counts.entrySet().stream()
                        .filter(e -> e.getValue() == max)
                        .forEach(System.out::println);
            }
        }
    }
}