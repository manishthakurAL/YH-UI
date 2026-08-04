public with sharing class ClearBypassFlowInvocable {

    @InvocableMethod(label='Clear Bypass a Trigger Flow')
    public static void clearBypassFlow(List<String> flowName){
        if(flowName == null || flowName.isEmpty()){
            throw new ClearBypassFlowException('Flow Bypass name input should not be null or Empty');
        } else {
            BypassFlowHandler.clearBypassFlow(flowName[0]);
        }
    }

    public class ClearBypassFlowException extends Exception{}
}