/**************************************************
This File will combine all previous .dta to make one consistent .dta (Cross-Section and Panel) for future analyses (Balancing Test, TWFE, Descriptives) 
THis includes sample - sensitive information such as percentiles of variables (C9) and merges of School Starting Age
	
***************************************************/

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

*** From Basic Panel ***
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date

* Constistent Cleaning of Dataset
* Only Born in West-Germany (excluding Berlin)
keep if inrange(bl_birth, 1, 10)
drop if age > 70

************************************************
* Age for C9 == 14 [As agreed upon]
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 14
global age_T 14
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date // We assign Treatment-Bula to age 14*12 = 14; Will later be filled via egen(max) bula_ = bula at age 14
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

*Check Constistence, Migration and Education
tab C9, m 
distinct ID_t if inrange(yob, 1945, 1964)
distinct ID_t if inrange(yob, 1945, 1964) & inrange(age, 25, 55) 
recode mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr (99=.)


foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

* Manually Drop Individuals with no Info on Education
drop if ID_t == 8002143| ID_t == 8011382 | ID_t == 8002692| ID_t == 8004579 | ID_t == 8007719 | ID_t == 8015414


*Save .dta
save "$results\C9_Combined_final.dta", replace
use "$results\C9_Combined_final.dta", clear


*** Full Sample (All Ages and YOB)
*** Panel 
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bl_birth kr_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T14 ///
female year mig_number_age mig_number_2555 mig_number_kr_age mig_number_kr_2555 ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign ///
dgr_max abi rs1 hs1 uni YOS_Sum yos_max yoe yoe_grade casmin profes ///
metropol_birth mig_stock_metropol mig_flow1_metropol mig_flow5_metropol labour_birth mig_stock_labour mig_flow1_labour mig_flow5_labour ///
pendel_br_cond pendel_br_uncond pendel_kr_cond pendel_kr_uncond RuralNEPSMZ, by(ID_t age) // 


* Final Year of Birth Clean
keep if inrange(yob, 1945, 1986)

* Save Full Panel
save "$results\C9_Combined_Full_Panel_final.dta", replace

*Cross-Section
preserve

duplicates drop ID_t, force
save "$results\C9_Combined_Full_CS_final.dta", replace

restore

*** Utilized Sample ***
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

*** Panel 
save "$results\C9_Combined_Utilized_Panel_final.dta", replace

*Cross-Section
preserve

duplicates drop ID_t, force
save "$results\C9_Combined_Utilized_CS_final.dta", replace

restore
