@Test
public void testTimeDurationParsing() {
    Assert.assertEquals(5000, new TimeDuration("5s").getMillis());
    Assert.assertEquals(120000, new TimeDuration("2m").getMillis());
}