public with sharing class BypassFlowHandler {
    @testVisible
    private static Set<String> bypassedFlows{
        get{
            if(bypassedFlows == null){
                bypassedFlows = new Set<String>();
            }
            return bypassedFlows;
        }
        set;
    }
	
    @testVisible
    private static Map<String, List<String>> flowsBySObject{
        get{
            if(flowsBySObject == null){
                flowsBySObject = new Map<String, List<String>>();
            }
            return flowsBySObject;
        }
        set;
    }

    @testVisible private static Boolean bypassAllFlows = false;

    @InvocableMethod(label='Is Trigger Flow bypassed')
	public static List<Boolean> isFlowBypassed(List<String> flowName){
        if(flowName == null || flowName.isEmpty()){
            throw new BypassFlowHandlerException('Flow Name is empty');
        }
        List<Boolean> results = new List<Boolean>();
        for(String flow : flowName){
            results.add(bypassAllFlows || bypassedFlows.contains(flow));
        }
		return results;
	}
	
    public static void bypassFlow(String flowName){
		bypassedFlows.add(flowName);
	}

    public static void bypassSObjectFlows(String sObjectAPIName){
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectAPIName);
        if(!flowsBySObject.containsKey(sObjectAPIName)){
            flowsBySObject.put(sObjectAPIName, new List<String>());
            for(FlowTrigger__mdt flwTriggerMdt : [SELECT Id, FlowAPIName__c, sObjectFlowTriggerSetting__c 
                                                    FROM FlowTrigger__mdt 
                                                    WHERE sObjectFlowTriggerSetting__r.SObjectAPIName__c = :sObjectAPIName]){
                flowsBySObject.get(sObjectAPIName).add(flwTriggerMdt.FlowAPIName__c);
                bypassedFlows.add(flwTriggerMdt.FlowAPIName__c);
            }
        } else {
            bypassedFlows.addAll(flowsBySObject.get(sObjectAPIName));
        }
    }

    public static void bypassAllFlows(){
        bypassAllFlows = true;
    }
	
	public static void clearBypassFlow(String flowName){
			bypassedFlows.remove(flowName);
	}

    public static void clearSObjectFlows(String sObjectAPIName){
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectAPIName);
        if(flowsBySObject.containsKey(sObjectAPIName)){
            for(String flowName : flowsBySObject.get(sObjectAPIName)){
                bypassedFlows.remove(flowName);
            }
        }
    }

    public static void clearBypassAllFlows(){
        bypassAllFlows = false;
    }

    public class BypassFlowHandlerException extends Exception{}
}