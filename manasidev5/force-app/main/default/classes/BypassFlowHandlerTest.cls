@isTest(seeAllData=false)
public class BypassFlowHandlerTest {
    @IsTest
	static void bypassFlowTest() {
        String flowName = 'Sample Flow';
        BypassFlowHandler.bypassFlow(flowName);
        
        Assert.areEqual(1, BypassFlowHandler.bypassedFlows.size());
        Assert.isTrue(BypassFlowHandler.bypassedFlows.contains(flowName));
    }
    
    @IsTest
	static void bypassSObjectFlowsTest() {
        String sObjectName = 'Case';
        BypassFlowHandler.bypassSObjectFlows(sObjectName);
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.isTrue(BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
    }

    @IsTest
	static void bypassAllFlowsTest() {
        BypassFlowHandler.bypassAllFlows();
        
        Assert.isTrue(BypassFlowHandler.bypassAllFlows);
    }

    @IsTest
	static void clearBypassFlowTest() {
        String flowName = 'Sample Flow';
        BypassFlowHandler.bypassFlow(flowName);
        
        Assert.areEqual(1, BypassFlowHandler.bypassedFlows.size());
        Assert.isTrue(BypassFlowHandler.bypassedFlows.contains(flowName));

        BypassFlowHandler.clearBypassFlow(flowName);
        
        Assert.areEqual(0, BypassFlowHandler.bypassedFlows.size());
        Assert.areEqual(false, BypassFlowHandler.bypassedFlows.contains(flowName));
    }
    
    @IsTest
	static void clearBypassSObjectFlowsTest() {
        String sObjectName = 'Case';
        BypassFlowHandler.bypassSObjectFlows(sObjectName);
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.isTrue(BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
        Assert.isTrue(BypassFlowHandler.bypassedFlows.size() > 1);

        BypassFlowHandler.clearSObjectFlows(sObjectName);
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.areEqual(true, BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
        Assert.areEqual(0, BypassFlowHandler.bypassedFlows.size());
    }

    @IsTest
	static void clearBypassAllFlowsTest() {
        BypassFlowHandler.bypassAllFlows();
        
        Assert.isTrue(BypassFlowHandler.bypassAllFlows);

        BypassFlowHandler.clearBypassAllFlows();
        
        Assert.isTrue(!BypassFlowHandler.bypassAllFlows);
    }

    @IsTest
	static void bypassFlowInvocableTest() {
        String flowName = 'Sample Flow';
        BypassFlowInvocable.bypassFlow(new List<String>{flowName});
        
        Assert.areEqual(1, BypassFlowHandler.bypassedFlows.size());
        Assert.isTrue(BypassFlowHandler.bypassedFlows.contains(flowName));
    }

    @IsTest
	static void bypassFlowInvocableExceptionTest() {
        String exceptionMessage;
        try{
            BypassFlowInvocable.bypassFlow(null);
        } catch (BypassFlowInvocable.BypassFlowException e){
            exceptionMessage = e.getMessage();
        }
        
        Assert.areEqual('Flow Bypass name input should not be null or Empty', exceptionMessage);
    }

    @IsTest
	static void bypassSObjectFlowsInvocableTest() {
        String sObjectName = 'Case';
        BypassSObjectFlowsInvocable.bypassFlow(new List<String>{sObjectName});
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.isTrue(BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
    }

    @IsTest
	static void bypassSObjectFlowsInvocableExceptionTest() {
        String exceptionMessage;
        try{
            BypassSObjectFlowsInvocable.bypassFlow(null);
        } catch (BypassSObjectFlowsInvocable.BypassSObjectFlowsException e){
            exceptionMessage = e.getMessage();
        }
        
        Assert.areEqual('Incorrect parameter', exceptionMessage);
    }

    @IsTest
	static void clearBypassFlowInvocableTest() {
        String flowName = 'Sample Flow';
        BypassFlowInvocable.bypassFlow(new List<String>{flowName});
        
        Assert.areEqual(1, BypassFlowHandler.bypassedFlows.size());
        Assert.isTrue(BypassFlowHandler.bypassedFlows.contains(flowName));

        ClearBypassFlowInvocable.clearBypassFlow(new List<String>{flowName});

        Assert.areEqual(0, BypassFlowHandler.bypassedFlows.size());
        Assert.areEqual(false, BypassFlowHandler.bypassedFlows.contains(flowName));
    }

    @IsTest
	static void clearBypassFlowInvocableExceptionTest() {
        String exceptionMessage;
        try{
            ClearBypassFlowInvocable.clearBypassFlow(null);
        } catch (ClearBypassFlowInvocable.ClearBypassFlowException e){
            exceptionMessage = e.getMessage();
        }
        
        Assert.areEqual('Flow Bypass name input should not be null or Empty', exceptionMessage);
    }

    @IsTest
	static void clearSObjectFlowsInvocableTest() {
        String sObjectName = 'Case';
        BypassFlowHandler.bypassSObjectFlows(sObjectName);
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.isTrue(BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
        Assert.isTrue(BypassFlowHandler.bypassedFlows.size() > 1);

        ClearSObjectFlowsInvocable.clearBypassFlow(new List<String>{sObjectName});
        
        Assert.areEqual(1, BypassFlowHandler.flowsBySObject.size());
        Assert.areEqual(true, BypassFlowHandler.flowsBySObject.containsKey(sObjectName));
        Assert.areEqual(0, BypassFlowHandler.bypassedFlows.size());
    }

    @IsTest
	static void clearSObjectFlowsInvocableExceptionTest() {
        String exceptionMessage;
        try{
            ClearSObjectFlowsInvocable.clearBypassFlow(null);
        } catch (ClearSObjectFlowsInvocable.ClearSObjectFlowsException e){
            exceptionMessage = e.getMessage();
        }
        
        Assert.areEqual('Incorrect parameter', exceptionMessage);
    }

    @IsTest
	static void clearBypassAllFlowsInvocableTest() {
        BypassFlowHandler.bypassAllFlows();
        
        Assert.isTrue(BypassFlowHandler.bypassAllFlows);

        ClearBypassAllFlowsInvocable.clearBypassAllFlows();
        
        Assert.isTrue(!BypassFlowHandler.bypassAllFlows);
    }
}