/*
This file will produce all Visualisations on Mobility over the lifetime and OLS Regressions
*/



use "$results\Descriptives_FullSample_Merged_final.dta", clear 
sort ID_t date
bysort ID_t: gen obs1=_n==12*10 
count if obs1

*** Collapse and Make Means so everything is faster ***
collapse (mean) yob mob date bdate year ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bula_T bl_birth cohort entry_y wave1 SSY_ ///
female w_t2_cal w_t4_cal RuralNEPSMZ ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign ///
dgr_max abi rs1 hs1 uni yoe YOS_Sum yos_max yoe_grade aase casmin, by(ID_t age)

*** Create Dummies for export *** 
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)


keep if inrange(age, 7, 64)

************************************************
*    Generate relevant background variables
************************************************
*recode educational attainment 
recode casmin (0 1 2=1) (3 4=2) (5 6=3) (7 8=4) (else=.), gen(educ)
qui tab educ, gen(educ) 
lab def educ2 1 "1: Haupt." 2 "2: Real." 3 "3: Fach(abi)" 4 "4: FH/Uni"  
lab val educ educ2

*group birth cohorts
recode yob (1944/1949=1944) (1950/1959=1950) (1960/1969=1960) (1970/1979=1970) (1980/1989=1980), gen(yobgr)
recode yob (1944/1949=1945) (1950/1954=1950) (1955/1959=1955) (1960/1964=1960) (1965/1969=1965) ///
		   (1970/1974=1970) (1975/1979=1975) (1980/1989=1980), gen(yobgr2)

*********************** regressions - all "determinants"  *****************
gen west = (inrange(bl_birth, 1, 10))
gen east=west==0
recode age (1/10=10) (11/20=20) (21/30=30) (31/40=40) (41/50=50) (51/60=60) (61/100=100), gen(agegr)

*** New Globals ***
*global parent c.m_ageb##c.m_ageb m_ageb_mis c.f_ageb##c.f_ageb f_ageb_mis p_gerborn* p_yos* // < - OLD Globals 
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

************************************************
*    Create Datasets 
************************************************
sort ID_t date
bysort ID_t: gen obs1= (age==10)


	
preserve
gen N=1 if obs1==1

recode yob (1944/1949=1940) (1950/1969=1960) (1970/1989=1980)
recode yobgr (1944=1940)

collapse (count) N (mean) *mig_stock *mig_flow1 *mig_flow5 [aweight=w_t4_cal], by(age yob) 
sort age yob
tab yob 

save $results\age_cohort_all_state.dta, replace
restore 

preserve
drop if mig_stock == 99 
recode mig_stock mig_flow1 mig_flow5 (99=.)
gen N=1 if obs1==1

recode yob (1944/1949=1940) (1950/1969=1960) (1970/1989=1980)
recode yobgr (1944=1940)

collapse (count) N (mean) *mig_stock *mig_flow1 *mig_flow5 [aweight=w_t4_cal], by(female age yob) 
sort female age yob

save $results\age_cohort_gender_state.dta, replace
restore 

preserve
gen N=1 if obs1==1

collapse (count) N (mean) *mig_stock *mig_flow1 *mig_flow5 [aweight=w_t4_cal], by(age educ) 
sort age educ

save $results\age_educ_all_state.dta, replace
restore 

preserve
drop if mig_stock == 99 
recode mig_stock mig_flow1 mig_flow5 (99=.)
gen N=1 if obs1==1

collapse (count) N (mean) *mig_stock *mig_flow1 *mig_flow5 [aweight=w_t4_cal], by(female age educ) 
sort female age educ

save $results\age_educ_gender_state.dta, replace
restore 




********************************************************************************
* 					Figure A1
********************************************************************************

preserve
gen N=1 if obs1==1

collapse (count) N (mean) mig_stock mig_flow1 mig_flow5 [aweight=w_t4_cal], by(age female) 
export excel using "$results\AgeSpecificStateMobilityGender", firstrow(variables) replace keepcellfmt
sort female age
bysort female: sum 

*S* New: 2024 / 06 / 07 : Drop if Age < 7
drop if age < 7 

