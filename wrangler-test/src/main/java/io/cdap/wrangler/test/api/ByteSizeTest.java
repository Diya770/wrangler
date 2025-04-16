@Test
public void testByteSizeParsing() {
    Assert.assertEquals(10240, new ByteSize("10KB").getBytes());
    Assert.assertEquals(1572864, new ByteSize("1.5MB").getBytes());
}