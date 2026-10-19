/*******************************************************************************
This file will conduct senstivity analyses/robustness checks
This file will do the randomized assignment of Treatment

*******************************************************************************/ 

************************************************
* define globals
************************************************


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ


********************************************************************************
*** Panel G of Table A.9 - The results that is part of the table is for "num = 4000"
********************************************************************************
forvalues num = 0 (1000) 10000 {
	set seed `num'

use "$results\schooling_laws_all.dta", clear
drop if bula > 10 // Lets stick with West-Germany only!
drop if yob > 1964

** assignment bei place of row
* Sort Bula and Generate Median of C9
sort bula bdate

* Random Number
generate Random = round(runiform(1,5), 0.01)
bysort bula: egen MedianRandom = median(Random)
bysort bula: replace MedianRandom = round(MedianRandom, 0.01)

* Assume first birthdate of first meadian interaction of Random Number as C9 treatment
bysort bula: gen DummyMedian = .
bysort bula: replace DummyMedian = 1 if Random == MedianRandom
bysort bula: replace DummyMedian = DummyMedian[_n-1] if DummyMedian[_n-1] != .
bysort bula: replace DummyMedian = 0 if DummyMedian == .

* Rename DummyMedian to C9_
rename DummyMedian C9_

* Save as new file!
save "$results\ROBUSTNESS_Full_Random_median_schooling_laws_all_`num'.dta", replace

*** From Basic Panel ***
use "$results\0_basicpanel_new.dta", clear
sort ID_t date
xtset ID_t date

*** Merge Family ***
joinby ID_t using "$results\Merge_Family_Final.dta"

*Merge Education
joinby ID_t using "$results\educ_final.dta"

*** Combine With Info on Rural ***
joinby ID_t using "$rural\Rural_Merge_Ready_neu.dta"

* Constistent Cleaning of Dataset
* Only Born in West-Germany (excluding Berlin)
keep if inrange(bl_birth, 1, 10)
drop if age > 70
count 

************************************************
* Age for C9 == 14 [For Robustness Test!]
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 12
global age_T 14
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date 
*br ID_t bdate date bula_
bysort ID_t: egen bula = max(bula_) 
lab val bula de1619
keep if inrange(bula, 1, 10) 

*merge with schooling_laws (contains C9-variable)
joinby yob mob bula using "$results\ROBUSTNESS_Full_Random_median_schooling_laws_all_`num'.dta"
*drop _merge
*4 Bula without Control/Always-Treated: 1SH, 2HH, 4BR, 10SA

*Generate Cohort (as time-variable) and Time of Treatment for Estimators 
sort ID_t bdate date
egen cohort = group(bdate)
bysort bula: egen Ei_ = min(cohort) if C9_ == 1 //create oldest cohorts when first C9 happens in for every state
bysort bula: egen Ei_T$age_T = min(Ei_) //copy this oldest cohort of C9 to every bula
drop Ei_

*** recode mig* (99=.)
recode mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr (99=.)
gen age2 = age*age

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

count // 1. 6,559,135 // At 12: 1.  6,558,155 

*** Collapse *** 
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 C9_ stime bula bl_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T$age_T ///
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
count // 159,685


*** Regression ***
foreach var of varlist mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr { 
	*i) No additional Controls
	areg `var' C9_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `e(depvar)' [aw=w_t4_cal] if e(sample)
	qui estadd scalar Mean = r(mean)
}
esttab pooled_c0_* using "$results\C9_Robustness_RandomizedStateStandort_`num'.csv", keep(C9_) cells(b(fmt(3) star) se(par)) stats(Mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Robustness: Mobility on C9 - Without Controlls. Reform Dates have been randomly assigned by Median, meaning the median/half of the sample has C9!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace
eststo clear


}