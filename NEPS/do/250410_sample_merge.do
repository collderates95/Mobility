/**************************************************
    Merge seperate datasets to basicpanel
	
	Author: A. Barabasch
	
	Version: 1.0, Created: 2022-03-01	
***************************************************/

************************************************
*    load basic panel
************************************************
use "$results\0_basicpanel_outcomes.dta", clear


************************************************
*    Merge weights
************************************************
merge m:1 ID_t using "$results\temp_weights.dta"
drop if _merge == 2
drop _merge

************************************************
*    merge week of birth
************************************************
merge m:1 ID_t using "$results\SC6_birthweek.dta", keepusing(wob)
drop if _merge == 2
drop _merge

************************************************
*    merge data on actual school entry
************************************************
merge m:1 ID_t using "$results\schoolentry.dta", keepusing(sbula_1 start_p start_sp1) 
label var sbula_1 "federal state of school entry (according to school spells)"
drop if _merge == 2
drop _merge


************************************************
*  merge educational variables
************************************************
merge m:1 ID_t using "$results\educ_final.dta"
drop if _merge == 2
drop _merge

************************************************
*  merge family background
************************************************
merge m:1 ID_t using "$results\background_temp.dta"
drop if _merge == 2
drop _merge


************************************************
*  merge cognitive skills
************************************************
merge m:1 ID_t using "$results\CognitiveSkills_new.dta"
drop if _merge == 2
drop _merge


************************************************
*  merge locus of control + risk
************************************************
merge m:1 ID_t using "$results\RiskAndLocus.dta"
drop if _merge == 2
drop _merge



************************************************
*    merge rural dummy

***This dataset was created onsite and has to be requested at the Research Data Centre of the Leibniz Institute for Educational Trajectories (FDZ-LIfBi)
***After receipt it has to be manually copied to the folder "$results"

************************************************
merge m:1 ID_t using "$results\Rural_Merge_Ready_neu.dta"
drop if _merge == 2
drop _merge


*******************************************************************************************
*    Create final information that requires the full dataset (basicpanel + single datasets)
*******************************************************************************************
gen age2 = age*age


*recode educational attainment
cap drop educ educ*
recode casmin (0 1 2=1) (3 4=2) (5 6=3) (7 8=4) (else=.), gen(educ)
qui tab educ, gen(educ) 
lab def educ 1 "1: Haupt." 2 "2: Real." 3 "3: Fach(abi)" 4 "4: FH/Uni", modify  
lab val educ educ


*group birth cohorts
cap drop yobgr*
recode yob (1944/1949=1940) (1950/1959=1950) (1960/1969=1960) (1970/1979=1970) (1980/1989=1980), gen(yobgr)



**********************************************
*** Parental Variables ***
**********************************************

*parental controls
foreach var of varlist sibl m_yob f_yob m_gerborn f_gerborn m_yos f_yos fam15 {
cap drop `var'_mis	
gen `var'_mis=`var'==.
replace `var'=0 if `var'==.
}


gen m_ageb=yob-m_yob if m_yob != 0
gen f_ageb=yob-f_yob if f_yob != 0

gen m_ageb_mis = (m_ageb == 0)
gen f_ageb_mis = (f_ageb == 0)

*recode Age at Birth of Mother and Father
** ageb2 == With First Child in Age 1-10
recode f_ageb (-99/0 = 0) (1/10 = 1) (11/20 = 2) (21/30 = 3) (31/40 = 4) (41/50 = 5) (51/99 = 6), gen(f_ageb2)
recode m_ageb (-99/0 = 0) (1/10 = 1) (11/20 = 2) (21/30 = 3) (31/40 = 4) (41/50 = 5) (51/99 = 6), gen(m_ageb2)

lab var m_ageb2 "Age of Birth Mother. 0 Missing 1 to Age 10 2 to Age 20. Missing not absorbed"
lab var f_ageb2 "Age of Birth Mother. 0 Missing 1 to Age 10 2 to Age 20. Missing not absorbed"

gen f_ageb2_m = (f_ageb2 == 0)
gen m_ageb2_m = (m_ageb2 == 0)

lab var f_ageb2_m "Dummy Age at Birth 2 Father Missing"
lab var m_ageb2_m "Dummy Age at Birth 2 Mother Missing"


*Main Control-Variable: "Youngest Age at Birth Parent" / "Age Mother at Birth"
recode m_ageb (. = 0) (-99/16 = 0) (50/99 = 50), gen(m_ageb4_T2) // Before: 18
recode f_ageb (. = 0) (-99/16 = 0) (50/99 = 50), gen(f_ageb4_T2) // Before: 18
gen m_ageb4_T2_m = (m_ageb4_T2 == 0)
gen f_ageb4_T2_m = (f_ageb4_T2 == 0)


**********************************************
*** Modify Parent Education
**********************************************

*Both parents German Born
gen p_gerborn =(m_gerborn==1 & f_gerborn ==1)
egen p_yos = rowmax(m_yos f_yos)
gen p_yos_m = (p_yos==0)


*Main Control-Variable: Average Years of Education Parents
egen p_yos_mean = rowmean(f_yos m_yos)
gen p_yos_mean_m = (p_yos_mean == 0)

lab var p_yos_mean "Average Years of Education Parents (CASMIN)"
lab var p_yos_mean_m "Average Years of Education Parents (CASMIN). Missing"


**********************************************
*** Change "Oldest Sibling" to "first born"
**********************************************
recode OlderSibling_T2 (1 = 2) (2 = 1)
label define Label_FirstBorn 0 "At least one older sibling: Missing " 1 "At least one older sibling: Yes" 2 "At least one older sibling: No (First Born)"
label values OlderSibling_T2 Label_FirstBorn


************************************************
* Dummies for Bi-Variate regressions
************************************************
gen D_JoinedKita_T0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2 = (JoinedKita_T2 == 2)

gen D_OlderSibling_T0 = (OlderSibling_T2 == 0)
gen D_OlderSibling_T1 = (OlderSibling_T2 == 1)
gen D_OlderSibling_T2 = (OlderSibling_T2 == 2)
















