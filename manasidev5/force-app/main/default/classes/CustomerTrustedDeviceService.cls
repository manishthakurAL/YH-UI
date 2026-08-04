public with sharing class CustomerTrustedDeviceService {
    private CustomerTrustedDevice__c trustedDevice;

    public CustomerTrustedDeviceService(CustomerTrustedDevice__c trustedDevice){
        this.trustedDevice = trustedDevice;
    }

    public CustomerTrustedDevice__c populateLstSeenAtDateTime(){
        this.populateLastSeenAt();
        upsert this.trustedDevice;
        return this.trustedDevice;
    }

    public CustomerTrustedDevice__c initialBuildCustomerTrustedDevice(Id userId, String deviceId, String signature, Datetime firstTrustedAt){
        this.trustedDevice = new CustomerTrustedDevice__c();
        this.trustedDevice.User__c = userId;
        this.trustedDevice.DeviceIdHash__c = deviceId;
        this.trustedDevice.FirstTrustedAt__c = firstTrustedAt;
        this.trustedDevice.Signature__c = signature;
        return this.trustedDevice;
    }

    public CustomerTrustedDevice__c populateTrustDateTime(Datetime trustedDateTime){
        this.populateLastSeenAt();
        this.trustedDevice.ExpiresAt__c = trustedDateTime;
        return this.trustedDevice;
    }

    public CustomerTrustedDevice__c populateLastSeenAt(){
        this.trustedDevice.LastSeenAt__c = System.now();
        return this.trustedDevice;
    }

    public CustomerTrustedDevice__c upsertTrustedDevice(){
        upsert this.trustedDevice;
        return this.trustedDevice;
    }

    public without sharing class CustomerTrustedDeviceDetails{
        private List<CustomerTrustedDevice__c> allCustomerTrustedDevice = new List<CustomerTrustedDevice__c>();
        private string revokeReason;
        public CustomerTrustedDeviceDetails(String userId, String revokeReason){
                this.allCustomerTrustedDevice = [SELECT Id
                    FROM CustomerTrustedDevice__c
                    WHERE User__c =: userId AND
                        IsRevoked__c = FALSE AND
                        IsExpired__c = FALSE];    
                this.revokeReason = revokeReason;
        }

        public void updateTrustedDevice() {
           update this.allCustomerTrustedDevice;
            if( !this.allCustomerTrustedDevice.isEmpty() ){
                for(CustomerTrustedDevice__c customerTrustedDevice : this.allCustomerTrustedDevice){
                    customerTrustedDevice.ConsentRevokeReason__c = this.revokeReason;
                }
                update this.allCustomerTrustedDevice;
            }
        }
    }
}