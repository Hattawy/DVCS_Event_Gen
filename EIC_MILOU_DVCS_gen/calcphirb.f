
*****************************************************************
      real function calcphirb(x,index)
*****************************************************************
      implicit real*4(a-h,o-z)

      include 'forpaw.common'
      integer index
      logical stFIXED_save
      common /FIXED/ stFIXED_save
      
ccc      print *,'enter calcphi',stFIXED_save

      sm1 = 0.
      sm2 = 0.
      sm3 = 0.
      sm4 = 0.
      sm5 = 0.
      sm6 = 0.
      
      xee_temp = plolab(4)
      xeg_temp = prglab(4)
      xthe_temp = atan2(sqrt(plolab(1)**2+plolab(2)**2),plolab(3))
      xphe_temp = atan2(plolab(2),plolab(1))
      xthg_temp = atan2(sqrt(prglab(1)**2+prglab(2)**2),prglab(3))
      xphg_temp = atan2(prglab(2),prglab(1))
     
      if (rndm(1).lt.0.5) then
      xeg_temp = plolab(4)
      xee_temp = prglab(4)
      xthg_temp = atan2(sqrt(plolab(1)**2+plolab(2)**2),plolab(3))
      xphg_temp = atan2(plolab(2),plolab(1))
      xthe_temp = atan2(sqrt(prglab(1)**2+prglab(2)**2),prglab(3))
      xphe_temp = atan2(prglab(2),prglab(1))
      endif 

      if (index.ge.1) then
       call smear(sm1,0.03)
       call smear(sm2,0.03)
  
       call smear(sm3,1.e-3)
       call smear(sm4,1.e-3)
 
       call smear(sm5,3.e-3)
       call smear(sm6,3.e-3)
      endif
c        sm1 = 0.
c        sm2 = 0.
c        sm3 = 0.
c        sm4 = 0.
c        sm5 = 0.
c        sm6 = 0.
    
       xee_temp = xee_temp*(1+sm1)
       xeg_temp = xeg_temp*(1+sm2)
       xthe_temp = xthe_temp*(1+sm3/xthe_temp)
       xthg_temp = xthg_temp*(1+sm4/xthg_temp)
       xphe_temp = xphe_temp*(1+sm5/xphe_temp)
       xphg_temp = xphg_temp*(1+sm6/xphg_temp)
      
      


      px_spa = xee_temp*sin(xthe_temp)*cos(xphe_temp)
      py_spa = xee_temp*sin(xthe_temp)*sin(xphe_temp)
      pz_spa = xee_temp*cos(xthe_temp)
      e_spa =  xee_temp
      
      px_lar = xeg_temp*sin(xthg_temp)*cos(xphg_temp)
      py_lar = xeg_temp*sin(xthg_temp)*sin(xphg_temp)
      pz_lar = xeg_temp*cos(xthg_temp)
      e_lar =  xeg_temp
      

c      px_spa = plolab(1)
c      py_spa = plolab(2)
c      pz_spa = plolab(3)
c      e_spa =  plolab(4)
c      px_lar = prglab(1)
c      py_lar = prglab(2)
c      pz_lar = prglab(3)
c      e_lar =  prglab(4)

      empz = e_spa-pz_spa+e_lar-pz_lar

      xel = plilab(4)
      xep = ppilab(4)
            
c c      call calcphir(index,px_spa,py_spa,pz_spa,e_spa,
c c     +                     px_lar,py_lar,pz_lar,e_lar,
c c     +                     empz,phi_r,phiout,iifail)
c 
c       if (.not.stFIXED_save) then
c c       call calc_phirb(xel,xep,px_spa,py_spa,pz_spa,e_spa,
c c     +                      px_lar,py_lar,pz_lar,e_lar,
c c     +                      empz,phi_r,iifail)
c       call calc_phircc(xel,xep,px_spa,py_spa,pz_spa,e_spa,
c      +                     px_lar,py_lar,pz_lar,e_lar,
c      +                     empz,phi_r2,iifail,2)
c ccc      print *,phi_r2
c c      phi_r2 = phi_r 
c       else
c c      call calc_phir(xel,xep,px_spa,py_spa,pz_spa,e_spa,
c c     +                     px_lar,py_lar,pz_lar,e_lar,
c c     +                     empz,phi_r,iifail,1) 
c       call calc_phir(xel,xep,px_spa,py_spa,pz_spa,e_spa,
c      +                     px_lar,py_lar,pz_lar,e_lar,
c      +                     empz,phi_r2,iifail,2)
c ccc      print *,phi_r,phi_r2
c       endif


      call calcphirorig(px_spa,py_spa,pz_spa,e_spa,
     +                     px_lar,py_lar,pz_lar,e_lar,
     +                     empz,phi_r2,iifail)
         
      
      calcphirb=phi_r2
      
      
      
      return
      end
      
*****************************************************************
      subroutine calcphirorig(px_spa,py_spa,pz_spa,e_spa,
     +                     px_lar,py_lar,pz_lar,e_lar,
     +                     empz,phi_r,iifail)
*****************************************************************

      implicit real(a-h,o-z)

      double precision mp,pi,elep,eproton,shat,boostp

      integer i,iifail

      real vec1(3),vec2(3),xvec1,xvec2,term1,term2,term3

**>> INI
      real px_spa,py_spa,pz_spa,e_spa,
     +     px_lar,py_lar,pz_lar,e_lar,
     +     empz

**>> OUT
      real phi_r,asym

      real pelep, phad, p4e(4), P(4), Q(4)
      double precision dpelep, dphad, dp4e(4), dP(4), dQ(4)

      real phisegp, phiggp, phipgp
      real phi_po,phi_lo,delta_phi,phi_poprf,phi_loprf

      real       xntp,qntp,yntp,phintp,tntp,
* -> In Lab frame :
     +         plilab(4),plolab(4),ppilab(4),ppolab(4),
     +         pvglab(4),prglab(4),
     +         pvisr(4),
* -> In p rest frame :
     +         pliprf(4),ploprf(4),ppiprf(4),ppoprf(4),
     +         pvgprf(4),prgprf(4),
* -> In Belitsky frame :
     +         plibel(4),plobel(4),ppibel(4),ppobel(4),
     +         pvgbel(4),prgbel(4)

* -> Lab frame :
      double precision pli_l(4)   ! incoming lepton in lab frame
      double precision plo_l(4)   ! outcoming lepton in lab frame
      double precision pvgam_l(4) ! virtual photon in lab frame
      double precision ppi_l(4)   ! incoming proton in lab frame
      double precision ppo_l(4)   ! outcoming proton
      double precision prgam_l(4) ! outcoming photon

* -> Proton rest frame :
      double precision pli_tmp(4)   ! incoming lepton in p-rest frame
      double precision plo_tmp(4)   ! outcoming lepton in p-rest frame
      double precision pvgam_tmp(4) ! virtual photon in p-rest frame
      double precision ppi_tmp(4)   ! incoming proton in p-rest frame
      double precision ppo_tmp(4)   ! outcoming proton
      double precision prgam_tmp(4) ! outcoming photon
      double precision toto_li(4)
      double precision toto_lo(4)
      double precision toto_vgam(4)


* -> In p-rest frame, with z = - q_1^3
*    (cf fig. 1 of Belitsky et al.)
      double precision pli_b(4)   ! incoming lepton
      double precision plo_b(4)   ! outcoming lepton
      double precision pvgam_b(4) ! virtual photon
      double precision ppi_b(4)   ! incoming proton
      double precision prgam_b(4) ! outcoming (real) photon
      double precision ppo_b(4)   ! outcoming proton


      double precision beta(3),betar(3)
      double precision ptmp(4)
      double precision rot(3)

      logical do_xaxis
      common/xaxis/do_xaxis,i_xaxis

      mp = 0.93827d0
      pi = datan(1.d0) * 4.0d0

      empz_calc = empz
cc      empz_calc = e_spa-pz_spa+e_lar-pz_lar

      elep     = dble(empz_calc/2.) ! for tests...

      eproton = 920.d0
      shat    = 4.0d0 * elep * eproton

* -> incoming lepton in lab frame
      pli_l(4) =  elep
      pli_l(3) = -elep
      pli_l(1) = 0.d0
      pli_l(2) = 0.d0
      call v_copy(pli_l,plilab)

* -> incoming proton in lab frame
      ppi_l(4) = dsqrt(eproton**2 + mp**2)
      ppi_l(3) = eproton
      ppi_l(1) = 0.0d0
      ppi_l(2) = 0.0d0
      call v_copy(ppi_l,ppilab)

c      print *,'px_sp_kin,py_sp_kin,pz_sp_kin',
c     +         px_sp_kin,py_sp_kin,pz_sp_kin

* -> outcoming lepton in lab frame

      plo_l(4) = dble(e_spa)
      plo_l(1) = dble(px_spa)
      plo_l(2) = dble(py_spa)
      plo_l(3) = dble(pz_spa)

      iifail = 0

      call v_copy(plo_l,plolab)

