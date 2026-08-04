public with sharing class StringSplitterInvocable {

    @InvocableMethod(label='Split String to Collection' description='Splits a comma-separated string into a collection of strings.')
    public static List<Output> splitString(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input input : inputs) {
            Output output = new Output();
            if (String.isNotBlank(input.inputString)) {
                output.outputCollection = input.inputString.split(',');
            } else {
                output.outputCollection = new List<String>();
            }
            results.add(output);
        }
        return results;
    }

    public class Input {
        @InvocableVariable(required=false label='Input String' description='Comma-separated string to be split into a collection.')
        public String inputString;
    }

    public class Output {
        @InvocableVariable(required=true label='Output Collection' description='Collection of strings resulting from splitting the input string.')
        public List<String> outputCollection;
    }
}