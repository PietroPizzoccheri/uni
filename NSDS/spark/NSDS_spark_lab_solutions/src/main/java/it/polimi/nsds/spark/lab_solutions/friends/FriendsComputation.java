package it.polimi.nsds.spark.lab_solutions.friends;

import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;

import java.util.ArrayList;
import java.util.List;

/**
 * Implement an iterative algorithm that implements the transitive closure of friends
 * (people that are friends of friends of ... of my friends).
 *
 * Set the value of the flag useCache to see the effects of caching.
 */
public class FriendsComputation {
    private static final boolean useCache = true;

    public static void main(String[] args) {
        final String master = args.length > 0 ? args[0] : "local[4]";
        final String filePath = args.length > 1 ? args[1] : "./";
        final String appName = useCache ? "FriendsCache" : "FriendsNoCache";

        final SparkSession spark = SparkSession
                .builder()
                .master(master)
                .appName(appName)
                .getOrCreate();
        spark.sparkContext().setLogLevel("ERROR");

        final List<StructField> fields = new ArrayList<>();
        fields.add(DataTypes.createStructField("person", DataTypes.StringType, false));
        fields.add(DataTypes.createStructField("friend", DataTypes.StringType, false));
        final StructType schema = DataTypes.createStructType(fields);

        final Dataset<Row> input = spark
                .read()
                .option("header", "false")
                .option("delimiter", ",")
                .schema(schema)
                .csv(filePath + "files/friends/friends.csv");

        if (useCache) {
            input.cache();
        }

        Dataset<Row> allFriends = input;
        long oldCount = 0;
        long newCount = allFriends.count();
        int iteration = 0;

        while (newCount > oldCount) {
            iteration++;
            // One could also join allFriends with allFriends.
            // It is a tradeoff between the number of joins and the size of the tables to join.
            Dataset<Row> newFriends = allFriends
                    .withColumnRenamed("friend", "to-join")
                    .join(
                            input.withColumnRenamed("person", "to-join"),
                            "to-join"
                    )
                    .drop("to-join");

            allFriends = allFriends
                    .union(newFriends)
                    .distinct();

            if (useCache) {
                allFriends.cache();
            }
            oldCount = newCount;
            newCount = allFriends.count();
            System.out.println("Iteration: " + iteration + " - Count: " + newCount);
        }

        allFriends.show();
        spark.close();
    }
}
