/*
This file will produce all Visualisations on Mobility over the lifetime and OLS Regressions
*/

*** Globals ***
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariableGraph RuralNEPSMZ

use "$results\Descriptives_FullSample_Merged_final.dta", clear // Not Yet Collapsed!!

*Use font Times New Roman
graph set window fontface "Times New Roman"

sort ID_t date
bysort ID_t: gen obs1=_n==12*10 
count if obs1

*** Collapse and Make Means so everything is faster ***
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bula_T bl_birth kreis kr_birth cohort w_t4_cal entry_y wave1 SSY_ ///
female RuralNEPSMZ ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign  ///
dgr_max abi rs1 hs1 uni yoe YOS_Sum yos_max yoe_grade aase casmin, by(ID_t age) // [aweight=w_t4_cal] fehlt?

*** Create Dummies for export *** 
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)

* Age And Yob restrictions
keep if inrange(yob, 1944, 1986)
keep if inrange(age, 25, 55)


************************************************
*    Generate relevant background variables
************************************************
*recode educational attainment 
recode casmin (0 1 2=1) (3 4=2) (5 6=3) (7 8=4) (else=.), gen(educ)
qui tab educ, gen(educ) 
lab def educ2 1 "1: Haupt." 2 "2: Real." 3 "3: Fach(abi)" 4 "4: FH/Uni"  
lab val educ educ2


*********************** regressions - all "determinants"  *****************
gen west = (inrange(bl_birth, 1, 10))
gen east=west==0
recode age (1/10=10) (11/20=20) (21/30=30) (31/40=40) (41/50=50) (51/60=60) (61/100=100), gen(agegr)


********************************************************************************		
*    Visualization of regressions
********************************************************************************		

********************************************************************************		
* Figure 5 - cross-state level
********************************************************************************		
estimates drop _all
foreach var of varlist mig_flow1 mig_flow5 mig_stock {

* i)	
qui reg `var' i.age i.yob female east $RuralVariableGraph i.educ  [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_a

* ii)
qui reg `var' i.age i.yob i.bl_birth female east $RuralVariableGraph i.educ [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_b

* iii)
qui reg `var' i.age i.yob i.kr_birth female east $RuralVariableGraph i.educ [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_c

* iv)
qui reg `var' i.age female i.yob i.kr_birth female east $RuralVariableGraph i.educ $family_new [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_d


qui sum `var' [aweight=w_t4_cal] if e(sample)
global Y_`var'=round(r(mean), .01)
}
	
coefplot  /// (mig_flow1_0, label(w/o controls) msize(small) mcolor(gs12) ciopts(color(gs12)))
		(mig_flow1_a, msize(small) mcolor(gs2 ) ciopts(color(gs2 ))) ///
		(mig_flow1_b, msize(small) mcolor(gs3 ) ciopts(color(gs3 ))) ///
		(mig_flow1_c, msize(small) mcolor(gs4 ) ciopts(color(gs4 ))) ///
		(mig_flow1_d, msize(small) mcolor(gs5 ) ciopts(color(gs5 ))), bylabel( (a) 1-year mobility (mean: 0$Y_mig_flow1)) || ///
		(mig_flow5_a, label(incl. age and year of birth FE) mcolor(gs2) ciopts(color(gs2))) ///
		(mig_flow5_b, label(incl. age, year and state of birth FE ) msize(small) mcolor(gs3) ciopts(color(gs3))) ///
		(mig_flow5_c, label(incl. age, year and county of birth FE ) msize(small) mcolor(gs4) ciopts(color(gs4))) ///
		(mig_flow5_d, label(incl. age, year and county of birth FE and background controls) msize(small) mcolor(gs5) ciopts(color(gs5))), bylabel( (b) 5-year mobility (mean: 0$Y_mig_flow5)) || ///
		(mig_stock_a, msize(small) mcolor(gs2) ciopts(color(gs2))) ///
		(mig_stock_b, msize(small) mcolor(gs3) ciopts(color(gs3))) ///
		(mig_stock_c, msize(small) mcolor(gs4) ciopts(color(gs4))) ///
		(mig_stock_d, msize(small) mcolor(gs5) ciopts(color(gs5))), bylabel( (c) Lifetime mobility (mean: 0$Y_mig_stock)) || ///
		, drop(_cons) xline(0) ///
		keep(female $RuralVariableGraph east *.educ) ///
		coeflabel(female = "Female" $RuralVariableGraph = "Born in Rural Area" east = "Born in East Germany"  ///
		2.educ = "Education: Middle school" 3.educ = "Education: High school" 4.educ = "Education: Univ./College" ) ///
		graphregion(color(white)) scheme(s1mono) legend(row(2) size(medium) ) byopts(xrescale rows(1)) format(%9.2f)
	graph display, ysize(10) xsize(24)	 
	graph save ${graphs}\descr_reg_BULA.gph, replace asis
	graph export ${graphs}\descr_reg_BULA.png, replace	
	graph export ${graphs}\descr_reg_BULA.pdf, replace
	