c      print *,'plolab(1),plolab(2),',
c     +        'plolab(3),plolab(4)',
c     +         real(plolab(1)),real(plolab(2)),
c     +         real(plolab(3)),real(plolab(4))

* -> virtual photon in lab frame
      do i=1,4
       pvgam_l(i) = pli_l(i) - plo_l(i)
      enddo
      call v_copy(pvgam_l,pvglab)
     
c      print *,'pvglab(1),pvglab(2),',
c     +        'pvglab(3),pvglab(4)',
c     +         real(pvglab(1)),real(pvglab(2)),
c     +         real(pvglab(3)),real(pvglab(4))

* -> real photon in lab frame

      prgam_l(4) = dble(e_lar)
      prgam_l(1) = dble(px_lar)
      prgam_l(2) = dble(py_lar)
      prgam_l(3) = dble(pz_lar)

      call v_copy(prgam_l,prglab)

c      print *,'prglab(1),prglab(2),',
c     +        'prglab(3),prglab(4)',
c     +         real(prglab(1)),real(prglab(2)),
c     +         real(prglab(3)),real(prglab(4))
 

* -> outgoing proton in lab frame

      ppo_l(4) = ppi_l(4)+pli_l(4)-prgam_l(4)-plo_l(4)
      ppo_l(1) = ppi_l(1)+pli_l(1)-prgam_l(1)-plo_l(1)
      ppo_l(2) = ppi_l(2)+pli_l(2)-prgam_l(2)-plo_l(2)
      ppo_l(3) = ppi_l(3)+pli_l(3)-prgam_l(3)-plo_l(3)

      call v_copy(ppo_l,ppolab)

c      print *,'ppolab(1),ppolab(2),',
c     +        'ppolab(3),ppolab(4)',
c     +         real(ppolab(1)),real(ppolab(2)),
c     +         real(ppolab(3)),real(ppolab(4))

* -> calculate phi angles in lab frame...

      phi_p_lab  = atan2(ppolab(2),ppolab(1))
      phi_l_lab  = atan2(plolab(2),plolab(1))
      phi_g_lab  = atan2(prglab(2),prglab(1))
      phi_li_lab = atan2(plilab(2),plilab(1))


* -> calculate phi between po and lo in lab frame...
      dphi_lab=atan2(ppolab(2),ppolab(1))-
     +          atan2(plolab(2),plolab(1))


* --- Boost to p-rest frame, same system axis ---

      boostp = eproton / mp
      beta(1) =  -ppi_l(1) / ppi_l(4)
      beta(2) =  -ppi_l(2) / ppi_l(4)
      beta(3) =  -ppi_l(3) / ppi_l(4)

      do i=1,3
       betar(i) = -beta(i)
      enddo

* -> Boost incoming lepton
      do i=1,4
       ptmp(i)    = pli_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       pli_tmp(i) = ptmp(i)
      enddo
      call v_copy(pli_tmp,pliprf)

c      print *,'pliprf(1),pliprf(2),',
c     +        'pliprf(3),pliprf(4)',
c     +         real(pliprf(1)),real(pliprf(2)),
c     +         real(pliprf(3)),real(pliprf(4))

* -> Boost outcoming lepton
      do i=1,4
       ptmp(i)    = plo_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       plo_tmp(i) = ptmp(i)
      enddo
      call v_copy(plo_tmp,ploprf)

c      print *,'ploprf(1),ploprf(2),',
c     +        'ploprf(3),ploprf(4)',
c     +         real(ploprf(1)),real(ploprf(2)),
c     +         real(ploprf(3)),real(ploprf(4))

* -> Boost incoming proton
      do i=1,4
       ptmp(i)    = ppi_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       ppi_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppi_tmp,ppiprf)

c      print *,'ppiprf(1),ppiprf(2),',
c     +        'ppiprf(3),ppiprf(4)',
c     +         real(ppiprf(1)),real(ppiprf(2)),
c     +         real(ppiprf(3)),real(ppiprf(4))

* -> Boost virtual photon
      do i=1,4
       ptmp(i)      = pvgam_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       pvgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(pvgam_tmp,pvgprf)

c      print *,'pvgprf(1),pvgprf(2),',
c     +        'pvgprf(3),pvgprf(4)',
c     +         real(pvgprf(1)),real(pvgprf(2)),
c     +         real(pvgprf(3)),real(pvgprf(4))

* -> Boost real gamma
      do i=1,4
       ptmp(i)    = prgam_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       prgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(prgam_tmp,prgprf)

c      print *,'prgprf(1),prgprf(2),',
c     +        'prgprf(3),prgprf(4)',
c     +         real(prgprf(1)),real(prgprf(2)),
c     +         real(prgprf(3)),real(prgprf(4))

* -> Boost outgoing proton
      do i=1,4
       ptmp(i)    = ppo_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       ppo_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppo_tmp,ppoprf)

c      print *,'ppoprf(1),ppoprf(2),',
c     +        'ppoprf(3),ppoprf(4)',
c     +         real(ppoprf(1)),real(ppoprf(2)),
c     +         real(ppoprf(3)),real(ppoprf(4))

* -> calculate phi angles in prf frame...

      phi_p_prf  = atan2(ppoprf(2),ppoprf(1))
      phi_l_prf  = atan2(ploprf(2),ploprf(1))
      phi_g_prf  = atan2(prgprf(2),prgprf(1))
      phi_li_prf = atan2(pliprf(2),pliprf(1))

* -> calculate phi between po and lo in prf frame...

      dphi_prf=atan2(ppoprf(2),ppoprf(1))-
     +          atan2(ploprf(2),ploprf(1))


* --- all the rest is needed to go in the belitsky frame...
* --- Rotate the system axis, z = -q_1^3 ---

      do i=1,3
       rot(i) = -pvgam_tmp(i)
      enddo

c      print *,'rot(1),rot(2),rot(3)',
c     +    real(rot(1)),real(rot(2)),real(rot(3))

      do_xaxis = .true.
      i_xaxis  = 1
      call rotate(pli_tmp,rot,1,pli_b)
      do_xaxis = .false.
      call v_copy(pli_b,plibel)

c      print *,'plibel(1),plibel(2),',
c     +        'plibel(3),plibel(4)',
c     +         real(plibel(1)),real(plibel(2)),
c     +         real(plibel(3)),real(plibel(4))

      call rotate(plo_tmp,rot,1,plo_b)
      call rotate(pvgam_tmp,rot,1,pvgam_b)
      call rotate(ppi_tmp,rot,1,ppi_b)
      call rotate(ppo_tmp,rot,1,ppo_b)
      call rotate(prgam_tmp,rot,1,prgam_b)

      call v_copy(plo_b,plobel)
      call v_copy(pvgam_b,pvgbel)
      call v_copy(ppi_b,ppibel)
      call v_copy(ppo_b,ppobel)
      call v_copy(prgam_b,prgbel)

c      print *,'plobel(1),plobel(2),',
c     +        'plobel(3),plobel(4)',
c     +         real(plobel(1)),real(plobel(2)),
c     +         real(plobel(3)),real(plobel(4))

c      print *,'pvgbel(1),pvgbel(2),',
c     +        'pvgbel(3),pvgbel(4)',
c     +         real(pvgbel(1)),real(pvgbel(2)),
c     +         real(pvgbel(3)),real(pvgbel(4))

c      print *,'ppibel(1),ppibel(2),',
c     +        'ppibel(3),ppibel(4)',
c     +         real(ppibel(1)),real(ppibel(2)),
c     +         real(ppibel(3)),real(ppibel(4))


c      print *,'ppobel(1),ppobel(2),',
c     +        'ppobel(3),ppobel(4)',
c     +         real(ppobel(1)),real(ppobel(2)),
c     +         real(ppobel(3)),real(ppobel(4))

c      print *,'prgbel(1),prgbel(2),',
c     +        'prgbel(3),prgbel(4)',
c     +         real(prgbel(1)),real(prgbel(2)),
c     +         real(prgbel(3)),real(prgbel(4))


      phi_p_bel  = atan2(ppobel(2),ppobel(1))
      phi_l_bel  = atan2(plobel(2),plobel(1))
      phi_g_bel  = atan2(prgbel(2),prgbel(1))
      phi_li_bel = atan2(plibel(2),plibel(1))

      dphi_bel=atan2(ppobel(2),ppobel(1))-
     +          atan2(plobel(2),plobel(1))

* --- final angle (which should be the correct PHI)
      phi_r = phi_p_bel
     
c       write(89,*) phi_p_lab,phi_l_lab,phi_g_lab,phi_li_lab,
c      +            phi_p_prf,phi_l_prf,phi_g_prf,phi_li_prf,
c      +            phi_p_bel,phi_l_bel,phi_g_bel,phi_li_bel


 5    continue

      return 
      end
