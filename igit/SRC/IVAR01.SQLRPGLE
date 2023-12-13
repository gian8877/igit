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
000132231129exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
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
000144231129exec sql create or replace table qtemp.dblibreria  ( libreria char(10) ) ;
000145231129exec sql delete  qtemp.dblibreria;
000146231129exec sql insert into qtemp.dblibreria values(:libreria);
000147231129// Crea il database
000149231129  testomsg = '02 - Create working DB';
000150231129  exsr messaggio;
000152231129exec sql create or replace table qtemp.iverdrive as(
000153231129SELECT a.TABLE_SCHEMA as libreria,
000154231129       a.TABLE_NAME as file,
000155231129       a.TABLE_PARTITION as membro,
000156231129       a.SOURCE_TYPE as tipo ,
000157231129       a.LAST_SOURCE_UPDATE_TIMESTAMP as modifica,
000158231129       coalesce(a.PARTITION_TEXT, ' ') as Testo,
000159231129       coalesce((SELECT PATH_NAME FROM TABLE (QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => '/iver/'||
000160231129          trim(a.table_schema), SUBTREE_DIRECTORIES => 'NO')) limit 1 ), ' ') as liv1,
000161231129       coalesce((SELECT PATH_NAME FROM TABLE (QSYS2.IFS_OBJECT_STATISTICS(START_PATH_NAME => '/iver/'||
000162231129          trim(a.table_schema)||'/'||trim(a.table_name), SUBTREE_DIRECTORIES => 'NO')) limit 1),' ') as liv2 , '/iver/' ||
000163231129          trim(a.table_schema) as crtliv1, '/iver/' ||  trim(a.table_schema) ||'/'||trim(a.table_name) as crtliv2
000164231129       FROM qsys2.SYSPARTITIONSTAT a
000165231129    WHERE a.TABLE_SCHEMA = (select libreria from qtemp.dblibreria limit 1)
000166231129    AND a.SOURCE_TYPE IS NOT NULL
000167231129     ) with data on replace delete rows;
000169231129  testomsg = '03 - Create Staging Area';
000170231129  exsr messaggio;
000173231129// crea le directory per le librerie
000174231129exec sql    create or replace table qtemp.dbcopy1 as(
000175231129       with lista as (select   crtliv1  from qtemp.iverdrive where liv1= ' ' or liv2 = ' ' group by crtliv1)
000176231129       select   crtliv1,    qsys2.qcmdexc( 'mkdir dir('''|| trim(crtliv1) ||  ''')' ) as esito from lista ) with data on replace delete rows;
000177231129// crea le directory per i file source
000178231129exec sql      create or replace table qtemp.dbcopy2 as(
000179231129       with lista as (select   crtliv2  from qtemp.iverdrive where liv1= ' ' or liv2 = ' ' group by crtliv2)
000180231129       select   crtliv2,    qsys2.qcmdexc( 'mkdir dir('''|| trim(crtliv2) ||  ''')' ) as esito from lista) with data on replace delete rows ;
000181231129// Coverte i sorgenti nelle directory
000182231129  testomsg = '04 - Mark sources as staged ';
000183231129  exsr messaggio;
000185231129exec sql    create or replace table qtemp.dbstage as(
000186231129       select libreria, file, membro, tipo,
000187231129        qsys2.qcmdexc( 'CPYTOSTMF FROMMBR(''/QSYS.LIB/'
000188231129                        || rtrim(libreria) || '.LIB/'
000189231129                        || rtrim(file)   || '.FILE/'
000190231129                        || rtrim(membro) || '.MBR'')'
000191231129                        || ' TOSTMF('''
000192231129                        || lower('/iver/')
000193231129                        || lower(rtrim(libreria)) || '/'
000194231129                        || lower(rtrim(file)) || '/'
000195231129                        || lower(rtrim(membro)) || '.'
000196231129                        || lower(rtrim(ifnull(tipo,'UNKNOWN'))) || ''') STMFOPT(*REPLACE)  DBFCCSID(277) STMFCCSID(1208)') as esito
000197231129             from qtemp.iverdrive) with data on replace delete rows  ;
000198231129
000199231129
000201231129  testomsg = '05 - Push commit';
000202231129  exsr messaggio;
000203231129
000209231129
000210231129exec sql    create or replace table qtemp.dbcommit as(
000211231129            select  qsys2.qcmdexc('QSH CMD(''PATH=/QOpenSys/pkgs/bin:$PATH;cd /iver; git add .;git commit -m " Commit di: '
000212231129            || dayname(current_timestamp) || '  '  ||current_date || '  '  ||current_time || '"   '')') as esito
000213231129            from sysibm.sysdummy1
000214231129            ) with data on replace delete rows;
000215231129
000216231129
000217231129*inlr = *on;
000218231129
000219231129begsr messaggio;
000220231129 Exec sql CALL SYSTOOLS.LPRINTF(:testomsg) ;
000221231129 QMHSNDPM ('CPA2401': 'QCPFMSG   *LIBL': testomsg: %size(testomsg): '*STATUS': '*EXT': 1: MsgKey: ErrorDS ) ;
000222231129ENDSR;
000223231129
000224231129
000225231129
000226231129
000227231129
000228231129
000229231129
000230231129
