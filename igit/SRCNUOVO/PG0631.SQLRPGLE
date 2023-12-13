000001230213**free
000002201008ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000003230213dcl-f pg0631v workstn sfile(SF1:$1) ;
000004230213dcl-ds db extname('DBSAVEOMIT') qualified end-ds;
000005200522
000006201008dcl-s $1 int(5);  // puntatore Subfile
000007230213
000008230213dcl-pr PG0632 extpgm('PG0632'); // Recupero della descrizione del messaggio
000009230213  *n char(7);               // Id
000010230213  *n char(100);             // Testo
000011230213  *n char(10);              // File dei messaggi
000014230213  *n char(10);              // Libreria
000015230213END-PR;
000016230213
000017230213
000018230213 dcl-s fil char(10);              // File dei messaggi
000019230213 dcl-s lib char(10);              // Libreria dei messaggi
000020200522
000021201008exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
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
000042201008  exsr scelta;
000043200522
000044201008ENDDO;
000045200522
000046201008*inlr =*on;
000047201008// =================================================================================
000048201008begsr carica; // caricamento dati dal file
000049201008  // =================================================================================
000050200522
000051201008  $1=0;
000052201008  *in12=*off;
000053201008  *in11=*on;
000054201008  write sc1;
000055201008  *in11=*off;
000056200522
000057230213  exec sql DECLARE lista CURSOR FOR select rrn(a), a.* from DBSAVEOMIT a order by msgid ;
000058201008  exec sql open lista;
000059200522
000060201008  dow 1=1;
000061210930    exec sql fetch lista into :rrn, :db;
000062201008    if sqlcode <> 0;
000063201008      leave;
000064201008    ENDIF;
000065201008
000066230213    nome=db.msgid;
000067230213    DESCRI= db.TESTO;
000075210610
000091201008    $1=$1+1;
000095220207
000096201008    WSSCEL=*blanks;
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
000128220302 *in22=*off;
000129220302  *in23=*off;
000130220302  clear w02;
000140220302
000141220302  dow 1=1;
000142220302    exfmt w02;
000143220302    if *in03=*on; // richiesta fine lavoro;
000144220302      leave;
000145220302    ENDIF;
000146220302
000147220302
000148230213    exsr decodifica; // decodifica del testo del messaggio
000149230213    db.msgid       = NOME   ;
000150230213    db.TESTO     =   DESCRI  ;
000174230213    exec sql INSERT INTO DBSAVEOMIT  VALUES(:db);
000176220302    leave;
000177220302  ENDDO;
000178220302endsr;
000235201008// =================================================================================
000236201008begsr scelta ; // scelta opzione
000237201008  // =================================================================================
000238201008  $1=0;
000239201008  dow 1=1;
000240201008    $1=$1+1;
000241201008    chain(e) $1 sf1;
000242230213    if not %found(pg0631v);
000243201008      leave;
000244201008    ENDIF;
000245200522
000246201008    if WSSCEL = '4';  // cancellazione
000247230213      exec sql delete DBSAVEOMIT a  where rrn(a) = :rrn ;
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
000264230213  exec sql select * into :db from DBSAVEOMIT a  where rrn(a) = :rrn;
000265210610
000266230213  NOME       =  DB.msgid      ;
000267230213  DESCRI     =  DB.TESTO    ;
000330200525
000331210930  dow 1=1;
000332201008    exfmt w02;
000333201008    if *in03=*on; // richiesta fine lavoro;
000334201008      leave;
000335201008    ENDIF;
000336201008    exsr ctlw02;
000337210930    if *in22 = *on;  // presenza di errori !!!
000338201008      iter;
000341201008    ENDIF;
000342210930
000344200522
000366230213    DB.msgid     = NOME      ;
000367230213    DB.testo     = DESCRI    ;
000407201008
000408230213    exec sql update DBSAVEOMIT a set row = :db where  rrn(a) = :rrn;
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
000483200522
000484201008endsr;
000485230213
000486230213// ==================================================================================
000487230213begsr decodifica;
000488230213
000489230213  fil= 'QCPFMSG';
000490230213  lib= 'QSYS';
000491230213  callp(e) pg0632(NOME:DESCRI:fil:lib);
000492230213  if descri = *blanks ;
000493230213      fil= 'Q1AMSGF';
000494230213      lib= 'QBRM';
000495230213  callp(e) pg0632(NOME:DESCRI:fil:lib);
000496230213  Endif;
000497230213Endsr;
