/*******************************************************************************
This file will conduct senstivity analyses/robustness checks
They include Exclusion of Samples and Additional Controlls 

*******************************************************************************/ 

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

use "$results\C9_Combined_Utilized_Panel_final.dta", clear




********************************************************************************
* Panel A: Include student-to-teacher-ratio as independent variable (school quality).  
********************************************************************************
use "$ratio\zeitreihen3.dta", clear
rename bula1 bula
rename jahr year_sttr
save "$ratio\studentteacherratio.dta", replace

*** From Bascial Panel ***
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date

* Constistent Cleaning of Dataset
* Only Born in West-Germany (excluding Berlin)
keep if inrange(bl_birth, 1, 10)
drop if age > 70
count 

************************************************
* Age for C9 == 14 
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 14
global age_T 14
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date 
*br ID_t bdate date bula_
bysort ID_t: egen bula = max(bula_) 
lab val bula de1619
keep if inrange(bula, 1, 10) 

* Year Merge for Student Ratio 
gen year_sttr_ = .
bysort ID_t: replace year_sttr_ = year if age == $age_T 
bysort ID_t: egen year_sttr = min(year_sttr_)

*merge with schooling_laws (contains C9-variable)
joinby yob mob bula using "$results\schooling_laws_all.dta"

*Generate Cohort (as time-variable) and Time of Treatment for Estimators 
sort ID_t bdate date
egen cohort = group(bdate)
bysort bula: egen Ei_ = min(cohort) if C9 == 1 //create oldest cohorts when first C9 happens in for every state
bysort bula: egen Ei_T$age_T = min(Ei_) //copy this oldest cohort of C9 to every bula
drop Ei_

*** recode mig* (99=.)
recode mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr (99=.)


foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}
count // 1. 6,559,135 // 6,559,135

* Joinby with info on student-teacher-ratio
joinby year_sttr bula using "$ratio\studentteacherratio.dta", unmatched(both)
keep if _merge == 3

*** Collapse *** 
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bl_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T$age_T ///
female t_wo_lehrer RuralNEPSMZ ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2, by(ID_t age)
count // 551,559

*** Restrict Age ***
keep if inrange(age, 25, 55)
keep if inrange(yob, 1945, 1964)

* Manually Drop Individuals with no Info on Education
drop if ID_t == 8002143| ID_t == 8011382 | ID_t == 8002692| ID_t == 8004579 | ID_t == 8007719 | ID_t == 8015414

*** Test 
drop if w_t4_cal == 0
distinct ID_t
count // 159,685 // Here:  159,604

*** Regression ***
foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9 t_wo_lehrer i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
	qui estadd scalar Mean = r(mean)
}
esttab pooled_c0_* using "$results\C9_Robustness_TeacherStudentRatio.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Controlled for student-to-teacher-ratio.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear







********************************************************************************
* Panel B: Include state x yob FE 
********************************************************************************
use "$results\C9_Combined_Utilized_Panel.dta", clear

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	*areg `var' C9 yob##bula [aweight = w_t4_cal], cluster(ID_t) // absorb(cohort)
	ivreg2 `var' C9 c.yob##i.bula [aweight = w_t4_cal], cluster(ID_t) // absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
	qui estadd scalar Mean = r(mean)
}
esttab pooled_c0_* using "$results\C9_YobXBula.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. With YOB and State Interaction.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear


********************************************************************************
* Panel C: Exclude Always-Treated (In this case: 01 SH, 02 HH, 04 BR, 10 SA) -> Looks Good
********************************************************************************
preserve

drop if bula == 1
drop if bula == 2
drop if bula == 4
drop if bula == 10

*foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
*	*i) No additional Controls
*	eststo m_`var': areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
*	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
*	estadd scalar Mean = r(mean)
*}

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
	qui estadd scalar Mean = r(mean)
}

esttab pooled_c0_* using "$results\C9_ExcludeAT.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Exlude Always-Treated States.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace

restore

/********************************************************************************
* Panel D is produced in the following do file "do "$prog\replic_250417_C9_AlternativeDiD_final.do" 
********************************************************************************/


********************************************************************************
* Panel E. Age of treatment assignment at age 12 (instead of 14)
********************************************************************************
*** From Basic Panel ***
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date


* Constistent Cleaning of Dataset
* Only Born in West-Germany (excluding Berlin)
keep if inrange(bl_birth, 1, 10)
drop if age > 70
count // 8,021,414

************************************************
* Age for C9 == 12 [For Robustness Test!] -> Even Smaller. Dangerous, as this contradicts our main assumptions.. lets do additional treatment years for alternatives
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 12
global age_T 12
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date // We assign Treatment-Bula to age 12*12 = 12; Will later be filled via egen(max) bula_ = bula at age 12
*br ID_t bdate date bula_
bysort ID_t: egen bula = max(bula_) // bula: Bundesland where I have been at 14 (Static)
lab val bula de1619
keep if inrange(bula, 1, 10) // Berlin and East-Germany excluded // distinct ID_t // 11497

*merge with schooling_laws (contains C9-variable)
joinby yob mob bula using "$results\schooling_laws_all.dta" 
*drop _merge
*4 Bula without Control/Always-Treated: 1SH, 2HH, 4BR, 10SA

*Generate Cohort (as time-variable) and Time of Treatment for Estimators 
sort ID_t bdate date
egen cohort = group(bdate)
bysort bula: egen Ei_ = min(cohort) if C9 == 1 //create oldest cohorts when first C9 happens in for every state
bysort bula: egen Ei_T$age_T = min(Ei_) //copy this oldest cohort of C9 to every bula
drop Ei_

*** recode mig* (99=.)
recode mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr (99=.)


foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

count // 1. 6,559,135 // At 12: 1.  6,558,155 

*** Collapse *** 
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bl_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T$age_T ///
female RuralNEPSMZ ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2, by(ID_t age)
count // 551,559

*** Restrict Age ***
keep if inrange(age, 25, 55)
keep if inrange(yob, 1945, 1964)

*** Test 
drop if w_t4_cal == 0
distinct ID_t
count // 159,685 // At 12: 1.  159,596

*** Regression ***
foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
	qui estadd scalar Mean = r(mean)
}
esttab pooled_c0_* using "$results\C9_AssignmentAtAge12.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Reform has been assigned at Age 12 instead of Age 14!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear



********************************************************************************
* Panel F: Unweighted Estimation -> Little bit higher coefficients than unweighted. 
********************************************************************************
use "$results\C9_Combined_Utilized_Panel.dta", clear
drop if w_t4_cal == 0

foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9 i.bula, cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' if e(sample)
	qui estadd scalar Mean = r(mean)
}
esttab pooled_c0_* using "$results\C9_Unweighted.csv", keep(C9) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Unweighted Regressions.") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear

/*