* 1-year
twoway (line mig_flow1 age if female==0, color(black)) (line mig_flow1 age if female==1, color(gs8) lpattern(dash)), ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.025) 0.1, glstyle(grid)) ///
	title("(a) 1-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// 
	legend(off) legend(label(1 "men") label(2 "women")) ///
	legend(size(medsmall)) ///
	graphregion(color(white)) 
graph save $results\age_1year_wt1_state.gph, replace

*xscale(noline) yscale(noline)

* 5-year
twoway (line mig_flow5 age if female==0, color(black)) (line mig_flow5 age if female==1, color(gs8) lpattern(dash)), ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.05) 0.2, glstyle(grid)) ///
	title("(b) 5-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// text(0.1 7 "info available") text(0.05 7 "(no mig/mig)") ///	text(0.8 68 "info missing") text(0.75 68 "(for good)") /// text(0.97 45 "info missing (gap to be filled)") ///
	legend(off) legend(label(1 "men") label(2 "women")) ///
	legend(size(medsmall)) ///
	graphregion(color(white))
graph save $results\age_5year_wt1_state.gph, replace

* lifetime
twoway (line mig_stock age if female==0, color(black)) (line mig_stock age if female==1, color(gs8) lpattern(dash)), ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.1) 0.4, glstyle(grid)) ///
	title("(c) Lifetime mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// text(0.1 7 "info available") text(0.05 7 "(no mig/mig)") ///	text(0.8 68 "info missing") text(0.75 68 "(for good)") /// text(0.97 45 "info missing (gap to be filled)") ///
	legend(on) legend(label(1 "men") label(2 "women")) ///
	legend(size(medsmall)) legend(ring(0) position(4) bmargin(zero)) ///
	graphregion(color(white))
graph save $results\age_lifetime_wt1_state.gph, replace

tab age female, sum(mig_stock) noobs nost nofreq
tab age female, sum(mig_flow1) noobs nost nofreq
tab age female, sum(mig_flow5) noobs nost nofreq
gen wt=1
save $results\age_wt1_state.dta, replace
restore 

* combine graphs 
graph combine ${results}\age_1year_wt1_state.gph ${results}\age_5year_wt1_state.gph ${results}\age_lifetime_wt1_state.gph ///
         , title(" ", size(medsmall)) ///
		 graphregion(color(white)) scheme(s1mono) cols(1) iscale(0.7) imargin(tiny)
		 
		 graph display, ysize(12) xsize(9)	
		graph save ${results}\age_wt1_state.gph, replace asis
		graph export ${results}\age_wt1_state.png, replace	
		graph export ${results}\age_wt1_state.pdf, replace	
		
			
		
*******************************************************************************
*    Figure 2
******************************************************************************
use $results\age_educ_gender_state.dta, clear
append using $results\age_educ_all_state.dta
export excel using "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\age_educ_all_state.xls", firstrow(variables) keepcellfmt replace
	
sort female age // yob

drop if age < 7 
	
		
	* 1-year
twoway (connected mig_flow1 age if female==. & educ==1, color(gs12) msymbol(d) msize(small))  /// 
		(connected mig_flow1 age if female==. & educ==2, color(gs6) msymbol(X) msize(medsmall))  /// 
	   (connected mig_flow1 age if female==. & educ==3, color(black) lpattern(shortdash) msymbol(oh) msize(medsmall)) ///	
	   (connected mig_flow1 age if female==. & educ==4, color(black) msymbol(o) msize(small))    ///
		, ///
	xlabel(7 (5) 62, nogrid) ylabel(0 (0.02) 0.125, glstyle(grid)) ///
	title("(a) 1-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// 
	legend(off) ///
	legend(size(medsmall)) ///
	graphregion(color(white))
graph save $results\age_1year_educ_state.gph, replace

* 5-year
twoway (connected mig_flow5 age if female==. & educ==1, color(gs12) msymbol(d) msize(small))  /// 
		(connected mig_flow5 age if female==. & educ==2, color(gs6) msymbol(X) msize(medsmall))  /// 
	   (connected mig_flow5 age if female==. & educ==3, color(black) lpattern(shortdash) msymbol(oh) msize(medsmall)) ///	
	   (connected mig_flow5 age if female==. & educ==4, color(black) msymbol(o) msize(small))    ///
		, ///
	xlabel(7 (5) 62, nogrid) ylabel(0 (0.05) 0.3, glstyle(grid)) ///
	title("(b) 5-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// 
	legend(off)  ///
	legend(size(medsmall)) /// 
	graphregion(color(white))
graph save $results\age_5year_educ_state.gph, replace

* lifetime
twoway (connected mig_stock age if female==. & educ==1, color(gs12) msymbol(d) msize(small))  /// 
		(connected mig_stock age if female==. & educ==2, color(gs6) msymbol(X) msize(medsmall))  /// 
	   (connected mig_stock age if female==. & educ==3, color(black) lpattern(shortdash) msymbol(oh) msize(medsmall)) ///	
	   (connected mig_stock age if female==. & educ==4, color(black) msymbol(o) msize(small))    ///
		, ///
	xlabel(7 (5) 62, nogrid) ylabel(0 (0.1) 0.60, glstyle(grid)) ///
	title("(c) Lifetime mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") ///
	legend(on) legend(order(1 "Basic degree" 3 "High school" 2 "Middle degree"  4 "University/College"))   ///
	legend(size(medsmall)) legend(ring(0) position(4) bmargin(zero) cols(3) rows(2)) ///
	graphregion(color(white))
graph save $results\age_lifetime_educ_state.gph, replace



* combine graphs 
graph combine ${results}\age_1year_educ_state.gph ${results}\age_5year_educ_state.gph ${results}\age_lifetime_educ_state.gph ///
         , title(" ", size(medsmall)) ///
		 graphregion(color(white)) scheme(s1mono) cols(1) iscale(0.7) imargin(tiny)
		 
		 graph display, ysize(12) xsize(9)	
		graph save ${results}\age_wt1_educ_state.gph, replace asis
		graph export ${results}\age_wt1_educ_state.png, replace	
		graph export ${results}\age_wt1_educ_state.pdf, replace	

	
		
********************************************************************************
*    Fig A.2
********************************************************************************
use $results\age_WestEast_state.dta, clear
append using $results\age_WestEast_all_state.dta
export excel using "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility\results\age_west_all_state.xls", firstrow(variables) keepcellfmt replace
	
sort age west

*S* New: 2024 / 06 / 07 : Drop if Age < 7
drop if age < 7 
	
		
	* 1-year
twoway (connected mig_flow1 age if west == 0, color( gs5) lpattern(shortdash) msymbol(dh) msize(small))  /// 
		(connected mig_flow1 age if west == 1, color(black) msymbol(o) msize(medsmall))  /// 
		, ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.02) 0.1, glstyle(grid)) ///
	title("(a) 1-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// 
	legend(off) ///
	legend(size(medsmall)) ///
	graphregion(color(white))
graph save $results\age_1year_west_bula.gph, replace

* 5-year
twoway (connected mig_flow5 age if west == 0, color( gs5) lpattern(shortdash) msymbol(dh) msize(small))  /// 
		(connected mig_flow5 age if west == 1, color(black ) msymbol(o) msize(medsmall))  /// 
		, ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.05) 0.25, glstyle(grid)) ///
	title("(b) 5-year mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") /// 
	legend(off)  ///
	legend(size(medsmall)) /// 
	graphregion(color(white))
