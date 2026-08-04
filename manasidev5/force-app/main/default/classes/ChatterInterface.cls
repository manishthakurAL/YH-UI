public interface ChatterInterface {
    ConnectApi.BatchResult[] postToChatterFeedBatchResults(Id subjectId, List<String> messages);
}