public with sharing class TA_Tenancy_AU_UpdateOccupanyEndDate  implements TriggerAction.AfterUpdate { 
    List<YH_Tenancy__c> newList;
    Map<Id, YH_Tenancy__c> oldMap;

    public void afterUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        List<Member__c> tenantMembersToUpdate = new List<Member__c>();
        this.newList = newList;
        this.oldMap = new Map<Id, YH_Tenancy__c>(oldList);
        for (YH_Tenancy__c tenancy : newList) {
               if (this.tenantMembers.containsKey(tenancy.Id) ) {
                for (Member__c tenantMember : this.tenantMembers.get(tenancy.Id)) {
                    tenantMember.OccupancyEndDate__c = tenancy.TenancyEndDate__c;
                    tenantMembersToUpdate.add(tenantMember);
                }
            }
        }
        update tenantMembersToUpdate;
    }

    private Map<Id, List<Member__c>> tenantMembers {
        get {
            if (this.tenantMembers == null) {
                this.tenantMembers = new Map<Id, List<Member__c>>();
                Set<Id> tenancyIds = new Set<Id>();
                for (YH_Tenancy__c tenancy : this.newList) {
                    if (tenancy.Active__c == false && tenancy.Active__c != this.oldMap.get(tenancy.Id).Active__c) {
                        tenancyIds.add(tenancy.Id);
                    }
                }

                if (!tenancyIds.isEmpty()) {
                    for(Member__c member : [SELECT Id, Tenancy__c, OccupancyEndDate__c 
                                        FROM   Member__c 
                                        WHERE Tenancy__c IN :tenancyIds AND OccupancyEndDate__c = null ORDER BY Tenancy__c ASC]){
                        if(!this.tenantMembers.containsKey(member.Tenancy__c)){
                            this.tenantMembers.put(member.Tenancy__c, new List<Member__c>());
                        }
                        this.tenantMembers.get(member.Tenancy__c).add(member);
                    }
                }
            } 
            return this.tenantMembers;
        } set;
    }    
}