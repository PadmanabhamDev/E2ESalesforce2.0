/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : HubspotAuthController
 * Author          : Padmanabham
 * Created Date    : Jun 26, 2026
 * Last Modified By: Padmanabham
 * Last Modified On: Jun 26, 2026
 * Description     : To get access token in-exchange of auth token
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jun 26, 2026  │ Padmanabham  │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class HubspotAuthController {

	@AuraEnabled(cacheable=true)
	public static String getAuthStatus(String code) {
	
		// 1. Instantiate Http class
		Http http = new Http();
		// 2. craft HttpRequest 
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubspot.com/oauth/v3/token');
		req.setMethod('POST');
		req.setHeader('content-type','application/x-www-form-urlencoded');
		String requestBody = 'grant_type=authorization_code&code='+code+
		'&redirect_uri=https://orgfarm-e2ca5826ba-dev-ed.develop.lightning.force.com/apex/HubSpotRedirectPage'+
		'&client_id=53c826dd-7399-4acc-a9c8-11432ffe90cc&client_secret=bf789e3c-c2ab-450b-9cd7-893217f31507'+
		'&code_verifier=9ZIJ6B5Td78SvdBP7hu8q5aUqR_mHArzs_iYHIGIRd_HIV7Ym5mj_DOrEN1hEdhN';
		req.setBody(requestBody);
		// 3. Send request and handle the response
		HttpResponse res = http.send(req);
		String body = res.getBody();
		if(res.getStatusCode()==200){
			Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
			String accessToken = (String)resMap.get('access_token');
			//System.debug('line 40 '+accessToken);
			//String companyInfo = createContacts(accessToken);
			return accessToken;
			
		} else{
			return 'Something went wrong. Authentication failed';
		}
	}

	public static String getCompanyDetail(String access_token){
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubapi.com/crm/objects/2026-03/Company?limit=10');
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer '+access_token);
		req.setHeader('content-type','application/json');
		HttpResponse res = http.send(req);
		if(res.getStatusCode()==200){
			return res.getBody();
		}else{
			return 'Error in retrieving';
		}
	}

	public static String createContacts(String access_token){

		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://api.hubapi.com/crm/objects/2026-03/Contact/batch/create');
		req.setMethod('POST');
		req.setHeader('Content-Type','application/json');
		req.setHeader('Authorization','Bearer '+access_token);
		req.setBody(' { "inputs": [ { "properties": { "firstname": "TestSalesforce2", "lastname": "Salesforce3", "email": "test3@mail.com", "phone":"1234567890" } } ] } ');
		HttpResponse res = http.send(req);
		if(res.getStatusCode()==201){
			return res.getBody();
		}else{
			return res.getBody();
		}
	}
		
}