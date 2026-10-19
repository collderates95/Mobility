********************************************************************************
*			compliers (Table A.4)
********************************************************************************
use "$results\ssa_panel_all_neu.dta", clear // one observation per individual
drop if inlist(run_week,-1,0,1,2)

keep if w_t4_cal != 0
keep if edgeweek == 0
keep if inrange(yob,1945,1964)
duplicates drop ID_t, force



*complier defintiion
gen year_act = year(start_sp1)
gen year_entry = year(entry_6)
gen complier = year_act ==  year_entry



****Sociodemographics
replace p_yos_mean = . if p_yos_mean == 0
replace m_ageb4_T2 = . if m_ageb4_T2 == 0
replace p_gerborn_ha_new = 0 if p_gerborn_ha_new == -1

cap drop west
gen west = inrange(bl_birth,1,10)

tab bula6, gen(bula6_d)

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
label var D_OlderSibling_T2 "First born: yes"
label var D_OlderSibling_T0 "First born: missing"
label var D_JoinedKita_T2 "Kindergarten attendance (0/1)"
label var D_JoinedKita_T0 "Kindergarten attendance: missing"
label var C9_6 "Exposed to compulsory schooling reform (0(1))"
label var SSY__6 "Exposed to short school years (0(1))"
label var RuralNEPSMZ "Born in rural area (< 20k)"



************* Means for compliers and non-compliers and calculation of difference

putexcel set "$results/ssa_compliers_$date.xlsx", replace

putexcel A1 = "Complier characteristics", bold
putexcel B3 = "Compliers (regular enrolment)"
putexcel C3 = "Non-compliers (early/late enrolment)"
putexcel D3 = "Difference"


order female yob bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 RuralNEPSMZ SSY__6 
local i = 4
foreach var of varlist female - SSY__6 {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


local i = 4
foreach var of varlist female yob bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 RuralNEPSMZ SSY__6   { 

sum `var' [aweight=w_t4_cal] if complier == 1 
matrix define A_`i' = `r(mean)'
sum `var' [aweight=w_t4_cal] if complier == 0
matrix define B_`i' = `r(mean)'
matrix define C_`i' = A_`i'[1,1] - B_`i'[1,1]

mat define full_`i' = A_`i', B_`i', C_`i'
	
local i = `++i'	
}

foreach num of numlist 4(1)27 {
	putexcel B`num' = matrix(full_`num'), nformat(#.##)
}


************* Run regressions (coefficient identifies the difference in means) and afterwards adjust with "rwolf2" the p-values for MHT


est drop _all
foreach var of varlist female yob bula6_d1 - bula6_d10 p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m D_OlderSibling_T2 D_OlderSibling_T0 D_JoinedKita_T2  D_JoinedKita_T0 C9_6 SSY__6 RuralNEPSMZ  { // aase acadt_filled YOS_Sum hs1 rs1 abi uni
	eststo complier_`var': reg `var' complier [aweight=w_t4_cal], robust
	
		
}

	esttab complier_* using "$results\SSA_complier_donut_reg_$date", replace scsv keep(complier) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (no controls)") nodepvars 	// unwbl_* unwkr_*
	
	
	
	
#delimit ;	
rwolf2 	(reg female complier [aweight=w_t4_cal], robust)	
		(reg yob complier [aweight=w_t4_cal], robust)
		(reg bula6_d1 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d2 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d3 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d4 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d5 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d6 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d7 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d8 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d9 complier [aweight=w_t4_cal], robust)		
		(reg bula6_d10 complier [aweight=w_t4_cal], robust)		
		(reg p_yos_mean complier [aweight=w_t4_cal], robust)		
		(reg p_yos_mean_m complier [aweight=w_t4_cal], robust)
		(reg p_gerborn_ha_new complier [aweight=w_t4_cal], robust)
		(reg p_gerborn_ha_new_m complier [aweight=w_t4_cal], robust)		
		(reg m_ageb4_T2 complier [aweight=w_t4_cal], robust)		
		(reg m_ageb4_T2_m complier [aweight=w_t4_cal], robust)				
		(reg D_OlderSibling_T2 complier [aweight=w_t4_cal], robust)	
		(reg D_OlderSibling_T0 complier [aweight=w_t4_cal], robust)			
		(reg D_JoinedKita_T2  complier [aweight=w_t4_cal], robust)	
		(reg D_JoinedKita_T0  complier [aweight=w_t4_cal], robust)	
		(reg RuralNEPSMZ complier [aweight=w_t4_cal], robust)
		(reg SSY__6 complier [aweight=w_t4_cal], robust), indepvars(complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier, complier) usevalid reps(1000) seed(256874);	

		
#delimit cr


putexcel set "$results/ssa_compliers_$date.xlsx", modify
putexcel E3 = "p-val (adjusted for mht)"

matrix list e(RW)
matrix M = e(RW)
matrix M3 = M[1..24, 3] 
putexcel E4 = matrix(M3) 
