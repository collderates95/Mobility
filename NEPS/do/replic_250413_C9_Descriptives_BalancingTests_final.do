/**************************************************
This file produces the Balancing Tests in Table A.3

***************************************************/

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralDummy RuralNEPSMZ 

************************************************
*    load panel
************************************************
use "$results\C9_Combined_Utilized_CS_final.dta", clear // From 231030_Combine_C9.do
sort ID_t age
xtset ID_t age

** Final Restrictions
keep if inrange(yob, 1945, 1964)
duplicates drop ID_t, force

*Labels
label var female "Women"
label var yob "Year of Birth"
label var bula "Federal state of school entry at Age 14"
label var p_yos_mean "Parental years of schooling (avg.)"
label var p_yos_mean_m "Parental years of schooling (avg.): Missing"
label var m_ageb4_T2 "Mother Age at Birth"
label var m_ageb4_T2_m "Mother Age at Birth: Missing"
label var D_JoinedKita_T0 "Joined Kita: Missing"
label var D_JoinedKita_T1 "Joined Kita: No"
label var D_JoinedKita_T2 "Joined Kita: Yes"
label var p_gerborn_ha_new "German parent(s)"
label var p_gerborn_ha_new_m  "German parent(s): missing"
label var D_OlderSibling_T0 "At least one older sibling: Missing"
label var D_OlderSibling_T1 "At least one older sibling: No"
label var D_OlderSibling_T2 "At least one older sibling: Yes"
label var SSY_ "Schort School Year"
label var RuralNEPSMZ "Born in Rural Municipality"

***
* Recode Sibling
***
recode D_OlderSibling_T1 (1 = 2)
recode D_OlderSibling_T2 (2 = 1)

************************************************
*    Columns 1 to 3 of Table A.3
************************************************
preserve
	
	*Female Parental Cohort Bula FE
	areg C9 female p_yos_mean p_yos_mean_m i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance1
	testparm female p_yos_mean p_yos_mean_m
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	* Other Parental BG Sibl Kita Migration 
	areg C9 female $family_new $Siblings_Kita_New $RuralDummy i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance2
	testparm female $family_new $Siblings_Kita_New $RuralNEPSMZ
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	*SSY
	areg C9 female $family_new $Siblings_Kita_New $RuralDummy SSY_ i.bula [aweight = w_t4_cal], robust absorb(cohort)
	estimate store Balance3
	testparm $family_new $Siblings_Kita_New $RuralNEPSMZ SSY_
	estadd scalar p_value = r(p)
	estadd scalar F_value = r(F)
	
	
esttab Balance1 Balance2 Balance3 using "$results\BalancingTest_final_C9.csv", cells(b(fmt(3) star) se(par) p) stats(F_value p_value N, fmt(3 3 0) labels("F-Test" "P-Value" "Indiv.")) mtitle("M1" "M2" "M3") label starlevels(* 0.1 ** 0.05 *** 0.01) drop(*.bula _cons) title("Balancing Test - Dependend Variable: C9") scalar(F_value p_value) stardetach note("Placeholder") replace //stats(F p_value N, labels("F-Test" "P-Value" "Indiv.") fmt(3 0)) using "$results\BalancingTest.xlsx"
eststo clear


restore

************************************************
*    Columns 4 of Table A.3
************************************************
preserve

*Bi-Variate CV
	foreach var of varlist female p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 RuralNEPSMZ SSY_ {
		
		est drop _all
		
		areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
		estimate store Bi10_`var'	
		qui sum `var' [aweight = w_t4_cal] if e(sample)
		*scalar y_mean = r(mean)
		*qui estadd scalar y_mean
		
		local name: variable label `var'
		esttab Bi10_* using "$results\BalancingTest_long.csv", cells(b(fmt(3) star) se(par) p) starlevels(* 0.1 ** 0.05 *** 0.01) keep(C9) coef(C9 "`name'") append nomtitle nonumbers noobs stardetach
		*append stats(N y_mean, fmt(0 3))
		
	}

restore