graph save $results\age_5year_west_bula.gph, replace

* lifetime
twoway (connected mig_stock age if west == 0, color( gs5) lpattern(shortdash) msymbol(dh) msize(small))  /// 
		(connected mig_stock age if west == 1, color(black) msymbol(o) msize(medsmall))  /// 
		, ///
	xlabel(7 (5) 64, nogrid) ylabel(0 (0.1) 0.5, glstyle(grid)) ///
	title("(c) Lifetime mobility", color(black) size(medsmall)) xtitle(" ") ytitle(" ") ///
	legend(on) legend(order(2 "West" 1 "East" ))   ///
	legend(size(medsmall)) legend(ring(0) position(4) bmargin(zero) cols(3) rows(1) holes(3 5)) ///
	graphregion(color(white))
graph save $results\age_lifetime_west_bula.gph, replace


* combine graphs 
graph combine ${results}\age_1year_west_bula.gph ${results}\age_5year_west_bula.gph ${results}\age_lifetime_west_bula.gph ///
         , title(" ", size(medsmall)) ///
		 graphregion(color(white)) scheme(s1mono) cols(1) iscale(0.7) imargin(tiny)
		 
		 graph display, ysize(12) xsize(9)	
		graph save ${results}\age_wt1_west_bula.gph, replace asis
		graph export ${results}\age_wt1_west_bula.png, replace	
		graph export ${results}\age_wt1_west_bula.pdf, replace			

