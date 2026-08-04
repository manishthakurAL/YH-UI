public class GetRepairHistoryListMock implements HttpCalloutMock{
    
    private Integer statusCode;
    private String responseBody;

    public GetRepairHistoryListMock(Integer status) {
        this.statusCode = status;
        String body;
        if(this.statusCode == 200){
            this.responseBody  = '[{' +
            '"jobNumber": 2223810,' +
            '"contractor": "Yorkshire Housing",' +
            '"dateReported": "31 Dec 2025",' +
            '"jobDescription": "DMC - AROUND THE WASHING MACHINE IN KITCHEN. TNT",' +
            '"status": "Open",' +
            '}, {' +
                '"jobNumber": 2222952,' +
                '"contractor": "SGS UK Ltd.",' +
                '"dateReported": "31 Dec 2025",' +
                '"jobDescription": "CIP 24 GEC project",' +
                '"status": "Complete",' +
            '}]';
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