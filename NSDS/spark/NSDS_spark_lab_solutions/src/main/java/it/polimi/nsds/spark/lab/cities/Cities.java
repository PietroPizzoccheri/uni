package it.polimi.nsds.spark.lab.cities;

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.streaming.StreamingQuery;
import org.apache.spark.sql.streaming.StreamingQueryException;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;
import static org.apache.spark.sql.functions.*;


import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeoutException;

public class Cities {
    public static void main(String[] args) throws TimeoutException {
        final String master = args.length > 0 ? args[0] : "local[4]";
        final String filePath = args.length > 1 ? args[1] : "./NSDS/spark/NSDS_spark_lab_solutions/";

        final SparkSession spark = SparkSession
                .builder()
                .master(master)
                .appName("SparkEval")
                .getOrCreate();
        spark.sparkContext().setLogLevel("ERROR");

        final List<StructField> citiesRegionsFields = new ArrayList<>();
        citiesRegionsFields.add(DataTypes.createStructField("city", DataTypes.StringType, false));
        citiesRegionsFields.add(DataTypes.createStructField("region", DataTypes.StringType, false));
        final StructType citiesRegionsSchema = DataTypes.createStructType(citiesRegionsFields);

        final List<StructField> citiesPopulationFields = new ArrayList<>();
        citiesPopulationFields.add(DataTypes.createStructField("id", DataTypes.IntegerType, false));
        citiesPopulationFields.add(DataTypes.createStructField("city", DataTypes.StringType, false));
        citiesPopulationFields.add(DataTypes.createStructField("population", DataTypes.IntegerType, false));
        final StructType citiesPopulationSchema = DataTypes.createStructType(citiesPopulationFields);

        final Dataset<Row> citiesPopulation = spark
                .read()
                .option("header", "true")
                .option("delimiter", ";")
                .schema(citiesPopulationSchema)
                .csv(filePath + "files/cities/cities_population.csv");

        final Dataset<Row> citiesRegions = spark
                .read()
                .option("header", "true")
                .option("delimiter", ";")
                .schema(citiesRegionsSchema)
                .csv(filePath + "files/cities/cities_regions.csv");


        final Dataset<Row> citiesRegionPopulation = citiesPopulation.join(citiesRegions,
                citiesPopulation.col("city").equalTo(citiesRegions.col("city")))
                .select(citiesPopulation.col("id"),
                        citiesPopulation.col("city"),
                        citiesRegions.col("region"),
                        citiesPopulation.col("population"));;
        citiesRegionPopulation.cache();

        final Dataset<Row> q1 = citiesRegionPopulation
                .drop("id")
                .groupBy("region")
                .sum();

        q1.show();

        final Dataset<Row> q2 = citiesRegionPopulation
                .drop("id")
                .groupBy("region")
                .agg(
                        count("city"),
                        max("population")
                );

        q2.show();

        // JavaRDD where each element is an integer and represents the population of a city
        JavaRDD<Integer> population = citiesPopulation.toJavaRDD().map(r -> r.getInt(2));
        int year = 0;
        long count  = population.reduce((a, b) -> a+b);

        while (count < 100 * 1000 * 1000) {
            year++;
            population = population.map(p -> p > 1000 ? p+(int)(p*0.01) : p-(int)(p*0.1));
            population.cache();
            count = population.reduce((a, b) -> a+b);
            System.out.println("Year: " + year + ", count: " + count);
        }

        // Bookings: the value represents the city of the booking
        final Dataset<Row> bookings = spark
                .readStream()
                .format("rate")
                .option("rowsPerSecond", 1)
                .load();

        final StreamingQuery q4 = citiesRegionPopulation.join(bookings ,
                        citiesRegionPopulation.col("id")
                                .equalTo(
                                        bookings.col("value")))
                .drop("id" , "population")
                .groupBy(
                        col("region"),
                        window(col("timestamp"), "30 seconds", "5 seconds")
                )
                .count()
                .writeStream()
                .outputMode("complete")
                .format("console")
                .start();

        try {
            q4.awaitTermination();
        } catch (final StreamingQueryException e) {
            e.printStackTrace();
        }

        spark.close();
    }
}