*****************************************************************
      subroutine calc_phirb(xel,xep,px_spa,py_spa,pz_spa,e_spa,
     +                      px_lar,py_lar,pz_lar,e_lar,
     +                      empz,phi_r,iifail)
*****************************************************************

      implicit real(a-h,o-z)

      double precision mp,pi,elep,eproton,boostp

      integer i,iifail,index

      real vec1(3),vec2(3),xvec1,xvec2,term1,term2,term3

**>> INI
      real px_spa,py_spa,pz_spa,e_spa,
     +     px_lar,py_lar,pz_lar,e_lar,
     +     empz

**>> OUT
      real phi_r,asym

      real pelep, phad, p4e(4), P(4), Q(4)
      double precision dpelep, dphad, dp4e(4), dP(4), dQ(4)

      real phisegp, phiggp, phipgp
      real phi_po,phi_lo,delta_phi,phi_poprf,phi_loprf

      real       xntp,qntp,yntp,phintp,tntp,
* -> In Lab frame :
     +         plilab(4),plolab(4),ppilab(4),ppolab(4),
     +         pvglab(4),prglab(4),
     +         pvisr(4),
* -> In p rest frame :
     +         pliprf(4),ploprf(4),ppiprf(4),ppoprf(4),
     +         pvgprf(4),prgprf(4),
* -> In Belitsky frame :
     +         plibel(4),plobel(4),ppibel(4),ppobel(4),
     +         pvgbel(4),prgbel(4)

* -> Lab frame :
      double precision pli_l(4)   ! incoming lepton in lab frame
      double precision plo_l(4)   ! outcoming lepton in lab frame
      double precision pvgam_l(4) ! virtual photon in lab frame
      double precision ppi_l(4)   ! incoming proton in lab frame
      double precision ppo_l(4)   ! outcoming proton
      double precision prgam_l(4) ! outcoming photon

* -> Proton rest frame :
      double precision pli_tmp(4)   ! incoming lepton in p-rest frame
      double precision plo_tmp(4)   ! outcoming lepton in p-rest frame
      double precision pvgam_tmp(4) ! virtual photon in p-rest frame
      double precision ppi_tmp(4)   ! incoming proton in p-rest frame
      double precision ppo_tmp(4)   ! outcoming proton
      double precision prgam_tmp(4) ! outcoming photon
      double precision toto_li(4)
      double precision toto_lo(4)
      double precision toto_vgam(4)


* -> In p-rest frame, with z = - q_1^3
*    (cf fig. 1 of Belitsky et al.)
      double precision pli_b(4)   ! incoming lepton
      double precision plo_b(4)   ! outcoming lepton
      double precision pvgam_b(4) ! virtual photon
      double precision ppi_b(4)   ! incoming proton
      double precision prgam_b(4) ! outcoming (real) photon
      double precision ppo_b(4)   ! outcoming proton


      double precision beta(3),betar(3)
      double precision ptmp(4)
      double precision rot(3)

      logical do_xaxis
      common/xaxis/do_xaxis,i_xaxis

      mp = 0.93827d0
      pi = datan(1.d0) * 4.0d0


      elep     = dble(empz/2.)!27.5
ccc      print *,empz/2,xel
      
      	
ccc      eproton = mp
      eproton = xep ! pz of the proton (incoming)


* -> incoming lepton in lab frame
      pli_l(4) =  elep
      pli_l(3) = -elep
      pli_l(1) = 0.d0
      pli_l(2) = 0.d0
      call v_copy(pli_l,plilab)

* -> incoming proton in lab frame

      ppi_l(4) = dsqrt(eproton**2 + mp**2)
      ppi_l(3) = eproton
      ppi_l(1) = 0.0d0
      ppi_l(2) = 0.0d0
      call v_copy(ppi_l,ppilab)

c      print *,'px_sp_kin,py_sp_kin,pz_sp_kin',
c     +         px_sp_kin,py_sp_kin,pz_sp_kin

* -> outcoming lepton in lab frame

      plo_l(4) = dble(e_spa)
      plo_l(1) = dble(px_spa)
      plo_l(2) = dble(py_spa)
      plo_l(3) = dble(pz_spa)

      iifail = 0

      call v_copy(plo_l,plolab)


* -> virtual photon in lab frame
      do i=1,4
       pvgam_l(i) = pli_l(i) - plo_l(i)
      enddo
      call v_copy(pvgam_l,pvglab)
     

* -> real photon in lab frame

      prgam_l(4) = dble(e_lar)
      prgam_l(1) = dble(px_lar)
      prgam_l(2) = dble(py_lar)
      prgam_l(3) = dble(pz_lar)
      
           
      call v_copy(prgam_l,prglab)

 

* -> outgoing proton in lab frame

      ppo_l(4) = ppi_l(4)+pli_l(4)-prgam_l(4)-plo_l(4)
      ppo_l(1) = ppi_l(1)+pli_l(1)-prgam_l(1)-plo_l(1)
      ppo_l(2) = ppi_l(2)+pli_l(2)-prgam_l(2)-plo_l(2)
      ppo_l(3) = ppi_l(3)+pli_l(3)-prgam_l(3)-plo_l(3)

      call v_copy(ppo_l,ppolab)


* -> calculate phi angles in lab frame...

      phi_p_lab  = atan2(ppolab(2),ppolab(1))
      phi_l_lab  = atan2(plolab(2),plolab(1))
      phi_g_lab  = atan2(prglab(2),prglab(1))
      phi_li_lab = atan2(plilab(2),plilab(1))


* -> calculate phi between po and lo in lab frame...
      dphi_lab=atan2(ppolab(2),ppolab(1))-
     +          atan2(plolab(2),plolab(1))


* --- Boost to p-rest frame, same system axis ---

      boostp = eproton / mp
      beta(1) =  -ppi_l(1) / ppi_l(4)
      beta(2) =  -ppi_l(2) / ppi_l(4)
      beta(3) =  -ppi_l(3) / ppi_l(4)

      do i=1,3
       betar(i) = -beta(i)
      enddo

* -> Boost incoming lepton
      do i=1,4
       ptmp(i)    = pli_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       pli_tmp(i) = ptmp(i)
      enddo
      call v_copy(pli_tmp,pliprf)

c      print *,'pliprf(1),pliprf(2),',
c     +        'pliprf(3),pliprf(4)',
c     +         real(pliprf(1)),real(pliprf(2)),
c     +         real(pliprf(3)),real(pliprf(4))

* -> Boost outcoming lepton
      do i=1,4
       ptmp(i)    = plo_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       plo_tmp(i) = ptmp(i)
      enddo
      call v_copy(plo_tmp,ploprf)

c      print *,'ploprf(1),ploprf(2),',
c     +        'ploprf(3),ploprf(4)',
c     +         real(ploprf(1)),real(ploprf(2)),
c     +         real(ploprf(3)),real(ploprf(4))

* -> Boost incoming proton
      do i=1,4
       ptmp(i)    = ppi_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       ppi_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppi_tmp,ppiprf)

c      print *,'ppiprf(1),ppiprf(2),',
c     +        'ppiprf(3),ppiprf(4)',
c     +         real(ppiprf(1)),real(ppiprf(2)),
c     +         real(ppiprf(3)),real(ppiprf(4))

* -> Boost virtual photon
      do i=1,4
       ptmp(i)      = pvgam_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       pvgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(pvgam_tmp,pvgprf)

c      print *,'pvgprf(1),pvgprf(2),',
c     +        'pvgprf(3),pvgprf(4)',
c     +         real(pvgprf(1)),real(pvgprf(2)),
c     +         real(pvgprf(3)),real(pvgprf(4))

* -> Boost real gamma
      do i=1,4
       ptmp(i)    = prgam_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       prgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(prgam_tmp,prgprf)

c      print *,'prgprf(1),prgprf(2),',
c     +        'prgprf(3),prgprf(4)',
c     +         real(prgprf(1)),real(prgprf(2)),
c     +         real(prgprf(3)),real(prgprf(4))

* -> Boost outgoing proton
      do i=1,4
       ptmp(i)    = ppo_l(i)
      enddo
      call boost(ptmp,beta)
      do i=1,4
       ppo_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppo_tmp,ppoprf)

c      print *,'ppoprf(1),ppoprf(2),',
c     +        'ppoprf(3),ppoprf(4)',
c     +         real(ppoprf(1)),real(ppoprf(2)),
c     +         real(ppoprf(3)),real(ppoprf(4))

* -> calculate phi angles in prf frame...

      phi_p_prf  = atan2(ppoprf(2),ppoprf(1))
      phi_l_prf  = atan2(ploprf(2),ploprf(1))
      phi_g_prf  = atan2(prgprf(2),prgprf(1))
      phi_li_prf = atan2(pliprf(2),pliprf(1))

