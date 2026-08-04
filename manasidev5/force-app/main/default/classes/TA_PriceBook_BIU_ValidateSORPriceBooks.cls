public with sharing class TA_PriceBook_BIU_ValidateSORPriceBooks implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {

    public void beforeInsert(List<Pricebook2> newList) {
        List<Pricebook2> pbList = new List<Pricebook2>();
        
        for(Pricebook2 pbRec : newList){      
            if(pbRec.Type__c == PricebookDecorator.TYPE_SOR){
                pbList.add(pbRec);         
            }
        }
        new SORPriceBooksValidator(pbList, null).validate();
    }

    public void beforeUpdate(List<Pricebook2> newList, List<Pricebook2> oldList) {
        Map<Id, Pricebook2> pbOldMap = new Map<Id, Pricebook2>(oldList);
        List<Pricebook2> pbList = new List<Pricebook2>();
        
        for(Pricebook2 pbRec : newList){      
            if(pbRec.Type__c == PricebookDecorator.TYPE_SOR && 
                    (pbRec.EffectiveStartDate__c != pbOldMap.get(pbRec.Id).EffectiveStartDate__c ||
                    pbRec.EffectiveEndDate__c != pbOldMap.get(pbRec.Id).EffectiveEndDate__c)){
                pbList.add(pbRec);         
            }
        }
        new SORPriceBooksValidator(pbList, pbOldMap).validate();
    }
}