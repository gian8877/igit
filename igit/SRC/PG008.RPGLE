000100200415      * PG008 * Calcolatore Hash - Il pgm effettua il calcolo di hashing md5 su file di db in qtemp
000200200415      *                            oppure della variabile passata.
000300200415      *                            richiede in input il nome del file formato libreria/file
000400200415      *                            una stringa da calcolare e restituisce l'hash calcolato
000500200415      *                            la stringa ha la precedenza rispetto alla richiesta del file
000501200415      *
000502200415      *parametri :                 pafile   char 21 libreria e file formato LIB/FILE (barra compresa
000503200415      *                            pastring char 80 Stringa da elaborare
000504200415      *                            pahash   char 50 Hash calcolato
000600200415     h  BNDDIR('QC2LE') debug DFTACTGRP(*NO) ACTGRP('AS')
000700200415     Ffile      if   f 4000        disk    usropn
000800200311     d Qc3CalculateHash...
000900200311     d                 PR                  ExtProc('Qc3CalculateHash')
001000200311     d   InData                        *   value
001100200311     d   IndataL                     10i 0 const
001200200311     d   InDataF                      8a   const
001300200311     d   AlgoDes                     16a   const
001400200311     d   AlgoFmt                      8a   const
001500200311     d   CryptoSP                     1a   const
001600200311     d   CryptoDev                    1a   const options(*omit)
001700200311     d   Hash                        64a   options(*varsize:*omit)
001800200311     d   ErrorCode                32767a   options(*varsize)
001900200311
002000200311     d ALGD0500_t      ds                  qualified
002100200311     d                                     based(Template)
002200200311     d   HashAlg                     10i 0
002300200311
002400200311     d QDCXLATE        PR                  ExtPgm('QDCXLATE')
002500200311     d   len                          5p 0 const
002600200311     d   data                     32702a   options(*varsize)
002700200311     d   table                       10a   const
002800200311
002900200311     d cvthc           PR                  ExtProc('cvthc')
003000200311     d   target                   65534A   options(*varsize)
003100200311     d   src_bits                 32767A   options(*varsize) const
003200200311     d   tgt_length                  10I 0 value
003300200311
003400200311     d ErrorNull       ds                  qualified
003500200311     d    BytesPro                   10i 0 inz(0)
003600200311     d    BytesAvai                  10i 0 inz(0)
003700200311
003701200415     d qcmdexc         PR                  Extpgm('QCMDEXC')
003703200415     d   cmd                        500A   options(*varsize) const
003704200415     d   lcom                        15p 5 const
003705200415
003706200415
003800200311     d HASH_MD5        c                   1
003900200311     d HASH_SHA1       c                   2
004000200311     d HASH_SHA256     c                   3
004100200311     d HASH_SHA384     c                   4
004200200311     d HASH_SHA512     c                   5
004300200311
004400200415     d data            s               a   len(16000000)
004500200415     d i               s             10i 0
004600200415     d r               s             10i 0
004700200311     d len             s             10i 0
004800200311     d alg             ds                  likeds(ALGD0500_t)
004900200311     d bin             s             20a
005000200311     d $hex            s             40a
005001200415     dcmd              s            500a
005002200415     dlcom             s             15p 5
005100200415     ddsdati           ds
005200200415     d  record                     4000a
005300200415
005400200415     C     *entry        plist
005500200415     C                   parm                    pafile           21
005600200415     C                   parm                    pastring         80
005700200415     C                   parm                    pahash           50
005800200415     C
005900200311
006000200415        if pafile > *blanks;
006001200415         cmd='OVRDBF FILE(FILE) TOFILE('+%trim(pafile)+ ') OVRSCOPE(*JOB)';
006003200415          QCMDEXC(Cmd:%len(%trimr(cmd)));
006100200415           open file;
006200200415          i=1;
006300200415          dow 1=1;
006400230310            read file dsdati;
006500200415            if %eof(file);
006600200415              leave;
006700200415            ENDIF;
006800200415          r=%len(record);
006900200415          %subst(data:i:r)=%subst(record:1:r);
007000200415          i=i+r+1;
007200200415          ENDDO;
007300200415          close file;
007301200415        else;
007302200415          data=pastring;
007303200415        endif;
007304200415
007400200311           len = %len(%trimr(data));
007500200311           alg.HashAlg = HASH_SHA1;
007600200311
007700200311           Qc3CalculateHash( %addr(data)
007800200311                           : len
007900200311                           : 'DATA0100'
008000200311                           : alg
008100200311                           : 'ALGD0500'
008200200311                           : '0'
008300200311                           : *OMIT
008400200311                           : bin
008500200311                           : ErrorNull );
008600200311
008700200311           //Convert to HEX
008800200311           cvthc( $hex: bin: %len(bin)*2);
008900200421       //  dsply $hex;
008901200415         pahash= $hex;
008902200415
009000200311           *inlr = *on;
