public with sharing class BypassSObjectFlowsInvocable {
 
    @InvocableMethod(label='Bypass Trigger Flows for a SObject')
    public static void bypassFlow(List<String> sObjectAPIName){
        if(sObjectAPIName == null || sObjectAPIName.size() != 1){
            throw new BypassSObjectFlowsException('Incorrect parameter');
        } else {
            BypassFlowHandler.bypassSObjectFlows(sObjectAPIName[0]);
        }
    }

    public class BypassSObjectFlowsException extends Exception{}
}