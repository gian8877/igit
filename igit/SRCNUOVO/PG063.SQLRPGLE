000001200522**free
000002201008ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000003230213dcl-f pg063v workstn sfile(SF1:$1)  sfile(SF2:$2) ;
000004220128dcl-ds db extname('WWE/DBSAVEJOB') qualified end-ds;
000005230213dcl-ds om extname('DBSAVEOMIT') qualified end-ds;
000006200522
000007201008dcl-s $1 int(5);  // puntatore Subfile
000008230213dcl-s $2 int(5);  // puntatore Subfile
000009230213
000010230213dcl-s sql1 varchar(10000);
000011230213dcl-s a char(1) inz(x'7d');
000012230213dcl-s xnome char(12) ;
000013230213
000014230213
000015230213dcl-pr pg0631 extpgm('PG0631'); // Recupero della descrizione del messaggio
000016230213END-PR;
000017200522
000020201008exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
000022200625
000023201008adesso=%timestamp();
000024200625
000025200522
000026200522
000027201008// MAIN LINE ========================================================================
000028201008dow 1=1;
000029201008  exsr carica;
000030200522
000031201008  write w01;
000032201008  exfmt sc1;
000033200522
000034201008  if *in03=*on;        // richiesto fine lavoro
000035201008    leave;
000036201008  endif;
000037200522
000038201008  if *in06 =*on;       // richiesto immissione nuova azione
000039201008    exsr immissione;
000040201008  ENDIF;
000041200522
000042230213  if *in09 =*on;       // richiesto immissione nuova azione
000043230213    callp(e) pg0631();
000044230213  ENDIF;
000045230213
000046201008  exsr scelta;
000047200522
000048201008ENDDO;
000049200522
000050201008*inlr =*on;
000051201008// =================================================================================
000052201008begsr carica; // caricamento dati dal file
000053201008  // =================================================================================
000054200522
000055201008  $1=0;
000056201008  *in12=*off;
000057201008  *in11=*on;
000058201008  write sc1;
000059201008  *in11=*off;
000060200522
000061220128  exec sql DECLARE lista CURSOR FOR select rrn(a), a.* from wwe.dbsavejob a order by nome ;
000062201008  exec sql open lista;
000063200522
000064201008  dow 1=1;
000065210930    exec sql fetch lista into :rrn, :db;
000066201008    if sqlcode <> 0;
000067201008      leave;
000068201008    ENDIF;
000069201008
000070210610    nome=db.nome;
000071210610    DESCRI= db.DESCRI;
000072210610    sospeso=db.sospeso;
000073210610    esito=db.ESITO;
000074220131    exec sql select  VARCHAR_FORMAT(:db.LASTCK,'HH24:MI:SS DD/MM/YYYY ') || '- ' ||
000075220131    substring(dayname(:db.LASTCK), 1, 3)  into :time from sysibm.sysdummy1;
000076220131    mess = db.message;
000077230213    // time=%char(db.LASTCK);
000078210610
000091201008    $1=$1+1;
000092220207    *in40 = *off; // Esito OK
000093220207    *in41 = *off; // Il job NON doveva essere controllato
000094220207    *in42 = *off; // Errore
000095220207
000096201008    WSSCEL=*blanks;
000097220207    select ;
000098230213    when esito = 'OK';
000099230213      *in40=*on;
000100230213    when esito = 'NO';
000101230213      *in41=*on;
000102230213    when esito = 'KO';
000103230213      *in42=*on;
000104220207    Endsl;
000105220207
000111201008    write sf1;
000112201008  enddo;
000113200522
000114201008  exec sql close lista;
000115200522
000116201008  if $1 > 0;
000117201008    *in12 = *on;
000118201008  else;
000119201008    *in12 = *off;
000120201008  ENDIF;
000121200522
000122200522
000123201008endsr;
000124200522
000125201008// =================================================================================
000126201008begsr immissione; // caricamento nuova azione
000127201008  // =================================================================================
000128230213  *in22=*off;
000129220302  *in23=*off;
000130220302  clear w02;
000131220302
000132220302  lun ='N';
000133220302  mar ='N';
000134220302  mer ='N';
000135220302  gio ='N';
000136220302  ven ='N';
000137220302  sab ='N';
000138220302  dom ='N';
000139220302
000140220302
000141220302  dow 1=1;
000142220302    exfmt w02;
000143220302    if *in03=*on; // richiesta fine lavoro;
000144220302      leave;
000145220302    ENDIF;
000146230213    if *in08=*on; // Analisi job;
000147230213      exsr analisijob;
000148230213    ENDIF;
000149220302
000150220302
000151220302    DB.NOME       = NOME      ;
000152220302    DB.DESCRI     = DESCRI    ;
000153220302    DB.SOSPESO    = SOSPESO   ;
000154220302    DB.ritroso    = ritroso   ;
000155220302    db.lun =lun;
000156220302    db.mar =mar;
000157220302    db.mer =mer;
000158220302    db.gio =gio;
000159220302    db.ven =ven;
000160220302    db.sab =sab;
000161220302    db.dom =dom;
000162220302
000163220302    DB.LASTCK     = %timestamp('0001-01-01-00.00.00.000000')   ;
000164220302    DB.sev      = 0;
000165220302    DB.DURMIN     = 0;
000166220302    DB.DURORE        = 0;
000167220302    DB.inizio     = %timestamp('0001-01-01-00.00.00.000000')   ;
000168220302    DB.ESITO      = ESITO     ;
000169220302    DB.MESSAGE    = MESSAGE   ;
000170220302    DB.msgid    = msgid   ;
000171220302    DB.tipolog    = tipolog   ;
000172220302
000173220302    if sospeso=' ';
000174220302      db.sospeso='N';
000175220302    ENDIF;
000176220302
000177220302    exec sql INSERT INTO wwe.dbsavejob  VALUES(:
000178220302    db);
000179220302    leave;
000180220302  ENDDO;
000181220302endsr;
000235201008// =================================================================================
000236201008begsr scelta ; // scelta opzione
000237201008  // =================================================================================
000238201008  $1=0;
000239201008  dow 1=1;
000240201008    $1=$1+1;
000241201008    chain(e) $1 sf1;
000242220128    if not %found(pg063v);
000243201008      leave;
000244201008    ENDIF;
000245200522
000246201008    if WSSCEL = '4';  // cancellazione
000247220128      exec sql delete wwe.dbsavejob a  where rrn(a) = :rrn ;
000248201008      iter;
000249201008    ENDIF;
000250200522
000251201008    if WSSCEL = '2'; // modifica
000252201008      exsr modifica;
000253201008      iter;
000254201008    endif;
000255201008  enddo;
000256200522
000257201008endsr;
000258201008// =================================================================================
000259201008begsr modifica; // caricamento nuova azione
000260201008  // =================================================================================
000264220128  exec sql select * into :db from wwe.dbsavejob a  where rrn(a) = :rrn;
000265210610
000266220128  NOME       =  DB.NOME      ;
000267220128  DESCRI     =  DB.DESCRI    ;
000268220128  SOSPESO    =  DB.SOSPESO   ;
000269220128  lun =db.lun;
000270220128  mar =db.mar;
000271220128  mer =db.mer;
000272220128  gio =db.gio;
000273220128  ven =db.ven;
000274220128  sab =db.sab;
000275220128  dom =db.dom;
000297220128  LASTCK     =  DB.LASTCK    ;
000298220128  ESITO      =  DB.ESITO     ;
000299220128  MESSAGE    =  DB.MESSAGE   ;
000300220128  msgid      =  DB.msgid   ;
000301220128  ritroso    =  db.ritroso   ;
000302220128  tipolog    =  db.tipolog   ;
000303210610
000330200525
000331210930  dow 1=1;
000332201008    exfmt w02;
000333230213    if *in08=*on; // Analisi job;
000334230213      exsr analisijob;
000335230213    ENDIF;
000336230213
000337230213
000338201008    if *in03=*on; // richiesta fine lavoro;
000339201008      leave;
000340201008    ENDIF;
000341201008    exsr ctlw02;
000342210930    if *in22 = *on;  // presenza di errori !!!
000343201008      iter;
000344201008    ENDIF;
000345230213
000346230213
000347210930
000348210930
000349200522
000366220128    DB.NOME       = NOME      ;
000367220128    DB.DESCRI     = DESCRI    ;
000368220128    DB.SOSPESO    = SOSPESO   ;
000369220128    db.lun =lun;
000370220128    db.mar =mar;
000371220128    db.mer =mer;
000372220128    db.gio =gio;
000373220128    db.ven =ven;
000374220128    db.sab =sab;
000375220128    db.dom =dom;
000397220128    DB.LASTCK     = LASTCK    ;
000398220128    DB.ESITO      = ESITO     ;
000399220128    DB.MESSAGE    = MESSAGE   ;
000400220131    DB.msgid      = msgid   ;
000401220128    DB.ritroso    = ritroso   ;
000402220128    DB.tipolog    = tipolog   ;
000403201008    if sospeso=' ';
000404201008      db.sospeso='N';
000405201008    ENDIF;
000406201008
000407201008
000408220128    exec sql update wwe.dbsavejob a set row = :db where  rrn(a) = :rrn;
000409201008    leave;
000410200522
000411201008  ENDDO;
000412201008endsr;
000413200522
000414201008// =================================================================================
000415201008begsr ctlw02; // caricamento nuova azione
000416210930
000417210930
000418210930  *in22 = *off;
000419210930  errore = *blanks;
000420210930
000421220128  if sospeso <> 'S' and sospeso <> 'N';
000422220128    *in22 = *on;
000423220128    errore = 'Il campo sospeso deve essere S o N';
000424220128  Endif;
000484201008endsr;
000485230213
000486230213
000487230213// =================================================================================
000488230213begsr analisijob; // Controllo e simulazione job di errori
000489230213
000490230213
000491230213  // Recupero le informazioni dell'ultimo job eseguito (negli ultimi 7 giorni
000492230213  xnome= a+ %trim(nome) + a;
000493230213  sql1 =
000494230213  'create  or replace table qtemp.savedrv as( WITH lancio AS( SELECT from_job AS job, message_timestamp AS inizio,' +
000495230213  'substring(from_job, locate_in_string (from_job, ''/'', 1, 2) + 1, 10) ' +
000496230213  'AS jobname FROM TABLE(qsys2.history_log_info( CURRENT timestamp- 10 DAYS )) WHERE substring(from_job, locate_in_string (from_job, ''/'', 1, 2) + 1, 10) = ' + %trim(xnome)  +
000497230213   ' AND message_id = ''CPF1124'' ORDER BY      message_timestamp DESC LIMIT 1 ) SELECT job, jobname, inizio, TIMESTAMPDIFF(8, CAST(current_timestamp - inizio AS CHAR(22))) AS numOre, ' +
000498230213  'CASE WHEN TIMESTAMPDIFF(8, CAST(current_timestamp - inizio AS CHAR(22))) < 10 THEN ''NO'' ELSE ''SI'' end as eseguito ' +
000513230213  'FROM lancio) with data on replace delete rows';
000514230213  exec sql EXECUTE immediate :sql1;
000515230213
000516230213  // Estrazione dei dati del log
000517230213  exec sql
000518230213  create or replace table qtemp.savelog as (SELECT
000519230213     from_job,
000520230213     substring(from_job, locate_in_string (from_job, '/', 1, 2) + 1, 10) AS jobname,
000521230213 	message_timestamp,
000522230213 	message_id,
000523230213 	severity,
000524230213 	message_type,
000525230213 	message_text
000526230213    FROM
000527230213 	TABLE(qsys2.history_log_info( CURRENT timestamp- 7 DAYS ))
000528230213    WHERE
000529230213 	from_job =
000530230213 	(select job from qtemp.savedrv  )
000531230213 	AND severity >= 30
000532230213 	OR
000533230213 	from_job =
000534230213 	(SELECT  job from qtemp.savedrv ) AND  message_id IN ('CPF1124','CPF1164')
000535230213    ORDER BY
000536230213 	message_timestamp ASC) with data on replace delete rows;
000537230213
000538230213
000539230213  // estrazione e match dei messaggi di errore
000540230213
000541230213
000542230213  dow 1=1;
000543230213
000544230213    exec sql  DECLARE curlist CURSOR FOR
000545230213     SELECT DISTINCT COALESCE(o.msgid,' ') AS msgid,   s.message_id,
000546230213    cast(s.message_text as char(94) ccsid 280), CASE WHEN COALESCE(o.msgid,' ') <> ' '
000547230213       THEN 'Omit' ELSE 'Error' END AS esito
000548230213      FROM qtemp.savelog s
000549230213      LEFT JOIN  wwe.dbsaveomit o  ON o.msgid =  message_id
000550230213      WHERE s.severity >= 30;
000551230213
000552230213    exec sql open curlist;
000553230213
000554230213    $2=0;
000555230213    *in22=*off;
000556230213    *in21=*on;
000557230213    write sc2;
000558230213    *in21=*off;
000559230213
000560230213    wssce2 = *blanks;
000561230213
000562230213
000563230213    dow 1=1;
000564230213      exec sql fetch curlist into :omid, :msid, :mstext, :mserr;
000565230213      if sqlcode <> 0;
000566230213        leave;
000567230213      ENDIF;
000568230213      $2 =$2 +1;
000569230213
000570230213      if mserr = 'Omit';
000571230213        *in51 = *off;
000572230213      else;
000573230213        *in51 = *on;
000574230213      Endif;
000575230213
000576230213      write sf2;
000577230213
000578230213    enddo;
000579230213
000580230213    exec sql close curlist;
000581230213
000582230213    if $2 > 0;
000583230213      *in22 = *on;
000584230213    else;
000585230213      *in22 = *off;
000586230213    ENDIF;
000587230213    write w03;
000588230213    exfmt sc2;
000589230213
000590230213    if *in03 = *on;
000591230213      leave;
000592230213    Endif;
000593230213
000594230213      if *in09 =*on;       // richiesto immissione nuova azione
000595230213        callp(e) pg0631();
000596230213      ENDIF;
000597230213
000598230213
000599230213    $2=0;
000600230213    dow 1=1;
000601230213      $2=$2+1;
000602230213      chain(e) $2 sf2;
000603230213      if not %found(pg063v);
000604230213        leave;
000605230213      ENDIF;
000606230213
000607230213      if WSSCE2 = '1';  // inserimento del msg nella tabella omit
000608230213
000609230213        om.msgid    =    MSID   ;
000610230213        om.TESTO    =    MSTEXT  ;
000611230213        exec sql INSERT INTO DBSAVEOMIT  VALUES(:om);
000612230213        iter;
000613230213      ENDIF;
000614230213
000615230213    enddo;
000616230213
000617230213
000618230213  enddo;
000619230213
000620230213endsr;
000621230213
000622230213