* -> calculate phi between po and lo in prf frame...

      dphi_prf=atan2(ppoprf(2),ppoprf(1))-
     +          atan2(ploprf(2),ploprf(1))


* --- all the rest is needed to go in the belitsky frame...
* --- Rotate the system axis, z = -q_1^3 ---

      
      do i=1,3
       rot(i) = -pvgam_tmp(i)
      enddo

      do_xaxis = .true.
      i_xaxis  = 1
      call rotate(pli_tmp,rot,1,pli_b)
      do_xaxis = .false.
      call v_copy(pli_b,plibel)


      call rotate(plo_tmp,rot,1,plo_b)
      call rotate(pvgam_tmp,rot,1,pvgam_b)
      call rotate(ppi_tmp,rot,1,ppi_b)
ccc      call v_copy8(ppi_b,ppi_tmp)
      call rotate(ppo_tmp,rot,1,ppo_b)
      call rotate(prgam_tmp,rot,1,prgam_b)

      call v_copy(plo_b,plobel)
      call v_copy(pvgam_b,pvgbel)
      call v_copy(ppi_b,ppibel)
      call v_copy(ppo_b,ppobel)
      call v_copy(prgam_b,prgbel)
      
c      print *,pvglab(3),pvgprf(3)
c      print *,prgprf(1),prgprf(2),prgbel(1),prgbel(2)
c      print *,pvgprf(3)/sqrt(pvgprf(3)**2+pvgprf(1)**2+pvgprf(2)**2)
ccc      print *,pvgprf(1),pvgprf(2)

      phi_p_bel  = atan2(ppobel(2),ppobel(1))
      phi_l_bel  = atan2(plobel(2),plobel(1))
      phi_g_bel  = atan2(prgbel(2),prgbel(1))
      phi_li_bel = atan2(plibel(2),plibel(1))
      phi_v_bel  = atan2(pvgbel(2),pvgbel(1))
      
* --- final angle (which should be the correct PHI)
      phi_r = -phi_g_bel
      


 5    continue

      return 
      end


*****************************************************************
      subroutine calc_phir(xel,xep,px_spa,py_spa,pz_spa,e_spa,
     +                     px_lar,py_lar,pz_lar,e_lar,
     +                     empz,phi_r,iifail,index)
*****************************************************************

      implicit real(a-h,o-z)

      double precision mp,pi,elep,eproton,boostp

      integer i,iifail,index

      real vec1(3),vec2(3),xvec1,xvec2,term1,term2,term3

**>> INI
      real px_spa,py_spa,pz_spa,e_spa,
     +     px_lar,py_lar,pz_lar,e_lar,
     +     empz

**>> OUT
      real phi_r,asym

      real pelep, phad, p4e(4), P(4), Q(4)
      double precision dpelep, dphad, dp4e(4), dP(4), dQ(4)

      real phisegp, phiggp, phipgp
      real phi_po,phi_lo,delta_phi,phi_poprf,phi_loprf

      real       xntp,qntp,yntp,phintp,tntp,
* -> In Lab frame :
     +         plilab(4),plolab(4),ppilab(4),ppolab(4),
     +         pvglab(4),prglab(4),
     +         pvisr(4),
* -> In p rest frame :
     +         pliprf(4),ploprf(4),ppiprf(4),ppoprf(4),
     +         pvgprf(4),prgprf(4),
* -> In Belitsky frame :
     +         plibel(4),plobel(4),ppibel(4),ppobel(4),
     +         pvgbel(4),prgbel(4)

* -> Lab frame :
      double precision pli_l(4)   ! incoming lepton in lab frame
      double precision plo_l(4)   ! outcoming lepton in lab frame
      double precision pvgam_l(4) ! virtual photon in lab frame
      double precision ppi_l(4)   ! incoming proton in lab frame
      double precision ppo_l(4)   ! outcoming proton
      double precision prgam_l(4) ! outcoming photon

* -> Proton rest frame :
      double precision pli_tmp(4)   ! incoming lepton in p-rest frame
      double precision plo_tmp(4)   ! outcoming lepton in p-rest frame
      double precision pvgam_tmp(4) ! virtual photon in p-rest frame
      double precision ppi_tmp(4)   ! incoming proton in p-rest frame
      double precision ppo_tmp(4)   ! outcoming proton
      double precision prgam_tmp(4) ! outcoming photon
      double precision toto_li(4)
      double precision toto_lo(4)
      double precision toto_vgam(4)


* -> In p-rest frame, with z = - q_1^3
*    (cf fig. 1 of Belitsky et al.)
      double precision pli_b(4)   ! incoming lepton
      double precision plo_b(4)   ! outcoming lepton
      double precision pvgam_b(4) ! virtual photon
      double precision ppi_b(4)   ! incoming proton
      double precision prgam_b(4) ! outcoming (real) photon
      double precision ppo_b(4)   ! outcoming proton


      double precision beta(3),betar(3)
      double precision ptmp(4)
      double precision rot(3)

      logical do_xaxis
      common/xaxis/do_xaxis,i_xaxis

      mp = 0.93827d0
      pi = datan(1.d0) * 4.0d0


      elep     = xel
ccc      print *,empz/2,xel
      	
      eproton = mp
ccc      print *,xel
      



* -> incoming lepton in lab frame
      pli_l(4) =  elep
      pli_l(3) = -elep
      pli_l(1) = 0.d0
      pli_l(2) = 0.d0
      call v_copy(pli_l,plilab)

* -> incoming proton in lab frame

      ppi_l(4) = dsqrt(eproton**2 + mp**2)
      ppi_l(3) = eproton
      ppi_l(1) = 0.0d0
      ppi_l(2) = 0.0d0
      call v_copy(ppi_l,ppilab)

c      print *,'px_sp_kin,py_sp_kin,pz_sp_kin',
c     +         px_sp_kin,py_sp_kin,pz_sp_kin

* -> outcoming lepton in lab frame

      plo_l(4) = dble(e_spa)
      plo_l(1) = dble(px_spa)
      plo_l(2) = dble(py_spa)
      plo_l(3) = dble(pz_spa)

      iifail = 0

      call v_copy(plo_l,plolab)


* -> virtual photon in lab frame
      do i=1,4
       pvgam_l(i) = pli_l(i) - plo_l(i)
      enddo
      call v_copy(pvgam_l,pvglab)
     

* -> real photon in lab frame

      prgam_l(4) = dble(e_lar)
      prgam_l(1) = dble(px_lar)
      prgam_l(2) = dble(py_lar)
      prgam_l(3) = dble(pz_lar)
      
           
      call v_copy(prgam_l,prglab)

 
c------------------------------------------------------
      if (index==2) then
      call calcangles(plilab,plolab,pvglab,prglab,phiout)
      phi_r = phiout
      goto 5
      endif
c------------------------------------------------------

* -> outgoing proton in lab frame

      ppo_l(4) = ppi_l(4)+pli_l(4)-prgam_l(4)-plo_l(4)
      ppo_l(1) = ppi_l(1)+pli_l(1)-prgam_l(1)-plo_l(1)
      ppo_l(2) = ppi_l(2)+pli_l(2)-prgam_l(2)-plo_l(2)
      ppo_l(3) = ppi_l(3)+pli_l(3)-prgam_l(3)-plo_l(3)

      call v_copy(ppo_l,ppolab)


* -> calculate phi angles in lab frame...

      phi_p_lab  = atan2(ppolab(2),ppolab(1))
      phi_l_lab  = atan2(plolab(2),plolab(1))
      phi_g_lab  = atan2(prglab(2),prglab(1))
      phi_li_lab = atan2(plilab(2),plilab(1))


* -> calculate phi between po and lo in lab frame...
      dphi_lab=atan2(ppolab(2),ppolab(1))-
     +          atan2(plolab(2),plolab(1))


* --- Boost to p-rest frame, same system axis ---

c       boostp = eproton / mp
c       beta(1) =  -ppi_l(1) / ppi_l(4)
c       beta(2) =  -ppi_l(2) / ppi_l(4)
c       beta(3) =  -ppi_l(3) / ppi_l(4)
c 
c       do i=1,3
c        betar(i) = -beta(i)
c       enddo

* -> Boost incoming lepton
      do i=1,4
       ptmp(i)    = pli_l(i)
      enddo
      do i=1,4
       pli_tmp(i) = ptmp(i)
      enddo
      call v_copy(pli_tmp,pliprf)

c      print *,'pliprf(1),pliprf(2),',
c     +        'pliprf(3),pliprf(4)',
c     +         real(pliprf(1)),real(pliprf(2)),
c     +         real(pliprf(3)),real(pliprf(4))

* -> Boost outcoming lepton
      do i=1,4
       ptmp(i)    = plo_l(i)
      enddo
      do i=1,4
       plo_tmp(i) = ptmp(i)
      enddo
      call v_copy(plo_tmp,ploprf)

