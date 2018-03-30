global with sharing class Tm_Apex_Sales implements vlocity_cmt.VlocityOpenInterface{
     
     global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     
        Boolean result = true;
        system.debug('methodName '+methodName );
        try
        {
            if(methodName.equals('createLeadFromReg'))
            {
                createLeadFromReg(inputMap,outMap,options);
            }
            else if(methodName.equals('callTibcoToGetNumber')){
                callTibcoToGetNumber(inputMap,outMap,options);
            }
            else if(methodName.equals('saveSelectedNumberToTibco')){
                saveSelectedNumberToTibco(inputMap,outMap,options);
            }
            else if(methodName.equals('callTibcoToGetFixedLine')){
                callTibcoToGetFixedLine(inputMap,outMap,options);
            }
            else if(methodName.equals('saveFixedLineToTibco')){
                saveFixedLineToTibco(inputMap,outMap,options);
            }           
                    
            else if(methodName.equals('checkpass')){
                checkpass(inputMap,outMap,options);
            }
            else if(methodName.equals('createMainAccount'))
            {
                createMainAccount(inputMap,outMap,options);
            }
            else if(methodName.equals('saveBASA'))
            {
                saveBASA(inputMap,outMap,options);
            }
            else if(methodName.equals('savePaymentInfo'))
            {
                savePaymentInfo(inputMap,outMap,options);
            } 
            else if(methodName.equals('getPromotions')){
                getPromotions(inputMap,outMap,options); 
            } 
            else if(methodName.equals('addPromotion')){
                addPromotion(inputMap,outMap,options);
            }
            else if(methodName.equals('confirmOrder')){
                confirmOrder(inputMap,outMap,options);
            } 
            else if(methodName.equals('submitOrderToTibco')){
                submitOrderToTibco(inputMap,outMap,options);
            }
            else if(methodName.equals('generateSeviceIds')){
                generateSeviceIds(inputMap,outMap,options);
            }           
        }
        catch(Exception ex)
        {
            system.debug('ex: '+ex);
        }
        return result;
    }
    void createLeadFromReg(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
    {   
        String Street;
        String City;
        String State;
        String Country;
        String ZipCode;
         
        Account customerAccount = [Select Id from Account where Name='Unifi Customer Account'];
        Map<String,Object> ContactDetail = (Map<String,Object>)inputMap.get('ContactDetail');
        Map<String,Object> RegistrationBlock = (Map<String,Object>)ContactDetail.get('RegistrationBlock');
        System.debug('RegistrationBlock '+RegistrationBlock );
        String FirstName = (String)RegistrationBlock.get('FirstName');
        String LastName = (String)RegistrationBlock.get('LastName');
        String Email = (String)RegistrationBlock.get('Email');
        String PhoneNumber = (String)RegistrationBlock.get('PhoneNumber');
            
        try{
             Map<String,Object> ServiceAvailability = (Map<String,Object>)inputMap.get('ServiceAvailability');
             Map<String,Object> AddressBlock  = (Map<String,Object>)ServiceAvailability.get('AddressBlock-Block');
             Street = (String)AddressBlock.get('Street'); 
             City = (String)AddressBlock.get('City');
             State = (String)AddressBlock.get('State');
             Country = (String)AddressBlock.get('Country');
             ZipCode = (String)AddressBlock.get('ZipCode'); 
             
        }
        catch(Exception e){
            System.debug('Exception caught'+e);
        }
        Lead lead = new Lead();
        lead.FirstName = FirstName;
        lead.LastName = LastName;
        lead.Email = Email;
        lead.Phone= PhoneNumber;
        lead.Company='Accenture';
        lead.Account_Name__c=customerAccount.Id;
        lead.Street=Street;
        lead.City=City;
        lead.PostalCode=ZipCode;
        lead.State=State;
        lead.Country=Country;
        //lead.Service_Address__c = Street+','+City+','+ZipCode+','+State+','+Country;
        lead.vlocity_cmt__ProductInterest__c='TM Quadplay Promotion';
        lead.Infra_Readiness__c =true;
        insert lead;
        /*Contact conObj = new Contact();
        conObj.LastName=FirstName+' '+LastName;
        conObj.Email=Email;
        conObj.AccountId=customerAccount.Id;
        insert conObj;*/
        Address__c address = new Address__c();
        address.Street__c = Street;
        address.City__c = City;
        address.ZipCode__c = ZipCode;
        address.State__c = State;
        address.Country__c = Country;   
        address.Lead__c = lead.Id;
        address.Name = Street+','+City+','+ZipCode+','+State+','+Country;
        insert address;
    } 
    
    void callTibcoToGetNumber(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
    {
        String strResponse = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://integration.haat.eu/tm/acc/st/msisdn/list');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody('{"quantity": 10, "namedGroup" :"/TM_TN/Mobile/Central"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response '+response.getBody());
            strResponse = response.getBody();
            System.debug(strResponse);
        } else {
            System.debug(response.getBody());
        }
        System.debug('strResponse =='+strResponse); 
        
        List<Map<String,String>> selectOptions = new List<Map<String, String>>();
        //List<String> msisdnList = new List<String>();
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'number')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                String msisdnNumber = parser.getText();
                Map<String, String> phoneMap = new Map<String, String>();
                phoneMap.put('name', msisdnNumber); 
                phoneMap.put('value', msisdnNumber);
                selectOptions.add(phoneMap);
            }
        }
        System.debug('selectOptions == '+selectOptions);
        outMap.put('options', selectOptions);
    }
    void callTibcoToGetFixedLine(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
    {
        String strResponse = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('http://integration.haat.eu/tm/acc/st/msisdn/list');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody('{"quantity": 10, "namedGroup" :"/TM_TN/FixedLine/03"}');
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
            response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response '+response.getBody());
            strResponse = response.getBody();
            System.debug(strResponse);
        } else {
            System.debug(response.getBody());
        }
        System.debug('strResponse =='+strResponse); 
        
        List<Map<String,String>> selectOptions = new List<Map<String, String>>();
        //List<String> msisdnList = new List<String>();
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'number')) {
                // Get the value.
                parser.nextToken();
                // Compute the grand total price for all invoices.
                String msisdnNumber = parser.getText();
                Map<String, String> phoneMap = new Map<String, String>();
                phoneMap.put('name', msisdnNumber); 
                phoneMap.put('value', msisdnNumber);
                selectOptions.add(phoneMap);
            }
        }
        System.debug('selectOptions == '+selectOptions);
        outMap.put('options', selectOptions);
    }
    void saveSelectedNumberToTibco(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
        {
            String strResponse = '';
            String strReqestBody = '';
            Map<String,Object> GetNewNumber = (Map<String,Object>)inputMap.get('GetNewNumber');
            String selectedNumber = (String)GetNewNumber.get('SelectNumber');
            //String userName = (String)GetNewNumber.get('UserName');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://integration.haat.eu/tm/acc/st/msisdn/reserve');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            //To rethink whether unique customer is required 
            //strReqestBody = '{"msisdn":"'+selectedNumber+'","customer":"'+UserName+'"}';
            strReqestBody = '{"msisdn":"'+selectedNumber+'","customer":"Deep@gmail.com"}';
            request.setBody(strReqestBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response '+response.getBody());
                strResponse = response.getBody();
                System.debug(strResponse);
            } else {
                System.debug(response.getBody());
            }
        }
        void saveFixedLineToTibco(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
        {
            String strResponse = '';
            String strReqestBody = '';
            Map<String,Object> GetNewNumber = (Map<String,Object>)inputMap.get('GetNewNumber');
            String selectedNumber = (String)GetNewNumber.get('ResidentialfixedVoice');
            //String userName = (String)GetNewNumber.get('UserName');
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://integration.haat.eu/tm/acc/st/msisdn/reserve');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            //To rethink whether unique customer is required 
            //strReqestBody = '{"msisdn":"'+selectedNumber+'","customer":"'+UserName+'"}';
            strReqestBody = '{"msisdn":"'+selectedNumber+'","customer":"Deep@gmail.com"}';
            request.setBody(strReqestBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response '+response.getBody());
                strResponse = response.getBody();
                System.debug(strResponse);
            } else {
                System.debug(response.getBody());
            }
        }
        void checkpass(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
        {
            Map<String,Object> Step1= (Map<String,Object>)inputMap.get('Step1');
            String Password1 = (String)Step1.get('Password1');
            System.debug('Password1 = '+Password1);
            Account acc = new Account();
            acc.Name = Password1;
            insert acc;
        }
        void createMainAccount(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
            Map<String, Object> checkOut = (Map<String, Object>) inputMap.get('CheckOut');
            Map<String, Object> PersonalInfo = (Map<String, Object>) checkOut.get('PersonalInfo'); 
            Map<String, Object> BillingAddressBlock = (Map<String, Object>) checkOut.get('BillingAddressBlock-Block'); 
            String street= (String)BillingAddressBlock.get('BillingStreetAddress');
            String zipCode= (String)BillingAddressBlock.get('ZipCode');
            String country= (String)BillingAddressBlock.get('Country');
            String city= (String)BillingAddressBlock.get('City');
            String state= (String)BillingAddressBlock.get('State');
            String firstName= (String)PersonalInfo.get('FirstName');
            String lastName= (String)PersonalInfo.get('LastName');
            String email= (String)PersonalInfo.get('Email');
            String phone= (String)PersonalInfo.get('Phone');
            Boolean copyAddress=(Boolean)PersonalInfo.get('CopyAddress');
            RecordType businessRecordType = [SELECT Id FROM RecordType WHERE Name =: ConstantsClass.BUSINESS_TEXT and SobjectType =: ConstantsClass.ACCOUNT_TEXT];
            Account businessAccount = new Account();
            businessAccount.Name=firstName+' '+lastName;
            businessAccount.RecordTypeId=businessRecordType.Id;
            if(copyAddress==true){
                    Lead lead=[Select city,country,street,state, PostalCode from lead where FirstName=:firstName and LastName=:LastName order by createdDate DESC limit 1];
                    businessAccount.BillingCountry=lead.country;
                    businessAccount.BillingStreet=lead.street;
                    businessAccount.BillingCity=lead.city;
                    businessAccount.BillingState=lead.state;
                    businessAccount.BillingPostalCode=lead.PostalCode;
                    businessAccount.Account__c = 'Global';
            }
            else{
                    businessAccount.BillingCountry=country;
                    businessAccount.BillingStreet=street;
                    businessAccount.BillingCity=city;
                    businessAccount.BillingState=state;
                    businessAccount.BillingPostalCode=zipCode;
                    businessAccount.Account__c = 'Global';
            }
            /* businessAccount.BillingCountry=country;
            businessAccount.BillingStreet=street;
            businessAccount.BillingCity=city;
            businessAccount.BillingState=state;
            businessAccount.BillingPostalCode=zipCode;
            businessAccount.Account__c = 'Global'; */
            try{
                insert businessAccount;
                System.debug('Business Account Inserted');
            }
            Catch(Exception e){
                System.debug('Exception '+e);
            }
            Id conId;
            outMap.put(ConstantsClass.BUSINESS_ACCOUNT_ID,businessAccount.Id);
            System.debug('Main Account Id '+businessAccount.Id);
            Contact userContact = new Contact();
            userContact.FirstName = firstName;
            userContact.LastName= lastName;
            userContact.AccountId=businessAccount.Id;
            userContact.Email = email;
            userContact.phone = phone;
            try{
                insert userContact;
                conId = userContact.Id;
                System.debug('User Contact Inserted');
            }
            Catch(Exception e){
                System.debug('Exception '+e);
            }
            System.debug('User Contact '+userContact.Id);
            outMap.put(ConstantsClass.CONTACT_ID,userContact.Id);
            String ranString3 = generateRandomString(3);
            String ranString = generateRandomString(5);
            String userFed=email+ranString3;
            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='CtD_High Volume Customer Portal User'].Id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = firstName;
            user.LastName = lastName;
            user.Username = userFed;   
            user.CommunityNickname = email+ranString;
            user.Alias ='user1';
            user.Email = email;
            user.IsActive = true;
            user.ContactId = conId;
            user.FederationIdentifier = userFed;
            try{
                insert user;
                Contact conToUpdate = new Contact();
                conToUpdate.vlocity_cmt__UserId__c = user.Id; 
                conToUpdate.Id = conId;
                update conToUpdate;
                System.debug('User  Inserted');
            }
            Catch(Exception e){
                System.debug('Exception '+e);
            }
            outMap.put('UserId',user.Id);
            
        }
        void saveBASA(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
            Map<String, Object> checkOut = (Map<String, Object>) inputMap.get('CheckOut');
            Map<String, Object> PersonalInfo = (Map<String, Object>) checkOut.get('PersonalInfo');
            Map<String, Object> BillingAddressBlock = (Map<String, Object>) checkOut.get('BillingAddressBlock-Block');
            String firstName= (String)PersonalInfo.get('FirstName');
            String lastName= (String)PersonalInfo.get('LastName');
            String email= (String)PersonalInfo.get('Email');
            String phone= (String)PersonalInfo.get('Phone');
            String street= (String)BillingAddressBlock.get('BillingStreetAddress');
            String zipCode= (String)BillingAddressBlock.get('ZipCode');
            String country= (String)BillingAddressBlock.get('Country');
            RecordType baRecordType= [SELECT Id FROM RecordType
                      WHERE Name =: ConstantsClass.BILLING_TEXT AND SobjectType =: ConstantsClass.ACCOUNT_TEXT LIMIT 1];
            RecordType saRecordType= [SELECT Id FROM RecordType
                      WHERE Name =: ConstantsClass.SERVICE_TEXT AND SobjectType =: ConstantsClass.ACCOUNT_TEXT LIMIT 1];
            String businessAccountId=(String) inputMap.get(ConstantsClass.BUSINESS_ACCOUNT_ID);
            Account parentAcocunt = [Select Id,Name,BillingCountry,BillingStreet,BillingPostalCode from Account where Id=:businessAccountId];
            Account billingAccount = new Account();
            billingAccount.Name=parentAcocunt.Name+ConstantsClass.BA_TEXT;
            billingAccount.RecordTypeId=baRecordType.Id;
            billingAccount.parentId=parentAcocunt.Id;
            billingAccount.BillingCountry=parentAcocunt.BillingCountry;
            billingAccount.BillingStreet=parentAcocunt.BillingStreet;
            billingAccount.BillingPostalCode=parentAcocunt.BillingPostalCode;
            billingAccount.Account__c = 'Global';
            try{
                insert billingAccount;
                System.debug('Billing Account Inserted');
            }
            Catch(Exception e){
                System.debug('Exception '+e);
            }
            outMap.put(ConstantsClass.BILLING_ACCOUNT_ID, billingAccount.Id);
            System.debug('Billing Account Id '+billingAccount.Id);  
            Account serviceAccount = new Account();
            serviceAccount.Name=parentAcocunt.Name+ConstantsClass.SA_TEXT;
            serviceAccount.RecordTypeId=saRecordType.Id;
            serviceAccount.parentId=parentAcocunt.Id;
            serviceAccount.ShippingCountry=parentAcocunt.BillingCountry;
            serviceAccount.ShippingStreet=parentAcocunt.BillingStreet;
            serviceAccount.ShippingPostalCode=parentAcocunt.BillingPostalCode;
            serviceAccount.Account__c = 'Global';
            try{
                insert serviceAccount;
                System.debug('Service Account Inserted');
            }
            Catch(Exception e){
                System.debug('Exception '+e);
            }
            outMap.put(ConstantsClass.SHIPPING_ACCOUNT_ID, serviceAccount.Id);
            System.debug('Service Account Id '+billingAccount.Id);      
        }
        void savePaymentInfo(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
            Map<String, Object> checkOut = (Map<String, Object>) inputMap.get('CheckOut');
            Map<String, Object> paymentBlock = (Map<String, Object>) checkOut.get('PaymentBlock');
            String MethodSelected= (String) paymentBlock.get('PaymentMethod');
            Account billingAccount;
            String billingAccountId=(String) inputMap.get(ConstantsClass.BILLING_ACCOUNT_ID);
            billingAccount=[Select Id from Account where Id=:billingAccountId];
            vlocity_cmt__PaymentMethod__c paymentMethod= new vlocity_cmt__PaymentMethod__c();
            if(MethodSelected.equalsIgnoreCase('BankAccount')){
                try{
                    Map<String,Object> bankAccountBlock= (Map<String,Object>) paymentBlock.get('BankAccountBlock');
                    paymentMethod.vlocity_cmt__CardHolderName__c= (String) bankAccountBlock.get('BankHolderName');
                    paymentMethod.vlocity_cmt__BankAccountType__c= (String) bankAccountBlock.get('BankAccountType');
                    paymentMethod.vlocity_cmt__RoutingTransitNumber__c= (String) bankAccountBlock.get('RoutingTransitNumber');
                    paymentMethod.vlocity_cmt__BankAccountNumber__c= (String) bankAccountBlock.get('IBAN');
                } 
                catch(Exception exc){
                    System.debug('Exception in Bank '+exc);
                }
            } 
            else if(MethodSelected.equalsIgnoreCase('CreditCard')){
                try{
                    Map<String,Object> creditCartBlock= (Map<String,Object>) paymentBlock.get('CreditCardBlock');
                    paymentMethod.vlocity_cmt__CardHolderName__c= (String) creditCartBlock.get('CardHolderName');
                    paymentMethod.vlocity_cmt__CardType__c= (String) creditCartBlock.get('CardType');
                    paymentMethod.vlocity_cmt__CardNumber__c= (String) creditCartBlock.get('CreditCardNumber');
                    paymentMethod.vlocity_cmt__ExpirationMonth__c= String.valueOf(creditCartBlock.get('ExpirationMonth'));
                    paymentMethod.vlocity_cmt__ExpirationYear__c= String.valueOf(creditCartBlock.get('ExpirationYear'));
                } 
                catch(Exception exc){
                    System.debug('Exception in Credit Card '+exc);
                }
            } 
            else{
                System.debug('exception on PaymentMethod creation');
            }
            paymentMethod.vlocity_cmt__MethodType__c= MethodSelected;
            paymentMethod.vlocity_cmt__AccountId__c= billingAccount.Id;
            paymentMethod.vlocity_cmt__IsPrimary__c= true;
            insert paymentMethod;
        }
        global void getPromotions(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    
            System.debug('input map GET PROMOTIONS -> '+inputMap);
            String JsonAttribute = (String) options.get('JSON Node');
            //Map<String,Object> vlcCart = (Map<String,Object>) inputMap.get('vlcCart');
            //String cur= (String) vlcCart.get('currencySymbol');
            String cur= '€';
            vlocity_cmt__Promotion__c prom1 = [SELECT Id,Name,SystemModstamp,vlocity_cmt__CannotBeCombined__c,vlocity_cmt__Code__c,vlocity_cmt__Description__c,
                                                vlocity_cmt__DurationTimePlanId__c,vlocity_cmt__DurationTimePolicyId__c,vlocity_cmt__EffectiveEndDate__c,
                                                vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__EnableAutoAddProducts__c,vlocity_cmt__EnableAutoApplyPromotion__c,
                                                vlocity_cmt__GlobalKey__c,vlocity_cmt__IsActive__c,vlocity_cmt__IsLimitedQuantity__c,vlocity_cmt__IsOrderable__c,
                                                vlocity_cmt__PriceListId__c,vlocity_cmt__ServiceContinuation__c
                                                FROM vlocity_cmt__Promotion__c WHERE Name = 'TM Quadplay Promotion Free Trial' LIMIT 1];
            
            vlocity_cmt__Promotion__c prom2 = [SELECT Id,Name,SystemModstamp,vlocity_cmt__CannotBeCombined__c,vlocity_cmt__Code__c,vlocity_cmt__Description__c,
                                            vlocity_cmt__DurationTimePlanId__c,vlocity_cmt__DurationTimePolicyId__c,vlocity_cmt__EffectiveEndDate__c,
                                            vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__EnableAutoAddProducts__c,vlocity_cmt__EnableAutoApplyPromotion__c,
                                            vlocity_cmt__GlobalKey__c,vlocity_cmt__IsActive__c,vlocity_cmt__IsLimitedQuantity__c,vlocity_cmt__IsOrderable__c,
                                            vlocity_cmt__PriceListId__c,vlocity_cmt__ServiceContinuation__c
                                            FROM vlocity_cmt__Promotion__c WHERE Name =: 'Accelerate' LIMIT 1]; 
            
            List<vlocity_cmt__PriceListEntry__c> entries1 = [SELECT Id,Name,vlocity_cmt__PriceListId__c,vlocity_cmt__PricingElementId__c,
                                                                vlocity_cmt__ProductId__c,vlocity_cmt__PromotionId__c,vlocity_cmt__PromotionItemId__c
                                                                FROM vlocity_cmt__PriceListEntry__c WHERE vlocity_cmt__PromotionId__c =: prom1.Id];
                                                                
             List<vlocity_cmt__PriceListEntry__c> entries2 = [SELECT Id,Name,vlocity_cmt__PriceListId__c,vlocity_cmt__PricingElementId__c,
                                                            vlocity_cmt__ProductId__c,vlocity_cmt__PromotionId__c,vlocity_cmt__PromotionItemId__c
                                                            FROM vlocity_cmt__PriceListEntry__c WHERE vlocity_cmt__PromotionId__c =: prom2.Id];
                 
            Double totalAmount1 = 0.00;
            for(vlocity_cmt__PriceListEntry__c entry : entries1){
                ID pricing = entry.vlocity_cmt__PricingElementId__c;
                if(pricing==null) continue;
                vlocity_cmt__PricingElement__c park = [SELECT Id,vlocity_cmt__Amount__c FROM vlocity_cmt__PricingElement__c WHERE Id =: pricing LIMIT 1];
                Double singleAmount = (park.vlocity_cmt__Amount__c==null) ? (0) : (park.vlocity_cmt__Amount__c);
                totalAmount1 = totalAmount1 + singleAmount;
            } 
            Double totalAmount2 = 0.00;
            for(vlocity_cmt__PriceListEntry__c entry : entries2){
                ID pricing = entry.vlocity_cmt__PricingElementId__c;
                if(pricing==null) continue;
                vlocity_cmt__PricingElement__c park = [SELECT Id,vlocity_cmt__Amount__c FROM vlocity_cmt__PricingElement__c WHERE Id =: pricing LIMIT 1];
                Double singleAmount = (park.vlocity_cmt__Amount__c==null) ? (0) : (park.vlocity_cmt__Amount__c);
                totalAmount2 = totalAmount2 + singleAmount;
            }   
            
            Map<String,Object> SuggestedOfferOut = new Map<String,Object>();
            
            Decimal TAdecimal1 = Decimal.valueOf(totalAmount1).setScale(2);
            String TAformatted1 = cur + String.valueOf(TAdecimal1).replace('.',',');
            SuggestedOfferOut.put('AmountPromo1',TAformatted1);
            
            Decimal TAdecimal2 = Decimal.valueOf(totalAmount2).setScale(2);
            String TAformatted2 = cur + String.valueOf(TAdecimal2).replace('.',',');
            SuggestedOfferOut.put('AmountPromo2',TAformatted2);
            
            
            String promoDescription = prom1.vlocity_cmt__Description__c + ',' + String.valueOf(TAdecimal1);
            String promo2Description = prom2.vlocity_cmt__Description__c + ',' + String.valueOf(TAdecimal2);
            prom1.vlocity_cmt__Description__c = promoDescription;
            prom2.vlocity_cmt__Description__c = promo2Description;
            
            List<vlocity_cmt__Promotion__c> promoList = new List<vlocity_cmt__Promotion__c>();
            promoList.add(prom1);
            promoList.add(prom2);
            SuggestedOfferOut.put(JsonAttribute,promoList);
            System.debug('promolist -> '+promoList);
    
            outMap.put('SuggestedOffer',SuggestedOfferOut);
            System.debug('outMap -> '+outMap);
            
        }
        global void addPromotion(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
            String methodName = 'postCartsPromoItems';
            Map<String,Object> SelectedItem = (Map<String,Object>) options.get('vlcSelectedItem');
            System.debug('SelectedItem ==='+SelectedItem);
            ID itemId = (ID) SelectedItem.get('Id');
            System.debug('SelectedItemId ='+itemId);
            ID ordId = (ID) inputMap.get('OrderId');
            List<Id> lineItemIdList = new List<Id>();
            List<OrderItem> OrderItemList = [SELECT Id, Product2.Name FROM OrderItem where OrderId =: ordId];
            System.debug('OrderItemList = '+OrderItemList);
            if(OrderItemList.size() != 0){
                for(OrderItem qli : OrderItemList){
                    if(qli.Product2.Name == 'TM Quadplay Promotion'|| qli.Product2.Name == 'Accelerate' ){
                        Id lineItemId = qli.Id; 
                        lineItemIdList.add(lineItemId);
                    }   
                }
                if(lineItemIdList.size() == 1){
                    System.debug('Size 1');
                    addPromoProduct(ordId,lineItemIdList[0],itemId);              
                }           
            }
            System.debug('Line Item size = '+lineItemIdList.size());
            if(lineItemIdList.size() != 1){
                List<Map<String,Object>> lista= new List<Map<String,Object>>();
                Map<String,Object> m1= new Map<String,Object>();
                m1.put('itemId',itemId);
                lista.add(m1);
                
                System.debug('promo id -> '+itemId);
                System.debug('quote id -> '+ordId);
                System.debug('lista -> '+lista);
            
                vlocity_cmt.CpqAppHandler cpqApp = new vlocity_cmt.CpqAppHandler();
                
                Map<String,Object> inMap = new Map<String,Object>();
                inMap.put('cartId',ordId);
                inMap.put('methodName',methodName);
                inMap.put('items',lista);
                inMap.put('promotionId',itemId);
                
                try{
                    Object obj = cpqApp.invokeMethod(methodName,inMap,outMap,null);
                    System.debug('metodo addPromotions: OK -> '+obj);
                } catch(Exception exc){
                    System.debug('metodo addPromotions: generata eccezione -> '+exc);
                }
                /*List<OrderItem> OrderItemList1 = [SELECT Id, Product2.Name FROM OrderItem where OrderId =: ordId];
                System.debug('upp**'+OrderItemList1);
                Map<String,Object> TriggerNeedAnalysisMap= (Map<String,Object>) inputMap.get('TriggerNeedAnalysis');
                System.debug('Trigger!!!***'+TriggerNeedAnalysisMap);
                List<OrderItem> OrderItemList= [Select Id,Product2.Name,Quantity,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c from OrderItem where OrderId=:ordId];
                List<OrderItem> updatedOrderItemList= new List<OrderItem>();
                System.debug('OrderItem!!!'+OrderItemList);
                Integer numberOfEmployeesQ= (Integer) TriggerNeedAnalysisMap.get('NoOfEmployees');
                System.debug('num**'+numberOfEmployeesQ);
                for(OrderItem quol:OrderItemList){
                    OrderItem quolObj = new OrderItem();
                    quolObj.Id=quol.Id; 
                    quolObj.Quantity=numberOfEmployeesQ; 
                    updatedOrderItemList.add(quolObj);
                }
                try{
                    update updatedOrderItemList;
                }
                catch(Exception e){
                    System.debug('Error while updating');
                }
                OrderItem qliobject1 =[Select Id,Product2.Name,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__EffectiveRecurringTotal__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__EffectiveOneTimeTotal__c from OrderItem where OrderId=:ordId and Product2.Name='Tariff Plan'];
                System.debug('qliobject1 ');
                OrderItem qliobject12 =[Select Id,Product2.Name,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__EffectiveRecurringTotal__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__EffectiveOneTimeTotal__c from OrderItem  where OrderId=:ordId and (Product2.Name='Start'or Product2.Name='Fast' or Product2.Name='Accelerate' or Product2.Name='Accelerate World')];
                qliobject1.vlocity_cmt__RecurringTotal__c=qliobject1.vlocity_cmt__RecurringTotal__c*numberOfEmployeesQ; 
                qliobject12.vlocity_cmt__RecurringTotal__c=qliobject1.vlocity_cmt__RecurringTotal__c;
                qliobject12.vlocity_cmt__EffectiveRecurringTotal__c=qliobject12.vlocity_cmt__RecurringTotal__c;
                update qliobject1;
                update qliobject12; 
                System.debug('Updated List!! '+updatedOrderItemList);*/
            }
        }
        global void addPromoProduct(Id carId,Id IteId,Id ItemId){
            String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm(); 
            String restAPIURL = 'https://tm--eaglelabap.cs89.my.salesforce.com' + '/services/apexrest/vlocity_cmt/v2/cpq/carts/'+carId+'/items/clone';  
            System.debug('EndPointUrl = '+restAPIURL );  
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod('POST');   
            httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
            httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setEndpoint(restAPIURL);
            String reqbody ='{\"items\":[{\"itemId\":\"'+IteId+'\"}]}';
            System.debug(reqbody);
            httpRequest.setBody(reqbody); 
            String response = '';
            try {  
                Http http = new Http();   
                HttpResponse httpResponse = http.send(httpRequest);  
                if (httpResponse.getStatusCode() == 200 ) { 
                    Id orderLineItem;
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) ); 
                    System.debug('response = '+response);
                    JSONParser parser = JSON.createParser(httpResponse.getBody());
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                            (parser.getText() == 'parentId')) {
                            parser.nextToken();
                            orderLineItem = parser.getText();
                            System.debug('orderLineItem = '+orderLineItem);
                            break;
                        }
                    }
        
                    List<OrderItem> OrderItemList = [SELECT Id FROM OrderItem where vlocity_cmt__ParentItemId__c =: orderLineItem];
                    OrderItem parOrderItem = new OrderItem();
                    parOrderItem.id = orderLineItem;
                    OrderItemList.add(parOrderItem);
                    List<vlocity_cmt__OrderAppliedPromotionItem__c> QuoApplProList = new List<vlocity_cmt__OrderAppliedPromotionItem__c>();
                    for(OrderItem qli: OrderItemList){
                        if(qli.id != null){
                            vlocity_cmt__OrderAppliedPromotion__c nitem = new vlocity_cmt__OrderAppliedPromotion__c();
                            nitem.vlocity_cmt__OrderId__c = carId;
                            nitem.vlocity_cmt__Action__c = 'Add';
                            nitem.vlocity_cmt__PromotionId__c=ItemId;
                            insert nitem;
        
                            vlocity_cmt__OrderAppliedPromotionItem__c newIns = new vlocity_cmt__OrderAppliedPromotionItem__c();
                            newIns.vlocity_cmt__OrderItemId__c = qli.id;
                            newIns.vlocity_cmt__AppliedAction__c = 'Add';
                            newIns.vlocity_cmt__OrderAppliedPromotionId__c = nitem.id;
                            QuoApplProList.add(newIns);
                        }
                    }
                    insert QuoApplProList;
                } else {  
                      System.debug(' httpResponse ' + httpResponse.getBody() );  
                      throw new CalloutException( httpResponse.getBody() );  
                }   
            } catch( System.Exception e) {  
                System.debug('ERROR: '+ e); 
                System.debug('Exception e '+e.getLineNumber());                             
                throw e;  
            }  
            System.debug(' ** response ** : ' + response ); 
         }
         public static String generateRandomString(Integer len) {
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randStr = '';
            while (randStr.length() < len) {
               Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
               randStr += chars.substring(idx, idx+1);
            }
            return randStr; 
        }
        void confirmOrder(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
            Order ord;
            Map<String, Object> GetNewNumber = (Map<String, Object>) inputMap.get('GetNewNumber');
            //String msisdn = (String) GetNewNumber.get('SelectNumber'); 
            String msisdn = '1111111111111';
            String fixedLine = (String) GetNewNumber.get('ResidentialfixedVoice'); 
            String unifyServiceId = (String) GetNewNumber.get('ResidentialHighSpeedInternet');
            String tvServiceId = (String) GetNewNumber.get('ResidentialTV');
            ID orderId= (ID) inputMap.get(ConstantsClass.ORDER_ID);
            ID contactId= (ID) inputMap.get(ConstantsClass.CONTACT_ID);
            ID baId= (ID) inputMap.get(ConstantsClass.BILLING_ACCOUNT_ID);
            ID saId= (ID) inputMap.get(ConstantsClass.SHIPPING_ACCOUNT_ID);
            Id busAccId = (ID) inputMap.get(ConstantsClass.BUSINESS_ACCOUNT_ID);
            Id usrId = (ID) inputMap.get('UserId');
            String tvAutoString = (String)inputMap.get('tvAutoString');
            String unifyAutoString = (String)inputMap.get('unifyAutoString');
            System.debug('tvAutoString == '+tvAutoString);
            System.debug('unifyAutoString == '+unifyAutoString);
            //aggiornamento dell'Order
            try{
                Date dateToday = Date.today();
                String sMonth = String.valueof(dateToday.month());
                String sDay = String.valueof(dateToday.day());
                if(sMonth.length()==1){
                  sMonth = '0' + sMonth;
                }
                if(sDay.length()==1){
                  sDay = '0' + sDay;
                }
                String sToday = String.valueof(dateToday.year())+'-'+sMonth+'-'+sDay ;
                Contact cnt= [SELECT Id, Phone, Email FROM Contact WHERE Id =: contactId LIMIT 1];
                Account ba= [SELECT Id, BillingAddress FROM Account WHERE Id =: baId LIMIT 1];
                System.Address billingAddress= ba.BillingAddress;
                Account sa= [SELECT Id, ShippingAddress FROM Account WHERE Id =: saId LIMIT 1];
                System.Address shippingAddress= sa.ShippingAddress;
                ord= [SELECT Id, AccountId FROM Order WHERE Id =: orderId LIMIT 1];
                System.debug('metodo confirmOrder: retrievato order -> '+ord.Id);
                //ord.Type= ConstantsClass.ACTIVATION_TEXT;
                //ord.Status= 'Activated';
                ord.OrderOwner__c = usrId; 
                ord.AccountId = busAccId; 
                ord.vlocity_cmt__Email__c = cnt.Email;
                ord.BillToContactId= contactId;
                ord.ShipToContactId= contactId;
                ord.BillingStreet= billingAddress.getStreet();
                ord.BillingCity= billingAddress.getCity();
                ord.BillingCountry= billingAddress.getCountry();
                ord.BillingPostalCode= billingAddress.getPostalCode();
                ord.BillingState= billingAddress.getState();
                ord.ShippingStreet= shippingAddress.getStreet();
                ord.ShippingCity= shippingAddress.getCity();
                ord.ShippingCountry= shippingAddress.getCountry();
                ord.ShippingPostalCode= shippingAddress.getPostalCode();
                ord.ShippingState= shippingAddress.getState();
                ord.Eligible_For_Mail__c = true;
                ord.vlocity_cmt__Delivery_Installation_Status__c = 'Yet to begin';
                ord.EffectiveDate = Date.valueOf(sToday);
                //RETRIEVARE L'ATTRIBUTO SELECTEDSHOPIS TRAMITE ConstantsClass.SELECTED_SHOP_NAME non viene usato
                ord.vlocity_cmt__Email__c = cnt.Email;
                ord.vlocity_cmt__Phone__c = cnt.Phone;
                UPDATE ord;
                System.debug('metodo confirmOrder: aggiornato order -> '+ord.Id);
            } catch(Exception exc){
                System.debug('metodo confirmOrder: generata eccezione su Order -> '+exc);
            }
            //aggiornamento dell'OrderItemList
            try{
                System.debug('baId == '+baId);
                System.debug('saId == '+saId);
                List<OrderItem> orderItemList= [SELECT Id, unitPrice, Quantity, Pricebookentry.Product2Id, Pricebookentry.ProductCode,Product2.Name,
                                                OrderItemNumber, vlocity_cmt__RecurringTotal__c, vlocity_cmt__OneTimeTotal__c,vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__AssetReferenceId__c,tm_tv_AutoNumber__c,tm_unifi_AutoNumber__c
                                                FROM OrderItem WHERE OrderId =: orderId];
                System.debug('metodo confirmOrder: retrievato orderitemlist');
                Integer quantity;
                Decimal discount= 1;
                for(OrderItem item: orderItemList){                 
                    if(item.Product2.Name == 'SIM Card' || item.Product2.Name == 'Mobile Service'){
                        item.vlocity_cmt__SerialNumber__c = msisdn;
                    }
                    else if(item.Product2.Name == 'VoIP'){
                        item.vlocity_cmt__SerialNumber__c = fixedLine;
                    }
                    else if(item.Product2.Name == 'High Speed Internet'){
                        item.vlocity_cmt__SerialNumber__c = unifyServiceId;
                        item.tm_unifi_AutoNumber__c = unifyAutoString;
                    }
                    else if(item.Product2.Name == 'IPTV'){
                        item.vlocity_cmt__SerialNumber__c = tvServiceId;
                        item.tm_tv_AutoNumber__c = tvAutoString;
                    }
                    else {
                        item.vlocity_cmt__SerialNumber__c= String.valueOf(Math.random()).substring(2);
                    }
                    item.vlocity_cmt__AssetReferenceId__c=item.Id;
                    item.vlocity_cmt__BillingAccountId__c= baId;
                    item.vlocity_cmt__ServiceAccountId__c= saId;
                    item.Contact__c=contactId;
                    item.ServiceDate= Date.today();
                    item.unitPrice= item.unitPrice*discount;
                    item.vlocity_cmt__RecurringTotal__c= item.vlocity_cmt__RecurringTotal__c*discount*item.Quantity;
                }
                //UPDATE orderItemList;
                Database.SaveResult[] srList = Database.update(orderItemList, false);

                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                System.debug('metodo confirmOrder: aggiornato orderitemlist');
            } catch(Exception exc){
                System.debug('metodo confirmOrder: generata eccezione su Order -> '+exc);
            }
            /* creazione degli Assets *
            try{
                vlocity_cmt.DefaultObjectCopierImplementation DefaultCopier = new vlocity_cmt.DefaultObjectCopierImplementation();
                vlocity_cmt.ObjectCopier Copier = new vlocity_cmt.ObjectCopier();
                Copier = DefaultCopier.copyObject(orderId,ConstantsClass.BLANK);
                System.debug('metodo confirmOrder: creati gli assets');
            } catch(Exception exc){
                System.debug('metodo confirmOrder: generata eccezione su Asset -> '+exc);
            }*/
            /* Added for XOM Aria */
            try{
                vlocity_cmt.SimpleDecompositionController.decomposeOrder(ord.Id);
                ID orchestrationId = vlocity_cmt.SimpleDecompositionController.startOrchestrationPlan(ord.Id);
                System.debug('metodo confirmOrder: creato orchestration plan -> '+orchestrationId);
            } catch(Exception exc){
                System.debug('metodo confirmOrder: generata eccezione su Orchestration Plan -> '+exc);
            }
        }
        void submitOrderToTibco(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options)
        {   Map<String, Object> CheckOut = (Map<String, Object>) inputMap.get('CheckOut');
            Map<String, Object> LoginBlock = (Map<String, Object>) CheckOut.get('LoginBlock');
            String myPassword = (String) LoginBlock.get('MyPassword');
            System.debug('myPassword ='+myPassword);
            System.debug('inputMap = '+inputMap);
            ID orderId= (ID) inputMap.get(ConstantsClass.ORDER_ID);
            ID contactId= (ID) inputMap.get(ConstantsClass.CONTACT_ID);
            ID baId= (ID) inputMap.get(ConstantsClass.BILLING_ACCOUNT_ID);
            ID saId= (ID) inputMap.get(ConstantsClass.SHIPPING_ACCOUNT_ID);
            Id busAccId = (ID) inputMap.get(ConstantsClass.BUSINESS_ACCOUNT_ID);
            Id usrId = (ID) inputMap.get('UserId');
            Order currentorder = [Select id,OrderNumber from Order where Id =: orderId limit 1];
            Contact contact = [Select id, email, Firstname , Lastname, phone from contact where id =: contactId limit 1];
            Account businessAccount = [SELECT Id, Name, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where id =: busAccId limit 1];
            vlocity_cmt__PaymentMethod__c paymentMethod = [SELECT Id, vlocity_cmt__AccountId__c, vlocity_cmt__MethodType__c FROM vlocity_cmt__PaymentMethod__c where vlocity_cmt__AccountId__c =: baId limit 1];
            OrderItem orderItem = [Select id, OrderId, Product2.Tibco_OfferId__c from OrderItem where orderId =: orderId limit 1];
            OrderItem simOrderItem = [Select id, OrderId, Product2.Tibco_OfferId__c, vlocity_cmt__SerialNumber__c from OrderItem where Product2.Name = 'SIM Card' and orderId =: orderId limit 1];
            OrderItem hsiOrderItem = [Select id, OrderId, Product2.Tibco_OfferId__c, vlocity_cmt__SerialNumber__c from OrderItem where Product2.Name = 'High Speed Internet' and orderId =: orderId limit 1];
            OrderItem iptvOrderItem = [Select id, OrderId, Product2.Tibco_OfferId__c, vlocity_cmt__SerialNumber__c from OrderItem where Product2.Name = 'IPTV' and orderId =: orderId limit 1];
            OrderItem voipOrderItem = [Select id, OrderId, Product2.Tibco_OfferId__c, vlocity_cmt__SerialNumber__c from OrderItem where Product2.Name = 'VoIP' and orderId =: orderId limit 1];
            User user = [SELECT Id,username from User where id =: usrId limit 1];
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('id', currentorder.OrderNumber);
            gen.writeStringField('externalId', 'account_1234457');
            gen.writeStringField('priority', '1');
            gen.writeStringField('description', 'A wonderful 42 order for brand new products');
            gen.writeStringField('category', 'residential');
            gen.writeStringField('notificationContact', contact.email);
            gen.writeFieldName('note');
            gen.writeStartArray();
            gen.writeStartObject();        
            gen.writeObjectField('text', 'A free text detailing the note');
            gen.writeObjectField('date', '2013-04-12T16:42:23-04:00');
            gen.writeObjectField('author', 'name');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('customer');
            gen.writeStartObject();
            gen.writeStringField('id', busAccId);
            gen.writeStringField('title', 'Mr');
            gen.writeStringField('firstName', contact.Firstname);
            gen.writeStringField('middleName', '');
            gen.writeStringField('lastName', contact.Lastname);
            gen.writeStringField('mobilePhone', contact.phone);
            gen.writeStringField('username', user.username);
            gen.writeStringField('password', mypassword);
            gen.writeStringField('address1', businessAccount.BillingStreet);
            gen.writeStringField('address2', businessAccount.BillingStreet);
            gen.writeStringField('city', businessAccount.BillingCity);
            gen.writeStringField('state', businessAccount.BillingState);
            gen.writeStringField('country', 'IT');
            gen.writeStringField('postcode', businessAccount.BillingPostalCode);
            gen.writeEndObject();
            gen.writeFieldName('orderItem');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', 'TM_QUADPLAY_PROMOTION_BPO');
            gen.writeStringField('action', 'PROVIDE');
            gen.writeFieldName('billingAccount');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', baId);
            gen.writeStringField('billcycle', '01');
            gen.writeStringField('paymentType', '1');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('productOffering');
            gen.writeStartObject();
            gen.writeStringField('id', orderItem.Product2.Tibco_OfferId__c);
            gen.writeEndObject();
            gen.writeFieldName('product');
            gen.writeStartObject();
            gen.writeFieldName('productCharacteristic');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('name', 'MSISDN');
            gen.writeStringField('value', simOrderItem.vlocity_cmt__SerialNumber__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('name', 'ResidentialInternetId');
            gen.writeStringField('value', hsiOrderItem.vlocity_cmt__SerialNumber__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('name', 'ResidentialIPTVId');
            gen.writeStringField('value', iptvOrderItem.vlocity_cmt__SerialNumber__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('name', 'ResidentialVoIPId');
            gen.writeStringField('value', voipOrderItem.vlocity_cmt__SerialNumber__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('name', 'IMSI');
            gen.writeStringField('value', '11232132326');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
        
            String stringBody = gen.getAsString();
            System.debug('stringBody = '+stringBody);
            String strResponse = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://integration.haat.eu//tm/acc/st/order/submit');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            // Set the body as a JSON object
            request.setBody(stringBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response '+response.getBody());
                strResponse = response.getBody();
                System.debug(strResponse);
            } else if(response.getStatusCode() == 200){
                System.debug(response.getBody());
                Order order = new Order();
                order.id = orderId;
                order.Status = 'Submitted';
                order.vlocity_cmt__Delivery_Installation_Status__c = 'In progress';
                update order;
            }
            System.debug('strResponse =='+strResponse);     
        }
        public static void createAssetafterOrdActivation(Id orderId){
            try{
                vlocity_cmt.DefaultObjectCopierImplementation DefaultCopier = new vlocity_cmt.DefaultObjectCopierImplementation();
                vlocity_cmt.ObjectCopier Copier = new vlocity_cmt.ObjectCopier();
                Copier = DefaultCopier.copyObject(orderId,ConstantsClass.BLANK);
                System.debug('Asset Created');
            } catch(Exception exc){
                System.debug('Exception occured during  -> '+exc);
            }   
        }
        
        @Future
        public static void terminateSubToTibco(Id orderIdd){    
            ID orderId = orderIdd;
            ID billingrecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType where SobjectType = 'Account' and Name  = 'Billing' limit 1].id;
            Order order = [Select id, AccountId  from Order where id =: orderId limit 1];
            Account businessAccount = [SELECT Id, Name, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry FROM Account where id =: order.AccountId limit 1];
            Account billingAccount = [SELECT Id, Name, Type, RecordTypeId, ParentId FROM Account where ParentId =: order.AccountId and recordTypeId =: billingrecordTypeId limit 1];
            Contact contact = [Select id, email, Firstname , Lastname, phone,AccountId  from contact where AccountId  =: order.AccountId limit 1];
            OrderItem orderItem = [Select id, OrderId, Product2.Tibco_OfferId__c from OrderItem where orderId =: orderId limit 1];
            OrderItem simOrderItem = [Select id, OrderId, Product2.Tibco_OfferId__c, vlocity_cmt__SerialNumber__c from OrderItem where Product2.Name = 'SIM Card' and orderId =: orderId limit 1];
            User user = [SELECT Id,username,ContactId  from User where ContactId =: contact.id limit 1];
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('id', orderId);
            gen.writeStringField('externalId', 'account_1234457');
            gen.writeStringField('priority', '1');
            gen.writeStringField('description', 'A wonderful 42 order for brand new products');
            gen.writeStringField('category', 'residential');
            gen.writeStringField('notificationContact', 'dyydeepak91@gmail.com');
            gen.writeFieldName('note');
            gen.writeStartArray();
            gen.writeStartObject();        
            gen.writeObjectField('text', 'A free text detailing the note');
            gen.writeObjectField('date', '2013-04-12T16:42:23-04:00');
            gen.writeObjectField('author', 'name');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('customer');
            gen.writeStartObject();
            gen.writeStringField('id', order.AccountId);
            gen.writeStringField('title', 'Mr');
            gen.writeStringField('firstName', contact.Firstname);
            gen.writeStringField('middleName', '');
            gen.writeStringField('lastName', contact.Lastname);
            gen.writeStringField('mobilePhone', contact.phone);
            gen.writeStringField('username', user.username);
            gen.writeStringField('password', 'pass123');
            gen.writeStringField('address1', businessAccount.BillingStreet);
            gen.writeStringField('address2', businessAccount.BillingStreet);
            gen.writeStringField('city', businessAccount.BillingCity);
            gen.writeStringField('state', businessAccount.BillingState);
            gen.writeStringField('country', 'IT');
            gen.writeStringField('postcode', businessAccount.BillingPostalCode);
            gen.writeEndObject();
            gen.writeFieldName('orderItem');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', 'TM_QUADPLAY_PROMOTION_BPO');
            gen.writeStringField('action', 'SEIZE');
            gen.writeFieldName('billingAccount');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', billingAccount.id);
            gen.writeStringField('billcycle', '01');
            gen.writeStringField('paymentType', '1');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('productOffering');
            gen.writeStartObject();
            gen.writeStringField('id', orderItem.Product2.Tibco_OfferId__c);
            gen.writeEndObject();
            gen.writeFieldName('product');
            gen.writeStartObject();
            gen.writeFieldName('productCharacteristic');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('name', 'MSISDN');
            gen.writeStringField('value', simOrderItem.vlocity_cmt__SerialNumber__c);
            gen.writeEndObject();
            gen.writeStartObject();
            gen.writeStringField('name', 'IMSI');
            gen.writeStringField('value', '11232132326');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeEndObject();

            String stringBody = gen.getAsString();
            System.debug('stringBody = '+stringBody);
            String strResponse = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://integration.haat.eu/tm/acc/st/order/terminate');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            // Set the body as a JSON object
            request.setBody(stringBody);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response '+response.getBody());
                strResponse = response.getBody();
                System.debug(strResponse);
            } else if(response.getStatusCode() == 200){
                System.debug(response.getBody());
            }
            System.debug('strResponse =='+strResponse);     
        }
        
            void generateSeviceIds(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options){
            String unifyAutoString = '000000';
            String tvAutoString = '000000';
            OrderItem latestUnifyOrderItem;
            OrderItem latestTVOrderItem;
            Map<String,Object> GetNewNumber = new Map<String,Object>();
            System.debug('inputMap = ='+inputMap);
            Id LeadId = (Id)inputMap.get('LeaddId');
            Lead lead = [Select id,Name from Lead where id =: LeadId limit 1];
            String leadName = lead.Name;
            leadName = leadName.replaceAll('\\s+','');
            try{
                latestUnifyOrderItem = [SELECT Id,tm_unifi_AutoNumber__c,product2.Name FROM OrderItem where product2.Name = 'High Speed Internet' and tm_unifi_AutoNumber__c != null order by createdDate desc limit 1];
                if(latestUnifyOrderItem.tm_unifi_AutoNumber__c != null){
                    Integer unifyAutoNumber = Integer.valueOF(latestUnifyOrderItem.tm_unifi_AutoNumber__c);
                    unifyAutoNumber = unifyAutoNumber + 1;
                    unifyAutoString = String.ValueOf(unifyAutoNumber);
                    unifyAutoString = unifyAutoString.leftPad(6,'0');
                }
                GetNewNumber.put('ResidentialHighSpeedInternet',leadName+unifyAutoString+'@unifi');
                outMap.put('GetNewNumber',GetNewNumber);
                outMap.put('unifyAutoString',unifyAutoString);
            }
            catch(Exception e){
                System.debug('Exception occured:'+ e);
                GetNewNumber.put('ResidentialHighSpeedInternet',leadName+unifyAutoString+'@unifi');
                outMap.put('GetNewNumber',GetNewNumber);
                outMap.put('unifyAutoString',unifyAutoString);  
            }
            try{
                latestTVOrderItem = [SELECT Id,tm_tv_AutoNumber__c,product2.Name FROM OrderItem where product2.Name = 'IPTV' and tm_tv_AutoNumber__c != null order by createdDate desc limit 1];
                if(latestTVOrderItem.tm_tv_AutoNumber__c != null){
                    Integer tvAutoNumber = Integer.valueOF(latestTVOrderItem.tm_tv_AutoNumber__c);
                    tvAutoNumber = tvAutoNumber + 1;
                    tvAutoString = String.ValueOf(tvAutoNumber);
                    tvAutoString = tvAutoString.leftPad(6,'0');
                }
                GetNewNumber.put('ResidentialTV',leadName+tvAutoString+'@IPTV');
                outMap.put('GetNewNumber',GetNewNumber);
                outMap.put('tvAutoString',tvAutoString);
            }
            catch(Exception e){
                System.debug('Exception occured:'+ e);
                GetNewNumber.put('ResidentialTV',leadName+tvAutoString+'@IPTV');
                outMap.put('GetNewNumber',GetNewNumber);
                outMap.put('tvAutoString',tvAutoString);    
            }
        }
}