********************************************************************************		
* Figure 6 - cross-county level
********************************************************************************
estimates drop _all


foreach var of varlist mig_flow1_kr mig_flow5_kr mig_stock_kr {	

	
* i)	
qui reg `var' i.age i.yob female east $RuralVariableGraph i.educ  [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_a

* ii)
qui reg `var' i.age i.yob i.bl_birth female east $RuralVariableGraph i.educ [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_b

* iii)
qui reg `var' i.age i.yob i.kr_birth female east $RuralVariableGraph i.educ [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_c

* iv)
qui reg `var' i.age female i.yob i.kr_birth female east $RuralVariableGraph i.educ $family_new [aweight=w_t4_cal], vce(cluster ID_t)
estimates store `var'_d


qui sum `var' [aweight=w_t4_cal] if e(sample)
global Y_`var'=round(r(mean), .01)

}

coefplot  /// (mig_flow1_0, label(w/o controls) msize(small) mcolor(gs12) ciopts(color(gs12)))
		(mig_flow1_kr_a, msize(small) mcolor(gs2 ) ciopts(color(gs2 ))) ///
		(mig_flow1_kr_b, msize(small) mcolor(gs3 ) ciopts(color(gs3 ))) ///
		(mig_flow1_kr_c, msize(small) mcolor(gs4 ) ciopts(color(gs4 ))) ///
		(mig_flow1_kr_d, msize(small) mcolor(gs5 ) ciopts(color(gs5 ))), bylabel( (a) 1-year mobility (mean: 0$Y_mig_flow1_kr)) || ///
		(mig_flow5_kr_a, label(incl. age and year of birth FE) mcolor(gs2) ciopts(color(gs2))) ///
		(mig_flow5_kr_b, label(incl. age, year and state of birth FE ) msize(small) mcolor(gs3) ciopts(color(gs3))) ///
		(mig_flow5_kr_c, label(incl. age, year and county of birth FE ) msize(small) mcolor(gs4) ciopts(color(gs4))) ///
		(mig_flow5_kr_d, label(incl. age, year and county of birth FE and background controls) msize(small) mcolor(gs5) ciopts(color(gs5))), bylabel( (b) 5-year mobility (mean: 0$Y_mig_flow5_kr)) || ///
		(mig_stock_kr_a, msize(small) mcolor(gs2) ciopts(color(gs2))) ///
		(mig_stock_kr_b, msize(small) mcolor(gs3) ciopts(color(gs3))) ///
		(mig_stock_kr_c, msize(small) mcolor(gs4) ciopts(color(gs4))) ///
		(mig_stock_kr_d, msize(small) mcolor(gs5) ciopts(color(gs5))), bylabel( (c) Lifetime mobility (mean: 0$Y_mig_stock_kr)) || ///
		, drop(_cons) xline(0) ///
		keep(female $RuralVariableGraph east *.educ) ///
		coeflabel(female = "Female" $RuralVariableGraph = "Born in Rural Area" east = "Born in East Germany"  ///
		2.educ = "Education: Middle school" 3.educ = "Education: High school" 4.educ = "Education: Univ./College" ) ///
		graphregion(color(white)) scheme(s1mono) legend(row(2)) byopts(xrescale rows(1)) format(%9.2f)
	graph display, ysize(10) xsize(24)	 
	graph save ${graphs}\descr_reg_COUNTY.gph, replace asis
	graph export ${graphs}\descr_reg_COUNTY.png, replace	
	graph export ${graphs}\descr_reg_COUNTY.pdf, replace