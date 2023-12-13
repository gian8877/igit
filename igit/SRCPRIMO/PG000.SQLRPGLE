000100230407**free
000200200420//==================================================================================================================================
000300200420// PG000 - Lanciatore delle sonde
000400200420//
000500200420// rel 1.0 Il pgm Legge il file delle sonde e sottomette i programmi di controllo
000600200420//         La sonda viene lanciata solo se il flag Lancio auto = S
000700200420//
000800200420// Parametri input: Nessuno
000900200420//
001000200420// Paramteri output:Nessuno
001100200420//
001200200420//==================================================================================================================================
001300200402ctl-opt option(*srcstmt:*nodebugio)  decedit('0,') Datedit(*DMY/) alwnull(*usrctl) DFTACTGRP(*no) ;
001400200402dcl-f dbsonde disk usage(*input) rename(dbsonde:fdbsonde);
001500200402dcl-ds log extname('DBLOG') qualified end-ds;
001600200402dcl-s comando char(32000);
001601200824
001900200402
002000200402  dcl-pr QCMDEXC extpgm ;
002100200402  *n char(500) options(*varsize) const ;
002200200402  *n packed(15:5) const ;
002300200402  end-pr ;
002301200824
002302200824// ============================================================================
002303200824// Controllo abilitazione prodotto --------------------------------------------
002304200824// ============================================================================
002305200824 dcl-pr pg043 extpgm('PG043');
002306200824        paprod char(10);
002307200824        pafine char(1);
002308200824 END-PR;
002309200824
002310200824 dcl-s paprod char(10) inz('WWE');
002311200824 dcl-s pafine char(1)  inz('E');
002312200824
002313200824callp(e) pg043(paprod:pafine);
002314200824if pafine = 'E';
002315200824  *inlr=*on;
002316200824  return;
002317200824ENDIF;
002318200824
002319200824// ============================================================================
002320200824// FINE Controllo abilitazione prodotto --------------------------------------------
002321200824// ============================================================================
002322200824
002323200824
002324200824
002325200824
002326200824 exec sql SET OPTION COMMIT=*NONE,CLOSQLCSR=*ENDMOD,DATFMT=*ISO,NAMING = *SYS;
002327200824
002328200824
002400200402
002500200402read fdbsonde;
002600200402dow not %eof;
002700200402  comando=*blanks;
002800200402  if lancioauto = 'S';
002900200525  comando = 'SBMJOB CMD(CALL PGM(WWE/PG0001) ' +
003000200402            'PARM('+%trim(sonda)+')) ' +
003100200402    'JOB('+ %trim(sonda)+ ') '  +
003200200402    'JOBD('+ %trim(jobdlib) +'/' + %trim(jobdnome) +') ' +
003300230407    'JOBQ(WWE/WWE) INLLIBL(*JOBD) INLASPGRP(*JOBD)  LOG(0 30 *NOLIST) USER(WWE) ';
003301200616                                                        //  LOG(0 30 *NOLIST)
003400200402callp(e) QCMDEXC(Comando:%len(%trimr(Comando))) ;
003500200402if %error;
003600200402ENDIF;
003700230407else;
003800200421      exec sql SELECT CURRENT SERVER into :log.system FROM SYSIBM.SYSDUMMY1;
003900200421      exec sql select  job_name into :log.job from sysibm.sysdummy1;
004000200421 LOG.SONDA      = SONDA     ;
004100200421 LOG.ORA        =  %timestamp();
004200200421 // LOG.SYSTEM     = SYSTEM    ;
004300200507 LOG.TIPOPRB    =tiposonda;
004400200421 LOG.ESITO      = 'KO'    ;
004500200421 LOG.SEVE       = '4'      ;
004600200421 LOG.MESSAG     = 'Sonda non avviata per Autostart = N';
004700200421 LOG.AVVIMM     = 'N'    ;
004800200421 LOG.HASH       = *blanks  ;
004900200421 LOG.CRTPDF     = 'N'    ;
005000200421 LOG.CRTXLSX    = 'N'   ;
005100200421 LOG.ELABORATO  = 'N' ;
005200200421 LOG.ORAELAB    = *loval    ;
005300200421 LOG.EVENTO     = 'ERR-START';
005400200421 LOG.CALLAZIO   = *blanks   ;
005500200421 LOG.LIBAZIO    = *blanks   ;
005600200421 LOG.PGMAZIO    = *blanks   ;
005700200421 LOG.MSGID      = *blanks   ;
005800200421 LOG.IDRIFER    = *loval    ;
005900200421 //LOG.JOB        = JOB       ;
006000200421 LOG.NOTE       = *blanks      ;
006001200616 log.IDEVEN = 0;
006100200402exec sql INSERT INTO DBLOG  VALUES(:log);
006200200402ENDIF;
006300200402
006400200402read fdbsonde;
006500200402enddo;
006600200402
006700200402*inlr=*on;
006800200402
