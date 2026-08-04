public class GetTenancyAccountDetailsResponseMock implements HttpCalloutMock {
    
	private Integer statusCode;
    private String responseBody;

    public GetTenancyAccountDetailsResponseMock(Integer status, Date occupancyStartDate, Date statementStartDate) {
        Assert.areEqual(false, statementStartDate < occupancyStartDate, 'Statement start date should not be before occupancy start date');
        this.statusCode = status;
        String body;
        if(this.statusCode == 200){
            this.responseBody  = '{' +
            '"tenancyNumber": 123456,' +
            '"subAccountNumber": 0,' +
            '"transactions": [ {"balanceDate": "31 Jul 2025",' +
            '"balance": 141.91,' +
            '"rent": { "amount": 714.82, "transactionDate" : "10 Jul 2025"},' +
            '"benefit": { "amount": 714.82, "transactionDate" : "10 Jul 2025"},' +
            '"payment": [{ "amount": 714.82, "transactionDate" : "10 Jul 2025"}],' +
            '"charges": {"totalAmount": 0.39, "chargesBreakdown": [{ "amount": 0.09, "transactionDate" : "10 Jul 2025", "description": "Administration"}'+
              ',{ "amount": 0.3, "transactionDate" : "10 Jul 2025", "description": "Gardens & Grounds"}]}' +
                '}]}';
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