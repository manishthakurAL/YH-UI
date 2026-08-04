public with sharing class SiteUserResetPassword {
     @InvocableMethod
    public static List<SiteUserResetPassword.Response> changePassword(List<SiteUserResetPassword.Request> requests){
        List<SiteUserResetPassword.Response> responses= new List<SiteUserResetPassword.Response>();
        try{
            SiteUserResetPassword.Request request = requests[0];
            System.resetPassword(request.aUserId,true);
            SiteUserResetPassword.Response aResponse = new SiteUserResetPassword.Response(true, 'Password update successful');
            responses.add(aResponse);
        }catch(Exception e){
            SiteUserResetPassword.Response aResponse = new SiteUserResetPassword.Response(true, e.getMessage());
            responses.add(aResponse);
            return responses;
        }
        return responses;
    }

    public class Request{
      @InvocableVariable(label='User Id' required=true)
      public String aUserId;

      public Request() {}
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

        public Response() {}
    }
}