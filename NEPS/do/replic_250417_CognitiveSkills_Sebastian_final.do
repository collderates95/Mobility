/*******************************************************************************
This file generates the results of column 1 to 4 from Table A.5

*/

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global Rural RuralNEPSMZ


********************************************************************************
* Step 1: Merge sample with cognitive skills data
********************************************************************************

use "$results\C9_Combined_Full_Panel_final.dta", clear
keep if inrange(yob, 1945, 1964)

* 2025 / 02 / 21
keep if inrange(age, 25, 55)

* Make it Cross - Sectional Again
duplicates drop ID_t, force

*** joinby
joinby ID_t using "$results/CognitiveSkills_new.dta", unmatched(both) 
tab _merge
gen missing = _merge ==1 // for later regression on Missings
drop if _merge == 2 
count if w_t4_cal != 0 // 5,260 obs.
count if w_t4_cal != 0 & missing != 1 // 4,411 obs.

*******************************************************************************
*	STEP 2 - standardize skills within estimation sample
*******************************************************************************/
foreach var in zmReading zmReadSpeed zVocabulary7 first_Math { 

	center `var' [aw=w_t4_cal], generate(z`var') standardize
}


********************************************************************************
* Step 6: Regress C9 on Cognitive Skills
********************************************************************************
foreach var of varlist zzmReading zzmReadSpeed zzVocabulary7 zfirst_Math { 
	
	gen missing_`var' = `var'== .

	
	areg `var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aw=w_t4_cal] if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
	
	areg missing_`var' C9 i.bula [aweight = w_t4_cal], robust absorb(cohort)
	eststo miss_`var'
	qui sum missing_`var' if e(sample)
	scalar Mean = r(mean)
	qui estadd scalar Mean
}
esttab c0_* using "$results\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions CognitiveSkills on C9 - Without Controlls") nodepvars replace // mtitle("1: YOS - All Perc. " "2: YOS - 0.5 & 99.5 Removed" "3: YOS - 0.5 & 99.5 Replaced" "1: Dummy: More than 8 Years of School" "2: Dummy: More than 8 Years of School" "3: Dummy: More than 8 Years of School" "Years Of Schooling (in Grades)" "Years of Education (in Grades): NEPS" "School Starting Age (Placebo)")

esttab miss_* using "$results\C9_Cognitive.csv", keep(C9) cells(b(fmt(3) star) se(par)) scalar(Mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("TWFE Regressions Missing CognitiveSkills on C9 - Without Controlls") nodepvars append
eststo clear


