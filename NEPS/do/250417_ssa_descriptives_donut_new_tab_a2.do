******************TABLE A.2****************************


**** Mobility measures

use "$results\ssa_panel_all_neu.dta", clear // one observation per individual
drop if inlist(run_week,-1,0,1,2)

keep if w_t4_cal != 0
keep if edgeweek == 0
keep if inrange(age,25,55)
keep if inrange(yob,1945,1964)

*drop if migstock_kr_max == 99

*replace migstock = . if migstock_kr_max == 99
*replace migstock_kr = . if migstock_kr_max == 99


foreach var of varlist migstock migflow1 migflow5 migstock_kr migflow1_kr migflow5_kr {
	replace `var' = . if mig_samp == 0
}


label var migstock "Lifetime cross-state"
label var migstock_kr "Lifetime cross-county"
label var migflow5 "5-year cross-state"
label var migflow5_kr "5-year cross-county"
label var migflow1 "1-year cross-state"
label var migflow1_kr "1-year cross-county"


putexcel set "$results/ssa_descriptives_donut_neu_$date.xlsx", replace

order migstock migstock_kr migflow5 migflow5_kr migflow1 migflow1_kr 
local i = 5
foreach var of varlist migstock - migflow1_kr {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}

putexcel A1 = "Descriptive Statistics (SSA estimation sample)"

putexcel B3 = "Number of obs."
putexcel C3 = "Mean"
putexcel D3 = "SD"
putexcel E3 = "Min"
putexcel F3 = "Max"

putexcel A4 = "Migration measures (mean at age 25-55)", bold


tabstat migstock migstock_kr migflow5 migflow5_kr migflow1 migflow1_kr [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B5 = matrix(stats_all), nformat(number_d2)
putexcel B5:B10, nformat(number) overwritefmt




*** Sociodemographic characteristics

use "$results\ssa_panel_all_neu.dta", clear // one observation per individual
drop if inlist(run_week,-1,0,1,2)

keep if w_t4_cal != 0
keep if edgeweek == 0
keep if inrange(yob,1945,1964)
duplicates drop ID_t, force

replace p_yos_mean = . if p_yos_mean == 0
replace m_ageb4_T2 = . if m_ageb4_T2 == 0
replace p_gerborn_ha_new = 0 if p_gerborn_ha_new == -1

cap drop west
gen west = inrange(bl_birth,1,10)

tab bula6, gen(bula6_d)
/*foreach var of varlist bula6_d1 - bula6_d10 {
	local old_lab: var lab `var'
	local new_lab = subinstr(`"`old_lab'"', "bula6==", "",1)
	label var `var' `"`new_lab'"'
}
*/
label var mob "Month of birth"
label var female "Women"
label var yob "Year of birth"
label var west "Born in West-Germany"
label var bula6 "Federal state of school entry"
label var bula6_d1 "State: Schleswig-Holstein"
label var bula6_d2 "State: Hamburg"
label var bula6_d3 "State: Lower Saxony"
label var bula6_d4 "State: Bremen"
label var bula6_d5 "State: Northrhine-Westphalia"
label var bula6_d6 "State: Hesse"
label var bula6_d7 "State: Rhineland Palatinate"
label var bula6_d8 "State: Baden-Wuerttemberg"
label var bula6_d9 "State: Bavaria"
label var bula6_d10 "State: Saarland"
label var p_yos_mean "Parental education (in yrs)"
label var p_yos_mean_m "Parental education: missing"
label var p_gerborn_ha_new "German parent (0/1)"
label var p_gerborn_ha_new_m  "German parent: missing"
label var m_ageb4_T2 "Maternal age at birth (in yrs)"
label var m_ageb4_T2_m "Maternal age at birth: missing"
label var D_OlderSibling_T2 "First born (0/1)"
label var D_OlderSibling_T0 "First born: missing"
label var D_JoinedKita_T2 "Kindergarten attendance (0/1)"
label var D_JoinedKita_T0 "Kindergarten attendance: missing"
label var C9_6 "Exposed to compulsory schooling reform (0(1))"
label var SSY__6 "Exposed to short school years (0(1))"
label var RuralNEPSMZ "Born in rural area (< 20k)"



putexcel set "$results/ssa_descriptives_donut_neu_$date.xlsx", modify

putexcel A11 = "Socio-demographic characteristics", bold

order yob mob female west RuralNEPSMZ bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9_6 SSY__6 
local i = 12
foreach var of varlist yob - SSY__6 {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}



tabstat yob mob female west RuralNEPSMZ bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9_6 SSY__6  [aweight=w_t4_cal], stat(n mean sd min max) save
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
*label var aase_mis "School starting age: missing"
*label var aase_outlier "School starting age: < 0.5 pct | > 99.5 pct"
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
*label var YOS_Sum_mis "Years of schooling: missing"
label var YOS_Sum_pct "Years of schooling (0.5 - 99.5 pct)"
*label var YOS_Sum_outlier "Years of schooling: < 0.5 pct | > 99.5 pct"
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

tabstat aase acadt_filled YOS_Sum  hs1 rs1 abi uni [aweight=w_t4_cal], stat(n mean sd min max) save
matrix stats_all = r(StatTotal)'
putexcel B40 = matrix(stats_all), nformat(number_d2)
putexcel B40:B51, nformat(number) overwritefmt




