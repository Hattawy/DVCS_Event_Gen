#include"genepi.h"

/*
 This function generates the Fermi distribution of the nucleon in the helium 
 nucleus, based on the spectral function derived in Ref. [1] for the two-body 
 breakup, valid up to 430 MeV/c. The function returns the initial momentum of 
 the nucleon in GeV/c. 
 [1] R. Schiavilla, V.R. Pandharipande and R.B. Wiringa,
  Nucl. Phys. A 449 (1986) 219 
*/
double fer_mom_hel4(double rndm)
{
  int    i(1);
  double u1;
  double sfp_lg, sfp_li, slo_lg, slo_li;
  double impp, impo, imp(0.0);

  //Fermi distribution Urbana VII potential (limited to 430 MeV/c)
  double spro[216]={0.000000E+00, 0.779425E-05, 0.623047E-04, 0.210024E-03, 0.497025E-03, 0.968766E-03, 
                    0.166990E-02, 0.264411E-02, 0.393389E-02, 0.558040E-02, 0.762331E-02, 0.101006E-01, 
		    0.130485E-01, 0.165011E-01, 0.204906E-01, 0.250470E-01, 0.301978E-01, 0.359657E-01, 
		    0.423721E-01, 0.494370E-01, 0.571778E-01, 0.656096E-01, 0.747447E-01, 0.845930E-01, 
		    0.951617E-01, 0.106456E+00, 0.118477E+00, 0.131225E+00, 0.144698E+00, 0.158889E+00, 
                    0.173792E+00, 0.189396E+00, 0.205689E+00, 0.222644E+00, 0.240242E+00, 0.258469E+00, 
		    0.277303E+00, 0.296727E+00, 0.316717E+00, 0.337251E+00, 0.358306E+00, 0.379855E+00, 
		    0.401873E+00, 0.424333E+00, 0.447207E+00, 0.470467E+00, 0.494083E+00, 0.518026E+00, 
		    0.542262E+00, 0.566743E+00, 0.591440E+00, 0.616326E+00, 0.641373E+00, 0.666555E+00, 
		    0.691845E+00, 0.717215E+00, 0.742641E+00, 0.768096E+00, 0.793555E+00, 0.818994E+00, 
                    0.844388E+00, 0.869714E+00, 0.894950E+00, 0.920073E+00, 0.945057E+00, 0.969873E+00, 
		    0.994504E+00, 0.101893E+01, 0.104314E+01, 0.106712E+01, 0.109084E+01, 0.111431E+01, 
		    0.113749E+01, 0.116039E+01, 0.118299E+01, 0.120528E+01, 0.122725E+01, 0.124888E+01, 
		    0.127018E+01, 0.129114E+01, 0.131173E+01, 0.133196E+01, 0.135182E+01, 0.137131E+01, 
		    0.139042E+01, 0.140915E+01, 0.142750E+01, 0.144547E+01, 0.146305E+01, 0.148024E+01, 
                    0.149705E+01, 0.151348E+01, 0.152953E+01, 0.154519E+01, 0.156047E+01, 0.157537E+01, 
		    0.158990E+01, 0.160406E+01, 0.161785E+01, 0.163127E+01, 0.164433E+01, 0.165703E+01, 
		    0.166938E+01, 0.168138E+01, 0.169303E+01, 0.170435E+01, 0.171533E+01, 0.172599E+01, 
		    0.173632E+01, 0.174633E+01, 0.175603E+01, 0.176543E+01, 0.177452E+01, 0.178333E+01, 
		    0.179185E+01, 0.180008E+01, 0.180804E+01, 0.181573E+01, 0.182316E+01, 0.183033E+01, 
                    0.183726E+01, 0.184393E+01, 0.185037E+01, 0.185657E+01, 0.186255E+01, 0.186831E+01, 
		    0.187385E+01, 0.187918E+01, 0.188431E+01, 0.188925E+01, 0.189399E+01, 0.189856E+01, 
		    0.190294E+01, 0.190714E+01, 0.191118E+01, 0.191505E+01, 0.191877E+01, 0.192233E+01, 
		    0.192574E+01, 0.192901E+01, 0.193214E+01, 0.193513E+01, 0.193799E+01, 0.194073E+01, 
		    0.194334E+01, 0.194584E+01, 0.194823E+01, 0.195051E+01, 0.195268E+01, 0.195476E+01, 
                    0.195673E+01, 0.195862E+01, 0.196041E+01, 0.196212E+01, 0.196375E+01, 0.196529E+01, 
		    0.196676E+01, 0.196816E+01, 0.196949E+01, 0.197075E+01, 0.197195E+01, 0.197309E+01, 
		    0.197417E+01, 0.197520E+01, 0.197617E+01, 0.197709E+01, 0.197797E+01, 0.197879E+01, 
		    0.197958E+01, 0.198031E+01, 0.198101E+01, 0.198167E+01, 0.198229E+01, 0.198288E+01, 
		    0.198343E+01, 0.198395E+01, 0.198444E+01, 0.198490E+01, 0.198534E+01, 0.198574E+01, 
                    0.198613E+01, 0.198648E+01, 0.198682E+01, 0.198714E+01, 0.198743E+01, 0.198771E+01, 
		    0.198797E+01, 0.198821E+01, 0.198844E+01, 0.198865E+01, 0.198884E+01, 0.198903E+01, 
		    0.198920E+01, 0.198937E+01, 0.198952E+01, 0.198966E+01, 0.198979E+01, 0.198992E+01, 
		    0.199003E+01, 0.199014E+01, 0.199023E+01, 0.199033E+01, 0.199041E+01, 0.199048E+01, 
		    0.199055E+01, 0.199062E+01, 0.199068E+01, 0.199074E+01, 0.199080E+01, 0.199086E+01, 
                    0.199091E+01, 0.199096E+01, 0.199101E+01, 0.199106E+01, 0.199110E+01, 0.199113E+01};


// Fermi distributions parameters
   double star = 1.00000E-03;
   double slop = 2.00000E-03;
   double stva = 9.74513E-07;

// Bounded random probability 
  u1 = rndm*spro[214];
  if(u1 <= spro[0])
  {
    imp = 0.0;
    return imp;
  }
// Linear interpolation up to the threshold value corresponding to p = 1 MeV/c
  else if(u1<=stva)
  {
    imp = star*u1/stva;
    return imp;
  }

  while(u1 >= spro[i])
  {
    i++;
  }

// Specific case between threshold and second array element
  if(i == 1)
  {      
    slo_lg = log(spro[i]) - log(stva);
    sfp_lg = log(u1)      - log(stva);
    slo_li = spro[i]      - stva;
    sfp_li = u1           - stva;
    impp   = slop         - star;
    impo   = star;
  }
  //General case
  else
  {
    slo_lg = log(spro[i]) - log(spro[i-1]);
    sfp_lg = log(u1)      - log(spro[i-1]);
    slo_li = spro[i]      - spro[i-1];
    sfp_li = u1           - spro[i-1];
    impp   = slop;
    impo   = (i-1)*slop;
  }

// Helium momentum from an average between logarithmic and linear interpolations
// This average reduces edge effects in the obtained distribution
  imp = impo + impp*(sfp_lg/slo_lg + sfp_li/slo_li)/2.;

  return imp;
}
