public class OtpSenderFactory {
    private OtpService.METHOD method;

    public OtpSenderFactory(OtpService.METHOD method){
        this.method = method;
    }
    public IOtpSender getInstance(){
        String otpSenderHandler;
        if(this.method == OtpService.METHOD.EMAIL){
            otpSenderHandler = EmailOtpSender.class.getName();
        } else if(this.method == OtpService.METHOD.SMS){
            otpSenderHandler = SMSOtpSender.class.getName();
        } else{
            throw new OtpSenderFactoryException('Class implementation not found for ' + this.method.name() + ' type');
        }

        Type classType = Type.forName(otpSenderHandler);
        if(classType == null || !IOtpSender.class.isAssignableFrom(classType)) {
            throw new OtpSenderFactoryException('Invalid OTP Sender Handler');
        }

        return (IOtpSender) classType.newInstance();
    }

    public class OtpSenderFactoryException extends Exception {}
}