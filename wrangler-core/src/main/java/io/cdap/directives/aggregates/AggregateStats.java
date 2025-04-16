@Plugin(type = Directive.Type)
@Name("aggregate-stats")
@Description("Aggregates byte sizes and time durations.")
public class AggregateStats implements Directive, Aggregate {
    private String byteColumn;
    private String timeColumn;
    private String totalByteOut;
    private String totalTimeOut;

    private long totalBytes = 0;
    private long totalMillis = 0;

    @Override
    public UsageDefinition define() {
        return UsageDefinition.builder("aggregate-stats")
            .withRequiredArg("byte_column")
            .withRequiredArg("time_column")
            .withRequiredArg("byte_out")
            .withRequiredArg("time_out")
            .build();
    }

    @Override
    public void initialize(Arguments args) {
        this.byteColumn = args.value("byte_column");
        this.timeColumn = args.value("time_column");
        this.totalByteOut = args.value("byte_out");
        this.totalTimeOut = args.value("time_out");
    }

    @Override
    public List<Row> execute(List<Row> rows, ExecutorContext ctx) {
        for (Row row : rows) {
            String byteStr = row.getValue(byteColumn).toString();
            String timeStr = row.getValue(timeColumn).toString();

            totalBytes += new ByteSize(byteStr).getBytes();
            totalMillis += new TimeDuration(timeStr).getMillis();
        }

        double mb = totalBytes / (1024.0 * 1024);
        double sec = totalMillis / 1000.0;

        Row output = new Row();
        output.add(totalByteOut, mb);
        output.add(totalTimeOut, sec);

        return Collections.singletonList(output);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
