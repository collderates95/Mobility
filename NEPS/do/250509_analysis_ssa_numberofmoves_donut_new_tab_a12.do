********************************************************************************
*			Table A.12 - number of moves
********************************************************************************
use "$results\ssa_panel_all_neu.dta", clear
est drop _all
cap erase "$results\SSA_numberofmoves_donut_neu_$date.csv"

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPSMZ

* sample restrictions
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)
keep if inrange(yob,1945,1964)


* one obs per individual
gen n1 = 1 if age == 40 
keep if n1 == 1

*** Outcomes

* dummy for having moved at least once
gen mig_number_2555_dummy = (mig_number_2555 > 0)
gen mig_number_kr_2555_dummy = (mig_number_kr_2555 > 0)

* create variabvles ln(y+1)
foreach var of varlist mig_number_2555 mig_number_kr_2555 {
cap drop `var'1 `var'_ln

* To correct for zeros, add 1 and take llogarithm afterwards 
gen `var'1 = `var'+1
gen `var'_ln1 = ln(`var'1)
drop `var'1 

* Take logarithm, if people have moved
*gen `var'1 = `var'+1 if `var' > 0
gen `var'_ln = ln(`var') if `var' > 0
*drop `var'1 

	
}
 

*estimations - plain specification (linear)
	preserve
	
	est drop _all

	* mig dummy - BL
	ivreg2 mig_number_2555_dummy $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_plain)	
	eststo bl_number_dummy	
	qui sum mig_number_2555_dummy [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			

	* mig number - BL
	ivreg2 mig_number_2555 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_plain)	
	eststo bl_number_total	
	qui sum mig_number_2555 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	* mig number (log) - BL
	ivreg2 mig_number_2555_ln1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_plain)	
	eststo bl_number_totallog
	qui sum mig_number_2555_ln1 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	* mig dummy - KR	
	ivreg2 mig_number_kr_2555_dummy $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_plain)	
	eststo kr_number_dummy		
	qui sum mig_number_kr_2555_dummy [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
		
	* mig number - KR	
	ivreg2 mig_number_kr_2555 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1, robust partial($lin_plain)	
	eststo kr_number_total		
	qui sum mig_number_kr_2555 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	* mig number (log) - KR	
	ivreg2 mig_number_kr_2555_ln1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1, robust partial($lin_plain)	
	eststo kr_number_totallog		
	qui sum mig_number_kr_2555_ln1 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	
	esttab bl_number_* kr_number_* using "$results\SSA_numberofmoves_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (no controls)") nodepvars mtitle("BL (ever moved)" "BL (number of moves)" "BL (log+1 number of moves)" "KR (ever moved)" "KR (number of moves)" "KR (log+1 number of moves)")	

	restore	

	
	
*estimations - full specification (linear)
	preserve
	
	est drop _all

	* mig dummy - BL
	ivreg2 mig_number_2555_dummy $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_full)	
	eststo bl_number_dummy	
	qui sum mig_number_2555_dummy [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			

	* mig number - BL
	ivreg2 mig_number_2555 $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_full)	
	eststo bl_number_total	
	qui sum mig_number_2555 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	* mig number (log) - BL
	ivreg2 mig_number_2555_ln1 $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_full)	
	eststo bl_number_totallog
	qui sum mig_number_2555_ln1 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			

	* mig dummy - KR	
	ivreg2 mig_number_kr_2555_dummy $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1 , robust partial($lin_full)	
	eststo kr_number_dummy		
	qui sum mig_number_kr_2555_dummy [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
		
	* mig number - KR	
	ivreg2 mig_number_kr_2555 $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1, robust partial($lin_full)	
	eststo kr_number_total		
	qui sum mig_number_kr_2555 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	* mig number (log) - KR	
	ivreg2 mig_number_kr_2555_ln1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1 & n1 == 1, robust partial($lin_plain)	
	eststo kr_number_totallog		
	qui sum mig_number_kr_2555_ln1 [aw=w_t4_cal]	 if mig_samp == 1 & n1 == 1
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if mig_samp == 1 & n1 == 1
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	

	
	esttab bl_number_* kr_number_* using "$results\SSA_numberofmoves_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (full controls)") nodepvars mtitle("BL (ever moved)" "BL (number of moves)" "BL (log+1 number of moves)" "KR (ever moved)" "KR (number of moves)" "KR (log+1 number of moves)")	
	

	restore	
