public with sharing class StringToCollectionService {
    @InvocableMethod(label='String to collection using delimitter' description='String to collection using delimitter.')
    public static List<Output> convertStringToCollection(List<Input> inputs) {
        List<Output> results = new List<Output>();
        if(inputs != null && !inputs.isEmpty()){
            Output output = new Output();
            for(Input input : inputs){
                Set<String> caseMilestoneStartDateSyncedIds = String.isNotBlank(input.inputString)
                                                    ? new Set<String>(input.inputString.split(input.delimitter)) 
                                                    : new Set<String>();
                
                if(!caseMilestoneStartDateSyncedIds.isEmpty()){
                    output.caseMilestoneStartDateSyncedIds.addAll(caseMilestoneStartDateSyncedIds);
                }
                results.add(output);
            }
        }
        return results;
    }

    public class Input {
        @InvocableVariable(required=false label='Input string' description='String to be split into a collection.')
        public String inputString;

        @InvocableVariable(required=true label='Delimitter' description='Delimitter to use for splitting string.')
        public String delimitter;
    }

    public class Output {
        @InvocableVariable(required=false label='Collection of string' description='Collection of string.')
        public List<String> caseMilestoneStartDateSyncedIds;

        public Output(){
            this.caseMilestoneStartDateSyncedIds = new List<String>();
        }
    }
}