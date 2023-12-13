000100230210**free
000101230210ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000102230210
000103230210// Ex *entry plist ora si chiama Program interface
000104230210
000105230210//dcl-pi *n;
000106230210//  paid char(20);
000107230210//End-pi;
000108230210
000109230210
000110230210// Dichiarazione dei campi per la chiamata del webservice
000111230210
000112230210dcl-s paid char(20) inz('1234'); // da togliere abilitando la program interface
000113230210
000114230210dcl-s wsurl char(4000); // url del webservice
000115230210dcl-s wsheader  char(4000); // url del header
000116230210dcl-s wsbody char(4000); // url del Body - conterrà il json con i parametri di richiesta
000117230210
000118230210
000119230210dcl-s wsJrisp char(10000); // Risposta del ws conterrà il json
000120230210dcl-s wsSrisp char(4000); // Risposta del ws "Sistemistica"
000121230210
000122230210
000123230210dcl-ds jrisposta;
000124230210    inputId varchar(200);
000125230210    operation varchar(200);
000126230210    success varchar(200);
000127230210    type varchar(200);
000128230210    message varchar(200);
000130230210End-ds;
000131230210
000132230210exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
000133230210
000134230210exec sql call qcmdEXC('chgjob ccsid(280)'); necessaria perchè il mio sistema utilizza per il job il codepGE 65565
000135230210
000136230210 // Valorizzazione dell'url con la specifica dell'id paziente che arriva da parametro esterno
000137230210 wsurl = 'https://sandbox.solgroup.com/test/estar-experience/api/accounts/' + %trim(paid) ;
000138230210
000139230210wsheader = '<httpHeader> <header name="Content-type"  value="application/json"/> <header name="client_id"  value="affa9b09c43d43e68b5d6d09404ec15d"/>' +
000140230210' <header name="client_secret"  value="62F17BD8179742E2bfeea17D8bDd8D95"/>   </httpHeader>' ;
000141230210
000142230210wsbody =
000143230210'{ "source" : "MEDICAIR", "inputId" : "1", "firstName": "Mario", "lastName": "Rossi", "taxCode": "123456ABCDEF123456", "ssnCode": "ABCDEF123456", "beginDate":'+
000144230210  '"2016-02-22T10:00:01.63+01:00", "birthDate": "1980-02-22T10:00:01.63+01:00", "birthCityId": "12345", "birthCountryId": "12345", "gender": "M", "title": "Mr.", "addresses": [' +
000145230210    '{ "inputId" : "2", "sintesiId": "12345", "addressType": "1", "locationType": "H", "default": true, "addressDescription": "Piazza Roma 10",'+
000146230210     '"zipCode": "12345", "city": "Milano", "country": "Italia", "hasLift": false }, ' +
000147230210    '{    "inputId" : "3", "addressType": "1", "locationType": "V", "default": false, "addressDescription": "Via Michelangelo 16", "zipCode": ' +
000148230210      '"54321", "city": "Roma", "country": "Italia", "hasLift": true }  ' +
000149230210  '], "accountTreatments": [ { "treatmentId": "987654321", "accountTreatmentStatuses": [ { "inputId" : "4", "status": "WAIT", "statusFromDate": "2023-02-22T10:00:01.63+01:00" } ] } ]}';
000150230210
000151230210
000152230210
000153230210 exec sql select coalesce(responsemsg,' '), coalesce(responsehttpheader,' ') into :wsJrisp , :wsSrisp
000154230210    from table (SYSTOOLS.HTTPPUTCLOBVERBOSE( :wsurl, :wsheader, :wsbody));
000155230210
000156230210 exec sql    INSERT INTO  gian.dblogpazienti VALUES(current_timestamp,:paid, 1234, 98765, :wsurl, :wsheader, :wsbody, :wsJrisp, :wsSrisp );
000157230210
000158230210
000159230210exec sql  declare jresult cursor for
000160230210      SELECT * FROM JSON_TABLE(:wsJrisp,
000161230210     '$' COLUMNS( NESTED '$.results[*]'COLUMNS ( "inputId" varchar(200) , "operation"varchar(200) , "success" varchar(200) , "type" varchar(200) , "message" varchar(200) ) ) ) ;
000162230210
000163230210exec sql open jresult;
000164230210
000165230210dow 1=1;
000166230210  exec sql fetch jresult into :jrisposta;
000167230210   if sqlcode <> 0;
000168230210    leave;
000169230210   endif;
000170230210Enddo;
000171230210
000172230210 exec sql close jresult;
000173230210
000174230210 *inlr = *on;
000175230210
