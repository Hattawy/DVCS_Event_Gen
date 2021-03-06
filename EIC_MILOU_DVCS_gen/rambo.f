*CMZ :  1.06/02 05/02/96  18.42.32  by  Benno List
*CMZ :  1.06/01 27/08/95  20.24.22  by  Benno List
*CMZ :  1.06/00 16/06/95  12.12.21  by  Benno List
*CMZ :  1.03/00 22/11/94  11.44.25  by  Benno List
*CMZ :  1.01/01 21/10/94  16.32.38  by  Benno List
*CMZ :  0.23/00 01/02/94  13.30.58  by  Benno List
*CMZ :  0.20/00 11/10/93  11.21.11  by  Benno List
*CMZ :  0.19/06 11/10/93  10.15.32  by  Benno List
*CMZ :  0.00/00 12/02/93  11.35.03  by  Benno List
*-- Author :    Thomas Jansen   12/01/93
      SUBROUTINE RAMBO(N,ET,XM,P,WT,LW,IOK)
C.      A NEW MONTE-CARLO TREATMENT OF MULTIPARTICLE PHASE SPACE AT HIGH
C.      ENERGIES - SUBROUTINE RAMBO (RANDOM MOMENTUM BOOSTER).
C.      AUTHORS:  R.KLEISS AND W.J.STIRLING, CERN, GENEVA
C.                S.D.ELLIS, U.WASHINGTON, SEATTLE.
C.
C.                 DOCUMENTATION = CERN-TH.4299/85, OCTOBER 1985
C. published as: KLEISS, R., W.J. STIRLING & S.D. ELLIS (1986):
C.   A new Monte Carlo treatment of multiparticle phase space at high
C.   energies. - Comp. Phys. Comm. 40, 359 - 373, Amsterdam.
C.             ORIGIN= R.KLEISS '86, STATUS= USED, USES IMPLICIT REAL*8.
C------------------------------------------------------
C
C                       RAMBO
C
C             RA(NDOM)  M(OMENTA)  BO(OSTER)
C
C    A DEMOCRATIC MULTI-PARTICLE PHASE SPACE GENERATOR
C    AUTHORS:  S.D. ELLIS,  R. KLEISS,  W.J. STIRLING
C
C    N  = NUMBER OF PARTICLES (>1, IN THIS VERSION <101)
C    ET = TOTAL CENTRE-OF-MASS ENERGY
C    XM = PARTICLE MASSES ( DIM=N )
C    P  = PARTICLE MOMENTA ( DIM=(4,N) )
C    WT = WEIGHT OF THE EVENT
C    LW = FLAG FOR EVENT WEIGHTING:
C         LW = 0 WEIGHTED EVENTS
C         LW = 1 UNWEIGHTED EVENTS ( FLAT PHASE SPACE )
C
C CHANGES MADE: RN --> H1RN 6.6.90   HJU
C BL: Iteration counting (LOOPS); return with a warning if LOOPS > LPMAX
C BL: IOK=0 indicates that all was O.K.; use H1STOP
C BL: Use ERRLOG
C------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL H1RN
      DIMENSION XM(N),P(4,N),Q(4,100),Z(100),R(4),
     .   B(3),P2(100),XM2(100),E(100),V(100),IWARN(6)
      DATA ACC/1.D-14/,ITMAX/6/,IBEGIN/0/,IWARN/6*0/
      PARAMETER (LPMAX = 10000)
      PARAMETER (TWOPI = 6.283 185 307 179 586 476 D0)
      DATA  PO2LOG /4.515 827 052 93 D-1/
      CHARACTER ERTEXT*132
C
C INITIALIZATION STEP: FACTORIALS FOR THE PHASE SPACE WEIGHT
      IF(IBEGIN.NE.0) GOTO 103
      IBEGIN=1
      PO2LOG = DLOG (TWOPI / 4D0)
      Z(2)=PO2LOG
      DO 101 K=3,100
  101 Z(K)=Z(K-1)+PO2LOG-2.*DLOG(DFLOAT(K-2))
      DO 102 K=3,100
  102 Z(K)=(Z(K)-DLOG(DFLOAT(K-1)))
C
C CHECK ON THE NUMBER OF PARTICLES
  103 IF(N.GT.1.AND.N.LT.101) GOTO 104
      PRINT 1001,N
      WRITE (ERTEXT, 1001) N
      CALL ERRLOG (270, ERTEXT)
      CALL H1STOP
