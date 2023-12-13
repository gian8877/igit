000100200402**free
000200200522// PG0001 - Gestore delle chiamate cicliche del programma di controllo.
000300200415//
000400200420// rel 1.1    Inserita la gestione di avvio immediato con il campo avvimm
000500200420//
000600200415// rel 1.0    Il pgm viene chiamato con il parametro Sonda.
000700200415//            viene letto il record della sonda corrispondente e chimato pg001 per marcare lo start della sonda
000800200415//            chiamata al pg007 per verificare i limiti temporali e viene condizionata la chiamata del programma di controllo
000900200522//            se i limiti sono soddisfatti viene chiamato il pg00011 che provvede a lanciare il pgm di controllo
001000200415//            il programma esegue la preparazione dell'ambiente e ritorna con gli esiti del controllo (parametri e file in qtemp
001100200415//            DBOUT (che è  a tracciato variabile)
001200200415//            Se esito = KO oppure Severity 99 il programma converte il file
001300200420//
001400200420// Paramtri input: Nome sonda
001500200415//
001600200402  ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
001700200402
001800200402  dcl-ds db extname('DBSONDE') qualified end-ds;
001900200402  dcl-pi *n;
002000200402    pasonda char(10);  // Nome Sonda
002100200402  END-PI;
002200231127
002300200402  dcl-pr QCMDEXC extpgm ;
002400200402    *n char(500) options(*varsize) const ;
002500200402    *n packed(15:5) const ;
002600200402  end-pr ;
002700200402
002800200402  dcl-s comando char(32000);
002900200402
003000200522  dcl-pr PROG extpgm('PG00011');
003100200402    *n char(10);     // Sonda
003200200402    *n char(10);     // Libreria
003300200402    *n char(10);     // Programma
003400200402    *n char(2);      // esito (ok o KO)
003500200402    *n char(80);     // Messaggio
003600200421    *n char(1);      // Severità
003700200420    *n char(1);      // avvio immediato azione
003800200402  END-PR;
003900200402
004000200402
004100200402  dcl-pr PG001 extpgm('PG001');     // Marcatore partenza sonda
004200200402    *n char(10);     // Sonda
004300200402  END-PR;
004400200402
004500200415  dcl-pr PG007 extpgm('PG007');     // Determina se la sonda deve lanciare il pgm di controllo
004600200415    *n char(10);     // Sonda
004700200415    *n timestamp;    // Ora attuale
004800200415    flag char(1);      // 1 = Esegui il programma 0=non Eseguire
004900200415  END-PR;
005000200415
005100200402
005200200402  dcl-s paesit char(2); // esito esecuzione sonda 'OK - KO'
005300200421  dcl-s paseve char(1); // severità dell'esito della sonda
005400200402  dcl-s pamess char(80); // messaggio di termine della sonda
005500200420  dcl-s paavvimm char(1); //avvio immediato pgm di reazione
005600200402  dcl-s delay char(6);   // ritardo del loop
005700200402  dcl-s nomepdf char(128); // nome del pdf creato
005800200415  dcl-s flag char(1);      // flag per determinare se il programma di controllo deve essere richiamato
005900200415  dcl-s adesso timestamp; // ora attuale
006000200420
006100200420  dcl-s oraavv char(8);// ora avvio in formato alfa
006200200420  dcl-s oraavvdly char(6);//ora avvio char x delay
006300200415
006400200402
006500200402  //********************************************************************************************
006600200402  // MAIN LINE  ********************************************************************************
006700200402  //********************************************************************************************
006800200402
006900200420    exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING=*SYS ;
007000200420
007100200420
007200200420    exsr hkeep;       // operazioni iniziali
007300200420
007400200420   dow 1=1;
007500200420
007600200420    exec sql select *  into :db  from dbsonde where sonda = :pasonda;
007700200420
007800200420    if %dec(db.runat) > 0  ; // decisione se attivare il loop a secondo o a ora definita
007900200420      exsr attesa;  // gestisce l'attesa
008000200420      exsr esegui;
008100200420      else;        // caso in cui il loop richiesto è per secondi
008200200420         adesso=%timestamp();
008300200420         callp(e) PG007 (db.sonda:adesso:flag);  // controllo i limiti temporali
008400200420         if flag='1';  // sonda tra tra i limiti
008500200420           exsr esegui;
008600200420         endif;
008700200420        exsr attesa;
008800200420      ENDIF;
008900200420
009000200420   enddo;
009100200420
009200200420      *inlr=*on;
009300200402
009400200402
009500200402  //********************************************************************************************
009600200402  // ATTESA - Gestione dell'attesa per il loop *** *********************************************
009700200402  //********************************************************************************************
009800200402  begsr attesa;
009900200402
010000200420    comando=*blanks;
010100200420    if %dec(db.runat) = 0;
010200200420       delay= %editc(db.rundelay:'X');
010300200420       comando='DLYJOB DLY('+ %trim(delay) + ' )';
010400200420    else;
010500200420      comando=*blank;
010600200420      oraavv = %char(db.runat);
010700200420      oraavvdly = %subst(oraavv:1:2)+%subst(oraavv:4:2)+%subst(oraavv:7:2);
010800200420      comando='DLYJOB RSMTIME(' +%trim(oraavvdly) +')';
010900200420    ENDIF;
011000200420
011100200420    callp(e) QCMDEXC(Comando:%len(%trimr(comando))) ;
011200200420    if %error;
011300200420    ENDIF;
011400200402  endsr;
011500200402
011600200402  //********************************************************************************************
011700200402  // HOUSE KEEPING *****************************************************************************
011800200402  //********************************************************************************************
011900200402  begsr hkeep;
012000200402    // Aggiunta della libreria prodotti in prima posizione ---------------------------------------
012100200525    comando='addlible WWE *first';
012200200402    callp(e) QCMDEXC(Comando:%len(%trimr(comando))) ;
012300200402
012400200402    exec sql select *  into :db  from dbsonde where sonda = :pasonda;
012500200402
012600200402    callp(e) PG001 (db.sonda );
012700200402    if %error;
012800200402    ENDIF;
012900200402  endsr;
013000200420
013100200420  //********************************************************************************************
013200200420  // Esegui - Esegue il programma di controllo ********************************************
013300200420  //********************************************************************************************
013400200420  begsr esegui;
013500200420    callp(e) PROG (db.sonda : db.pgmlib : db.pgmnome: paesit :pamess : paseve : paavvimm);
013600200420      if %error;
013700200420      ENDIF;
013800200420  ENDSR;
