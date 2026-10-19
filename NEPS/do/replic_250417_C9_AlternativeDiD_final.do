/**************************************************
Wooldridge estimator for Panel D of Table A.9
***************************************************/

*Install Packages
*ssc install did_imputation

************************************************
* define globals
************************************************
* Some DiD-Packages do not like i. - prefix, therefore define new globals
global family_new_DiD p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m
global Siblings_Kita_New_DiD JoinedKita_T2 OlderSibling_T2
global RuralVariable_IMP RuralNEPSMZ


************************************************
*    load final panel
************************************************
use "$results\C9_Combined_Utilized_Panel_final.dta", clear
sort ID_t age
xtset ID_t age


************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)


************************************************ ************************************************
*** *** *** wooldid *** *** ***
************************************************ ************************************************
*  wooldid y i t ttre [if] [aw/pw=weights]
* Need:
* ssc install reghdfe
* ssc install ftools
* ssc install gtools
* ssc install ppmlhdfe
* help wooldid


**********************************************************Panel D of Table A.9


foreach var in mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr {
	display("`var'")
	wooldid `var' bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) att safety(off) // automatically drops AT! // Safety Off necessary for using aweights!
	eststo e_`var'
	qui sum `var' [aweight = w_t4_cal] if e(sample)
	scalar mig_mean = r(mean)
	qui estadd scalar mig_mean
}

esttab e_* using "$results\C9_WoolDiD.csv", cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Wooldridge (2021) Estimator Used. Weighted!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") replace

*/esttab e_* using "$results\C9_AllCombined.csv", cells(b(fmt(3) star) se(par)) stats(mig_mean N N_clust, labels("Y-Mean" "Obs" "Indiv")) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("Wooldridge (2021) Estimator Used. Weighted!") nodepvars mtitle("1: mig_stock " "2: mig_flow1" "3: mig_flow5" "4: mig_stock_kr" "5: mig_flow1_kr" "6: mig_flow5_kr") append */

eststo clear