C
C CHECK WHETHER TOTAL ENERGY IS SUFFICIENT; COUNT NONZERO MASSES
  104 XMT=0.
      NM=0
      DO 105 I=1,N
      IF(XM(I).NE.0.D0) NM=NM+1
  105 XMT=XMT+DABS(XM(I))
      IF(XMT.LE.ET) GOTO 106
      PRINT 1002,XMT,ET
      WRITE (ERTEXT, 1002) XMT,ET
      CALL ERRLOG (271, ERTEXT)
      CALL H1STOP
C
C CHECK ON THE WEIGHTING OPTION
  106 IF(LW.EQ.1.OR.LW.EQ.0) GOTO 200
      PRINT 1003,LW
      WRITE (ERTEXT, 1003) LW
      CALL ERRLOG (272, ERTEXT)
      CALL H1STOP
C
C THE PARAMETER VALUES ARE NOW ACCEPTED
C
  200 LOOPS = 0
      IOK = 0
C GENERATE N MASSLESS MOMENTA IN INFINITE PHASE SPACE
  201 LOOPS = LOOPS + 1
      DO 202 I=1,N
      C=2.*DBLE(H1RN(1))-1.
      S=DSQRT(1.-C*C)
      F=TWOPI*DBLE(H1RN(2))
      Q(4,I)=-DLOG(DBLE(H1RN(3))*DBLE(H1RN(4)))
      Q(3,I)=Q(4,I)*C
      Q(2,I)=Q(4,I)*S*DCOS(F)
  202 Q(1,I)=Q(4,I)*S*DSIN(F)
C
C CALCULATE THE PARAMETERS OF THE CONFORMAL TRANSFORMATION
      DO 203 I=1,4
  203 R(I)=0.
      DO 204 I=1,N
      DO 204 K=1,4
  204 R(K)=R(K)+Q(K,I)
      RMAS=DSQRT(R(4)**2-R(3)**2-R(2)**2-R(1)**2)
      DO 205 K=1,3
  205 B(K)=-R(K)/RMAS
      G=R(4)/RMAS
      A=1./(1.+G)
      X=ET/RMAS
C
C TRANSFORM THE Q'S CONFORMALLY INTO THE P'S
      DO 207 I=1,N
      BQ=B(1)*Q(1,I)+B(2)*Q(2,I)+B(3)*Q(3,I)
      DO 206 K=1,3
  206 P(K,I)=X*(Q(K,I)+B(K)*(Q(4,I)+A*BQ))
  207 P(4,I)=X*(G*Q(4,I)+BQ)
C
C RETURN FOR UNWEIGHTED MASSLESS MOMENTA
      WT=1.D0
      IF(NM.EQ.0.AND.LW.EQ.1) RETURN
C
C CALCULATE WEIGHT AND POSSIBLE WARNINGS
      WT=PO2LOG
      IF(N.NE.2) WT=(2.*N-4.)*DLOG(ET)+Z(N)
      IF(WT.GE.-180.D0) GOTO 208
      IOK = 1
      WRITE (ERTEXT, 1004) WT
      CALL ERRLOG (273, ERTEXT)
      IF(IWARN(1).LE.5) PRINT 1004,WT
      IWARN(1)=IWARN(1)+1
  208 IF(WT.LE. 174.D0) GOTO 209
      IOK = 2
      WRITE (ERTEXT, 1005) WT
      CALL ERRLOG (274, ERTEXT)
      IF(IWARN(2).LE.5) PRINT 1005,WT
      IWARN(2)=IWARN(2)+1
C
C RETURN FOR WEIGHTED MASSLESS MOMENTA
  209 IF(NM.NE.0) GOTO 210
      WT=DEXP(WT)
      RETURN
C
C MASSIVE PARTICLES: RESCALE THE MOMENTA BY A FACTOR X
  210 XMAX=DSQRT(1.-(XMT/ET)**2)
      DO 301 I=1,N
      XM2(I)=XM(I)**2
  301 P2(I)=P(4,I)**2
      ITER=0
      X=XMAX
      ACCU=ET*ACC
  302 F0=-ET
      G0=0.
      X2=X*X
      DO 303 I=1,N
      E(I)=DSQRT(XM2(I)+X2*P2(I))
      F0=F0+E(I)
  303 G0=G0+P2(I)/E(I)
      IF(DABS(F0).LE.ACCU) GOTO 305
      ITER=ITER+1
      IF(ITER.LE.ITMAX) GOTO 304
      PRINT 1006,ITMAX,ACCU
      WRITE (ERTEXT, 1006) ITMAX,ACCU
      CALL ERRLOG (275, ERTEXT)
      GOTO 305
  304 X=X-F0/(X*G0)
      GOTO 302
  305 DO 307 I=1,N
      V(I)=X*P(4,I)
      DO 306 K=1,3
  306 P(K,I)=X*P(K,I)
  307 P(4,I)=E(I)
