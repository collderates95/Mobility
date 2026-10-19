**************Table 4************************************************

use "$results\ssa_panel_all_neu.dta", clear
est drop _all
cap erase "$results\SSA_maintable_donut_neu_$date.csv"

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPSMZ

**Restrictions
keep if w_t4_cal != 0
gen n1 = 1 if age == 40 
drop if inlist(run_week,-1,0,1,2)



*Panel A
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	
	est drop _all

	
	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	ivreg2 migflow1_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	
	ivreg2 migstock_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	
	
	
	esttab bl_* kr_* using "$results\SSA_maintable_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (no controls)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime" )	

	restore	

	
	
*Panel B
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 migflow1 $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_full)	
	eststo bl_flow1_full		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo bl_flow5_full		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo bl_stock_full		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_full)	
	eststo kr_flow1_full		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo kr_flow5_full		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_full  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_full)	
	eststo kr_stock_full		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	
	esttab bl_* kr_* using "$results\SSA_maintable_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends (full controls)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL (number of moves)" "KR 1 yr" "KR 5 yrs" "KR lifetime" ) //  

	restore	

