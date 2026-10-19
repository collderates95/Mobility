/*
This file will produce all descriptives tables for the C9 -Reform (includes e.g. Data on SSA As Well)

Weighted For Compulsory Schooling Sample, cohorts 1944-1986. Table 1: Sample Means, Columns 3
*/

*Globals
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable RuralNEPSMZ

************************************************
* Full Sample
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear 
keep if inrange(age, 25, 55)

*Merge with Info on Schooling and SSA
joinby ID_t using "$results\educ_final.dta"

*Dummies for export:
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)

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

* Mobility
**
label var mig_stock "Lifetime cross-state"
label var mig_stock_kr "Lifetime cross-county"
label var mig_flow5 "5-year cross-state"
label var mig_flow5_kr "5-year cross-county"
label var mig_flow1 "1-year cross-state"
label var mig_flow1_kr "1-year cross-county"

order mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr mig_stock mig_stock_kr 

putexcel set "$results\C9_descriptives.xlsx", replace

local i = 5
foreach var of varlist mig_flow1 - mig_stock_kr {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

putexcel A1 = "Descriptive Statistics (C9 Estimation Sample)"

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
label var C9 "Exposed to compulsory schooling reform (0/1)"
label var SSY_ "Exposed to short school years (0(1))"
label var RuralNEPSMZ "Born in Rural Municipality (0/1)"


order yob mob female west RuralNEPSMZ bula_d1 - bula_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2_2 D_JoinedKita_T2_0 C9 SSY_

putexcel set "$results\C9_descriptives.xlsx", modify

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
putexcel B12:B38, nformat(number) overwritefmt


*** Educational Outcomes

putexcel A39 = "Educational Outcomes", bold


replace abi_sectrack = 0 if abi_sectrack == -99
replace abi_sectrack_max = 0 if abi_sectrack_max == -99

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


