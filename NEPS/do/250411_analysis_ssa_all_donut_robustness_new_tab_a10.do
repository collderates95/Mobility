********************************************************************************
*			Table A.10 - robustness (Panel A to I)
********************************************************************************
use "$results\ssa_panel_all_neu.dta", clear
est drop _all
cap erase "$results\SSA_robust_donut_neu_$date.csv"

cap drop run_week2 
gen run_week2 = run_week*run_week

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPSMZ
global lin_early run_week i.after_week#c.run_week i.kann_6
global lin_student run_week i.after_week#c.run_week t_wo_lehrer
global quad_plain run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2
global quad_full run_week i.after_week#c.run_week run_week2 i.after_week#c.run_week2 i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2 SSY__6 i.RuralNEPSMZ


global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2

*sample restriction
keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)



*Panel A: student teacher ratio (assign at age 6, 10 and 14)
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week  

	foreach num of numlist 6 {
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	clonevar jahr = yob
	replace jahr = jahr + `num'
	clonevar bula1 = bula`num'
	
	merge m:1 jahr bula1 using "$ratio/zeitreihen3.dta", keepusing(t_wo_lehrer)
	drop if _merge == 2
	
	ivreg2 migflow1 $instr $lin_student  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_student)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_student  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_student)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock $instr $lin_student [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_student)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	ivreg2 migflow1_kr $instr $lin_student  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_student)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_student  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_student)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock_kr $instr $lin_student  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_student)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Linear trends + student teacher ratio at age `num'") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore		
	}		



	
*Panel B: cutoff-FE

preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all
	
	ivreg2 migflow1 $instr $lin_plain i.cutm_6 [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain i.cutm_6  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock $instr $lin_plain i.cutm_6  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_plain i.cutm_6  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain i.cutm_6 [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_plain i.cutm_6  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_plain i.cutm_6)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("cutoff-FE") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

restore			
	
	




	
*Panel C:  quadratic
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 migflow1 $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($quad_plain )	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_plain )	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_plain )	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($quad_plain )	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_plain )	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $quad_plain   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_plain )	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Quadratic trends (no controls)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore		


*Panel D:  quadratic + controls

	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	ivreg2 migflow1 $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($quad_full )	
	eststo bl_flow1_full		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_full )	
	eststo bl_flow5_full		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_full )	
	eststo bl_stock_full		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		


	ivreg2 migflow1_kr $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($quad_full )	
	eststo kr_flow1_full		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_full )	
	eststo kr_flow5_full		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $quad_full   [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($quad_full )	
	eststo kr_stock_full		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
		
	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Quadratic trends (full controls)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")		

	restore	


	
******Panel E: non-parametric (robust results are relevant)	
preserve 	
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	drop if w_t4_cal == 0
	keep if mig_samp == 1

cap drop donut
gen donut = inlist(run_week,-1,0,1,2)
	
	est drop _all
	
foreach var of varlist migflow1 migflow5 migstock   {  // 
	eststo bl_rdrobust_`var': 		rdrobust `var' run_week if donut == 0, kernel(uniform) c(1) p(1) weights(w_t4_cal) vce(cluster ID_t) masspoints(check) all
	qui sum `var' [aw=w_t4_cal]	 if e(sample) & donut == 0		
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample) & donut == 0	
	scalar Indiv = r(ndistinct)			
	qui estadd scalar Indiv		
	scalar cutoff_left = e(b_l)
	qui estadd scalar cutoff_left			
	scalar cutoff_right = e(b_r)
	qui estadd scalar cutoff_right		
	
	scalar rd_robpval = e(pv_rb)
	scalar rd_robci_lb = e(ci_l_rb)
	scalar rd_robci_ub = e(ci_r_rb)
	qui estadd scalar rd_robpval
	qui estadd scalar rd_robci_lb
	qui estadd scalar rd_robci_ub	
}

 	
foreach var of varlist migflow1_kr migflow5_kr migstock_kr  {
	eststo kr_rdrobust_`var': 		rdrobust `var' run_week if donut == 0, kernel(uniform) c(1) p(1) weights(w_t4_cal) vce(cluster ID_t) masspoints(check) all
	qui sum `var' [aw=w_t4_cal]	 if e(sample) & donut == 0	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample) & donut == 0
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	scalar cutoff_left = e(h_l)
	qui estadd scalar cutoff_left			
	scalar cutoff_right = e(h_r)
	qui estadd scalar cutoff_right		
	
	scalar rd_robpval = e(pv_rb)
	scalar rd_robci_lb = e(ci_l_rb)
	scalar rd_robci_ub = e(ci_r_rb)
	qui estadd scalar rd_robpval
	qui estadd scalar rd_robci_lb
	qui estadd scalar rd_robci_ub
}


esttab bl_rdrobust_* kr_rdrobust_* using "$results\SSA_robust_donut_neu_$date", append scsv cells(b(fmt(3) star) se(par) p) stats(rd_robpval rd_robci_lb rd_robci_ub cutoff_left cutoff_right mig_mean N Indiv  , labels("Robust p-value" "Robust 95%-KI Lower Bound" "Robust 95%-KI Upper Bound" "Bandwidth left" "Bandwidth right" "Mean of Y" "Obs." "N-Persons")  fmt(3 3 3 0 0 3 0 0)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RD robust") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")
restore		
	
	
	
*Panel F - 20 weeks bandwidth
foreach num of numlist 20 {
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	keep if inrange(run_week,-`num',`num')
	est drop _all

	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain)	
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

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Bandwidth from -`num' to `num'") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")	

	restore		
}		
	
	

