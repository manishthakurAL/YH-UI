public inherited sharing class FindDuplicateSObjectService {
    public List<List<Sobject>> findDuplicates(List<SObject> sObjects){
        List<List<SObject>> listOfMatchingRecords = new List<List<SObject>>();
        List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(sObjects);
        for (Datacloud.FindDuplicatesResult dupeResult: duplicateResults) {
            List<Sobject> matchingRecords  = new List<Sobject>();
            Set<Id> matchedIds = new Set<Id>();
            for (Datacloud.DuplicateResult dupeRes: dupeResult.getDuplicateResults()) {
              for (Datacloud.MatchResult matchRes: dupeRes.getMatchResults()) {
                for (Datacloud.MatchRecord matchRec: matchRes.getMatchRecords()) {
                  SObject matchingRecord = (SObject) matchRec.getRecord();
                  if (!matchedIds.contains(matchingRecord.Id)) {
                    matchedIds.add(matchingRecord.Id);
                    matchingRecords.add(matchingRecord);
                  }
                }
              }
            }
            listOfMatchingRecords.add(matchingRecords);
        }
        return listOfMatchingRecords;
    }
}