c      print *,'ploprf(1),ploprf(2),',
c     +        'ploprf(3),ploprf(4)',
c     +         real(ploprf(1)),real(ploprf(2)),
c     +         real(ploprf(3)),real(ploprf(4))

* -> Boost incoming proton
      do i=1,4
       ptmp(i)    = ppi_l(i)
      enddo
      do i=1,4
       ppi_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppi_tmp,ppiprf)

c      print *,'ppiprf(1),ppiprf(2),',
c     +        'ppiprf(3),ppiprf(4)',
c     +         real(ppiprf(1)),real(ppiprf(2)),
c     +         real(ppiprf(3)),real(ppiprf(4))

* -> Boost virtual photon
      do i=1,4
       ptmp(i)      = pvgam_l(i)
      enddo
      do i=1,4
       pvgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(pvgam_tmp,pvgprf)

c      print *,'pvgprf(1),pvgprf(2),',
c     +        'pvgprf(3),pvgprf(4)',
c     +         real(pvgprf(1)),real(pvgprf(2)),
c     +         real(pvgprf(3)),real(pvgprf(4))

* -> Boost real gamma
      do i=1,4
       ptmp(i)    = prgam_l(i)
      enddo
      do i=1,4
       prgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(prgam_tmp,prgprf)

c      print *,'prgprf(1),prgprf(2),',
c     +        'prgprf(3),prgprf(4)',
c     +         real(prgprf(1)),real(prgprf(2)),
c     +         real(prgprf(3)),real(prgprf(4))

* -> Boost outgoing proton
      do i=1,4
       ptmp(i)    = ppo_l(i)
      enddo
      do i=1,4
       ppo_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppo_tmp,ppoprf)

c      print *,'ppoprf(1),ppoprf(2),',
c     +        'ppoprf(3),ppoprf(4)',
c     +         real(ppoprf(1)),real(ppoprf(2)),
c     +         real(ppoprf(3)),real(ppoprf(4))

* -> calculate phi angles in prf frame...

      phi_p_prf  = atan2(ppoprf(2),ppoprf(1))
      phi_l_prf  = atan2(ploprf(2),ploprf(1))
      phi_g_prf  = atan2(prgprf(2),prgprf(1))
      phi_li_prf = atan2(pliprf(2),pliprf(1))

* -> calculate phi between po and lo in prf frame...

      dphi_prf=atan2(ppoprf(2),ppoprf(1))-
     +          atan2(ploprf(2),ploprf(1))


* --- all the rest is needed to go in the belitsky frame...
* --- Rotate the system axis, z = -q_1^3 ---

      do i=1,3
       rot(i) = -pvgam_tmp(i)
      enddo

      do_xaxis = .true.
      i_xaxis  = 1
      call rotate(pli_tmp,rot,1,pli_b)
      do_xaxis = .false.
      call v_copy(pli_b,plibel)


      call rotate(plo_tmp,rot,1,plo_b)
      call rotate(pvgam_tmp,rot,1,pvgam_b)
ccc      call rotate(ppi_tmp,rot,1,ppi_b)
      call v_copy8(ppi_b,ppi_tmp)
      call rotate(ppo_tmp,rot,1,ppo_b)
      call rotate(prgam_tmp,rot,1,prgam_b)

      call v_copy(plo_b,plobel)
      call v_copy(pvgam_b,pvgbel)
      call v_copy(ppi_b,ppibel)
      call v_copy(ppo_b,ppobel)
      call v_copy(prgam_b,prgbel)
      


      phi_p_bel  = atan2(ppobel(2),ppobel(1))
      phi_l_bel  = atan2(plobel(2),plobel(1))
      phi_g_bel  = atan2(prgbel(2),prgbel(1))
      phi_li_bel = atan2(plibel(2),plibel(1))
      phi_v_bel  = atan2(pvgbel(2),pvgbel(1))
      
* --- final angle (which should be the correct PHI)
      phi_r = real(pi)-phi_p_bel
      phi_r = -phi_g_bel
      


 5    continue

      return 
      end



*****************************************************************
      subroutine calc_phircc(xel,xep,px_spa,py_spa,pz_spa,e_spa,
     +                     px_lar,py_lar,pz_lar,e_lar,
     +                     empz,phi_r,iifail,index)
*****************************************************************

      implicit real(a-h,o-z)

      double precision mp,pi,elep,eproton,boostp

      integer i,iifail,index

      real vec1(3),vec2(3),xvec1,xvec2,term1,term2,term3

**>> INI
      real px_spa,py_spa,pz_spa,e_spa,
     +     px_lar,py_lar,pz_lar,e_lar,
     +     empz

**>> OUT
      real phi_r,asym

      real pelep, phad, p4e(4), P(4), Q(4)
      double precision dpelep, dphad, dp4e(4), dP(4), dQ(4)

      real phisegp, phiggp, phipgp
      real phi_po,phi_lo,delta_phi,phi_poprf,phi_loprf

      real       xntp,qntp,yntp,phintp,tntp,
* -> In Lab frame :
     +         plilab(4),plolab(4),ppilab(4),ppolab(4),
     +         pvglab(4),prglab(4),
     +         pvisr(4),
* -> In p rest frame :
     +         pliprf(4),ploprf(4),ppiprf(4),ppoprf(4),
     +         pvgprf(4),prgprf(4),
* -> In Belitsky frame :
     +         plibel(4),plobel(4),ppibel(4),ppobel(4),
     +         pvgbel(4),prgbel(4)

* -> Lab frame :
      double precision pli_l(4)   ! incoming lepton in lab frame
      double precision plo_l(4)   ! outcoming lepton in lab frame
      double precision pvgam_l(4) ! virtual photon in lab frame
      double precision ppi_l(4)   ! incoming proton in lab frame
      double precision ppo_l(4)   ! outcoming proton
      double precision prgam_l(4) ! outcoming photon

* -> Proton rest frame :
      double precision pli_tmp(4)   ! incoming lepton in p-rest frame
      double precision plo_tmp(4)   ! outcoming lepton in p-rest frame
      double precision pvgam_tmp(4) ! virtual photon in p-rest frame
      double precision ppi_tmp(4)   ! incoming proton in p-rest frame
      double precision ppo_tmp(4)   ! outcoming proton
      double precision prgam_tmp(4) ! outcoming photon
      double precision toto_li(4)
      double precision toto_lo(4)
      double precision toto_vgam(4)


* -> In p-rest frame, with z = - q_1^3
*    (cf fig. 1 of Belitsky et al.)
      double precision pli_b(4)   ! incoming lepton
      double precision plo_b(4)   ! outcoming lepton
      double precision pvgam_b(4) ! virtual photon
      double precision ppi_b(4)   ! incoming proton
      double precision prgam_b(4) ! outcoming (real) photon
      double precision ppo_b(4)   ! outcoming proton


      double precision beta(3),betar(3)
      double precision ptmp(4)
      double precision rot(3)

      logical do_xaxis
      common/xaxis/do_xaxis,i_xaxis

      mp = 0.93827d0
      pi = datan(1.d0) * 4.0d0


      
      elep     = dble(empz/2.)!27.5
ccc      print *,empz/2,xel
      
      	
ccc      eproton = mp
      eproton = xep ! pz of the proton (incoming)



* -> incoming lepton in lab frame
      pli_l(4) =  elep
      pli_l(3) = -elep
      pli_l(1) = 0.d0
      pli_l(2) = 0.d0
      call v_copy(pli_l,plilab)

* -> incoming proton in lab frame

      ppi_l(4) = dsqrt(eproton**2 + mp**2)
      ppi_l(3) = eproton
      ppi_l(1) = 0.0d0
      ppi_l(2) = 0.0d0
      call v_copy(ppi_l,ppilab)

c      print *,'px_sp_kin,py_sp_kin,pz_sp_kin',
c     +         px_sp_kin,py_sp_kin,pz_sp_kin

* -> outcoming lepton in lab frame

      plo_l(4) = dble(e_spa)
      plo_l(1) = dble(px_spa)
      plo_l(2) = dble(py_spa)
      plo_l(3) = dble(pz_spa)

      iifail = 0

      call v_copy(plo_l,plolab)


* -> virtual photon in lab frame
      do i=1,4
       pvgam_l(i) = pli_l(i) - plo_l(i)
      enddo
      call v_copy(pvgam_l,pvglab)
     

