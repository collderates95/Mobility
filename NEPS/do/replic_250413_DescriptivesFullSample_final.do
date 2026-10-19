/*
This file will produce all descriptives tables for the C9 -Reform (includes e.g. Data on SSA As Well)
	- For the complete sample of 1944 - 1986
	- West German Cohorts
	
	In One final Version:
	i) Weighted with [aweight == cal]
*/

*Globals
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

************************************************
* Full Sample
************************************************
*** Load Basic Panel ***
use "$results\0_basicpanel_final.dta", clear
sort ID_t date
xtset ID_t date

************************************************
*    Limit data-Set
************************************************
keep if inrange(yob, 1944, 1986)
keep if inrange(bl_birth, 1, 16) 

************************************************
* Merge with Info on C9
************************************************
************************************************
* Age for C9 == 14 [As agreed upon]
************************************************
sort ID_t date
*define state for treatment assignment (C9): Age 14
global age_T 14
rename bula bula_T
gen bula_= bula_T if bdate + $age_T *12 == date // We assign Treatment-Bula to age 14*12 = 14; Will later be filled via egen(max) bula_ = bula at age 14
bysort ID_t: egen bula = max(bula_) // bula: Bundesland where I have been at 14 (Static)
lab val bula de1619
*keep if inrange(bula, 1, 10) // We want full sample this time

*merge with schooling_laws (contains C9-variable)
joinby yob mob bula using "$results\schooling_laws_all.dta", unmatched(master) 
drop _merge
*4 Bula without Control/Always-Treated: 1SH, 2HH, 4BR, 10SA

*Generate Cohort (as time-variable) and Time of Treatment for Estimators (*S* ist es ok die jetzt schon zu machen?)
sort ID_t bdate date
egen cohort = group(bdate)
bysort bula: egen Ei_ = min(cohort) if C9 == 1 //create oldest cohorts when first C9 happens in for every state
bysort bula: egen Ei_T$age_T = min(Ei_) //copy this oldest cohort of C9 to every bula
drop Ei_

*Check Constistence, Migration and Education
tab C9, m 
replace C9 = 1 if bula > 10
replace SSY_ = 0 if bula > 10
tab C9, m

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


*Keep age for Visualization
preserve
drop if C9 == . 
drop if YOS_Sum == .

* Drop and Clean
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
	drop if `var' == 99
}

save "$results\Descriptives_FullSample_Merged_Visualize_final.dta", replace
restore

*Drop and Clean
foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
	drop if `var' == 99
}

drop if C9 == .
drop if YOS_Sum == .



*** Save interim Dataset
save "$results\Descriptives_FullSample_Merged_final.dta", replace
use "$results\Descriptives_FullSample_Merged_final.dta", clear 


********************************************************************************
********************************************************************************
*** Descriptives: HERE: Full Germany, YOB 1944 - 1986 (Column 1 of Table A.2)
********************************************************************************
********************************************************************************
use "$results\Descriptives_FullSample_Merged_final.dta", clear 


keep if inrange(yob, 1944, 1986)
keep if inrange(age,25,55)


*** Full Sample (All Ages and YOB)
*** Panel 
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bl_birth kr_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T14 ///
female year mig_number_age mig_number_2555 mig_number_kr_age mig_number_kr_2555 ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign ///
dgr_max abi rs1 hs1 uni YOS_Sum  aase ///
metropol_birth mig_stock_metropol mig_flow1_metropol mig_flow5_metropol labour_birth mig_stock_labour mig_flow1_labour mig_flow5_labour ///
pendel_br_cond pendel_br_uncond pendel_kr_cond pendel_kr_uncond RuralNEPSMZ, by(ID_t age) 


*** Create Dummies for Descriptive Table *** 
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)




label var mig_stock "Lifetime cross-state"
label var mig_stock_kr "Lifetime cross-county"
label var mig_flow5 "5-year cross-state"
label var mig_flow5_kr "5-year cross-county"
label var mig_flow1 "1-year cross-state"
label var mig_flow1_kr "1-year cross-county"

order mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr mig_stock mig_stock_kr 

putexcel set "$results\FullSample_descriptives.xlsx", replace

local i = 5
foreach var of varlist mig_flow1 - mig_stock_kr {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

putexcel A1 = "Descriptive Statistics (Full Sample, Cohorts 1944 - 1986)"

putexcel B3 = "Number of obs."
putexcel C3 = "Mean"
putexcel D3 = "SD"
putexcel E3 = "Min"
putexcel F3 = "Max"

putexcel A4 = "Migration measures (mean at age 25-55)", bold


tabstat mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr mig_stock mig_stock_kr [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B5 = matrix(stats_all), nformat(number_d2)
putexcel B5:B10, nformat(number) overwritefmt


*** Sociodemographic characteristics
duplicates drop ID_t, force

replace p_yos_mean = . if p_yos_mean == 0
replace m_ageb4_T2 = . if m_ageb4_T2 == 0
replace p_gerborn_ha_new = 0 if p_gerborn_ha_new == -1

cap drop west
gen west = inrange(bl_birth,1,10)

tab bula, gen(bula_d)
drop bula_d11 - bula_d16

label var mob "Month of birth"
label var female "Women"
label var yob "Year of birth"
label var west "Born in West-Germany"
label var bula "Federal state of school entry"
label var bula_d1 "State: Schleswig-Holstein"
label var bula_d2 "State: Hamburg"
label var bula_d3 "State: Lower Saxony"
label var bula_d4 "State: Bremen"
label var bula_d5 "State: Northrhine-Westphalia"
label var bula_d6 "State: Hesse"
label var bula_d7 "State: Rhineland Palatinate"
label var bula_d8 "State: Baden-Wuerttemberg"
label var bula_d9 "State: Bavaria"
label var bula_d10 "State: Saarland"
label var p_yos_mean "Parental education (in yrs)"
label var p_yos_mean_m "Parental education: missing"
label var p_gerborn_ha_new "German parents (0/1)"
label var p_gerborn_ha_new_m  "German parents: missing"
label var m_ageb4_T2 "Maternal age at birth (in yrs)"
label var m_ageb4_T2_m "Maternal age at birth: missing"
label var D_OlderSibling_T2 "First born (0/1)"
label var D_OlderSibling_T0 "First born: missing"
label var D_JoinedKita_T2_2 "Kindergarten attendance (0/1)"
label var D_JoinedKita_T2_0 "Kindergarten attendance: missing"
label var C9 "Exposed to compulsory schooling reform (0(1))"
label var SSY_ "Exposed to short school years (0(1))"
label var RuralNEPSMZ "Born in rural municipality"


order yob mob female west RuralNEPSMZ bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2 D_JoinedKita_T2_0 C9 SSY_ 

putexcel set "$results\FullSample_descriptives.xlsx", modify

putexcel A11 = "Socio-demographic characteristics", bold


local i = 12
foreach var of varlist yob - SSY_ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

tabstat yob mob female west RuralNEPSMZ bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2 D_JoinedKita_T2_0 C9 SSY_ [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B12 = matrix(stats_all), nformat(number_d2)
putexcel B12:B37, nformat(number) overwritefmt


*** Educational Outcomes
putexcel A39 = "Educational Outcomes", bold


replace abi_sectrack = 0 if abi_sectrack == -99
replace abi_sectrack = 0 if abi_sectrack == .
replace abi_sectrack_max = 0 if abi_sectrack_max == -99
replace abi_sectrack_max = 0 if abi_sectrack_max == .

foreach var of varlist YOS_Sum aase {
cap drop `var'_outlier
centile(`var'), centile(0.5, 99.5)
gen `var'_outlier = ( `var' < r(c_1) | `var' > r(c_2) )

gen `var'_pct = `var' if `var'_outlier == 0

}
label var aase "School starting age"
label var aase_pct "School starting age (0.5 - 99.5 pct)"
label var abi_sectrack "Tracked to gymnasium (Anton; original version)"
label var abi_sectrack_max "Tracked to gymnasium (Anton; coded as highest track ever attended)"
label var acadt "Tracked to gymnasium (Kamila; original version)"
label var acadt_filled "Tracked to gymnasium (Kamila, missings coded as zero)"
label var YOS_Sum "Years of schooling"
label var hs1 "Highest school degree: basic"
label var rs1 "Highest school degree: middle"
label var abi "Highest school degree: high school"
label var uni "College/university degree"
label var aase "School starting age"
label var abi_sectrack "Tracked to gymnasium (Anton; original version)"
label var abi_sectrack_max "Tracked to gymnasium (Anton; coded as highest track ever attended)"
label var acadt "Tracked to gymnasium (Kamila; original version)"
label var acadt_filled "Tracked to gymnasium (Kamila, missings coded as zero)"
label var YOS_Sum "Years of schooling"
label var hs1 "Highest school degree: basic"
label var rs1 "Highest school degree: middle"
label var abi "Highest school degree: high school"
label var uni "College/university degree"

order aase  acadt_filled YOS_Sum  hs1 rs1 abi uni
local i = 40
foreach var of varlist aase - uni {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

tabstat aase  acadt_filled YOS_Sum  hs1 rs1 abi uni [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B40 = matrix(stats_all), nformat(number_d2)
putexcel B40:B51, nformat(number) overwritefmt



********************************************************************************
********************************************************************************
*** Descriptives: HERE: West Germany, YOB 1945 - 1964 (Column 2 of Table A.2)
********************************************************************************
********************************************************************************

use "$results\Descriptives_FullSample_Merged_final.dta", clear

*** Collapse and Make Means so everything is faster ***
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bl_birth kr_birth cohort w_t4_cal entry_y wave1 SSY_ Ei_T14 ///
female year mig_number_age mig_number_2555 mig_number_kr_age mig_number_kr_2555 ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign ///
dgr_max abi rs1 hs1 uni YOS_Sum  aase ///
metropol_birth mig_stock_metropol mig_flow1_metropol mig_flow5_metropol labour_birth mig_stock_labour mig_flow1_labour mig_flow5_labour ///
pendel_br_cond pendel_br_uncond pendel_kr_cond pendel_kr_uncond RuralNEPSMZ, by(ID_t age) 


*** Create Dummies for export *** 
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)

**********************************************
*** Further Limit Data Set to West Germany
**********************************************
keep if inrange(bl_birth, 1, 10)
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

*** Mobility
label var mig_stock "Lifetime cross-state"
label var mig_stock_kr "Lifetime cross-county"
label var mig_flow5 "5-year cross-state"
label var mig_flow5_kr "5-year cross-county"
label var mig_flow1 "1-year cross-state"
label var mig_flow1_kr "1-year cross-county"

order mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr mig_stock mig_stock_kr 

putexcel set "$results\WestGermany_descriptives.xlsx", replace

local i = 5
foreach var of varlist mig_flow1 - mig_stock_kr {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

putexcel A1 = "Descriptive Statistics (West Germany, Cohorts 1945 - 1964)"

putexcel B3 = "Number of obs."
putexcel C3 = "Mean"
putexcel D3 = "SD"
putexcel E3 = "Min"
putexcel F3 = "Max"

putexcel A4 = "Migration measures (mean at age 25-55)", bold


tabstat mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr mig_stock mig_stock_kr [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B5 = matrix(stats_all), nformat(number_d2)
putexcel B5:B10, nformat(number) overwritefmt


*** Sociodemographic characteristics
duplicates drop ID_t, force

replace p_yos_mean = . if p_yos_mean == 0
replace m_ageb4_T2 = . if m_ageb4_T2 == 0
replace p_gerborn_ha_new = 0 if p_gerborn_ha_new == -1

cap drop west
gen west = inrange(bl_birth,1,10)

tab bula, gen(bula_d)
*tab bula_T, gen(bula_d)

label var mob "Month of birth"
label var female "Women"
label var yob "Year of birth"
label var west "Born in West-Germany"
label var bula "Federal state of school entry"
label var bula_d1 "State: Schleswig-Holstein"
label var bula_d2 "State: Hamburg"
label var bula_d3 "State: Lower Saxony"
label var bula_d4 "State: Bremen"
label var bula_d5 "State: Northrhine-Westphalia"
label var bula_d6 "State: Hesse"
label var bula_d7 "State: Rhineland Palatinate"
label var bula_d8 "State: Baden-Wuerttemberg"
label var bula_d9 "State: Bavaria"
label var bula_d10 "State: Saarland"
label var p_yos_mean "Parental education (in yrs)"
label var p_yos_mean_m "Parental education: missing"
label var p_gerborn_ha_new "German parents (0/1)"
label var p_gerborn_ha_new_m  "German parents: missing"
label var m_ageb4_T2 "Maternal age at birth (in yrs)"
label var m_ageb4_T2_m "Maternal age at birth: missing"
label var D_OlderSibling_T2 "First born (0/1)"
label var D_OlderSibling_T0 "First born: missing"
label var D_JoinedKita_T2_2 "Kindergarten attendance (0/1)"
label var D_JoinedKita_T2_0 "Kindergarten attendance: missing"
label var C9 "Exposed to compulsory schooling reform (0(1))"
label var SSY_ "Exposed to short school years (0(1))"
label var RuralNEPSMZ "Born in rural municipality"


order yob mob female west RuralNEPSMZ bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2  D_JoinedKita_T2_0 C9 SSY_ RuralNEPSMZ

putexcel set "$results\WestGermany_descriptives.xlsx", modify

putexcel A11 = "Socio-demographic characteristics", bold


local i = 12
foreach var of varlist yob - SSY_ {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

tabstat yob mob female west RuralNEPSMZ bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2  D_JoinedKita_T2_0 C9 SSY_ [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B12 = matrix(stats_all), nformat(number_d2)
putexcel B12:B37, nformat(number) overwritefmt


*** Educational Outcomes

putexcel A39 = "Educational Outcomes", bold


replace abi_sectrack = 0 if abi_sectrack == -99
replace abi_sectrack = 0 if abi_sectrack == .
replace abi_sectrack_max = 0 if abi_sectrack_max == -99
replace abi_sectrack_max = 0 if abi_sectrack_max == .

foreach var of varlist YOS_Sum aase {
cap drop `var'_outlier
centile(`var'), centile(0.5, 99.5)
gen `var'_outlier = ( `var' < r(c_1) | `var' > r(c_2) )

gen `var'_pct = `var' if `var'_outlier == 0

}
label var aase "School starting age"
label var aase_pct "School starting age (0.5 - 99.5 pct)"
label var abi_sectrack "Tracked to gymnasium (Anton; original version)"
label var abi_sectrack_max "Tracked to gymnasium (Anton; coded as highest track ever attended)"
label var acadt "Tracked to gymnasium (Kamila; original version)"
label var acadt_filled "Tracked to gymnasium (Kamila, missings coded as zero)"
label var YOS_Sum "Years of schooling"
label var hs1 "Highest school degree: basic"
label var rs1 "Highest school degree: middle"
label var abi "Highest school degree: high school"
label var uni "College/university degree"
label var aase "School starting age"
label var abi_sectrack "Tracked to gymnasium (Anton; original version)"
label var abi_sectrack_max "Tracked to gymnasium (Anton; coded as highest track ever attended)"
label var acadt "Tracked to gymnasium (Kamila; original version)"
label var acadt_filled "Tracked to gymnasium (Kamila, missings coded as zero)"
label var YOS_Sum "Years of schooling"
label var hs1 "Highest school degree: basic"
label var rs1 "Highest school degree: middle"
label var abi "Highest school degree: high school"
label var uni "College/university degree"

order aase  acadt_filled YOS_Sum  hs1 rs1 abi uni
local i = 40
foreach var of varlist aase - uni {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

tabstat aase  acadt_filled YOS_Sum  hs1 rs1 abi uni [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B40 = matrix(stats_all), nformat(number_d2)
putexcel B40:B51, nformat(number) overwritefmt