C
C CALCULATE THE MASS-EFFECT WEIGHT FACTOR
      WT2=1.
      WT3=0.
      DO 308 I=1,N
      WT2=WT2*V(I)/E(I)
  308 WT3=WT3+V(I)**2/E(I)
      WTM=(2.*N-3.)*DLOG(X)+DLOG(WT2/WT3*ET)
      IF(LW.EQ.1) GOTO 401
C
C RETURN FOR  WEIGHTED MASSIVE MOMENTA
      WT=WT+WTM
      IF(WT.GE.-180.D0) GOTO 309
      IOK = 3
      IF(IWARN(3).LE.5) PRINT 1004,WT
      WRITE (ERTEXT, 1004) WT
      CALL ERRLOG (273, ERTEXT)
      IWARN(3)=IWARN(3)+1
  309 IF(WT.LE. 174.D0) GOTO 310
      IOK = 4
      IF(IWARN(4).LE.5) PRINT 1005,WT
      WRITE (ERTEXT, 1005) WT
      CALL ERRLOG (274, ERTEXT)
      IWARN(4)=IWARN(4)+1
  310 WT=DEXP(WT)
      RETURN
C
C UNWEIGHTED MASSIVE MOMENTA REQUIRED: ESTIMATE MAXIMUM WEIGHT
  401 WT=DEXP(WTM)
      IF(NM.GT.1) GOTO 402
C
C ONE MASSIVE PARTICLE
      WTMAX=XMAX**(4*N-6)
      GOTO 405
  402 IF(NM.GT.2) GOTO 404
C
C TWO MASSIVE PARTICLES
      SM2=0.
      PM2=0.
      DO 403 I=1,N
      IF(XM(I).EQ.0.D0) GOTO 403
      SM2=SM2+XM2(I)
      PM2=PM2*XM2(I)
  403 CONTINUE
      WTMAX=((1.-SM2/(ET**2))**2-4.*PM2/ET**4)**(N-1.5)
      GOTO 405
C
C MORE THAN TWO MASSIVE PARTICLES: AN ESTIMATE ONLY
  404 WTMAX=XMAX**(2*N-5+NM)
C
C DETERMINE WHETHER OR NOT TO ACCEPT THIS EVENT
  405 W=WT/WTMAX
      IF(W.LE.1.001D0) GOTO 406
      IOK = 5
      IF(IWARN(5).LE.5) PRINT 1007,WTMAX,W
      WRITE (ERTEXT, 1007) WTMAX,W
      CALL ERRLOG (276, ERTEXT)
      IWARN(5)=IWARN(5)+1
  406 CONTINUE
      IF(W.LT.DBLE(H1RN(5)) .AND. LOOPS .LE. LPMAX) GOTO 201
      WT=1.D0
      IF (LOOPS .LE. LPMAX) GO TO 407
      IOK = 6
      IF(IWARN(6).LE.5) PRINT 1008,LPMAX,W
      WRITE (ERTEXT, 1008) LPMAX,W
      CALL ERRLOG (277, ERTEXT)
      IWARN(6)=IWARN(6)+1
  407 CONTINUE
      RETURN
 1001 FORMAT('F: RAMBO FAILS: # OF PARTICLES =',I5,' IS NOT ALLOWED')
 1002 FORMAT('F: RAMBO FAILS: TOTAL MASS =',D15.6,' IS NOT',
     . ' SMALLER THAN TOTAL ENERGY =',D15.6)
 1003 FORMAT('F: RAMBO FAILS: LW=',I3,' IS NOT AN ALLOWED OPTION')
 1004 FORMAT('W: RAMBO WARNS: WEIGHT = EXP(',F20.9,') MAY UNDERFLOW')
 1005 FORMAT('W: RAMBO WARNS: WEIGHT = EXP(',F20.9,') MAY  OVERFLOW')
 1006 FORMAT('W: RAMBO WARNS:',I3,' ITERATIONS DID NOT GIVE THE',
     . ' DESIRED ACCURACY =',D15.6)
 1007 FORMAT('W: RAMBO WARNS: ESTIMATE FOR MAXIMUM WEIGHT =',D15.6,
     . '     EXCEEDED BY A FACTOR ',D15.6)
 1008 FORMAT('W: RAMBO WARNS: MORE THAN',I7,' ITERATIONS. LAST W=',
     . D15.6)
      END
