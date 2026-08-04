public with sharing class BypassFlowInvocable {
    
    @InvocableMethod(label='Bypass a Trigger Flow')
    public static void bypassFlow(List<String> flowName){
        if(flowName == null || flowName.isEmpty()){
            throw new BypassFlowException('Flow Bypass name input should not be null or Empty');
        } else {
            BypassFlowHandler.bypassFlow(flowName[0]);
        }
    }

    public class BypassFlowException extends Exception{}
}