000100230214**free
000200201008ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
001000201008dcl-pi *n;
001100201008  pa_sonda char(10);  // IN Nome della sonda
001200201008  pa_esit  char(2);   // OU Esito del controllo (OK/KO)
001300201008  pa_mess  char(80);  // OU Descrizione esito controllo
001400201008  pa_seve char(1);    // OU Severità errore esecuzione (RFC5424)
001500201008  pa_avvi char(1);    // OU Avvio immediata reazione (S=si  N=No)
001600201008  pa_msid char(10);   // OU Message Id
001700201008END-PI;
001701220131
001702220131dcl-pr pg0611 extpgm('PG0611') end-pr;   // Crea ambiente
001703220131
001704220131dcl-pr pg0612 extpgm('PG0612');          // Converte e inserisce il file HTML
001705220131  pafil char(10);   // file di db
001706220131  palib char(10);   // Libreria del DB
001707220131  pah2c char(10);   // Colore h2
001708220131  pah2t char(200);  // Testo dell'h2
001709220131  pah3c char(10);   // Colore h3
001710220131  pah3t char(200);  // Testo dell'h3
001711220131End-pr;
001712220131
001713220131dcl-pr pg0613 extpgm('PG0613');          // Chiude il file HTML e lo converte in IFS
001714220131  padoc char(200);   // file di db
001715220131End-pr;
001716220317
001717220317dcl-pr pg073 extpgm('PG073'); // crea i documenti in formato html in wwe
001718220317     *n char(10);   // Sonda
001719220317     *n timestamp;
001720220317End-pr;
001721220317
001722220131
001723220201dcl-s   pafil char(10);   // file di db
001724220201dcl-s   palib char(10);   // Libreria del DB
001725220201dcl-s   pah2c char(10);   // Colore h2
001726220201dcl-s   pah2t char(200);  // Testo dell'h2
001727220201dcl-s   pah3c char(10);   // Colore h3
001728220201dcl-s   pah3t char(200);  // Testo dell'h3
001729220201dcl-s   padoc char(200);  // file di db
001730220131
001732220201dcl-pr PG0614 extpgm('PG0614') ;
001733220201  paogg char(300); // Oggetto della mail
001734220201  padoc char(200); // Nome del documento creato
001735220201  pades char(100); // Destinatario
001736220201  pafi1 char(100); // patf allegato 1
001737220201  pafi2 char(100); // patf allegato 2
001738220201  pasta char(5); // status
001739220201end-pr ;
001740220201
001741220201dcl-s paogg char(300); // Oggetto della mail
001743220201dcl-s pades char(100); // Destinatario
001744220201dcl-s pafi1 char(100); // patf allegato 1
001745220201dcl-s pafi2 char(100); // patf allegato 2
001746220201dcl-s pasta char(5); // status
001747220201dcl-s Linea char(4108);
001757220201
001758220201
001759220131dcl-pr QCMDEXC extpgm('QCMDEXC') ;
001760220131  *N  char(500) options(*varsize) const ;
001761220131  *n packed(15:5) const ;
001762220131end-pr ;
001763220131
001764220131dcl-s comando char(500);
001765201008
001766220128dcl-pr pg039 extpgm('PG039');   // scrive il file di log
001767220128  *n      char(10) const;    // Nome sonda
001768220128  *n      char(1)  const;     // Severità evento
001769220128  *n      char(2)  const;     // esito della sonda
001770220128  *n      char(80) const;    // testo dell'evento
001771220128  *n      char(7)  const;     // Id Messaggio
001772220128  *n      char(10) const;    // Nome sonda
001773220128  *n      zoned(15:0) const; // id evento
001774220128  *n      char(80) const;    // Nota
001775220128  *n      char(80) const;    // Nota
001776220128END-Pr;
001777201012
001778220128dcl-ds db extname('WWE/DBSAVEJOB') qualified end-ds;
001779220128
001780220128dcl-ds jo qualified;
001781220128  job char(28);
001782220128  ini timestamp;
001783220128  fin timestamp;
001784220128  sev zoned(10:0);
001785220128  tra char(50);
001786220128  dur zoned(10:0);
001787220128  ore zoned(10:0);
001788220131  nomejob char(28);
001789220131  gra zoned(2:0);
001790220131  trascorso char(30);
001791220131  durmin zoned(13:0);
001792220131  durore zoned(13:0);
001793220128End-ds;
001794201006
001795220128dcl-s wknome char(10); // wrk nome deljob
001796220128dcl-s esitojob char(2); // Esito del job di backup
001797210610dcl-s giorno char(1); // giorno della settimana 1=Lunedì
001798201008dcl-s adesso timestamp;
001799201008dcl-s sonda char(10);
001800220201dcl-s sistema char(10);
001801220128
001802201008dcl-s errori int(5);
001803201008dcl-s buoni int(5);
001804201008dcl-s flag  char(1);
001805210610dcl-s flagerror  char(1);  // determina se si è verificato un errore o meno
001806210610dcl-s attivo int(5);  // Numero di JOB/SBS Attivi
001807220314
001808220314dcl-s todonumero int(5);
001809201006
001810201008exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
001811201008//
001812201008adesso=%timestamp();
001813220128sonda= 'SYS016';
001814201008errori = 0;
001815220201exec sql SELECT CURRENT SERVER into :sistema FROM SYSIBM.SYSDUMMY1;
001816220314
001817220314 exsr todo; // Verifica se c'è qualcosa da fare.
001818220314
001819220128exec sql DECLARE savejob  CURSOR FOR SELECT * FROM wwe.dbsavejob WHERE sospeso <> 'S';
001820201008
001821220128exec sql open savejob ;
001822201008dow 1=1;
001823220128  exec sql fetch savejob into :db;
001824201008  if sqlcode <> 0;
001825201008    leave;
001826201008  ENDIF;
001827220128  //=================================================================================================================================
001828220128
001829220128  exsr verifica; // verifica che il controllo deve essere effettuato
001830220128
001831220128
001832210610  if flag = '1'; // la routine verifica ha determinato che il controllo deve essere effettuato !
001833220128    wknome=db.nome;
001834220128    exsr Control;  // Controllo del job/sbs
001835220207  else;
001836220207    exsr nonprevisto;
001837210610  endif;
001838210610
001839201008enddo;
001840200827
001841220128exsr Esita;    // Esita il fine ciclo della sonda
001842220131
001843220131exsr Creadoc;  // Crea il documento e lo invia ai destinatari
001844220207
001845220207
001846220207exec sql close savejob ;
001847201008*inlr = *on;
001848210610
001849210610
001850210610// =============================================================================================
001851210610begsr esita;  // Termine delle operazioni e scrittura dei risultati
001852220128  // =============================================================================================
001853210610
001854220128  if errori = 0;
001855210610
001856220128    pa_esit = 'OK';                              // esito Positivo
001857220207    pa_mess = 'Tutti i job di Backup sono completati correttamente';
001858220128    pa_seve = '6';                               // Messaggio di tipo informativo (6)
001859220128    pa_avvi = 'N';                               // Solo registrazione su log
001860220128    pa_msid = 'BCK00001';                        // Chiave del messaggio
001861210610
001862220128  else;
001863220128    callp(e) pg039(pa_sonda:'3':'KO':
001864220128      'ATTENZIONE: Si sono verificati dei problemi nei job di backup'
001865220128    : ' ' : 'BCK ERROR':0:' ': ' ');
001866210610
001867220128    pa_esit = 'KO';                              // esito Positivo
001868220209    pa_mess = 'ALERT! Si sono verificati errori nei job di backup' ; //
001869220128    pa_seve = '3';                               // Messaggio di tipo informativo (6)
001870220214    pa_avvi = 'N';                               // Solo registrazione su log
001871220128    pa_msid = 'BCK00002';                        // Chiave del messaggio
001872220128  ENDIF;
001873220131
001874220131
001875210610endsr;
001876210610// =============================================================================================
001877220131begsr control;  // esito del backup
001878220128  // =============================================================================================
001879210610
001888220128  exec sql
001889220128
001890220128     SELECT  from_job AS job,
001891220128    min(message_timestamp) AS Inizio,
001892220128    max(message_timestamp) AS Fine,
001893220128    max(severity) Sev,
001894220128    wwe.difdate(max(message_timestamp), min(message_timestamp)) Trascorso,
001895220128    TIMESTAMPDIFF(4, CAST(max(message_timestamp) - min(message_timestamp) AS CHAR(22)))   AS DurataMinuti,
001896220131    TIMESTAMPDIFF(8, CAST(current_timestamp - min(message_timestamp) AS CHAR(22)))   AS Ore_trascorse ,
001897220131    from_job as nomejob
001898220128			  into :jo
001899220128          FROM  TABLE(qsys2.history_log_info( CURRENT timestamp- 7 days ))
001900220128    WHERE substr(from_job, locate_in_string (from_job, '/', 1, 2) +1, 10)  =  :wknome
001901230214          AND MESSAGE_ID NOT IN (SELECT msgid FROM wwe.dbsaveomit)
001902220128    GROUP BY from_job ORDER BY from_job DESC LIMIT 1;
001903220128
001904220128    // - Controllo Esito ---------------------------------------
001905220128  esitojob = *blanks;
001906220128
001907220128  if jo.job <> *blanks; // Il job è stato trovato
001908220128    if jo.ore < db.ritroso; // job nei limiti
001909220128      esitojob ='OK';
001910220128    else;
001911220128      esitojob = 'KO'; // Job trovato ma fuori limite
001912220128    Endif;
001913220128  Else;
001914220128    esitojob = 'KO'; // Job non trovato
001915220128  Endif;
001916220128
001917220128  if esitojob = 'OK';
001918220128    if jo.sev = 0;
001919220128      db.esito = 'OK';                        // Job completato in modo corretto
001920220131      db.message = %trim(wknome)  + ' - Completato correttamente';
001921220128    else;
001922220128      db.esito = 'KO';                        // Job completato con errori
001923220131      db.message = %trim(wknome)  + ' - Completato Con errori';
001924220128      errori = errori+1;
001925220128    Endif;
001926220128  else;
001927220128    db.esito = 'KO';                       // Job NON Eseguito
001928220131    db.message = %trim(wknome)  +  ' - Job non eseguito';
001929220128    errori = errori+1;
001930220128  Endif;
001931220128
001933220128
001934220131  exec sql update wwe.dbsavejob a set lastck= :adesso, esito=:db.esito, message = :db.message,
001935220131           job=:jo.nomejob, sev = :jo.sev, trascorso = :jo.tra, durmin = :jo.dur ,durore = :jo.ore,
001936220131           inizio = :jo.ini
001937220131             where nome = substr(:jo.nomejob, locate_in_string (:jo.nomejob, '/', 1, 2) +1, 10);
001938210610
001939210610
001940210610endsr;
001941210610
001942210610// =============================================================================================
001943210610begsr verifica;  // verifica se il controllo deve essere eseguito.
001944220128  // =============================================================================================
001945201008
001946220128  exec sql select  DAYOFWEEK_ISO(:adesso) into :giorno from sysibm.sysdummy1;   // recupero il giorno della settimana
001947210610
001948220128  flag = '0';
001949220128
001950220128  select; // Controllo per esecuziona ad una determinata ora !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
001951220128  when giorno = '1' and db.lun = 'S';
001952220128    flag = '1';
001953220128  when giorno = '2' and db.mar = 'S';
001954220128    flag = '1';
001955220128  when giorno = '3' and db.mer = 'S';
001956220128    flag = '1';
001957220128  when giorno = '4' and db.gio = 'S';
001958220128    flag = '1';
001959220128  when giorno = '5' and db.ven = 'S';
001960220128    flag = '1';
001961220128  when giorno = '6' and db.sab = 'S';
001962220128    flag = '1';
001963220128  when giorno = '7' and db.dom = 'S';
001964220128    flag = '1';
002068220128  Endsl;
008900201008endsr;
008901201008
008902220131// =============================================================================================
008903220131begsr creadoc; // Operazioni di creazione pagina html e salvataggio in ifs
008904220131  // =============================================================================================
008905220201  // prepara l'ambiente
008906220131
008907220131  comando = 'dltf qtemp/dbrptsa*';
008908220131  callp(e) QCMDEXC(Comando:%len(Comando));
008909220131
008910220131  // Prepara i dati della lista dei job come sono andati:
008911220131
008912220131  exec sql create table qtemp.dbrptsa1 as(
008913220207SELECT
008914220207                CASE  WHEN esito = 'OK' THEN '<b><font color="00c400">' || nome
008915220207                      WHEN esito = 'NO' THEN '<b><font color="d9a806">' || nome
008916220207                      ELSE '<b><font color="red">'  || nome END AS nome ,
008917220207                CASE  WHEN esito = 'OK' THEN '<b><font color="00c400">' || descri
008918220207                      WHEN esito = 'NO' THEN '<b><font color="d9a806">' || descri
008919220207                      ELSE '<b><font color="red">'  || descri END AS descri ,
008920220207                SOSPESO,
008921220207                substring(dayname(inizio), 1, 3) || ' - '  || VARCHAR_FORMAT(inizio ,'HH24:MI:SS DD/MM/YYYY ') AS Start_Job ,
008922220207                TRASCORSO AS Durata_Totale  ,
008923220207                VARCHAR_FORMAT(LASTCK ,'HH24:MI:SS DD/MM/YYYY ') AS Controllato,
008924220207                CASE WHEN esito = 'OK' THEN '<b><font color="00c400">' || esito
008925220207                     WHEN esito = 'NO' THEN '<b><font color="d9a806">' || esito
008926220207                     ELSE '<b><font color="red">'  || esito  END AS esito ,
008927220207				sev, MESSAGE, MSGID, JOB
008928220207  FROM wwe.dbsavejob
008930220131  ) with data;
008931220131
008932220131
008933220131  // Prepara i dati degli ultimi salvataggi effettuati :
008934220131
008935220131  exec sql create table qtemp.dbrptsa2 as(
008936220131    WITH temp as(
008937220131                SELECT from_job, severity,message_timestamp
008938220131                FROM TABLE(qsys2.history_log_info( CURRENT timestamp- 7 days ))
008939220131                WHERE message_id   in('BRM10A1', 'BRM14A1', 'BRM16A1', 'CPC3701', 'CPC3704', 'CPC3708', 'CPC370D',
008940220131                'CPC3720', 'CPC3721', 'CPC3722',  'CPC3723', 'CPC3732', 'CPC3733', 'CPC3736',
008941220131                'CPC9036', 'CPC9410', 'CPD3796','CPF3701','CPF3702','CPF3751','CPF3771','CPF3777','CPF3823',
008942230214                'CPF3837','CPF3838',' CPI671F') and MESSAGE_ID NOT IN (SELECT msgid FROM wwe.dbsaveomit))
008943220131                SELECT
008944220131                CASE
008945220131                WHEN max(severity) = '00' THEN '<b><font color="00c400">Information'
008946220131                WHEN max(severity) = '10' THEN '<b><font color="d9a806">Warning'
008947220131                WHEN max(severity) = '20' THEN '<b><font color="d9a806">Error'
008948220131                WHEN max(severity) = '30' THEN '<b><font color="red">Severe Error'
008949220131                WHEN max(severity) = '40' THEN '<b><font color="red">Abnormal End of Program'
008950220131                WHEN max(severity) = '50' THEN '<b><font color="red">Abnormal End of Job'
008951220131                WHEN max(severity) = '60' THEN '<b><font color="red">System Status'
008952220131                WHEN max(severity) = '70' THEN '<b><font color="red">Device Integrity'
008953220131                WHEN max(severity) = '80' THEN '<b><font color="red">System Alert'
008954220131                WHEN max(severity) = '90' THEN '<b><font color="red">System Integrity'
008955220131                END AS Esito,
008956220131                substr(from_job, locate_in_string (from_job, '/', 1, 2) +1, 10) aS NOME,
008957220131                max(severity) AS MaxSev,
008958220131                from_job AS job,
008959220131                 DAYNAME(min(message_timestamp))  AS giorno,
008960220131                VARCHAR_FORMAT(min(message_timestamp) ,'HH24:MI:SS DD/MM/YYYY ') AS inizio ,
008961220131                VARCHAR_FORMAT(max(message_timestamp) ,'HH24:MI:SS DD/MM/YYYY ') AS fine ,
008962220131                wwe.difdate(max(message_timestamp), min(message_timestamp)) durata
008963220131                FROM temp GROUP BY from_job ORDER BY job desc limit 100
008964220131  ) with data;
008965220131
008966220131
008967220201
008968220131
008969220201  callp(e)  pg0611();                                       // Creazione ambiente HTML
008970220201
008984220201  pafil = 'DBRPTSA1';
008985220201  Palib = 'QTEMP' ;
008986220201  pah2c = '01718a';
008987220201  pah2t = 'Esito job di backup:';
008988220201  callp(e)  pg0612(pafil:palib:pah2c:pah2t:pah3c:pah3t);    // Iserisce DB in HTML
008989220131
008990220131
008991220201  pafil = 'DBRPTSA2';
008992220201  Palib = 'QTEMP' ;
008993220201  pah2c = '01718a';
008994220201  pah2t = 'Job che hanno eseguito operazioni di Backup (ultimi 7 giorni):';
008995220201  callp(e)  pg0612(pafil:palib:pah2c:pah2t:pah3c:pah3t);     // Iserisce DB in HTML
008996220131
008997220131
008998220318  padoc = '/WWE/' +  %trim(sonda)   + '-' + %trim(%char(%timestamp(adesso))) +'.html';
008999220201  callp(e)  pg0613(padoc);                                     //  chiude il file HTML
009000220131
009001220308  paogg=  %trim(sistema) + '/SYS016 - Backup Jobs - ' +' '+   %trimr(%char(adesso)) ;
009002220308
009003220308    EXEC SQL  DECLARE sndmail CURSOR FOR select DESTIN from wwe.dbmail where sonda = :sonda;
009004220201  exec sql open sndmail;
009005220201  dow 1=1;
009006220201    exec sql FETCH sndmail INTO :pades;
009007220201    if sqlcode <> 0;
009008220201
009009220201      leave;
009010220201    Endif;
009011220201    callp(e) PG0614(paogg:padoc:pades:pafi1:pafi2:pasta) ;
009012220202
009013220202
009014220202  if pasta = *blanks;
009015220202       callp(e) pg039(pa_sonda:'6':'OK': 'Invio Report Ok a: ' + pades  : ' ' : 'RPT-BCK':0:' ': ' ');
009016220202  else;
009017220202       callp(e) pg039(pa_sonda:'3':'KO': 'ERRORE ' + pasta + ' invio report a:' + pades : ' ' : 'RPT-BCK':0:' ': ' ');
009018220202  endif;
009019220202
009020220201  Enddo;
009021220207
009022220207  exec sql close sndmail;
009023220317
009024220318  // callp(e) pg073(pa_sonda: adesso);     // recupera e scrivei dettagli del lavoro
009025220201
009026220207endsr;
009027220207
009028220207// =============================================================================================
009029220207begsr nonprevisto;
009030220207// =============================================================================================
009031220207
009032220207    db.esito = 'NO';                       // Job NON Eseguito
009033220207    db.message = %trim(db.nome)  +  ' - Esecuzione JOB NON Prevista ';
009034220207
009035220207
009036220207  exec sql update wwe.dbsavejob a set lastck= :adesso, esito=:db.esito, message = :db.message,
009037220207           job='  ', sev = 0, trascorso = 0, durmin = 0 ,durore = 0 , msgid='          '
009038220207             where nome = :db.nome;
009039220207
009040220207endsr;
009041220314
009042220314//================================================================================================================
009043220314begsr todo; // controllo se c'è qualcosa da fare --
009044220314//
009045220314exec sql select count(*) into :todonumero from wwe.dbsavejob where sospeso <> 'S';
009046220314
009047220314  if todonumero = 0;
009048220314    pa_esit = 'OK';                              // esito Positivo
009049220314    pa_mess = 'Nessun job di salvataggio da controllare!';
009050220314    pa_seve = '6';                               // Messaggio di tipo informativo (6)
009051220314    pa_avvi = 'N';                               // Solo registrazione su log
009052220314    pa_msid = 'NO-SAVEJOB';
009053220314    *inlr = *on;
009054220314    return;
009055220314  endif;
009056220314
009057220314endsr;
009058220314
