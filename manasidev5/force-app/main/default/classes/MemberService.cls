public inherited sharing class MemberService {
    
    public Member__c createMember(Id tenancyId, Id contactId, String memberType, Date dateOfOccupancy, String synchPropertyAddressOnActivation, Address synchAddress ) {
        Member__c mem = new Member__c(
            Tenancy__c = tenancyId,
            Contact__c = contactId,
            Type__c = memberType,
            DateOfOccupancy__c = dateOfOccupancy
        );
        if(!String.isBlank(synchPropertyAddressOnActivation)){
            mem.SynchPropertyAddressOnActivation__c = synchPropertyAddressOnActivation;
            mem.SynchAddress__City__s = synchAddress.getCity();
            mem.SynchAddress__Street__s = synchAddress.getStreet();
            mem.SynchAddress__PostalCode__s = synchAddress.getPostalCode();
            mem.SynchAddress__CountryCode__s = 'GB';
        }
        return mem;
    }
    
    public  Member__c setDateOfOccupancy(Member__c member, Date dateOfOccupancy) {
        member.DateOfOccupancy__c = dateOfOccupancy;
        return member;
    }

    public  Member__c setOccupancyEndDate(Member__c member, Date occupancyEndDate) {
        member.OccupancyEndDate__c = occupancyEndDate;
        return member;
    }

    public  Member__c setSynchAddressOnDeactivation(Member__c member, String synchPropertyAddressOnDeActivation, Address synchAddress) {
        setSynchAddressOnDeactivation(member, synchPropertyAddressOnDeActivation,  synchAddress.getCity(), synchAddress.getStreet(), synchAddress.getPostalCode());
        return member;
    }

    public  Member__c setSynchAddressOnDeactivation(Member__c member, String synchPropertyAddressOnDeActivation, String city, String street, String postalCode) {
        member.SynchPropertyAddressOnDeactivation__c = synchPropertyAddressOnDeActivation; 
        member.SynchAddress__City__s = city;
        member.SynchAddress__Street__s = street;
        member.SynchAddress__PostalCode__s = postalCode;
        member.SynchAddress__CountryCode__s = 'GB';
        return member;
    }

    public  List<Member__c> getActiveMembersByContactId(Id contactId) {
        List<Member__c> memberList = new List<Member__c>();
        if(contactId != null){
            // Tenancy__r.Property__r.CurrentGrossRent__c is deliberately NOT
            // selected here: this class is "inherited sharing", so for portal
            // users (who have sharing access to their own Tenancy but not to
            // YH_Property__c) that field silently resolves to null. Callers
            // needing the property's rent amount must fetch it separately via
            // a without-sharing path (see TenancyService.getTenanciesWithRentDetails).
            memberList = [SELECT id, DateOfOccupancy__c, Tenancy__c,Contact__r.name,
                                Tenancy__r.YH_TenancyNumber__c, IsActive__c,
                                Tenancy__r.PropertyAddress__c, Tenancy__r.AssetClass__c,
                                Tenancy__r.OrchardChequeDigit__c, Tenancy__r.Property__r.RentTag__c,
                          		Tenancy__r.OrchardPropertyReferenceNumber__c, Tenancy__r.RentTag__c,
                                Tenancy__r.RentType__c,Tenancy__r.YH_ChargeFrequency__c
                                FROM Member__c WHERE Contact__c = :contactId
                                AND IsActive__c = TRUE
                                AND (Type__c =: MemberDecorator.TYPE_JOINT OR Type__c =: MemberDecorator.TYPE_SOLO)];
        }
        return memberList;
    }

    public  List<Member__c> getActiveMembersByContactIdOrderByTenancyStartDate(Id contactId) {
        List<Member__c> memberList = new List<Member__c>();
        if(contactId != null){
            memberList = [SELECT Id, TenancyStartDate__c FROM Member__c WHERE Contact__c = :contactId AND IsActive__c = true
                    AND (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT) ORDER BY TenancyStartDate__c ASC];
        }
        return memberList;
    }
}