*Panel G: incl. donut hole (full sample)

preserve
use "$results\ssa_panel_all_neu.dta", clear

cap drop run_week2 
gen run_week2 = run_week*run_week

keep if w_t4_cal != 0

	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain)	
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
	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Full sample ") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

restore	
		
	
	

*Panel H: unweighted 
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

tab mob, gen()	
	
	ivreg2 migflow1 $instr $lin_plain   	if mig_samp == 1, cluster(ID_t) partial($lin_plain )	
	eststo bl_flow1_plain		
	qui sum migflow1 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain		if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo bl_flow5_plain		
	qui sum migflow5 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_plain    	if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo bl_stock_plain		
	qui sum migstock	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_plain  	if mig_samp == 1, cluster(ID_t) partial($lin_plain )	
	eststo kr_flow1_plain		
	qui sum migflow1_kr  if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain   if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo kr_flow5_plain		
	qui sum migflow5_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_plain   if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo kr_stock_plain		
	qui sum migstock_kr 	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("unweighted (main specification)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore		
	
	
** Panel I: placebo cutoff - 6 months
	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	drop if inrange(run_week,-1,2)
	
	gen run_week_donut = .
	foreach num of numlist 3(1)25 {
		replace run_week_donut = run_week - 27 if run_week == `num' // new values = -24 to -2
	} 
	foreach num of numlist -24(1)-2 {
		replace run_week_donut = run_week + 27 if run_week == `num' // new values = 3 to 25
	}

	gen after_week_donut = inrange(run_week_donut,3,25)
tab run_week_donut run_week
tab run_week after_week_donut
tab run_week_donut after_week_donut



est drop _all
global lin_placebo run_week_donut i.after_week_donut#c.run_week_donut
global instr  i.after_week_donut
	

	ivreg2 migflow1 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_placebo  [aw=w_t4_cal] 	if mig_samp == 1	, cluster(ID_t) partial($lin_placebo)	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	esttab bl_* kr_*  using "$results\SSA_robust_donut_neu_$date", append scsv keep(1.after_week_donut) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Donut sample (placebo cutoff shifted by 6 months)") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")
	
restore				
	
	
	