public Interface ICaseExternalSharingByCaseType {
    void manageCaseSharingReason(
        List<Case> newList,
        Map<Id, Case> oldMap
    );
}