* -> real photon in lab frame

      prgam_l(4) = dble(e_lar)
      prgam_l(1) = dble(px_lar)
      prgam_l(2) = dble(py_lar)
      prgam_l(3) = dble(pz_lar)
      
           
      call v_copy(prgam_l,prglab)

      gamma = eproton/mp
      xbeta=eproton/dsqrt(mp**2+eproton**2)
      
      temp4=gamma*(plilab(4)-xbeta*plilab(3))
      temp3=gamma*(plilab(3)-xbeta*plilab(4))
      plilab(4)=temp4
      plilab(3)=temp3
      temp4=gamma*(plolab(4)-xbeta*plolab(3))
      temp3=gamma*(plolab(3)-xbeta*plolab(4))
      plolab(4)=temp4
      plolab(3)=temp3
      temp4=gamma*(pvglab(4)-xbeta*pvglab(3))
      temp3=gamma*(pvglab(3)-xbeta*pvglab(4))
      pvglab(4)=temp4
      pvglab(3)=temp3
      temp4=gamma*(prglab(4)-xbeta*prglab(3))
      temp3=gamma*(prglab(3)-xbeta*prglab(4))
      prglab(4)=temp4
      prglab(3)=temp3
      
 
c------------------------------------------------------
      if (index==2) then
      call calcangles(plilab,plolab,pvglab,prglab,phiout)
      phi_r = phiout
      goto 5
      endif
c------------------------------------------------------

* -> outgoing proton in lab frame

      ppo_l(4) = ppi_l(4)+pli_l(4)-prgam_l(4)-plo_l(4)
      ppo_l(1) = ppi_l(1)+pli_l(1)-prgam_l(1)-plo_l(1)
      ppo_l(2) = ppi_l(2)+pli_l(2)-prgam_l(2)-plo_l(2)
      ppo_l(3) = ppi_l(3)+pli_l(3)-prgam_l(3)-plo_l(3)

      call v_copy(ppo_l,ppolab)


* -> calculate phi angles in lab frame...

      phi_p_lab  = atan2(ppolab(2),ppolab(1))
      phi_l_lab  = atan2(plolab(2),plolab(1))
      phi_g_lab  = atan2(prglab(2),prglab(1))
      phi_li_lab = atan2(plilab(2),plilab(1))


* -> calculate phi between po and lo in lab frame...
      dphi_lab=atan2(ppolab(2),ppolab(1))-
     +          atan2(plolab(2),plolab(1))


* --- Boost to p-rest frame, same system axis ---

c       boostp = eproton / mp
c       beta(1) =  -ppi_l(1) / ppi_l(4)
c       beta(2) =  -ppi_l(2) / ppi_l(4)
c       beta(3) =  -ppi_l(3) / ppi_l(4)
c 
c       do i=1,3
c        betar(i) = -beta(i)
c       enddo

* -> Boost incoming lepton
      do i=1,4
       ptmp(i)    = pli_l(i)
      enddo
      do i=1,4
       pli_tmp(i) = ptmp(i)
      enddo
      call v_copy(pli_tmp,pliprf)

c      print *,'pliprf(1),pliprf(2),',
c     +        'pliprf(3),pliprf(4)',
c     +         real(pliprf(1)),real(pliprf(2)),
c     +         real(pliprf(3)),real(pliprf(4))

* -> Boost outcoming lepton
      do i=1,4
       ptmp(i)    = plo_l(i)
      enddo
      do i=1,4
       plo_tmp(i) = ptmp(i)
      enddo
      call v_copy(plo_tmp,ploprf)

c      print *,'ploprf(1),ploprf(2),',
c     +        'ploprf(3),ploprf(4)',
c     +         real(ploprf(1)),real(ploprf(2)),
c     +         real(ploprf(3)),real(ploprf(4))

* -> Boost incoming proton
      do i=1,4
       ptmp(i)    = ppi_l(i)
      enddo
      do i=1,4
       ppi_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppi_tmp,ppiprf)

c      print *,'ppiprf(1),ppiprf(2),',
c     +        'ppiprf(3),ppiprf(4)',
c     +         real(ppiprf(1)),real(ppiprf(2)),
c     +         real(ppiprf(3)),real(ppiprf(4))

* -> Boost virtual photon
      do i=1,4
       ptmp(i)      = pvgam_l(i)
      enddo
      do i=1,4
       pvgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(pvgam_tmp,pvgprf)

c      print *,'pvgprf(1),pvgprf(2),',
c     +        'pvgprf(3),pvgprf(4)',
c     +         real(pvgprf(1)),real(pvgprf(2)),
c     +         real(pvgprf(3)),real(pvgprf(4))

* -> Boost real gamma
      do i=1,4
       ptmp(i)    = prgam_l(i)
      enddo
      do i=1,4
       prgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(prgam_tmp,prgprf)

c      print *,'prgprf(1),prgprf(2),',
c     +        'prgprf(3),prgprf(4)',
c     +         real(prgprf(1)),real(prgprf(2)),
c     +         real(prgprf(3)),real(prgprf(4))

* -> Boost outgoing proton
      do i=1,4
       ptmp(i)    = ppo_l(i)
      enddo
      do i=1,4
       ppo_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppo_tmp,ppoprf)

c      print *,'ppoprf(1),ppoprf(2),',
c     +        'ppoprf(3),ppoprf(4)',
c     +         real(ppoprf(1)),real(ppoprf(2)),
c     +         real(ppoprf(3)),real(ppoprf(4))

* -> calculate phi angles in prf frame...

      phi_p_prf  = atan2(ppoprf(2),ppoprf(1))
      phi_l_prf  = atan2(ploprf(2),ploprf(1))
      phi_g_prf  = atan2(prgprf(2),prgprf(1))
      phi_li_prf = atan2(pliprf(2),pliprf(1))

* -> calculate phi between po and lo in prf frame...

      dphi_prf=atan2(ppoprf(2),ppoprf(1))-
     +          atan2(ploprf(2),ploprf(1))


* --- all the rest is needed to go in the belitsky frame...
* --- Rotate the system axis, z = -q_1^3 ---

      do i=1,3
       rot(i) = -pvgam_tmp(i)
      enddo

      do_xaxis = .true.
      i_xaxis  = 1
      call rotate(pli_tmp,rot,1,pli_b)
      do_xaxis = .false.
      call v_copy(pli_b,plibel)


      call rotate(plo_tmp,rot,1,plo_b)
      call rotate(pvgam_tmp,rot,1,pvgam_b)
ccc      call rotate(ppi_tmp,rot,1,ppi_b)
      call v_copy8(ppi_b,ppi_tmp)
      call rotate(ppo_tmp,rot,1,ppo_b)
      call rotate(prgam_tmp,rot,1,prgam_b)

      call v_copy(plo_b,plobel)
      call v_copy(pvgam_b,pvgbel)
      call v_copy(ppi_b,ppibel)
      call v_copy(ppo_b,ppobel)
      call v_copy(prgam_b,prgbel)
      


      phi_p_bel  = atan2(ppobel(2),ppobel(1))
      phi_l_bel  = atan2(plobel(2),plobel(1))
      phi_g_bel  = atan2(prgbel(2),prgbel(1))
      phi_li_bel = atan2(plibel(2),plibel(1))
      phi_v_bel  = atan2(pvgbel(2),pvgbel(1))
      
* --- final angle (which should be the correct PHI)
      phi_r = real(pi)-phi_p_bel
      phi_r = -phi_g_bel
      


 5    continue

      return 
      end

         
*****************************************************************
      subroutine calcphir(index,px_spa,py_spa,pz_spa,e_spa,
     +                     px_lar,py_lar,pz_lar,e_lar,
     +                     empz,phi_r,phiout,iifail)
*****************************************************************

      implicit real(a-h,o-z)

      double precision mp,pi,elep,eproton,shat,boostp

      integer i,iifail,index

      real vec1(3),vec2(3),xvec1,xvec2,term1,term2,term3
      logical stFIXED_save
      common /FIXED/ stFIXED_save
      real elepi,EGAMR,sweight,srad,elepin,ehadi
      common /RADGEN/ elepi,EGAMR,sweight,srad,elepin,ehadi

**>> INI
      real px_spa,py_spa,pz_spa,e_spa,
     +     px_lar,py_lar,pz_lar,e_lar,
     +     empz

**>> OUT
      real phi_r,asym

      real pelep, phad, p4e(4), P(4), Q(4)
      double precision dpelep, dphad, dp4e(4), dP(4), dQ(4)

      real phisegp, phiggp, phipgp
      real phi_po,phi_lo,delta_phi,phi_poprf,phi_loprf

      real       xntp,qntp,yntp,phintp,tntp,
* -> In Lab frame :
     +         plilab(4),plolab(4),ppilab(4),ppolab(4),
     +         pvglab(4),prglab(4),
     +         pvisr(4),
* -> In p rest frame :
     +         pliprf(4),ploprf(4),ppiprf(4),ppoprf(4),
     +         pvgprf(4),prgprf(4),
* -> In Belitsky frame :
     +         plibel(4),plobel(4),ppibel(4),ppobel(4),
     +         pvgbel(4),prgbel(4)

* -> Lab frame :
      double precision pli_l(4)   ! incoming lepton in lab frame
      double precision plo_l(4)   ! outcoming lepton in lab frame
      double precision pvgam_l(4) ! virtual photon in lab frame
      double precision ppi_l(4)   ! incoming proton in lab frame
      double precision ppo_l(4)   ! outcoming proton
      double precision prgam_l(4) ! outcoming photon

