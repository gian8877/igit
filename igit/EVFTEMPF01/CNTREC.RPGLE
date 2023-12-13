000100231130**free
000101231130ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000102231130
000103231130dcl-s NumeroRecords int(10); //numero records
000104231130
000104             /SET CCSID(*CHAR:*JOBRUNMIX)
000104             // SQL COMMUNICATION AREA                                                //SQL
000104             DCL-DS SQLCA;                                                            //SQL
000104               SQLCAID CHAR(8) INZ(X'0000000000000000');                              //SQL
000104                SQLAID CHAR(8) OVERLAY(SQLCAID);                                      //SQL
000104               SQLCABC INT(10);                                                       //SQL
000104                SQLABC BINDEC(9) OVERLAY(SQLCABC);                                    //SQL
000104               SQLCODE INT(10);                                                       //SQL
000104                SQLCOD BINDEC(9) OVERLAY(SQLCODE);                                    //SQL
000104               SQLERRML INT(5);                                                       //SQL
000104                SQLERL BINDEC(4) OVERLAY(SQLERRML);                                   //SQL
000104               SQLERRMC CHAR(70);                                                     //SQL
000104                SQLERM CHAR(70) OVERLAY(SQLERRMC);                                    //SQL
000104               SQLERRP CHAR(8);                                                       //SQL
000104                SQLERP CHAR(8) OVERLAY(SQLERRP);                                      //SQL
000104               SQLERR CHAR(24);                                                       //SQL
000104                SQLER1 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLER2 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLER3 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLER4 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLER5 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLER6 BINDEC(9) OVERLAY(SQLERR:*NEXT);                               //SQL
000104                SQLERRD INT(10) DIM(6) OVERLAY(SQLERR);                               //SQL
000104               SQLWRN CHAR(11);                                                       //SQL
000104                SQLWN0 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN1 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN2 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN3 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN4 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN5 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN6 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN7 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN8 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWN9 CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWNA CHAR(1) OVERLAY(SQLWRN:*NEXT);                                 //SQL
000104                SQLWARN CHAR(1) DIM(11) OVERLAY(SQLWRN);                              //SQL
000104               SQLSTATE CHAR(5);                                                      //SQL
000104                SQLSTT CHAR(5) OVERLAY(SQLSTATE);                                     //SQL
000104             END-DS SQLCA;                                                            //SQL
000104             DCL-PR SQLROUTE_CALL EXTPGM(SQLROUTE);                                   //SQL
000104               CA LIKEDS(SQLCA);                                                      //SQL
000104               *N BINDEC(4) OPTIONS(*NOPASS);                                         //SQL
000104               *N CHAR(1) OPTIONS(*NOPASS);                                           //SQL
000104             END-PR SQLROUTE_CALL;                                                    //SQL
000104             DCL-PR SQLOPEN_CALL EXTPGM(SQLOPEN);                                     //SQL
000104               CA LIKEDS(SQLCA);                                                      //SQL
000104               *N BINDEC(4);                                                          //SQL
000104             END-PR SQLOPEN_CALL;                                                     //SQL
000104             DCL-PR SQLCLSE_CALL EXTPGM(SQLCLSE);                                     //SQL
000104               CA LIKEDS(SQLCA);                                                      //SQL
000104               *N BINDEC(4);                                                          //SQL
000104             END-PR SQLCLSE_CALL;                                                     //SQL
000104             DCL-PR SQLCMIT_CALL EXTPGM(SQLCMIT);                                     //SQL
000104               CA LIKEDS(SQLCA);                                                      //SQL
000104               *N BINDEC(4);                                                          //SQL
000104             END-PR SQLCMIT_CALL;                                                     //SQL
000104             /RESTORE CCSID(*CHAR)
000104             DCL-C SQLROUTE CONST('QSYS/QSQROUTE');                                   //SQL
000104             DCL-C SQLOPEN CONST('QSYS/QSQROUTE');                                    //SQL
000104             DCL-C SQLCLSE CONST('QSYS/QSQLCLSE');                                    //SQL
000104             DCL-C SQLCMIT CONST('QSYS/QSQLCMIT');                                    //SQL
000104             DCL-C SQFRD CONST(2);                                                    //SQL
000104             DCL-C SQFCRT CONST(8);                                                   //SQL
000104             DCL-C SQFOVR CONST(16);                                                  //SQL
000104             DCL-C SQFAPP CONST(32);                                                  //SQL
000111      **END-FREE
000111           D                 DS                                                       SELECT
000111           D  SQL_00000              1      2B 0 INZ(128)                             length of header
000111           D  SQL_00001              3      4B 0 INZ(4)                               statement number
000111           D  SQL_00002              5      8U 0 INZ(0)                               invocation mark
000111           D  SQL_00003              9      9A   INZ('0') CCSID(*JOBRUNMIX)           data is okay
000111           D  SQL_00004             10    128A   CCSID(*JOBRUNMIX)                    end of header
000111           D  SQL_00005            129    132I 0                                      NUMERORECORDS
000111      **FREE
000105231130//*exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
000106231130
000107231130//*exec sql
000108231130//*
000109231130//*      select sum(NUMBER_ROWS) as numrec into :NumeroRecords from qsys2.SYSPARTITIONSTAT
000111231130//*      WHERE TABLE_SCHEMA = 'WWE' and TABLE_NAME ='DBSONDE'     ;
000111                SQLER6 = -4;                                                          //SQL 4
000111                SQLROUTE_CALL(                                                        //SQL
000111                     SQLCA                                                            //SQL
000111                   : SQL_00000                                                        //SQL
000111                );                                                                    //SQL
000111                IF SQL_00003 = '1';                                                   //SQL
000111                EVAL NUMERORECORDS = SQL_00005;                                       //SQL
000111                ENDIF;                                                                //SQL
000112231130
000113231130dsply %editc(NumeroRecords:'2');
000114231130
000115231130*inlr = *on;
