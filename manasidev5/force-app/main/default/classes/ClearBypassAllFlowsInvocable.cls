public with sharing class ClearBypassAllFlowsInvocable {
    
    @InvocableMethod(label='Clear Bypass All Flows')
    public static void clearBypassAllFlows(){
        BypassFlowHandler.clearBypassAllFlows();
    }
}