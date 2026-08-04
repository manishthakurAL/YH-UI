public inherited sharing class SORPriceBooksValidator {
    private List<Pricebook2> pbNewList;
    private Map<Id, Pricebook2> pbOldMap;

    private Map<Id, Pricebook2> pbExistingMap{
        get{
            if(this.pbExistingMap == null){
                this.pbExistingMap = new Map<Id, Pricebook2>();
                for(Pricebook2 pbRec : [SELECT Id, EffectiveStartDate__c, EffectiveEndDate__c
                        FROM Pricebook2
                        WHERE Type__c = :PricebookDecorator.TYPE_SOR]){
                    this.pbExistingMap.put(pbRec.Id, pbRec);
                }
            }
            return this.pbExistingMap;
        }
        set;
    }

    private Set<Id> pbIdsOutOfRangeSet{
        get{
            if(this.pbIdsOutOfRangeSet == null){
                this.pbIdsOutOfRangeSet = new Set<Id>();
                Map<Id, Pricebook2> pbNewMap = new Map<Id, Pricebook2>(this.pbNewList);
                for(WorkOrder woRec : [SELECT Id, Pricebook2Id,ReportedDate__c FROM WorkOrder WHERE Pricebook2Id IN :pbNewMap.keySet()]){
                    Pricebook2 pbRec = pbNewMap.get(woRec.Pricebook2Id);
                    if(this.pbIdsOutOfRangeSet.contains(woRec.Pricebook2Id)){
                        continue;
                    }else if(isOutOfRange(woRec, pbRec)){
                        this.pbIdsOutOfRangeSet.add(woRec.Pricebook2Id);
                    }
                }
            }
            return this.pbIdsOutOfRangeSet;
        }
        set;
    }

    public SORPriceBooksValidator( List<Pricebook2> pbNewList, Map<Id, Pricebook2> pbOldMap){
        this.pbNewList = pbNewList;
        this.pbOldMap = pbOldMap;
    }
    
    public void validate(){

        validateIncomingPricebooks();
        validateExistingPricebooks();

        if(this.pbOldMap != null){
            validateWorkOrders();
        }
    }

    private void validateIncomingPricebooks(){

        this.pbNewList.sort(new ComparatorPricebook());

        for(Integer i = 0; i < this.pbNewList.size(); i++){
            Pricebook2 pbNewRec = this.pbNewList[i];
            for(Integer j = i + 1; j < this.pbNewList.size(); j++){
                Pricebook2 pbNewRec2 = this.pbNewList[j];
                if(pbNewRec.EffectiveEndDate__c == null && pbNewRec.EffectiveStartDate__c <=  pbNewRec2.EffectiveStartDate__c){
                    pbNewRec.addError(PricebookDecorator.ERROR_SOR_OVERLAP);
                    break;
                }else if(pbNewRec.EffectiveEndDate__c != null &&
                    pbNewRec.EffectiveStartDate__c <=  pbNewRec2.EffectiveStartDate__c &&
                    pbNewRec.EffectiveEndDate__c >= pbNewRec2.EffectiveStartDate__c){
                    pbNewRec.addError(PricebookDecorator.ERROR_SOR_OVERLAP);
                    break;
                }
            }
        }
    }

    private void validateExistingPricebooks(){

        for (Pricebook2 pbNewRec : this.pbNewList) {
            for (Pricebook2 existingPbRec : this.pbExistingMap.values()) {
                if (pbOldMap != null && pbOldMap.containsKey(existingPbRec.Id)){
                    continue;
                }

                Boolean overlaps =
                    (existingPbRec.EffectiveEndDate__c == null &&
                        (pbNewRec.EffectiveEndDate__c == null ||
                         existingPbRec.EffectiveStartDate__c <=
                             (pbNewRec.EffectiveEndDate__c != null ? pbNewRec.EffectiveEndDate__c : Date.newInstance(9999, 12, 31))
                        )
                    ) ||
                    (existingPbRec.EffectiveEndDate__c != null &&
                        existingPbRec.EffectiveEndDate__c >= pbNewRec.EffectiveStartDate__c);

                if (overlaps) {
                    pbNewRec.addError(PricebookDecorator.ERROR_SOR_OVERLAP);
                    break;
                }
            }
        }
    }

    private void validateWorkOrders(){
        
        for(Pricebook2 pbNewRec : this.pbNewList){
            if(this.pbIdsOutOfRangeSet.contains(pbNewRec.Id)){
                pbNewRec.addError(PricebookDecorator.ERROR_WORKORDER_OUTOFRANGE);
            }
        }
    }    

    private Boolean isOutOfRange(WorkOrder woRec, Pricebook2 pbRec) {
        boolean isOutOfRange = false;
        if (pbRec.EffectiveEndDate__c == null) {
            isOutOfRange = woRec.ReportedDate__c < pbRec.EffectiveStartDate__c;
        }else{
            isOutOfRange = woRec.ReportedDate__c < pbRec.EffectiveStartDate__c ||
            woRec.ReportedDate__c > pbRec.EffectiveEndDate__c;
        }
        return isOutOfRange;
    }

    public class ComparatorPricebook implements Comparator<Pricebook2>{
        public Integer compare(Pricebook2 pbRec1, Pricebook2 pbRec2){
            Integer result = 0;
            if(pbRec1.EffectiveStartDate__c == pbRec2.EffectiveStartDate__c){
                result = 0;
            }else{
                result = pbRec1.EffectiveStartDate__c < pbRec2.EffectiveStartDate__c ? -1 : 1;
            }
            return result;
        }
    }
}