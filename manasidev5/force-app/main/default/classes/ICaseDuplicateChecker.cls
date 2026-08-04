public Interface ICaseDuplicateChecker {
    Map<Id, List<Case>> getDuplicate(List<Case> caseRecords, Id recordTypeId, String caseType);
}