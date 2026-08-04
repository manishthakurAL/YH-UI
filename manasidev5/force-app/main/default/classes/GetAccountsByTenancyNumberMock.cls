@IsTest
public class GetAccountsByTenancyNumberMock implements HttpCalloutMock {
    
    private Integer statusCode;
    private String responseBody;

    public GetAccountsByTenancyNumberMock(Integer status) {
        this.statusCode = status;
        String body;
        if(this.statusCode == HTTPRequestResponseDecorator.SUCCESS_CODE){
            this.responseBody  = '[{' +
            '"tenancyNumber": 123456,' +
            '"subAccountNumber": "0",' +
            '"accountDescription": "Main Account",' +
            '"occupancyCommenced": "2023-01-01",' +
            '"occupancyTerminated": "2023-01-02",' +
            '"accountBalance": 100.0' +
            '}, {' +
                '"tenancyNumber": 123456,' +
                '"subAccountNumber": "1",' +
                '"accountDescription": "Rechargeable Repairs",' +
                '"occupancyCommenced": "2023-01-01",' +
                '"occupancyTerminated": "2023-01-02",' +
                '"accountBalance": 50.0' +
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