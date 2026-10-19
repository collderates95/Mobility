/*******************************************************************************
Produces the results for the different clustering of SE in Table A.9

*******************************************************************************/ 

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ


************************************************
* Load and Clean
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear // From "250413_Combine_C9_final.do"

keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

************************************************
* Baseline: Pooled estimations
************************************************
foreach var of varlist mig_flow1 mig_flow5 mig_stock mig_flow1_kr mig_flow5_kr mig_stock_kr {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	/**i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean */
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results\TWFE_SE_Robustness.csv", keep(C9) cells(b(fmt(3) star) se(par fmt(3)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Baseline: SE clustered on ID_t") mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr"  "KR 5 yrs" "KR lifetime")  replace 
eststo clear

	
	
************************************************
* SE: Cluster Bula
************************************************
foreach var of varlist mig_flow1 mig_flow5 mig_stock mig_flow1_kr mig_flow5_kr mig_stock_kr {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(bula) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	/*
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(bula) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean */
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results\TWFE_SE_Robustness.csv", keep(C9) cells(b(fmt(3) star) se(par fmt(3)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Cluster Bula") mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr"  "KR 5 yrs" "KR lifetime") append
eststo clear
	
	
************************************************
* SE: Bula x mob x yob
************************************************
egen ClusterGroupBulaYobMob = group(bula yob mob)

foreach var of varlist mig_flow1 mig_flow5 mig_stock mig_flow1_kr mig_flow5_kr mig_stock_kr {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ClusterGroupBulaYobMob) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	/* *i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(ClusterGroupBulaYobMob) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean */
	}
	
*Estout
*W/o Bula
esttab pooled_* using "$results\TWFE_SE_Robustness.csv", keep(C9) cells(b(fmt(3) star) se(par fmt(3)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Cluster Bula x Bdate") mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr"  "KR 5 yrs" "KR lifetime") append
eststo clear
	

************************************************
* SE: Wildcluster SE - Bula
************************************************	
foreach var of varlist mig_flow1 mig_flow5 mig_stock mig_flow1_kr mig_flow5_kr mig_stock_kr {
	*i) No additional Controls
	eststo bl_`var'_0: areg `var' C9 i.bula [aweight = w_t4_cal], cluster(bula) absorb(cohort)
	boottest C9, boottype(wild) cluster(bula) svmat(t) nograph
	
	scalar zstat = r(z)
	scalar boot_pval = r(p)
	scalar boot_ci_lb = r(CI)[1,1]
	scalar boot_ci_ub = r(CI)[1,2]
	qui estadd scalar zstat: bl_`var'_0
	qui estadd scalar boot_pval: bl_`var'_0
	qui estadd scalar boot_ci_lb: bl_`var'_0
	qui estadd scalar boot_ci_ub: bl_`var'_0
	
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	/* *i) Baseline Regression (With Optimized Vars from Balancing Tests)
	eststo bl_`var'_1: areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(bula) absorb(cohort)
	boottest C9, boottype(wild) cluster(bula) svmat(t) nograph
	
	scalar zstat = r(z)
	scalar boot_pval = r(p)
	scalar boot_ci_lb = r(CI)[1,1]
	scalar boot_ci_ub = r(CI)[1,2]
	qui estadd scalar zstat: bl_`var'_1
	qui estadd scalar boot_pval: bl_`var'_1
	qui estadd scalar boot_ci_lb: bl_`var'_1
	qui estadd scalar boot_ci_ub: bl_`var'_1
	
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean */
	
	}
	
*Estout
esttab bl_* using "$results\TWFE_SE_Robustness_WildCluster.csv", replace scsv keep(C9) cells(b(fmt(3) star) se(par) p) stats(boot_pval boot_ci_lb boot_ci_ub N Indiv, labels("p-value" "95%-KI Lower Bound" "95%-KI Upper Bound" "Obs" "N-Personen") fmt(3 3 3 0 0)) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Wildcluster Boottest") nodepvars mtitle("BL 1 yr" "BL 5 yrs" "BL lifetime" "KR 1 yr"  "KR 5 yrs" "KR lifetime")
eststo clear



	
	
	
	
	