pro refbeamposition, update

    ra = !g.s[0].longitude_axis
    dec = !g.s[0].latitude_axis
    az = !g.s[0].azimuth
    el = !g.s[0].elevation
    jd = double(!g.s[0].mjd)+2400000.5d
    gbtlat = !g.s[0].site_location[1]
    gbtlon = !g.s[0].site_location[0]
    gbtalt = !g.s[0].site_location[2]

    eq2hor, ra, dec, jd, el_comp, az_comp, lat=gbtlat, lon=gbtlon, $
            altitude=gbtalt
    if (not keyword_set(update)) then begin
      print, 'Header az/el   :', az, el
      print, 'Computed az/el :',az_comp, el_comp
      print
      print,' Az/El computed from RA/Dec values stored in header:'
    endif

    xel = !g.s[0].beamxoff              ; offset position in degrees
    del = !g.s[0].beameoff  

    ; compute angular azimuth and elevation corrections for reference beam
    ; apply el offset first - see http://www.gb.nrao.edu/GBT/MC/dataproc/gbtAntFits/gbtAntFits/node5.html
    ref_el = el_comp - del
    ref_az = az_comp - (xel/cos(el_comp*!pi/180.D0))

    ;now that we have the az, el of ref, need ra,dec
    hor2eq, ref_el, ref_az, jd, ref_ra, ref_dec, lat=gbtlat, lon=gbtlon, $
            altitude=gbtalt
    hor2eq, el_comp, az_comp, jd, comp_ra, comp_dec, lat=gbtlat, lon=gbtlon, $
            altitude=gbtalt

    ; this is how much the shift was in ra,dec using computed values
    dRa  = ref_ra - comp_ra; 
    dDec = ref_dec - comp_dec
    if (not keyword_set(update)) then begin
      print,'Header   ra/dec = ',ra, dec
      print,'Computed ra/dec = ',comp_ra, comp_dec

      print,'Delta ra/dec (") = ', $
          dRa*3600.0d*cos(dec/180.0*!pi), dDec*3600.0d

      radec,ra,dec,ihr,imin,xsec,ideg,imn,xsc
      print,'Hdr RA  = ',ihr,imin,xsec
      print,'Hdr Dec = ',ideg,imn,xsc
      radec,ref_ra,ref_dec,ihr,imin,xsec,ideg,imn,xsc
      print,'Ref RA  = ',ihr,imin,xsec
      print,'Ref Dec = ',ideg,imn,xsc
      radec,comp_ra,comp_dec,ihr,imin,xsec,ideg,imn,xsc
      print,'Cmp RA  = ',ihr,imin,xsec
      print,'Cmp Dec = ',ideg,imn,xsc
    endif 

    if (keyword_set(update)) then begin
      ; apply the shift to header values
      ; header values should be very close to the computed values
      !g.s[0].longitude_axis = ra + dRa
      !g.s[0].latitude_axis  = dec + dDec
      !g.s[0].beamxoff = 0;              ; make sure no double offsets
      !g.s[0].beameoff = 0;
    endif
end
