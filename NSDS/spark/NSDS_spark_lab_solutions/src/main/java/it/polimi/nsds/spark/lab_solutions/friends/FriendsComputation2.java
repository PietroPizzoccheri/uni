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
public class FriendsComputation2 {
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
        Dataset<Row> newFriends = input;
        long newCount = newFriends.count();
        int iteration = 0;

        while (newCount > 0) {
            iteration++;
            newFriends = newFriends
                    .withColumnRenamed("friend", "to-join")
                    .join(
                            allFriends.withColumnRenamed("person", "to-join"),
                            "to-join"
                    )
                    .drop("to-join");

            newFriends = newFriends.except(allFriends);

            allFriends = allFriends
                    .union(newFriends);

            if (useCache) {
                newFriends.cache();
                allFriends.cache();
            }
            newCount = newFriends.count();
            System.out.println("Iteration: " + iteration + " - New count: " + newCount);
        }

        allFriends.show();
        spark.close();
    }
}