* -> Proton rest frame :
      double precision pli_tmp(4)   ! incoming lepton in p-rest frame
      double precision plo_tmp(4)   ! outcoming lepton in p-rest frame
      double precision pvgam_tmp(4) ! virtual photon in p-rest frame
      double precision ppi_tmp(4)   ! incoming proton in p-rest frame
      double precision ppo_tmp(4)   ! outcoming proton
      double precision prgam_tmp(4) ! outcoming photon
      double precision toto_li(4)
      double precision toto_lo(4)
      double precision toto_vgam(4)


* -> In p-rest frame, with z = - q_1^3
*    (cf fig. 1 of Belitsky et al.)
      double precision pli_b(4)   ! incoming lepton
      double precision plo_b(4)   ! outcoming lepton
      double precision pvgam_b(4) ! virtual photon
      double precision ppi_b(4)   ! incoming proton
      double precision prgam_b(4) ! outcoming (real) photon
      double precision ppo_b(4)   ! outcoming proton


      double precision beta(3),betar(3)
      double precision ptmp(4)
      double precision rot(3)

      logical do_xaxis
      common/xaxis/do_xaxis,i_xaxis

      mp = 0.93827d0
      pi = datan(1.d0) * 4.0d0

      empz_calc = empz
cc      empz_calc = e_spa-pz_spa+e_lar-pz_lar

      if (stFIXED_save) then      
      elep     = dble(empz_calc/2.) !elepi!dble(empz_calc/2.) ! for tests...	
      else
      elep     = dble(empz_calc/2.) !elepi!dble(empz_calc/2.) ! for tests...
      endif

      if (stFIXED_save) then
      eproton = mp
      else
      eproton = 920.d0
      endif

      if (stFIXED_save) then
      shat    = 2.0d0 * elep * mp + mp**2
      else
      shat    = 4.0d0 * elep * eproton
      endif


* -> incoming lepton in lab frame
      pli_l(4) =  elep
      pli_l(3) = -elep
      pli_l(1) = 0.d0
      pli_l(2) = 0.d0
      call v_copy(pli_l,plilab)

* -> incoming proton in lab frame
      ppi_l(4) = dsqrt(eproton**2 + mp**2)
      ppi_l(3) = eproton
      if (stFIXED_save) then
      ppi_l(4) = mp
      ppi_l(3) = 0.0d0
      endif
      ppi_l(1) = 0.0d0
      ppi_l(2) = 0.0d0
      call v_copy(ppi_l,ppilab)

c      print *,'px_sp_kin,py_sp_kin,pz_sp_kin',
c     +         px_sp_kin,py_sp_kin,pz_sp_kin

* -> outcoming lepton in lab frame

      plo_l(4) = dble(e_spa)
      plo_l(1) = dble(px_spa)
      plo_l(2) = dble(py_spa)
      plo_l(3) = dble(pz_spa)

      iifail = 0

      call v_copy(plo_l,plolab)

c      print *,'plolab(1),plolab(2),',
c     +        'plolab(3),plolab(4)',
c     +         real(plolab(1)),real(plolab(2)),
c     +         real(plolab(3)),real(plolab(4))

* -> virtual photon in lab frame
      do i=1,4
       pvgam_l(i) = pli_l(i) - plo_l(i)
      enddo
      call v_copy(pvgam_l,pvglab)
     
c      print *,'pvglab(1),pvglab(2),',
c     +        'pvglab(3),pvglab(4)',
c     +         real(pvglab(1)),real(pvglab(2)),
c     +         real(pvglab(3)),real(pvglab(4))

* -> real photon in lab frame

      prgam_l(4) = dble(e_lar)
      prgam_l(1) = dble(px_lar)
      prgam_l(2) = dble(py_lar)
      prgam_l(3) = dble(pz_lar)
      
           
      call v_copy(prgam_l,prglab)

c------------------------------------------------------
ccc      print *,'prglab(1)',prglab(1),px_lar
      call calcangles(plilab,plolab,pvglab,prglab,phiout)
ccc      print *,phiout,plolab(4)
c------------------------------------------------------
c  
c       GOTO 5

c      print *,'prglab(1),prglab(2),',
c     +        'prglab(3),prglab(4)',
c     +         real(prglab(1)),real(prglab(2)),
c     +         real(prglab(3)),real(prglab(4))
 

* -> outgoing proton in lab frame

      ppo_l(4) = ppi_l(4)+pli_l(4)-prgam_l(4)-plo_l(4)
      ppo_l(1) = ppi_l(1)+pli_l(1)-prgam_l(1)-plo_l(1)
      ppo_l(2) = ppi_l(2)+pli_l(2)-prgam_l(2)-plo_l(2)
      ppo_l(3) = ppi_l(3)+pli_l(3)-prgam_l(3)-plo_l(3)

      call v_copy(ppo_l,ppolab)

c      print *,'ppolab(1),ppolab(2),',
c     +        'ppolab(3),ppolab(4)',
c     +         real(ppolab(1)),real(ppolab(2)),
c     +         real(ppolab(3)),real(ppolab(4))

* -> calculate phi angles in lab frame...

      phi_p_lab  = atan2(ppolab(2),ppolab(1))
      phi_l_lab  = atan2(plolab(2),plolab(1))
      phi_g_lab  = atan2(prglab(2),prglab(1))
      phi_li_lab = atan2(plilab(2),plilab(1))


* -> calculate phi between po and lo in lab frame...
      dphi_lab=atan2(ppolab(2),ppolab(1))-
     +          atan2(plolab(2),plolab(1))

c *  --- Boost to p-rest frame, same system axis ---
c 
c       call v_copy8(pli_l,pli_tmp)
c       call v_copy(pli_tmp,pliprf)
c 
c       call v_copy8(plo_l,plo_tmp)
c       call v_copy(plo_tmp,ploprf)
c 
c       call v_copy8(ppi_l,ppi_tmp)
c       call v_copy(ppi_tmp,ppiprf)
c 
c       call v_copy8(pvgam_l,pvgam_tmp)
c       call v_copy(pvgam_tmp,pvgprf)
c * --- Rotate the system axis, z = -q_1^3 ---
c 
c       do i=1,3
c        rot(i) = -pvgam_tmp(i)
c       enddo
c 
c       do_xaxis = .true.
c       i_xaxis  = 1
c       call rotate(pli_tmp,rot,1,pli_b)
c       do_xaxis = .false.
c       call v_copy(pli_b,plibel)
c 
c       call rotate(plo_tmp,rot,1,plo_b)
c       call rotate(pvgam_tmp,rot,1,pvgam_b)
c 
c ccc      call rotate(ppi_tmp,rot,1,ppi_b)
c       call v_copy8(ppi_b,ppi_tmp)
c 
c       call v_copy(plo_b,plobel)
c       call v_copy(pvgam_b,pvgbel)
c       call v_copy(ppi_b,ppibel)

* --- Boost to p-rest frame, same system axis ---

      boostp = eproton / mp
      beta(1) =  -ppi_l(1) / ppi_l(4)
      beta(2) =  -ppi_l(2) / ppi_l(4)
      beta(3) =  -ppi_l(3) / ppi_l(4)

      do i=1,3
       betar(i) = -beta(i)
      enddo

* -> Boost incoming lepton
      do i=1,4
       ptmp(i)    = pli_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       pli_tmp(i) = ptmp(i)
      enddo
      call v_copy(pli_tmp,pliprf)

c      print *,'pliprf(1),pliprf(2),',
c     +        'pliprf(3),pliprf(4)',
c     +         real(pliprf(1)),real(pliprf(2)),
c     +         real(pliprf(3)),real(pliprf(4))

* -> Boost outcoming lepton
      do i=1,4
       ptmp(i)    = plo_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       plo_tmp(i) = ptmp(i)
      enddo
      call v_copy(plo_tmp,ploprf)

c      print *,'ploprf(1),ploprf(2),',
c     +        'ploprf(3),ploprf(4)',
c     +         real(ploprf(1)),real(ploprf(2)),
c     +         real(ploprf(3)),real(ploprf(4))

* -> Boost incoming proton
      do i=1,4
       ptmp(i)    = ppi_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       ppi_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppi_tmp,ppiprf)

c      print *,'ppiprf(1),ppiprf(2),',
c     +        'ppiprf(3),ppiprf(4)',
c     +         real(ppiprf(1)),real(ppiprf(2)),
c     +         real(ppiprf(3)),real(ppiprf(4))

* -> Boost virtual photon
      do i=1,4
       ptmp(i)      = pvgam_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       pvgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(pvgam_tmp,pvgprf)

c      print *,'pvgprf(1),pvgprf(2),',
c     +        'pvgprf(3),pvgprf(4)',
c     +         real(pvgprf(1)),real(pvgprf(2)),
c     +         real(pvgprf(3)),real(pvgprf(4))

