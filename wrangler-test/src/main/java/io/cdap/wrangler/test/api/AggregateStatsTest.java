@Test
public void testAggregateStats() throws Exception {
    List<Row> rows = Arrays.asList(
        new Row("data_transfer_size", "1MB", "response_time", "2s"),
        new Row("data_transfer_size", "512KB", "response_time", "1.5s")
    );

    String[] recipe = new String[] {
        "aggregate-stats :data_transfer_size :response_time total_size_mb total_time_sec"
    };

    List<Row> results = TestingRig.execute(recipe, rows);
    Assert.assertEquals(1, results.size());

    double expectedSizeMb = (1024 * 1024 + 512 * 1024) / (1024.0 * 1024);
    double expectedTimeSec = (2000 + 1500) / 1000.0;

    Assert.assertEquals(expectedSizeMb, results.get(0).getValue("total_size_mb"), 0.001);
    Assert.assertEquals(expectedTimeSec, results.get(0).getValue("total_time_sec"), 0.001);
}
