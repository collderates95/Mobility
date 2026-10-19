********************************************************************************
*			Table A.10 - alternative inference methods
********************************************************************************
use "$results\ssa_panel_all_neu.dta", clear
est drop _all
cap erase "$results\SSA_robust_donut_standarderr_$date.csv"


* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 


keep if w_t4_cal != 0
drop if inlist(run_week,-1,0,1,2)


	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(ID_t) partial($lin_plain )	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain  [aw=w_t4_cal]	if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_plain   [aw=w_t4_cal]  	if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_plain [aw=w_t4_cal]  	if mig_samp == 1, cluster(ID_t) partial($lin_plain )	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain [aw=w_t4_cal]   if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_plain  [aw=w_t4_cal]  if mig_samp == 1	, cluster(ID_t) partial($lin_plain )	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_standarderr_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Baseline") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore	

	
	
************ a) SE clustered at the state level 


	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) partial($lin_plain )	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain  [aw=w_t4_cal]	if mig_samp == 1	, cluster(bula6) partial($lin_plain )	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_plain   [aw=w_t4_cal]  	if mig_samp == 1	, cluster(bula6) partial($lin_plain )	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_plain [aw=w_t4_cal]  	if mig_samp == 1, cluster(bula6) partial($lin_plain )	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain [aw=w_t4_cal]   if mig_samp == 1	, cluster(bula6) partial($lin_plain )	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_plain  [aw=w_t4_cal]  if mig_samp == 1	, cluster(bula6) partial($lin_plain )	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_standarderr_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("SE: bula") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore	

	

	
************ b) SE clustered at the birth date x state level 


	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	egen gruppe = group(bula6 yob mob)
	
	ivreg2 migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(gruppe) partial($lin_plain )	
	eststo bl_flow1_plain		
	qui sum migflow1 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5 $instr $lin_plain  [aw=w_t4_cal]	if mig_samp == 1	, cluster(gruppe) partial($lin_plain )	
	eststo bl_flow5_plain		
	qui sum migflow5 [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	

	ivreg2 migstock $instr $lin_plain   [aw=w_t4_cal]  	if mig_samp == 1	, cluster(gruppe) partial($lin_plain )	
	eststo bl_stock_plain		
	qui sum migstock [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv			
	
	ivreg2 migflow1_kr $instr $lin_plain [aw=w_t4_cal]  	if mig_samp == 1, cluster(gruppe) partial($lin_plain )	
	eststo kr_flow1_plain		
	qui sum migflow1_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		
	
	ivreg2 migflow5_kr $instr $lin_plain [aw=w_t4_cal]   if mig_samp == 1	, cluster(gruppe) partial($lin_plain )	
	eststo kr_flow5_plain		
	qui sum migflow5_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv	
	
	ivreg2 migstock_kr $instr $lin_plain  [aw=w_t4_cal]  if mig_samp == 1	, cluster(gruppe) partial($lin_plain )	
	eststo kr_stock_plain		
	qui sum migstock_kr [aw=w_t4_cal]	 if e(sample)	
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	qui estadd scalar Indiv		

	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_standarderr_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) stats(N Indiv mig_mean, fmt(0 0 3)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("SE: bula x bdate") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore		
	

************* c) Wildcluster SE	

	preserve
	keep if inrange(age,25,55)
	keep if inrange(yob,1945,1964)
	est drop _all

	
	eststo bl_flow1_plain: wildbootstrap regress migflow1 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: bl_flow1_plain	
	qui estadd scalar boot_pval: bl_flow1_plain
	qui estadd scalar boot_ci_lb: bl_flow1_plain
	qui estadd scalar boot_ci_ub: bl_flow1_plain

	
	eststo bl_flow5_plain: wildbootstrap regress migflow5 $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)
	distinct ID_t if e(sample)	
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: bl_flow5_plain	
	qui estadd scalar boot_pval: bl_flow5_plain
	qui estadd scalar boot_ci_lb: bl_flow5_plain
	qui estadd scalar boot_ci_ub: bl_flow5_plain	
	
	eststo bl_stock_plain: wildbootstrap regress migstock $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)
	distinct ID_t if e(sample)	
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: bl_stock_plain	
	qui estadd scalar boot_pval: bl_stock_plain
	qui estadd scalar boot_ci_lb: bl_stock_plain
	qui estadd scalar boot_ci_ub: bl_stock_plain		
	
	eststo kr_flow1_plain: wildbootstrap regress migflow1_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: kr_flow1_plain	
	qui estadd scalar boot_pval: kr_flow1_plain
	qui estadd scalar boot_ci_lb: kr_flow1_plain
	qui estadd scalar boot_ci_ub: kr_flow1_plain	
	
	eststo kr_flow5_plain: wildbootstrap regress migflow5_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: kr_flow5_plain	
	qui estadd scalar boot_pval: kr_flow5_plain
	qui estadd scalar boot_ci_lb: kr_flow5_plain
	qui estadd scalar boot_ci_ub: kr_flow5_plain	
		
	eststo kr_stock_plain: wildbootstrap regress migstock_kr $instr $lin_plain  [aw=w_t4_cal] 	if mig_samp == 1, cluster(bula6) rseed(12345)	
	distinct ID_t if e(sample)
	scalar Indiv = r(ndistinct)
	scalar boot_pval = e(wboot)[1,3]
	scalar boot_ci_lb = e(wboot)[1,4]
	scalar boot_ci_ub = e(wboot)[1,5]
	qui estadd scalar Indiv: kr_stock_plain	
	qui estadd scalar boot_pval: kr_stock_plain
	qui estadd scalar boot_ci_lb: kr_stock_plain
	qui estadd scalar boot_ci_ub: kr_stock_plain		
	
	
	esttab bl_* kr_*  using "$results\SSA_robust_donut_standarderr_$date", append scsv keep(1.after_week) cells(b(fmt(3) star)) stats(boot_pval boot_ci_lb boot_ci_ub N Indiv, labels("p-value" "95%-KI Lower Bound" "95%-KI Upper Bound" "Obs" "N-Personen") fmt(3 3 3 0 0)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("wildcluster") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr" "KR 5 yrs" "KR lifetime")

	restore	
	
	
	
	
	
	