* -> Boost real gamma
      do i=1,4
       ptmp(i)    = prgam_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       prgam_tmp(i) = ptmp(i)
      enddo
      call v_copy(prgam_tmp,prgprf)

c      print *,'prgprf(1),prgprf(2),',
c     +        'prgprf(3),prgprf(4)',
c     +         real(prgprf(1)),real(prgprf(2)),
c     +         real(prgprf(3)),real(prgprf(4))

* -> Boost outgoing proton
      do i=1,4
       ptmp(i)    = ppo_l(i)
      enddo
      if (.not.stFIXED_save) then
      call boost(ptmp,beta)
      endif
      do i=1,4
       ppo_tmp(i) = ptmp(i)
      enddo
      call v_copy(ppo_tmp,ppoprf)

c      print *,'ppoprf(1),ppoprf(2),',
c     +        'ppoprf(3),ppoprf(4)',
c     +         real(ppoprf(1)),real(ppoprf(2)),
c     +         real(ppoprf(3)),real(ppoprf(4))

* -> calculate phi angles in prf frame...

      phi_p_prf  = atan2(ppoprf(2),ppoprf(1))
      phi_l_prf  = atan2(ploprf(2),ploprf(1))
      phi_g_prf  = atan2(prgprf(2),prgprf(1))
      phi_li_prf = atan2(pliprf(2),pliprf(1))

* -> calculate phi between po and lo in prf frame...

      dphi_prf=atan2(ppoprf(2),ppoprf(1))-
     +          atan2(ploprf(2),ploprf(1))


* --- all the rest is needed to go in the belitsky frame...
* --- Rotate the system axis, z = -q_1^3 ---

      do i=1,3
       rot(i) = -pvgam_tmp(i)
      enddo
ccc      print *,index,pvgprf(4)

c      print *,'rot(1),rot(2),rot(3)',
c     +    real(rot(1)),real(rot(2)),real(rot(3))

      do_xaxis = .true.
      i_xaxis  = 1
      call rotate(pli_tmp,rot,1,pli_b)
      do_xaxis = .false.
      call v_copy(pli_b,plibel)

c      print *,'plibel(1),plibel(2),',
c     +        'plibel(3),plibel(4)',
c     +         real(plibel(1)),real(plibel(2)),
c     +         real(plibel(3)),real(plibel(4))

      call rotate(plo_tmp,rot,1,plo_b)
      call rotate(pvgam_tmp,rot,1,pvgam_b)

      if (.not.stFIXED_save) then
      call rotate(ppi_tmp,rot,1,ppi_b)
      endif
      if (stFIXED_save) then
      call v_copy8(ppi_b,ppi_tmp)
      endif

      call rotate(ppo_tmp,rot,1,ppo_b)
      call rotate(prgam_tmp,rot,1,prgam_b)

      call v_copy(plo_b,plobel)
      call v_copy(pvgam_b,pvgbel)
      call v_copy(ppi_b,ppibel)
      call v_copy(ppo_b,ppobel)
      call v_copy(prgam_b,prgbel)
      
c      print *,index,ppobel(4),ppobel(3),ppobel(2),ppobel(1)



c       call v_copy44(pliprf,plibel)
c       call v_copy44(ploprf,plobel)
c       call v_copy44(pvgprf,pvgbel)
c       call v_copy44(ppiprf,ppibel)
c       call v_copy44(ppoprf,ppobel)
c       call v_copy44(prgprf,prgbel)

c      print *,'plobel(1),plobel(2),',
c     +        'plobel(3),plobel(4)',
c     +         real(plobel(1)),real(plobel(2)),
c     +         real(plobel(3)),real(plobel(4))

c      print *,'pvgbel(1),pvgbel(2),',
c     +        'pvgbel(3),pvgbel(4)',
c     +         real(pvgbel(1)),real(pvgbel(2)),
c     +         real(pvgbel(3)),real(pvgbel(4))

c      print *,'ppibel(1),ppibel(2),',
c     +        'ppibel(3),ppibel(4)',
c     +         real(ppibel(1)),real(ppibel(2)),
c     +         real(ppibel(3)),real(ppibel(4))


c      print *,'ppobel(1),ppobel(2),',
c     +        'ppobel(3),ppobel(4)',
c     +         real(ppobel(1)),real(ppobel(2)),
c     +         real(ppobel(3)),real(ppobel(4))

c      print *,'prgbel(1),prgbel(2),',
c     +        'prgbel(3),prgbel(4)',
c     +         real(prgbel(1)),real(prgbel(2)),
c     +         real(prgbel(3)),real(prgbel(4))


      phi_p_bel  = atan2(ppobel(2),ppobel(1))
      phi_l_bel  = atan2(plobel(2),plobel(1))
      phi_g_bel  = atan2(prgbel(2),prgbel(1))
      phi_li_bel = atan2(plibel(2),plibel(1))
      phi_v_bel  = atan2(pvgbel(2),pvgbel(1))
      
c      print *,index,atan2(ppobel(2),ppobel(1))

c       the_p_bel  = 
c      + atan2(sqrt(ppobel(1)**2+ppobel(2)**2),ppobel(3))
c       the_l_bel  = 
c      + atan2(sqrt(plobel(1)**2+plobel(2)**2),plobel(3))
c       the_r_bel  = 
c      + atan2(sqrt(prgbel(1)**2+prgbel(2)**2),prgbel(3))
c 
c       dphi_bel=atan2(ppobel(2),ppobel(1))-
c      +          atan2(plobel(2),plobel(1))

* --- final angle (which should be the correct PHI)
      phi_r = phi_p_bel
      
c        if (index==0) then
c        write(89,*) index,phi_p_bel,phi_l_bel,phi_g_bel,
c      + the_p_bel,the_l_bel,the_r_bel
c        endif
c        if (index==1) then
c        write(91,*) index,phi_p_bel,phi_l_bel,phi_g_bel,
c      + the_p_bel,the_l_bel,the_r_bel
c        endif
      
c       write(89,*) phi_p_lab,phi_l_lab,phi_g_lab,phi_li_lab,
c      +            phi_p_prf,phi_l_prf,phi_g_prf,phi_li_prf,
c      +            phi_p_bel,phi_l_bel,phi_g_bel,phi_li_bel


 5    continue

      return 
      end




     
c------------------------------------------------------
      subroutine calcangles(livec,lovec,vgvec,rgvec,phiout)
c------------------------------------------------------

      real vgvec(4)
      real rgvec(4)
      real livec(4)
      real lovec(4)
      
      real out1(4)
      real out2(4)
      real out3(4)
      
      
      iii=0
      call calc_vectoriel(vgvec,livec,out1)
      call calc_vectoriel(vgvec,rgvec,out2)
      call calc_scalar(out1,out2,res1)
      call calc_norme(out1,xn1)
      call calc_norme(out2,xn2)

c      print *,rgvec(1),rgvec(2),rgvec(3)
c      print *,out1(1),out1(2),out1(3)
      
       if ((xn1*xn2)==0) print *,'warning'
ccc       if ((xn1*xn2)==0) iii=1
      temp1 = res1/(xn1*xn2)
       if ((temp1).gt.1.) temp1=1.
       if ((temp1).lt.-1.) temp1=-1.
       
ccc       print *,res1,(xn1*xn2),temp1
ccc       if (abs(temp1).gt.1.) iii=1
      temp1 = acos(temp1)
      
      call calc_vectoriel(vgvec,livec,out3)
      call calc_scalar(rgvec,out3,res2)
      
       if ((res2)==0) print *,'warning'
       if ((res2)==0) iii=1
      temp2 = res2/abs(res2)
      
      final = temp1*temp2
      

c---------------------      
      phiout = final
c--------------------- 
       if (iii==1)   phiout=-100.   
       
     
      return
      end
      
      
      subroutine calc_scalar(p1,p2,result)
      
      real p1(4) ! x,y,z,E
      real p2(4) ! x,y,z,E
      real result
      
      sum = 0.
      do i=1,3
      sum=sum+p1(i)*p2(i)
      enddo
      
      result = sum
      
      return
      end
      
      subroutine calc_vectoriel(p1,p2,presult)
      
      real p1(4) ! x,y,z,E
      real p2(4) ! x,y,z,E
      real presult(4)
      
      presult(1) = p1(2)*p2(3)-p1(3)*p2(2)
      presult(2) = p1(3)*p2(1)-p1(1)*p2(3)
      presult(3) = p1(1)*p2(2)-p1(2)*p2(1)
           
      return
      end
      
      subroutine calc_norme(p1,result)
      
      real p1(4) ! x,y,z,E
      real result
      
      sum = 0.
      do i=1,3
      sum=sum+p1(i)*p1(i)
      enddo
      
      result = sqrt(sum)
      
      return
      end
      
 
