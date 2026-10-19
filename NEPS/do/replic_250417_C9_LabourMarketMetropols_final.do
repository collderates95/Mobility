/**************************************************
This file will do the TWFE-Regressions for Mobility out of (and within) Labour Markets and Metropolian Areas


***************************************************/

************************************************
* define globals
************************************************
global family_new_DiD p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_DiD JoinedKita_T2 OlderSibling_T2
global RuralVariable_IMP RuralNEPSMZ

************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear
sort ID_t age
* xtset ID_t age


************************************************
*    Regression
************************************************
foreach var of varlist mig_flow1_labour mig_flow5_labour mig_stock_labour mig_flow1_metropol mig_flow5_metropol mig_stock_metropol {
	
	*i) No additional Controls
	areg `var' C9 i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo c0_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
esttab c* using "$results\TWFE_C9_LabourMetropol_Full.csv", cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") keep(C9) replace // scalar(mig_mean)
esttab c* using "$results\TWFE_C9_LabourMetropol_Full.xslx", cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") keep(C9) replace 

eststo clear

foreach var of varlist mig_flow1_labour mig_flow5_labour mig_stock_labour mig_flow1_metropol mig_flow5_metropol mig_stock_metropol {
	
	*i) Baseline Regression (With Optimized Vars from Balancing Tests)
	areg `var' C9 female $family_new $Siblings_Kita_New $RuralVariable SSY_ i.bula [aweight = w_t4_cal], cluster(ID_t) absorb(cohort)
	eststo c1_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
	}
	
*Estout
esttab c* using "$results\TWFE_C9_LabourMetropol_Full.csv", cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") keep(C9) append 
esttab c* using "$results\TWFE_C9_LabourMetropol_Full.xslx", cells(b(fmt(3) star) se(par) p) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("`var'") addnotes("") keep(C9) append
eststo clear