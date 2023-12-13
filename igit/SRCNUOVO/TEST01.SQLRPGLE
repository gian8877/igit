000100200420**free
000200200702  ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000300200702  // ===================================================================================================================
000301200702  // WWE - Work With Events                   Generazione programma sonde                          Powered By Wise Frogs
000302200702  // ===================================================================================================================
000303200702  //
000304200702  // Sonda TEST01     - Sonda di test per filtrare i messaggi dell'operatore di sistema
000305200702  //
000306200702  // Release 1.0     16.16.58 2023-02-15
000307200702  //
000308200702  // Change Log      Commenti alla sonda
000309200702  //
000310200702  //
000311200702  //
000312200702  //
000313200702  //
000314200702  //
000315200702  //
000316200702  //
000317200702  // ===================================================================================================================
000318200702  // Questo programma viene richiamato passando il codice della sonda e richiede in output:
000319200702  // Pa_esit = Esisto del controllo prende il valore di OK se il controllo è positivo, altrimenti KO
000320200702  // Pa_mess = Messaggio descrittivo o dati del messaggio saranno poi passati al programma di azione o invio mail
000321200702  // Pa_seve = Codice severità può prendere il 3 = Errore, 4 = Warning, 5=Notifica, 6=Informativo 7=Debug
000322200702  //           i valori 0,1,2 sono riservati
000323200702  // Pa_avvi = Tipo di avvio della reazione
000324200702  //           N = Nessuna Azione Richiesta (solo registrazione log)
000325200702  //           S = Azione Immediata
000326200702  //           C = Azione immediata solo se il msg / report
000327200702  //               generato è nuovo oppure se è trascorso il limite dei msg univoci (definito nell'azione)
000328200702  // Pa_msid = Codicedel messaggio di riferimento.
000329200702  //
000330200702  // REPORT: Per generare automaticamente i report è sufficiente specificare nella configurazione dell'azione
000331200702  //         la creazione in PDF e/o Excel e posizionare queste informazioni in un file in QTEMP denominato DBWORK.
000332200702  //
000333200702  // ===================================================================================================================
001000200702  dcl-pi *n;
001100200702    pa_sonda char(10);  // IN Nome della sonda
001200200702    pa_esit  char(2);   // OU Esito del controllo (OK/KO)
001300200702    pa_mess  char(80);  // OU Descrizione esito controllo
001400200702    pa_seve char(1);    // OU Severità errore esecuzione (RFC5424)
001500200702    pa_avvi char(1);    // OU Avvio immediata reazione (S=si  N=No)
001600200702    pa_msid char(10);   // OU Message Id
001700200702  END-PI;
001701200702
001703200702  //
001704200702  // Inserire le istruzioni di controllo ---------------------------------------------------------------------------
001706200702  //
001707200702  // Chiusura programma e valorizzazione retourn code
001708200702  //
001709200702
001710200702    pa_esit = 'OK';                              // esito Positivo
001712200702    pa_mess = 'Nessun problema riscontrato !';   // commento all'esito
001713200702    pa_seve = '6';                               // Messaggio di tipo informativo (6)
001714200702    pa_avvi = 'N';                               // Solo registrazione su log
001715200702    pa_msid = 'MSG00001';                        // Chiave del messaggio
001800200420
008800200702  *inlr = *on;
008900200420
