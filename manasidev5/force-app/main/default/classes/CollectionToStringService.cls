public with sharing class CollectionToStringService {
    @InvocableMethod(label='Collection to string using delimitter' description='Collection to string using delimitter.')
    public static List<Output> convertCollectionToString(List<Input> inputs) {
        List<Output> results = new List<Output>();
        for (Input input : inputs) {
            Output output = new Output();
            if (!input.inputStringCollection.isEmpty()) {
                output.outputString = String.join(input.inputStringCollection, input.delimitter);
            }
            results.add(output);
        }
        return results;
    }

    public class Input {
        @InvocableVariable(required=true label='Input string collection' description='Input string collection.')
        public List<String> inputStringCollection;

        @InvocableVariable(required=true label='Delimitter' description='Delimitter.')
        public String delimitter;
    }

    public class Output {
        @InvocableVariable(required=true label='Output string' description='Output sting.')
        public String outputString;
    }
}