/********************************************************************************
*			Life-cycle estimations for enrollment sample (for Figure A.12)


The figure itself has been produced locally after exporting the excel datasets
********************************************************************************/
use "$results\ssa_panel_all_neu.dta", clear
est drop _all


cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 


********************************************************************************
*age-specific estimations (moving averages)
********************************************************************************

clonevar age_avg3 = age

* Markieren der Altersjahre, aus denen der Mean gebildet werden soll 
foreach num of numlist 8(1)63 {
	local i = `num'-1
	local j = `num'+1
	recode age_avg3 (`i' `num' `j' = `num') (else = .), gen(avg3_`num')
	
}

*Check if outcomes available at specfic age
foreach num of numlist 8(1)63 {
	bys ID_t avg3_`num': gen avg_`num'_valid = inlist(migstock_kr_max,0,1) & inlist(migflow1_kr_max,0,1) & inlist(migflow5_kr_max,0,1) if avg3_`num' != . 
	
}

foreach num of numlist 8(1)63 {
	bys ID_t avg_`num'_valid: egen avg_`num'_valid_total = total(avg_`num'_valid) if avg_`num'_valid != .
}

*Generate age-specific outcome 
foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr { // 
	foreach num of numlist 8(1)63 {
	bys ID_t avg3_`num': egen `var'_avg3_`num'= mean(`var') if avg_`num'_valid_total == 3
	}
}
foreach var of varlist migstock migstock_kr migflow1 migflow1_kr migflow5 migflow5_kr {
	gen `var'_avg3 = .
		foreach num of numlist 8(1)63{
			replace `var'_avg3 = `var'_avg3_`num' if age == `num'
		}
}
			
sort ID_t age
drop avg3_8 - migflow5_kr_avg3_63

*Save dataset
save "$results\ssa_panel_avg3.dta", replace

	
*************LIFETIME MOBILITY
use "$results\ssa_panel_avg3.dta", clear
est drop _all
cap erase "$results\lifecycle_stock_bl_donut_avg3_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 8(1)63 {
	ivreg2 migstock_avg3 $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migstock_kr_max,0,1)	, robust partial($contr)	
	eststo stock_bl_`num' 	
	qui sum migstock_avg3 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_stock_cycle_donut_avg3_`num'.dta", replace) idnum(`num')
	restore
}


*results
esttab stock_bl_* using "$results\lifecycle_stock_bl_donut_avg3_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility stock - BL life cycle)")


*****create dataset for export
*BL
use "$results\temp\bl_stock_cycle_donut_avg3_8.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\temp\bl_stock_cycle_donut_avg3_`num'.dta"
	cap erase "$results\temp\bl_stock_cycle_donut_avg3_`num'.dta"
}
keep if parm == "1.after_week"
rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
export excel using "$results\temp\bl_stock_cycle_donut_avg3.xls", firstrow(variables) replace
save "$results\temp\bl_stock_cycle_donut_avg3.dta", replace
cap erase "$results\temp\bl_stock_cycle_donut_avg3_8.dta"




	
	
*************1-YEAR MOBILITY
use "$results\ssa_panel_avg3.dta", clear
est drop _all

cap erase "$results\lifecycle_flow1_bl_donut_avg3_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 8(1)63 {
	ivreg2 migflow1_avg3 $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow1_kr_max,0,1)	, robust partial($contr)	
	eststo flow1_bl_`num' 	
	qui sum migflow1_avg3 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_flow1_cycle_donut_avg3_`num'.dta", replace) idnum(`num')
	restore
}


*results
esttab flow1_bl_* using "$results\lifecycle_flow1_bl_donut_avg3_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow1 - BL life cycle)")

*****create dataset for export
*BL
use "$results\temp\bl_flow1_cycle_donut_avg3_8.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\temp\bl_flow1_cycle_donut_avg3_`num'.dta"
	cap erase "$results\temp\bl_flow1_cycle_donut_avg3_`num'.dta"
}
keep if parm == "1.after_week"
rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
save "$results\temp\bl_flow1_cycle_donut_avg3.dta", replace
export excel using "$results\temp\bl_flow1_cycle_donut_avg3.xls", firstrow(variables) replace
cap erase "$results\temp\bl_flow1_cycle_donut_avg3_8.dta"




	


*************5-YEAR MOBILITY
use "$results\ssa_panel_avg3.dta", clear
est drop _all



cap erase "$results\lifecycle_flow5_bl_donut_avg3_$date.csv"

keep if inrange(yob,1945,1964)
drop if inlist(run_week,-1,0,1,2)
*estimations
foreach num of numlist 8(1)63 {
	ivreg2 migflow5_avg3 $instr $lin_plain  [aw=w_t4_cal] 	if age == `num' & inlist(migflow5_kr_max,0,1)	, robust partial($contr)	
	eststo flow5_bl_`num' 	
	qui sum migflow5_avg3 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	preserve
	parmest, es(N) saving ("$results\temp\bl_flow5_cycle_donut_avg3_`num'.dta", replace) idnum(`num')
	restore
}


*results
esttab flow5_bl_* using "$results\lifecycle_flow5_bl_donut_avg3_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(mig_mean) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Mobility flow5 - BL life cycle)")


*****create dataset for export
*BL
use "$results\temp\bl_flow5_cycle_donut_avg3_8.dta", clear
foreach num of numlist 9(1)63 {
	append using "$results\temp\bl_flow5_cycle_donut_avg3_`num'.dta"
	cap erase "$results\temp\bl_flow5_cycle_donut_avg3_`num'.dta"
}
keep if parm == "1.after_week"
rename idnum age
rename min95 lo_ci
rename max95 up_ci
rename es_1 obs
save "$results\temp\bl_flow5_cycle_donut_avg3.dta", replace
export excel using "$results\temp\bl_flow5_cycle_donut_avg3.xls", firstrow(variables) replace
cap erase "$results\temp\bl_flow5_cycle_donut_avg3_8.dta"





	
	