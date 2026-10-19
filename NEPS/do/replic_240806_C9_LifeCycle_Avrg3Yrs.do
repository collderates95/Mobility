/*******************************************************************************
This file produces and visualizes the lifecycle results
*******************************************************************************/

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ

*** Load .dta ***
use "$results\C9_Combined_Full_Panel.dta", clear // From "231030_Combine_C9.do"
keep if inrange(yob, 1945, 1964)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}



sort ID_t age
keep if inrange(age, 7, 64)

*** Generate Moving Averages ***
bysort ID_t: egen maxAge = max(age)
bysort ID_t: egen minAge = min(age)

foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr { 
	egen MA_`var' = ma(`var')
	sort ID_t age
	bysort ID_t: replace MA_`var' = . if age == maxAge
	bysort ID_t: replace MA_`var' = . if age == minAge
}

save "$results\C9_Panel_Avrg3.dta", replace


************************************************
* TWFE on Migration
************************************************
use "$results\C9_Panel_Avrg3.dta", clear
keep if inrange(age, 8, 63)

*** Mig_Stock Bula***
est drop _all
cap erase 

foreach num of numlist 8(1)63 {

	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg MA_mig_stock C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo MA_mig_stock_`num'
	qui sum MA_mig_stock [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results\mig_stock_`num'_Avrg3.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab MA_mig_stock_* using "$results\Lifecycle_Avrg3_mig_stock.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Stock - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results\mig_stock_8_Avrg3.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\mig_stock_`num'_Avrg3.dta"
	cap erase "$results\mig_stock_`num'_Avrg3.dta"
}
export excel using "$results\mig_stock_ALL_Avrg3.xls", firstrow(variables) replace
save "$results\Lifecycle_mig_stock_ALL_Avrg3.dta", replace
capture erase "$results\mig_stock_5_Avrg3.dta"
restore


**Produce graph (original graph from figure A.12 was produced locally, this is just an example)
preserve
use "$results\Lifecycle_mig_stock_ALL_Avrg3.dta", clear	
	keep if parm == "C9"

	rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
	
	keep if inrange(age,8,63)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.15(0.05)0.15)) ylabel(-0.15(0.05)0.15, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_stock_cycle_donut_avg3_C9", replace
	graph export "$graphs\bl_stock_cycle_donut_avg3_C9.pdf", as(pdf) replace	
restore




********************************************************************************
*** Mig_Flow 1 Bula ***
********************************************************************************
est drop _all
cap erase 

foreach num of numlist 8(1)63 {

	*i) Baseline Regression 
	areg MA_mig_flow1 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo MA_mig_flow1_`num'
	qui sum MA_mig_flow1 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results\mig_flow1_`num'_Avrg3.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab MA_mig_flow1_* using "$results\Lifecycle_Avrg3_mig_flow1.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 1 Yr - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results\mig_flow1_8_Avrg3.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\mig_flow1_`num'_Avrg3.dta"
	cap erase "$results\mig_flow1_`num'_Avrg3.dta"
}
export excel using "$results\mig_flow1_ALL_Avrg3.xls", firstrow(variables) replace
save "$results\Lifecycle_mig_flow1_ALL_Avrg3.dta", replace
capture erase "$results\mig_flow1_5_Avrg3.dta"
restore

**Produce graph (original graph from figure A.12 was produced locally, this is just an example)
preserve
use "$results\Lifecycle_mig_flow1_ALL_Avrg3.dta", clear	
	keep if parm == "C9"

	rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
	
	keep if inrange(age,8,63)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.15(0.05)0.15)) ylabel(-0.15(0.05)0.15, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow1_cycle_donut_avg3_C9", replace
	graph export "$graphs\bl_flow1_cycle_donut_avg3_C9.pdf", as(pdf) replace	

restore




********************************************************************************
*** Mig_Flow 5 Bula ***
********************************************************************************
est drop _all
cap erase 

foreach num of numlist 8(1)63 {

	*i) Baseline Regression 
	areg MA_mig_flow5 C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal] if age == `num', cluster(ID_t) absorb(cohort)
	eststo MA_mig_flow5_`num'
	qui sum MA_mig_flow5 [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	preserve
	parmest, es(N) saving("$results\mig_flow5_`num'_Avrg3.dta", replace) idnum(`num')
	restore
	
	}
	
*Save Results
esttab MA_mig_flow5_* using "$results\Lifecycle_Avrg3_mig_flow5.csv", append scsv keep(C9) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility Flow 5 Yr - State Life Cycle)")

*** *** Create Dataset for export *** ***
preserve
use "$results\mig_flow5_8_Avrg3.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\mig_flow5_`num'_Avrg3.dta"
	cap erase "$results\mig_flow5_`num'_Avrg3.dta"
}
export excel using "$results\mig_flow5_ALL_Avrg3.xls", firstrow(variables) replace
save "$results\Lifecycle_mig_flow5_ALL_Avrg3.dta", replace
capture erase "$results\mig_flow5_5_Avrg3.dta"
restore


**Produce graph (original graph from figure A.12 was produced locally, this is just an example)
preserve
use "$results\Lifecycle_mig_flow5_ALL_Avrg3.dta", clear	
	keep if parm == "C9"

	rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
	
	keep if inrange(age,8,63)

	sum obs if age <= 64
	local min1 = r(min)
	local max1 = r(max)		
	twoway 	(rarea lo_ci up_ci age if age <= 64, fcolor(gs8%25) lcolor(%0)) ///
			(line estimate age if age <= 64, lcolor(gs0)), ///
			scheme(s1mono) legend(off) ///
			xtitle("age") xscale(range(0(5)65)) xlabel(0(5)65, labsize(small)) xline(25, lcolor(gs8)) ///
			ytitle("all") yscale(range(-0.15(0.05)0.15)) ylabel(-0.15(0.05)0.15, labsize(small)) yline(0, lcolor(red)) ///
			title("1945-1964", size(small)) ///
			note("min obs: `min1'; max obs: `max1'")
	graph save "$graphs\bl_flow5_cycle_donut_avg3_C9", replace
	graph export "$graphs\bl_flow5_cycle_donut_avg3_C9.pdf", as(pdf) replace	
restore
