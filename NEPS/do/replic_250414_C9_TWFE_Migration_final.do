/**************************************************
This file produces the main regression table (Table 3)

***************************************************/

************************************************
* define globals
************************************************
global family_new p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New ib1.JoinedKita_T2 ib1.OlderSibling_T2
global RuralVariable i.RuralNEPSMZ


************************************************
* Load and Clean
************************************************
 use "$results\C9_Combined_Utilized_Panel_final.dta", clear 

keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	drop if `var' == .
}

************************************************
* TWFE on Migration
************************************************
foreach var of varlist mig_flow1 mig_flow5 mig_stock mig_flow1_kr mig_flow5_kr mig_stock_kr {
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo pooled_c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
*W/o Bula
esttab pooled_c0_* using "$results\TWFE_`var'_Full_new_final.csv", keep(C9) cells(b(fmt(3) star) se(par fmt(3)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") replace 

esttab pooled_c1_* using "$results\TWFE_`var'_Full_new_final.csv", keep(C9) cells(b(fmt(3) star) se(par fmt(3)) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") append 

