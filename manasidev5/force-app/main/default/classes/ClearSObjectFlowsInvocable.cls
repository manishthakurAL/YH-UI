public with sharing class ClearSObjectFlowsInvocable {
    @InvocableMethod(label='Clear Bypass SObject Trigger Flows')
    public static void clearBypassFlow(List<String> sObjectAPIName){
        if(sObjectAPIName == null || sObjectAPIName.size() != 1){
            throw new ClearSObjectFlowsException('Incorrect parameter');
        } else {
            BypassFlowHandler.clearSObjectFlows(sObjectAPIName[0]);
        }
    }

    public class ClearSObjectFlowsException extends Exception{}
}