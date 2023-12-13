000100231129**free
000101231129ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000102231129
000103231129dcl-pi *n ;
000104231129  pa_libreria char(10);
000105231129 end-pi;
000106231129
000107231129dcl-pr QCMDEXC extpgm('QCMDEXC') ;
000108231129  *n char(512) options(*varsize) const ;
000109231129  *n packed(15:5) const ;
000110231129end-pr ;
000111231129
000112231129dcl-pr  QMHSNDPM     extpgm('QMHSNDPM');
000113231129  MsgID              char(7)      const;
000114231129  MsgFile            char(20)     const;
000115231129  MsgDta             char(32767)  const   options(*varsize);
000116231129  MsgDtaLen          int(10)      const;
000117231129  MsgType            char(10)     const;
000118231129  MsgQ               char(10)     const;
000119231129  MsgQNbr            int(10)      const;
000120231129  MsgKey             char(4);
000121231129  ErrorDs            char(200);
000122231129end-pr;
000123231129dcl-s   MsgKey             char(4);
000124231129dcl-s   ErrorDs            char(200);
000125231129dcl-s   testomsg char(100);
000126231129
000127231129dcl-s comando char(512 );
000128231129
000129231129
000130231129dcl-s libreria char(10);
000131231129
000131             /SET CCSID(*CHAR:*JOBRUNMIX)
000131             // SQL COMMUNICATION AREA                                                //SQL
000131             DCL-DS SQLCA;                                                            //SQL
000131               SQLCAID CHAR(8) INZ(X'0000000000000000');                              //SQL
000131                SQLAID CHAR(8) OVERLAY(SQLCAID);                                      //SQL
000131               SQLCABC INT(10);                                                       //SQL
000131                SQLABC BINDEC(9) OVERLAY(SQLCABC);                                    //SQL
000131               SQLCODE INT(10);                                                       //SQL
000131                SQLCOD BINDEC(9) OVERLAY(SQLCODE);                                    //SQL
000131               SQLERRML INT(5);                                                       //SQL
000131                SQLERL BINDEC(4) OVERLAY(SQLERRML);                                   //SQL
000131               SQLERRMC CHAR(70);                                                     //SQL
000131                SQLERM CHAR(70) OVERLAY(SQLERRMC);                                    //SQL
000131               SQLERRP CHAR(8);                                                       //SQL
000131                SQLERP CHAR(8) OVERLAY(SQLERRP);                                      //SQL
000131               SQLERR CHAR(24);                                                       //SQL
000131                SQLER1 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLER2 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLER3 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLER4 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLER5 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLER6 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000131                SQLERRD INT(10) DIM(6) OVERLAY(SQLERR);                               //SQL
000131               SQLWRN CHAR(11);                                                       //SQL
000131                SQLWN0 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN1 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN2 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN3 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN4 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN5 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN6 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN7 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN8 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWN9 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWNA CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000131                SQLWARN CHAR(1) DIM(11) OVERLAY(SQLWRN);                              //SQL
000131               SQLSTATE CHAR(5);                                                      //SQL
000131                SQLSTT CHAR(5) OVERLAY(SQLSTATE);                                     //SQL
000131             END-DS SQLCA;                                                            //SQL
000131             DCL-PR SQLROUTE_CALL EXTPGM(SQLROUTE);                                   //SQL
000131               CA LIKEDS(SQLCA);                                                      //SQL
000131               *N BINDEC(4) OPTIONS(*NOPASS);                                         //SQL
000131               *N CHAR(1) OPTIONS(*NOPASS);                                           //SQL
000131             END-PR SQLROUTE_CALL;                                                    //SQL
000131             DCL-PR SQLOPEN_CALL EXTPGM(SQLOPEN);                                     //SQL
000131               CA LIKEDS(SQLCA);                                                      //SQL
000131               *N BINDEC(4);                                                          //SQL
000131             END-PR SQLOPEN_CALL;                                                     //SQL
000131             DCL-PR SQLCLSE_CALL EXTPGM(SQLCLSE);                                     //SQL
000131               CA LIKEDS(SQLCA);                                                      //SQL
000131               *N BINDEC(4);                                                          //SQL
000131             END-PR SQLCLSE_CALL;                                                     //SQL
000131             DCL-PR SQLCMIT_CALL EXTPGM(SQLCMIT);                                     //SQL
000131               CA LIKEDS(SQLCA);                                                      //SQL
000131               *N BINDEC(4);                                                          //SQL
000131             END-PR SQLCMIT_CALL;                                                     //SQL
000131             /RESTORE CCSID(*CHAR)
000131             DCL-C SQLROUTE CONST('QSYS/QSQROUTE');                                   //SQL
000131             DCL-C SQLOPEN CONST('QSYS/QSQROUTE');                                    //SQL
000131             DCL-C SQLCLSE CONST('QSYS/QSQLCLSE');                                    //SQL
000131             DCL-C SQLCMIT CONST('QSYS/QSQLCMIT');                                    //SQL
000131             DCL-C SQFRD CONST(2);                                                    //SQL
000131             DCL-C SQFCRT CONST(8);                                                   //SQL
000131             DCL-C SQFOVR CONST(16);                                                  //SQL
000131             DCL-C SQFAPP CONST(32);                                                  //SQL
000146      **END-FREE
000146           D                 DS                                                       INSERT
000146           D  SQL_00000              1      2B 0 INZ(128)                             length of header
000146           D  SQL_00001              3      4B 0 INZ(6)                               statement number
000146           D  SQL_00002              5      8U 0 INZ(0)                               invocation mark
000146           D  SQL_00003              9      9A   INZ('0') CCSID(*JOBRUNMIX)           data is okay
000146           D  SQL_00004             10    128A   CCSID(*JOBRUNMIX)                    end of header
000146           D  SQL_00005            129    138A   CCSID(*JOBRUNMIX)                    LIBRERIA
000146      **FREE
000220      **END-FREE
000220           D                 DS                                                       CALL
000220           D  SQL_00006              1      2B 0 INZ(128)                             length of header
000220           D  SQL_00007              3      4B 0 INZ(12)                              statement number
000220           D  SQL_00008              5      8U 0 INZ(0)                               invocation mark
000220           D  SQL_00009              9      9A   INZ('0') CCSID(*JOBRUNMIX)           data is okay
000220           D  SQL_00010             10    128A   CCSID(*JOBRUNMIX)                    end of header
000220           D  SQL_00011            129    228A   CCSID(*JOBRUNMIX)                    TESTOMSG
000220      **FREE
000132231129//*exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
000133231129
000134231129libreria=pa_libreria;
000135231129
000136231129  comando = *blanks;
000137231129  comando = 'ovrdbf stdout qtemp/dbrisp ovrscope(*job)';
000138231129  callp(e) QCMDEXC(Comando:%len(Comando));
000139231129
000140231129  testomsg = '01 - Get source information';
000141231129  exsr messaggio;
000143231129// imposta la libreria su cui operare
000144231129//*exec sql create or replace table qtemp.dblibreria  ( libreria char(10) ) ;
000144                SQLER6 = 4;                                                           //SQL
000144                SQLROUTE_CALL(                                                        //SQL
000144                     SQLCA                                                            //SQL
000144                );                                                                    //SQL
000145231129//*exec sql delete  qtemp.dblibreria;
000145                SQLER6 = 5;                                                           //SQL
000145                SQLROUTE_CALL(                                                        //SQL
000145                     SQLCA                                                            //SQL
000145                );                                                                    //SQL
000146231129//*exec sql insert into qtemp.dblibreria values(:libreria);
000146                SQL_00005 = LIBRERIA;                                                 //SQL
000146                SQLER6 = -4;                                                          //SQL 6
000146                SQLROUTE_CALL(                                                        //SQL
000146                     SQLCA                                                            //SQL
000146                   : SQL_00000                                                        //SQL
000146                );                                                                    //SQL
000147231129// Crea il database
000149231129  testomsg = '02 - Create working DB';
000150231129  exsr messaggio;
000152231129//*exec sql create or replace table qtemp.iverdrive as(
000153231129//*SELECT a.TABLE_SCHEMA as libreria,
000154231129//*       a.TABLE_NAME as file,
000155231129//*       a.TABLE_PARTITION as membro,
000156231129//*       a.SOURCE_TYPE as tipo ,
000157231129//*       a.LAST_SOURCE_UPDATE_TIMESTAMP as modifica,
000158231129//*       coalesce(a.PARTITION_TEXT, ' ') as Testo,
000159231129//*       coalesce((SELECT PATH_NAME FROM TABLE (QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => '/iv
000160231129//*          trim(a.table_schema), SUBTREE_DIRECTORIES => 'NO')) limit 1 ), ' ') as liv1,
000161231129//*       coalesce((SELECT PATH_NAME FROM TABLE (QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => '/iv
000162231129//*          trim(a.table_schema)||'/'||trim(a.table_name), SUBTREE_DIRECTORIES => 'NO')) limit 1),'
000163231129//*          trim(a.table_schema) as crtliv1, '/iver/' ||  trim(a.table_schema) ||'/'||trim(a.table_
000164231129//*       FROM qsys2.SYSPARTITIONSTAT a
000165231129//*    WHERE a.TABLE_SCHEMA = (select libreria from qtemp.dblibreria limit 1)
000166231129//*    AND a.SOURCE_TYPE IS NOT NULL
000167231129//*     ) with data on replace delete rows;
000167                SQLER6 = 7;                                                           //SQL
000167                SQLROUTE_CALL(                                                        //SQL
000167                     SQLCA                                                            //SQL
000167                );                                                                    //SQL
000169231129  testomsg = '03 - Create Staging Area';
000170231129  exsr messaggio;
000173231129// crea le directory per le librerie
000174231129//*exec sql    create or replace table qtemp.dbcopy1 as(
000175231129//*       with lista as (select   crtliv1  from qtemp.iverdrive where liv1= ' ' or liv2 = ' ' group
000176231129//*       select   crtliv1,    qsys2.qcmdexc( 'mkdir dir('''|| trim(crtliv1) ||  ''')' ) as esito fr
000176                SQLER6 = 8;                                                           //SQL
000176                SQLROUTE_CALL(                                                        //SQL
000176                     SQLCA                                                            //SQL
000176                );                                                                    //SQL
000177231129// crea le directory per i file source
000178231129//*exec sql      create or replace table qtemp.dbcopy2 as(
000179231129//*       with lista as (select   crtliv2  from qtemp.iverdrive where liv1= ' ' or liv2 = ' ' group
000180231129//*       select   crtliv2,    qsys2.qcmdexc( 'mkdir dir('''|| trim(crtliv2) ||  ''')' ) as esito fr
000180                SQLER6 = 9;                                                           //SQL
000180                SQLROUTE_CALL(                                                        //SQL
000180                     SQLCA                                                            //SQL
000180                );                                                                    //SQL
000181231129// Coverte i sorgenti nelle directory
000182231129  testomsg = '04 - Mark sources as staged ';
000183231129  exsr messaggio;
000185231129//*exec sql    create or replace table qtemp.dbstage as(
000186231129//*       select libreria, file, membro, tipo,
000187231129//*        qsys2.qcmdexc( 'CPYTOSTMF FROMMBR(''/QSYS.LIB/'
000188231129//*                        || rtrim(libreria) || '.LIB/'
000189231129//*                        || rtrim(file)   || '.FILE/'
000190231129//*                        || rtrim(membro) || '.MBR'')'
000191231129//*                        || ' TOSTMF('''
000192231129//*                        || lower('/iver/')
000193231129//*                        || lower(rtrim(libreria)) || '/'
000194231129//*                        || lower(rtrim(file)) || '/'
000195231129//*                        || lower(rtrim(membro)) || '.'
000196231129//*                        || lower(rtrim(ifnull(tipo,'UNKNOWN'))) || ''') STMFOPT(*REPLACE)  DBFCCS
000197231129//*             from qtemp.iverdrive) with data on replace delete rows  ;
000197                SQLER6 = 10;                                                          //SQL
000197                SQLROUTE_CALL(                                                        //SQL
000197                     SQLCA                                                            //SQL
000197                );                                                                    //SQL
000198231129
000199231129
000201231129  testomsg = '05 - Push commit';
000202231129  exsr messaggio;
000203231129
000209231129
000210231129//*exec sql    create or replace table qtemp.dbcommit as(
000211231129//*            select  qsys2.qcmdexc('QSH CMD(''PATH=/QOpenSys/pkgs/bin:$PATH;cd /iver; git add .;gi
000212231129//*            || dayname(current_timestamp) || '  '  ||current_date || '  '  ||current_time || '"
000213231129//*            from sysibm.sysdummy1
000214231129//*            ) with data on replace delete rows;
000214                SQLER6 = 11;                                                          //SQL
000214                SQLROUTE_CALL(                                                        //SQL
000214                     SQLCA                                                            //SQL
000214                );                                                                    //SQL
000215231129
000216231129
000217231129*inlr = *on;
000218231129
000219231129begsr messaggio;
000220231129//* Exec sql CALL SYSTOOLS.LPRINTF(:testomsg) ;
000220                SQL_00011 = TESTOMSG;                                                 //SQL
000220                SQLER6 = -4;                                                          //SQL 12)
000220                SQLROUTE_CALL(                                                        //SQL
000220                     SQLCA                                                            //SQL
000220                   : SQL_00006                                                        //SQL
000220                );                                                                    //SQL
000220                IF SQL_00009 = '1';                                                   //SQL
000220                EVAL TESTOMSG = SQL_00011;                                            //SQL
000220                ENDIF;                                                                //SQL
000221231129 QMHSNDPM ('CPA2401': 'QCPFMSG   *LIBL': testomsg: %size(testomsg): '*STATUS': '*EXT': 1: MsgKey: Er
000222231129ENDSR;
000223231129
000224231129
000225231129
000226231129
000227231129
000228231129
000229231129
000230231129
