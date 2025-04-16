public class TimeDuration extends Token {
    private final long millis;

    public TimeDuration(String value) {
        super(value);
        this.millis = parse(value);
    }

    private long parse(String input) {
        input = input.toLowerCase();
        if (input.endsWith("ms")) return (long)(Double.parseDouble(input.replace("ms", "")));
        if (input.endsWith("s")) return (long)(Double.parseDouble(input.replace("s", "")) * 1000);
        if (input.endsWith("m")) return (long)(Double.parseDouble(input.replace("m", "")) * 60000);
        if (input.endsWith("h")) return (long)(Double.parseDouble(input.replace("h", "")) * 3600000);
        throw new IllegalArgumentException("Invalid time duration: " + input);
    }

    public long getMillis() {
        return millis;
    }
}
