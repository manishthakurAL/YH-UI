public class GetRepairDetailsMock implements HttpCalloutMock{
	
    private Integer statusCode;
    private String responseBody;

    public GetRepairDetailsMock(Integer status) {
        this.statusCode = status;
        String body;
        if(this.statusCode == 200){
            this.responseBody  = '{' +
            '"jobNumber": 2223810,' +
            '"dateReported": "31 Dec 2025" ,' +
            '"mainTrade": "PLUMBER" ,' +
            '"location": "SEE NOTES" ,' +
            '"description": "**FW CHECK FOR LEAK IN KITCHEN - WATER UNDER LINO AND WATER DAMAGE UNDER WASTE PIPE" ,' +
            '"priority": "Routine" ,' +
            '"address": "4 West End Terrace, Brawby, MALTON, YO17 6PT" ,' +
            '"status": "Open" ,' +
            '"overallTargetDate": "31 Dec 2025" ,' +
            '"completionDate": "31 Dec 2025" ,' +
            '"contractor": "Yorkshire Housing" ,' +
            '"appointments": [{ "appointmentStatus": "Appointment Complete", "appointmentDate" : "30 Dec 2025", "timeslot": "PM"}'+
              ',{ "appointmentStatus": "Appointment Complete", "appointmentDate" : "31 Dec 2025", "timeslot": "PM"}]}';
        }
        else{
           this.responseBody  ='{' +
            '"errorMessage": "Resource Not Found", ' +
            '"errorType": "HTTP:NOT_FOUND", ' +
            '"errorDescription": "Method Not Allowed", ' +
            '"correlationId": "35ed74c6-c98c-4db7-8ab4-1448a518bf90", ' +
            '"httpStatus": 404, ' +
            '"errorTimeStamp": "2024-01-01T00:00:00.000Z" ' +
            '}';
        }
        
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(this.statusCode);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(this.responseBody);
        return res;
    }
}