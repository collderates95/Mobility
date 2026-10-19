/**************************************************
This file will do the TWFE of the C9 (Compulsory School Reform) on Educational Outcomes

***************************************************/
************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

************************************************
*    load final panel
************************************************
*use "$results_Des\Balancing_C9_CrossSectional.dta", clear  
use "$results\C9_Combined_Utilized_CS_final.dta", clear
sort ID_t age
xtset ID_t age

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)
*replace YOS_Sum = 10.02648 if YOS_Sum == . // Here we lose one observation!
drop if YOS_Sum == .

*Recode abi_sectrack
replace abi_sectrack = . if abi_sectrack == -99
* replace yoe_yrs = 8 if yoe_yrs < 8
replace yoe = 8 if yoe < 8

***********************************************
* Produce new Variable more than 8 Years of Schooling
* With all 3 Main YOS Variables of Interest
***********************************************
clonevar YOS_Sum_r = YOS_Sum
replace YOS_Sum_r = round(YOS_Sum_r,0.1)
gen MoreThan8 = (YOS_Sum_r > 8) 

************************************************
* Create Info on School Starting Age
************************************************
merge m:1 ID_t using "$results\schoolentry.dta", keepusing(sbula_1 start_p start_sp1) // .dta from Anton
keep if _merge == 3
drop _merge
gen bdate_SSA = mdy(mob,14,yob)
format %tdD_m_CY start_p bdate_SSA
gen aase = round(((start_sp1 - bdate_SSA)/365),.01)
label var aase "age at school entry"


drop YOS_Sum_r 
********************************************************************************
*************************************TABLE 1************************************
********************************************************************************

*Panel A
foreach var of varlist YOS_Sum yoe_grade aase {  // YOS_Harmonized YOS_NoOutlier MoreThan8_Harm MoreThan8_NoOutl
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c0_* using "$results\Compliance_Educ_TWFE.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Without Controlls") nodepvars mtitle("Duration of schooling (calend.)" "YOS" "SSA (placebo)") replace
eststo clear

*Panel B
foreach var of varlist YOS_Sum yoe_grade aase { 
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c1_* using "$results\Compliance_Educ_TWFE.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Full Controlls") nodepvars mtitle("Duration of schooling (calend.)" "YOS" "SSA (placebo)") append
eststo clear





********************************************************************************
*************************************TABLE A.7**********************************
********************************************************************************

*Panel A
foreach var of varlist hs1 rs1 abi uni profes { // rs_abi
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c0_* using "$results\Educ_TWFE_Full.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Without Controlls") nodepvars mtitle("Basic degree" "Middle degree" "High school"  "University degree" "Voc. educ.") replace
eststo clear

*Panel B
foreach var of varlist hs1 rs1 abi uni profes { // rs_abi
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab pooled_c1_* using "$results\Educ_TWFE_Full.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Education on C9 - Full Controlls") nodepvars mtitle("Basic degree" "Middle degree" "High school"  "University degree" "Voc. educ.") append
eststo clear
	


********************************************************************************
*************************************Fig A.10**********************************
********************************************************************************	


*Running Variable:
* Six Months before and after C9 introduction of the Cohort
* T_0 is Introduction of C9
* Cut == C9 from schooling_laws
* Running Variable == BIRTH Months after and before cut-off

*bysort bula: gen run = Ei_T$age_T - cohort
bysort bula: gen run = cohort - Ei_T14 
gen after = (run > 0) // after exact replica of C9!

tab run, mis
label var run "running variable ( month distance to first C9 cohort)"



**********************************************************************
* Now Balanced 
**********************************************************************
*** years of schooling relative to C9

centile(YOS_Sum), centile(0.5, 99.5)
gen yos_outlier = ( YOS_Sum < r(c_1) | YOS_Sum > r(c_2) )


preserve
keep if inrange(yob,1945,1964)
keep if YOS_Sum != .
drop if YOS_Sum == -99
keep if yos_outlier == 0
keep if inrange(run, -108, 108)

*Balanced:
*drop if bula == 1 | bula == 2 | bula == 4 | bula == 10

gen N=1 
label var abi_sectrack "Years of schooling"
collapse (mean) YOS_Sum (count) N [aw=w_t4_cal], by(run)

		twoway scatter YOS_Sum run, msize(small) color(gs10) mlcolor(gs8) mfcolor(white) || lfit YOS_Sum run if inrange(run,-108,-1), color(gs10) clcolor(gs10)  || lfit YOS_Sum run if inrange(run,0,108), color(gs10) clcolor(gs10) || lfit YOS_Sum run if inrange(run,-54,-1), lpattern(dash) color(gs0) clcolor(gs0)  || lfit YOS_Sum run if inrange(run,0,54), lpattern(dash) color(gs0) clcolor(gs0) ///
		scheme(s1mono) legend(off) xlabel(-108(12)108, labsize(small)) xscale(range(-108 108)) xline(0, lcolor(red) lpattern(dash))  ///
		yscale(range(7 12)) ylabel(7(1)12) ///
		ytitle("", size(medsmall))       /// 
	    xtitle("Date of birth relative to the reform (in months)", size(medsmall)) ///
		legend(off) ///
		title("Years of schooling", size(medsmall))  //
graph display, xsize(10) ysize(6)
graph save "${results}\YOS_Sum_aw_UNBALANCED", replace
graph export "${results}\YOS_Sum_aw_UNBALANCED.pdf", replace
*xlabel(-6 (1) 6) yscale(range(8.5 11)) ylabel(8.5(0.5)11)
restore	
	