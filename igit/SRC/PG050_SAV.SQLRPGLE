000100210105**free
000200210105ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000300230321dcl-f pg050v workstn sfile(SF1:$1)  sfile(SF2:$2) sfile(SF3:$3) ;
000400230321dcl-ds db extname('WWE/DBSTORAGE') qualified end-ds;
000500210105
000600210105dcl-s $1 int(5);  // puntatore Subfile
000601230321dcl-s $2 int(5);  // puntatore Subfile
000602230321dcl-s $3 int(5);  // puntatore Subfile
000700210105dcl-s result int(5);
000800210105dcl-s pa_typ char(10); // tipo oggetto (*PGM)
000900210105dcl-s pa_fla char(1); // Flag 1 = Esiste 0 = Non c'è
000901230321
000902230321dcl-s stgerr int(5); // presenti errori nello storage
000903230321
000904230321dcl-pr QCMDEXC extpgm('QCMDEXC') ;
000905230321  *n char(512) options(*varsize) const ;
000906230321  *n packed(15:5) const ;
000907230321end-pr ;
000908230321dcl-s comando char(512) ;
001000210105
001100210105exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
001200210105
001300210105adesso=%timestamp();
001400210105
001500210105
001600210105
001700210105// MAIN LINE ========================================================================
001800210105dow 1=1;
001900210105  exsr carica;
002000210105
002100210105  write w01;
002200210105  exfmt sc1;
002300210105
002400210105  if *in03=*on;        // richiesto fine lavoro
002500210105    leave;
002600210105  endif;
002700210105
002800210105  if *in06 =*on;       // richiesto immissione nuova azione
002900210105    exsr immissione;
003000210105  ENDIF;
003100210105
003200210105  exsr scelta;
003300210105
003400210105ENDDO;
003500210105
003600210105*inlr =*on;
003700210105// =================================================================================
003800210105begsr carica; // caricamento dati dal file
003900210105  // =================================================================================
004000210105
004100210105  $1=0;
004200210105  *in12=*off;
004300210105  *in11=*on;
004400210105  write sc1;
004500210105  *in11=*off;
004600210105
004700210105  exec sql DECLARE lista CURSOR FOR select * from DBSTORAGE order by id;
004800210105  exec sql open lista;
004900210105
005000210105  dow 1=1;
005100210105    exec sql fetch lista into :db;
005200210105    if sqlcode <> 0;
005300210105      leave;
005400210105    ENDIF;
005401210105
005402210105    id =db.id;
005403210105    sospeso = db.sospeso;
005404210105    descri = db.descri;
005405210105    esito = db.esito;
005406210105    ora = %char(db.LASTCK);
005407210105    smessage = db.message;
005408210105
008100210105    $1=$1+1;
008200210105    WSSCEL=*blanks;
008300210105    if esito='KO';
008400210105    *in44 = *on;
008500210105    else;
008600210105    *in44 = *off;
008700210105    endif;
008800210105    write sf1;
008900210105  enddo;
009000210105
009100210105  exec sql close lista;
009200210105
009300210105  if $1 > 0;
009400210105    *in12 = *on;
009500210105  else;
009600210105    *in12 = *off;
009700210105  ENDIF;
009800210105
009900210105
010000210105endsr;
010100210105
010200210105// =================================================================================
010300210105begsr immissione; // caricamento nuova azione
010400210105  // =================================================================================
010500210105  *in22=*off;
010600210105  *in23=*off;
010700210105  clear w02;
010800210105
011700210105  dow 1=1;
011800210105    *in21 = *off;
011900210105    exfmt w02;
012000210105    if *in03=*on; // richiesta fine lavoro;
012100210105      leave;
012200210105    ENDIF;
012300210105    exec sql select count(*) into :result from DBSTORAGE where id = :id;
012400210105    if id=*blanks ;
012500210105      result = 1;
012600210105    ENDIF;
012700210105    if result > 0; //
012800210105      *in23 = *on;
012900210105      iter;
013000210105    else ;
013100210105      *in23= *off;
013200210105    ENDIF;
013300210105    exsr ctlw02;
013400210105    if pa_fla = '0';
013500210105      *in22 =*on;
013600210105      iter;
013700210105    else;
013800210105      *in22 = *off;
013900210105    ENDIF;
013901210105
013902210105    db.id =id;
013903210105    db.sospeso =sospeso;
013904210105    db.descri = descri;
013905210105    db.esito = esito;
013906210105    db.lastck = lastck;
013907210105    db.message = message;
013908210105    db.ipname  = ipname;
013909210105    db.key = key;
013910210105    db.user = user;
013911210105
016700210105
016800210105    if sospeso=' ';
016900210105      db.sospeso='N';
017000210105    ENDIF;
017100210105
017200210105
017300210105
017400210105    exec sql INSERT INTO DBSTORAGE  VALUES(:db);
017500210105    leave;
017600210105  ENDDO;
017700210105endsr;
017800210105
017900210105// =================================================================================
018000210105begsr scelta ; // scelta opzione
018100210105  // =================================================================================
018200210105  $1=0;
018300210105  dow 1=1;
018400210105    $1=$1+1;
018500210105    chain(e) $1 sf1;
018600210105    if not %found(pg050v);
018700210105      leave;
018800210105    ENDIF;
018900210105
019000210105    if WSSCEL = '4';  // cancellazione
019100210105      exec sql delete DBSTORAGE where id = :id ;
019200210105      iter;
019300210105    ENDIF;
019400210105
019500210105    if WSSCEL = '2'; // modifica
019600210105      exsr modifica;
019700210105      iter;
019800210105    endif;
019900210105  enddo;
020000210105
020100210105endsr;
020200210105// =================================================================================
020300210105begsr modifica; // caricamento nuova azione
020400210105  // =================================================================================
020500210105  *in22=*off;
020600210105  *in23=*off;
020700210105  dow 1=1;
020800210105    *in21 = *on;
020900210105    exec sql select * into :db from DBSTORAGE where id = :id;
021000210105
021001210105
021002210105    id =db.id;
021003210105    sospeso =db.sospeso;
021004210105    descri = db.descri;
021005210105    esito = db.esito;
021006210105    lastck= db.lastck;
021007210105    message = db.message;
021008210105    ipname  = db.ipname;
021009210105    key = db.key;
021010210105    user = db.user;
021011210105
023400210105
023500210105    if esito = 'KO';
023600210105      *in43 = *on;
023700210105    else;
023800210105      *in43 = *off;
023900210105    ENDIF;
024000210105
024100210105
024200210105    exfmt w02;
024201230321
024202230321    if *in09 = *on; // richiesta visualizzazione dello storage
024203230321      exsr storagelog;
024204230321      iter;
024205230321    Endif;
024206230321
024207230321    if *in11 = *on; // richiesta visualizzazione della configurazione dello storage
024208230321      exsr storageconfig;
024209230321      iter;
024210230321    Endif;
024211230321
024212230321
024300210105    if *in03=*on; // richiesta fine lavoro;
024400210105      leave;
024500210105    ENDIF;
024600210105    exsr ctlw02;
024700210105    if pa_fla = '0';
024800210105      *in22 =*on;
024900210105      iter;
025000210105    else;
025100210105      *in22 = *off;
025200210105    ENDIF;
025300210105
025301210105    db.id =id;
025310210105    db.sospeso =sospeso;
025311210105    db.descri = descri;
025314210105    db.message =message;
025315210105    db.ipname  =ipname;
025316210105    db.key = key;
025317210105    db.user = user;
028100210105
028200210105    if sospeso=' ';
028300210105      db.sospeso='N';
028400210105    ENDIF;
028500210105
028600210105
028700210105    exec sql update DBSTORAGE set row = :db where  id = :id;
028800210105    leave;
028900210105
029000210105  ENDDO;
029100210105endsr;
029200210105
029300210105// =================================================================================
029400210105begsr ctlw02; // caricamento nuova azione
029600210105endsr;
029601230321
029602230321
029603230321
029604230321
029605230321
029606230321// =================================================================================
029607230321begsr Storagelog ; // Controllo del log dello storage
029608230321
029609230321   dow 1=1;
029610230321       $2=0;
029611230321       *in62=*off;
029612230321       *in61=*on;
029613230321       write sc2;
029614230321       *in61=*off;
029615230321
029625230321//  =====================================================================================================================
029626230321// preparazione file di lavoro per raccogliere l'output dei comandi di
029627230321exec sql call qcmdexc('dltovr *all');
029628230321exec sql create or replace table qtemp.stgout (stgout char(300) not null) on replace delete rows;
029629230321exec sql call qcmdexc('ovrdbf stdout qtemp/stgout ovrscope(*job)');
029630230321//  =====================================================================================================================
029631230321
029632230321// "lseventlog  -expired no -fixed no -monitoring no -message no -order severity -nohdr -delim :" - Per estrarre il log
029633230321// "clearerrlog -force"  per cancellare il log dello storage
029634230321
029635230321comando = 'QSH CMD(''ssh -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=Error -T -i '+
029636230321%trim(db.key) + ' ' + ' ' +
029637230321%trim(db.USER) + '@' + %trim(db.IPNAME) +' '+' '+
029638230321'"lseventlog  -expired no -fixed no -monitoring no  -order severity -nohdr -delim :"'')';
029639230321callp(e) QCMDEXC(Comando:%len(Comando));
029640230321if (%error);
029641230321  stgerr = 1;  // errori nel collegamento degli storage
029642230321Endif;
029643230321//  =====================================================================================================================
029644230321
029645230321exec sql
029646230321  create or replace table qtemp.stglog as( select
029647230321  substr(stgout, 1, locate_in_string (stgout, ':', 1, 1) -1) AS id,
029648230321  substr(stgout, locate_in_string (stgout, ':', 1, 1) +1, locate_in_string (stgout, ':', 1, 2) -locate_in_string (stgout, ':', 1, 1) -1) aS Ora,
029649230321  substr(stgout, locate_in_string (stgout, ':', 1, 2) +1, locate_in_string (stgout, ':', 1, 3) -locate_in_string (stgout, ':', 1, 2) -1) aS Oggetto,
029650230321  substr(stgout, locate_in_string (stgout, ':', 1, 3) +1, locate_in_string (stgout, ':', 1, 4) -locate_in_string (stgout, ':', 1, 3) -1) as Obj_id,
029651230321  substr(stgout, locate_in_string (stgout, ':', 1, 4) +1, locate_in_string (stgout, ':', 1, 5) -locate_in_string (stgout, ':', 1, 4) -1) aS Nname,
029652230321  substr(stgout, locate_in_string (stgout, ':', 1, 5) +1, locate_in_string (stgout, ':', 1, 6) -locate_in_string (stgout, ':', 1, 5) -1) aS copy_id,
029653230321  substr(stgout, locate_in_string (stgout, ':', 1, 6) +1, locate_in_string (stgout, ':', 1, 7) -locate_in_string (stgout, ':', 1, 6) -1) aS status,
029654230321  substr(stgout, locate_in_string (stgout, ':', 1, 7) +1, locate_in_string (stgout, ':', 1, 8) -locate_in_string (stgout, ':', 1, 7) -1) aS fixed,
029655230321  substr(stgout, locate_in_string (stgout, ':', 1, 8) +1, locate_in_string (stgout, ':', 1, 9) -locate_in_string (stgout, ':', 1, 8) -1) aS Ev_id,
029656230321  substr(stgout, locate_in_string (stgout, ':', 1, 9) +1, locate_in_string (stgout, ':', 1, 10) -locate_in_string (stgout, ':', 1, 9) -1) aS Error,
029657230321  substr(stgout, locate_in_string (stgout, ':', 1, 10) +1)  aS DESCRIPTION
029658230321  FROM qtemp.stgout
029659230321  ) with data on replace delete rows;
029660230321
029661230321exec sql declare lislog cursor for
029662230321select
029663230321  to_char( TO_date(ora,'YYMMDDHH24MISS'), 'DD-MM-YY HH24:MI:SS') as data ,
029664230321  dayname(TO_date(ora,'YYMMDDHH24MISS')) as giorno,
029665230321  l.ev_id as evento, l.DESCRIPTION as descrizione  from qtemp.stglog l  order by ora desc limit 300 ;
029666230321
029667230321exec sql open lislog;
029668230321
029669230321dow 1=1;
029670230321  exec sql fetch lislog into :wsdata, :wsgior, :wseven, :wsdesc;
029671230321  if sqlcode <> 0 ;
029672230321    leave;
029674230321  Endif;
029675230321$2=$2+1;
029676230321write sf2;
029677230321Enddo;
029678230321
029679230321exec sql close lislog;
029680230321
029681230321if $2 > 0;  // controllo se ci sono errori (ha caricato almento un record dal log
029682230321  *in62 = *on;
029683230321  else;
029684230321  *in62= *off;
029685230321Endif;
029686230321
029687230321 write w03;
029688230321 exfmt sc2;
029689230321
029690230321 if *in03=*on;
029691230321   leave;
029692230321 Endif;
029693230321
029694230321 if *in09=*on; // Pulizia log
029695230321   exsr clrlog ;
029696230321   iter;
029697230321 Endif;
029698230321
029699230321   Enddo;
029700230321
029701230321
029702230321endsr;
029703230321
029704230321
029705230321// =================================================================================
029706230321begsr storageconfig ; // Configurazione dello storage
029707230321
029708230321   dow 1=1;
029709230321       $3=0;
029710230321       *in72=*off;
029711230321       *in71=*on;
029712230321       write sc3;
029713230321       *in71=*off;
029714230321
029715230321//  =====================================================================================================================
029716230321// preparazione file di lavoro per raccogliere l'output dei comandi di
029717230321exec sql call qcmdexc('dltovr *all');
029718230321exec sql create or replace table qtemp.stgwconf (stgwconf char(300) not null) on replace delete rows;
029719230321exec sql call qcmdexc('ovrdbf stdout qtemp/stgwconf ovrscope(*job)');
029720230321//  =====================================================================================================================
029721230321
029722230321// "lseventlog  -expired no -fixed no -monitoring no -message no -order severity -nohdr -delim :" - Per estrarre il log
029723230321// "clearerrlog -force"  per cancellare il log dello storage
029724230321
029725230321comando = 'QSH CMD(''ssh -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=Error -T -i '+
029726230321%trim(db.key) + ' ' + ' ' +
029727230321%trim(db.USER) + '@' + %trim(db.IPNAME) +' '+' '+
029728230321'"lssystem -delim :"'')';
029729230321callp(e) QCMDEXC(Comando:%len(Comando));
029730230321if (%error);
029731230321  stgerr = 1;  // errori nel collegamento degli storage
029732230321Endif;
029733230321//  =====================================================================================================================
029734230321
029735230321exec sql
029736230321  create or replace table qtemp.stgconf as(
029737230321    SELECT  cast( substr(stgwconf, 1, locate(':', stgwconf)-1) as char(80) )AS Item,
029738230321             cast(substr(stgwconf, locate(':', stgwconf)+1) as char(100) )  AS Valore FROM  qtemp.stgwconf
029746230321  ) with data on replace delete rows;
029747230321
029748230321exec sql declare lisconf cursor for select * from qtemp.stgconf limit 300 ;
029753230321
029754230321exec sql open lisconf;
029755230321
029756230321dow 1=1;
029757230321  exec sql fetch lisconf into :item, :Valore;
029758230321  if sqlcode <> 0 ;
029759230321    leave;
029760230321  Endif;
029761230321$3=$3+1;
029762230321write sf3;
029763230321Enddo;
029764230321
029765230321exec sql close lisconf;
029766230321
029767230321if $3 > 0;  // controllo se ci sono errori (ha caricato almento un record dal log
029768230321  *in72 = *on;
029769230321  else;
029770230321  *in72= *off;
029771230321Endif;
029772230321
029773230321 write w04;
029774230321 exfmt sc3;
029775230321
029776230321 if *in03=*on;
029777230321   leave;
029778230321 Endif;
029779230321
029780230321   Enddo;
029781230321
029782230321
029783230321endsr;
029784230321
029785230321
029786230321// =================================================================================
029787230321begsr clrlog ; // Configurazione dello storage
029788230321
029797230321// preparazione file di lavoro per raccogliere l'output dei comandi di
029798230321exec sql call qcmdexc('dltovr *all');
029799230321exec sql create or replace table qtemp.clr (clr char(300) not null) on replace delete rows;
029800230321exec sql call qcmdexc('ovrdbf stdout qtemp/clr ovrscope(*job)');
029801230321//  =====================================================================================================================
029802230321
029803230321// "lseventlog  -expired no -fixed no -monitoring no -message no -order severity -nohdr -delim :" - Per estrarre il log
029804230321// "clearerrlog -force"  per cancellare il log dello storage
029805230321
029806230321comando = 'QSH CMD(''ssh -o ConnectTimeout=10 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=Error -T -i '+
029807230321%trim(db.key) + ' ' + ' ' +
029808230321%trim(db.USER) + '@' + %trim(db.IPNAME) +' '+' '+
029809230321' "clearerrlog -force"'')';
029810230321callp(e) QCMDEXC(Comando:%len(Comando));
029811230321if (%error);
029812230321  stgerr = 1;  // errori nel collegamento degli storage
029813230321Endif;
029814230321//  =====================================================================================================================
029815230321
029852230321
029853230321endsr;
