public with sharing class MfaTrustedDeviceService {

    public static final String TRUST_COOKIE_NAME = 'yh_mfa_trust';
    private static final String HMAC_ALGO = 'HmacSHA256';

    private final MfaSettingDecorator mfaSettings;
    @testVisible
    private CustomerTrustedDevice__c trustedDevice;
    @testVisible
    private DateTime nowDateTime{
        get{
            if(this.nowDateTime == null){
                this.nowDateTime = System.now();
            }
            return this.nowDateTime;
        }
        private set;
    }

    private static List<CustomerTrustedDevice__c> allCustomerTrustedDevice{
        get{
            if(allCustomerTrustedDevice == null){
                allCustomerTrustedDevice = [SELECT Id
                    FROM CustomerTrustedDevice__c
                    WHERE User__c =: UserInfo.getUserId() AND
                        IsRevoked__c = FALSE AND
                        IsExpired__c = FALSE];
            }
            return allCustomerTrustedDevice;
        }
        private set;
    }

    @testVisible
    private TrustCookie trustCookie {
        get{
            if(this.trustCookie == null){
                Cookie cookie = ApexPages.currentPage().getCookies().get(TRUST_COOKIE_NAME);
                if(cookie != null && !String.isBlank(cookie.getValue())){
                    String cookieValue = cookie.getValue();
                    try{
                        String payloadJson = base64UrlDecode(cookieValue);
                        TrustCookie trustCookieObj = (TrustCookie) JSON.deserialize(payloadJson, TrustCookie.class);
                        if(trustCookieObj != null && String.isNotBlank(trustCookieObj.did) && String.isNotBlank(trustCookieObj.kid) && trustCookieObj.kid == this.mfaSettings.cookieName ){
                            this.trustCookie = trustCookieObj;
                        }
                    } catch(Exception e){
                        this.trustCookie = null;
                    }
                }
            }
            return this.trustCookie;
        }
        set;
    }



    public Boolean isTrustedDevice{
        get{
            if(this.isTrustedDevice == null){
                this.isTrustedDevice = false;
                if(this.trustCookie != null){
                    CustomerTrustedDevice__c trustedDeviceReturned = findTrustedDevice(UserInfo.getUserId(), this.trustCookie.did);
                    if(trustedDeviceReturned != null){
                        String expectedSig = this.trustCookie.sign(this.trustCookie);
                        if(trustedDeviceReturned.Signature__c == expectedSig){
                            this.trustedDevice = trustedDeviceReturned;
                            this.isTrustedDevice = true;
                        }
                    }
                }
            }
            return this.isTrustedDevice;
        }
        private set;
    }

    private String currentDeviceId{
        get{
            if(this.currentDeviceId == null){
                if(this.trustcookie != null && String.isNotBlank(this.trustcookie.did) && String.isNotBlank(this.trustcookie.kid)){
                    this.currentDeviceId = this.trustcookie.did;
                } else {
                    this.currentDeviceId = generateDeviceId();
                }
            }
            return currentDeviceId;
        }
        private set;
    }

    public MfaTrustedDeviceService() {
        this.mfaSettings = new MfaSettingDecorator();
    }

    public void updateTrustedDevice(){
        this.trustedDevice = new CustomerTrustedDeviceService(this.trustedDevice)
            .populateLastSeenAt();
    }

    public Boolean establishTrust() {
        this.trustCookie = new TrustCookie(this.currentDeviceId, this.mfaSettings.cookieName);
        this.setTrustDevice();
        this.setTrustCookie();
        return true;
    }

    private void setTrustDevice(){
        if (this.trustedDevice == null) {
            this.trustedDevice = new CustomerTrustedDeviceService(this.trustedDevice)
                .initialBuildCustomerTrustedDevice(
                    UserInfo.getUserId(), 
                    hashDeviceId(this.currentDeviceId),
                    this.trustCookie.sign(this.trustCookie),
                    this.nowDateTime
                );
        }
        this.trustedDevice = new CustomerTrustedDeviceService(this.trustedDevice)
            .populateTrustDateTime(
                this.nowDateTime.addDays(this.mfaSettings.trustDays)
            );

        new CustomerTrustedDeviceService(this.trustedDevice)
            .upsertTrustedDevice();
    }

    private CustomerTrustedDevice__c findTrustedDevice(String uid, String did) {
        String hash = hashDeviceId(did);
        List<CustomerTrustedDevice__c> rows = [
            SELECT Id, ExpiresAt__c, Signature__c
            FROM CustomerTrustedDevice__c
            WHERE User__c = :uid AND 
                DeviceIdHash__c = :hash AND 
                IsExpired__c = FALSE AND 
                IsRevoked__c = FALSE
            Order By CreatedDate DESC 
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    private void setTrustCookie() {
        Long exp = getEpoch(this.nowDateTime) + (this.mfaSettings.trustDays * 86400L);
        Long maxAge = Math.max(1, exp - nowEpoch());
        String payload = this.trustCookie.base64UrlEncode(Blob.valueOf(JSON.serialize(this.trustCookie)));
        Cookie trustCookie = new Cookie(TRUST_COOKIE_NAME, payload, null, Integer.valueOf(maxAge), true, 'Lax', true);
        ApexPages.currentPage().setCookies(new Cookie[]{trustCookie});
    }

    private String generateDeviceId() {
        return UUID.randomUUID().toString();
    }

    private String hashDeviceId(String did) {
        return EncodingUtil.convertToHex(
            Crypto.generateDigest('SHA-256', Blob.valueOf(did))
        );
    }

    private Long getEpoch(Datetime dtime) {
        return dtime.getTime() / 1000L;
    }

    private Long nowEpoch() {
        return System.now().getTime() / 1000L;
    }

    private String base64UrlDecode(String input) {
        String b64 = input.replace('-', '+').replace('_', '/');
        while (Math.mod(b64.length(), 4) != 0){
            b64 += '=';
        } 
        return EncodingUtil.base64Decode(b64).toString();
    }

    public void revokeTrustDeviceOnResetPassword(){
        if(!allCustomerTrustedDevice.isEmpty()){
            for(CustomerTrustedDevice__c customerTrustedDevice : allCustomerTrustedDevice){
                customerTrustedDevice.ConsentRevokeReason__c = CustomerTrustedDeviceDecorator.PASSWORD_RESET_REVOKE_REASON;
            }
            update allCustomerTrustedDevice;
        }
        this.isTrustedDevice = null;
        allCustomerTrustedDevice = null;
    }

   
    public void revokeTrustDeviceOnAccountLockout(String revokeReason, Id userId){
        CustomerTrustedDeviceService.CustomerTrustedDeviceDetails detailsController =  new CustomerTrustedDeviceService.CustomerTrustedDeviceDetails(userId, revokeReason);
        detailsController.updateTrustedDevice();
        this.isTrustedDevice = null;
        allCustomerTrustedDevice = null;
    }
    
    @AuraEnabled
    public static void revokeTrustDevice(){
        if(!allCustomerTrustedDevice.isEmpty()){
            for(CustomerTrustedDevice__c customerTrustedDevice : allCustomerTrustedDevice){
                customerTrustedDevice.ConsentRevokeReason__c = CustomerTrustedDeviceDecorator.REVOKE_REASON_ALLDEVICECONSENTREVOKED;
            }
            update allCustomerTrustedDevice;
        }
    }

    @AuraEnabled(cacheable = true)
    public static Boolean trustDeviceExist(){
        Boolean trustDeviceExist = false;
        if(!allCustomerTrustedDevice.isEmpty()){
                trustDeviceExist = true;
        }
        return trustDeviceExist;
    }

    public class TrustCookie {
        public String did;
        public String kid;

        public TrustCookie(String did, String kid){
            this.did = did;
            this.kid = kid;
        }

        public String sign(TrustCookie tc) {
            String payload = JSON.serialize(tc);
            Blob mac = Crypto.generateMac(
                HMAC_ALGO,
                Blob.valueOf(payload),
                Blob.valueOf(new MfaSettingDecorator().hmacSecret)
            );
            return base64UrlEncode(mac);
        }

        private String base64UrlEncode(Blob input) {
            return EncodingUtil.base64Encode(input)
                .replace('+', '-')
                .replace('/', '_')
                .replaceAll('=+$', '');
        }
    }
}