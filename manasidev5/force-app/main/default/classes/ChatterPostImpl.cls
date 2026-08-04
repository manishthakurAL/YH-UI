public with sharing class ChatterPostImpl implements ChatterInterface {
    public ConnectApi.BatchResult[] postToChatterFeedBatchResults( Id subjectId, List<String> messages){
        List <ConnectApi.BatchInput> batchInputs = new List< ConnectApi.BatchInput>();
        for(String message: messages){
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.subjectId = subjectId;
            
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = message;

            body.messageSegments.add(textSegment);
            input.body = body;
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
            batchInputs.add(batchInput);
        }
        ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        return batchResults;
    }
}