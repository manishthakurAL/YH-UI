public without sharing class OtpService {

    public enum METHOD { 
        EMAIL, 
        SMS 
    }

    public enum STATUS { 
        PENDING, 
        VERIFIED, 
        LOCKED 
    }

    public CustomerPortalSettingsDecorator customPortalSettings{
        get{
            if(this.customPortalSettings == null){
                this.customPortalSettings = new CustomerPortalSettingsDecorator();
            }
            return this.customPortalSettings; 
        }
        private set;
    }

    public String generateOtp() {
        Integer n = Math.mod( Math.abs(Crypto.getRandomInteger()),  generateLong(this.customPortalSettings.otpLength));   
        return String.valueOf(n).leftPad(this.customPortalSettings.otpLength, '0');
    }

    public String createSalt() {
        String blobString = String.valueOf(Crypto.getRandomLong()) + String.valueOf(System.currentTimeMillis()) + UserInfo.getUserId() + UUID.randomUUID();
        return EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(String.valueOf(blobString))));
    }

    public String hashOtp(String otp, String salt) {
        Blob digest = Crypto.generateDigest(
            'SHA-256',
            Blob.valueOf(otp + ':' + salt)
        );
        return EncodingUtil.convertToHex(digest);
    }

    public Boolean verifyOtp(String userInput, String storedHash, String salt) {
        Boolean otpMatched = false;
        if (String.isBlank(userInput) || String.isBlank(storedHash) || String.isBlank(salt)) {
            otpMatched = false;
        } else{
            String calcHash = this.hashOtp(userInput, salt);
            if (calcHash == storedHash) {
                otpMatched = true;
            }
        }
        return otpMatched;
    }
    
    private Integer generateLong(Integer length) {
        return (Integer)Math.pow(10, length - 1);
    }
}