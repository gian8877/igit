000100231129**free
000101230213ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
000102230213dcl-s esiste int(5)  ; // esistenza oggetto
000103230213
000104230213exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
000105230213
000106230213
000107230213exec sql SELECT count(*) into :esiste FROM TABLE (QSYS2.OBJECT_STATISTICS('WWE', '*FILE', OBJECT_NAME => 'DBSAVEOMIT' )) ;
000109230213if esiste = 0;
000111230213exec sql CREATE TABLE wwe.dbsaveomit ( msgid char(7), testo char(100) ) ;
000112230213endif;
000113230213
000114230213*inlr  = *on;
