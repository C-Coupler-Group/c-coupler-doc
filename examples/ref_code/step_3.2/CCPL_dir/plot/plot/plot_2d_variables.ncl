;----------------------------------------------------------------------------------
;----500hPa--lev:19(midpoint)--ilev:18(interface)--------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;*******************************************************************************
begin

    path1 = "../run/data/atm/atm_demo/"
    path2 = "../run/data/ocn/ocn_demo/"
    date = (/"0801","0801"/)
    time = (/"450","450"/)
    plot_var = new(2,"graphic")
    wks = gsn_open_wks("png","atm_ocn_psl")
    gsn_define_colormap(wks,"ViBlGrWhYeOrRe")
m=0
i=m
    f1 = addfile(path1+"atm_ocn_coupled_demo.atm_demo.r.2015"+date(m)+"-"+time(i)+"00.nc","r")
    f2 = addfile(path2+"atm_ocn_coupled_demo.ocn_demo.r.2015"+date(m)+"-"+time(i)+"00.nc","r")
    dim_H2D_01=7680
    dim_H2D_02=70560

    psl1 = f1->$"psl.atm_demo_H2D_grid.decomp_atm_demo_grid.0"$
    psl_varname="psl.ocn_demo_H2D_grid.decomp_ocn_demo_grid.0"
    psl2 = f2->$psl_varname$

    atm_demo_lon = f1->grid_0_lon
    atm_demo_lat = f1->grid_0_lat
    ocn_demo_lon = f2->grid_0_lon
    ocn_demo_lat = f2->grid_0_lat

;******************************************************************************************    

    res  = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@gsnSpreadColors = True

    res@mpProjection             = "CylindricalEquidistant"
    res@mpCenterLonF             = 180.0
    res@mpGridAndLimbOn          = False
    res@mpPerimOn                = True
    res@mpGridLatSpacingF        = 10.0
    res@mpGridLonSpacingF        = 10.0
    res@mpFillOn                 = False

    res@cnLinesOn                = False
    res@cnLineLabelsOn           = False
    res@cnFillOn                 = True
    res@cnFillMode               = "AreaFill"

    res@lbLabelBarOn                = False

    res@tmXBLabelFontHeightF = 0.028
    res@tmYLLabelFontHeightF = 0.028
    res@gsnLeftStringFontHeightF  = 0.03

    res@tmXBMajorOutwardLengthF = 0.008
    res@tmXTMajorOutwardLengthF = 0.008
    res@tmYLMajorOutwardLengthF = 0.008
    res@tmYRMajorOutwardLengthF = 0.008

    res@tmXBMinorOutwardLengthF = 0
    res@tmXTMinorOutwardLengthF = 0
    res@tmYLMinorOutwardLengthF = 0
    res@tmYRMinorOutwardLengthF = 0

    res@tmXBLabelStride = 2
    res@cnLevelSelectionMode  = "ManualLevels"

    res2 = res

    res@sfXArray = atm_demo_lon
    res@sfYArray = atm_demo_lat

    res2@sfXArray = ocn_demo_lon
    res2@sfYArray = ocn_demo_lat



        res@gsnRightString = "Pa"
        res@gsnRightStringFontHeightF  = 0.02
        res2@gsnRightString = "Pa"
        res2@gsnRightStringFontHeightF  = 0.02
        res@cnLevelSpacingF      = 200
        res@cnMinLevelValF       = 98000
        res@cnMaxLevelValF       = 102000
        res2@cnLevelSpacingF     = 200
        res2@cnMinLevelValF      = 98000
        res2@cnMaxLevelValF      = 102000

        res@gsnLeftString = "PSL in ATM_DEMO "+date(m)+"_"+stringtoint(time(i))/36+"h"
        plot_var(0) = gsn_csm_contour_map(wks,psl1,res)
        res2@gsnLeftString = "PSL in OCN_DEMO "+date(m)+"_"+stringtoint(time(i))/36+"h"
        plot_var(1) = gsn_csm_contour_map(wks,psl2,res2)
        delete([/res,res2/])

    resp                     = True
    resp@gsnMaximize         = True
    resp@gsnPanelRowSpec     = True
    resp@gsnPanelLabelBar    = True
    resp@lbAutoManage        = False
    resp@lbLabelFontHeightF  = 0.009
    resp@txString = "PSL 2015_" +date(m)+"_"+stringtoint(time(i))/36+"h"
        gsn_panel(wks,plot_var,(/1,2/),resp)

end
