public with sharing class SiteUserChangePasswordInvocable {
    @InvocableMethod
    public static List<SiteUserChangePasswordInvocable.Response> changePassword(List<SiteUserChangePasswordInvocable.Request> requests){
        List<SiteUserChangePasswordInvocable.Response> responses= new List<SiteUserChangePasswordInvocable.Response>();
        try{
            SiteUserChangePasswordInvocable.Request request = requests[0];
            Site.changePassword(request.newPassword, request.verifyNewPassword, request.oldPassword);
            SiteUserChangePasswordInvocable.Response aResponse = new SiteUserChangePasswordInvocable.Response(true, 'Password update successful');
            responses.add(aResponse);
        }catch(Exception e){
            SiteUserChangePasswordInvocable.Response aResponse = new SiteUserChangePasswordInvocable.Response(true, e.getMessage());
            responses.add(aResponse);
            return responses;
        }
        return responses;
    }

    public class Request{
        @InvocableVariable(label='New Password' required=true)
        public String newPassword;
        @InvocableVariable(label='Old Password'  required=true)
        public String oldPassword;
        @InvocableVariable(label='Verify new Password' required=true)
        public String verifyNewPassword;
    }

     public class Response{
        @InvocableVariable(label='Password Change Successful' required=true)
        public Boolean isSuccessful;
        @InvocableVariable(label='Message')
        public String message;
      
        public Response(Boolean isSuccessful, String message){
            this.isSuccessful = isSuccessful;
            this.message = message;
        }
    }
}