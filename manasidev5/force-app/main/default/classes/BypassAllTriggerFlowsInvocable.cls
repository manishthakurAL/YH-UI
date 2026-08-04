public with sharing class BypassAllTriggerFlowsInvocable {
    @InvocableMethod(label='Bypass a Trigger Flow')
    public static void bypassAllFlows(){
        BypassFlowHandler.bypassAllFlows();
    }
}