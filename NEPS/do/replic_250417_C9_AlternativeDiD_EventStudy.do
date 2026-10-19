/**************************************************
This file provides results on the Wooldridge estimator
***************************************************/

*Install Packages
*ssc install did_imputation

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
xtset ID_t age

************************************************
* Limit Data-Set
************************************************
keep if inrange(yob, 1945, 1964)
keep if inrange(age, 25, 55)

************************************************ ************************************************
*** *** *** wooldid *** *** ***
************************************************ ************************************************

*** Mig_stock
wooldid mig_stock bula cohort Ei_T14 [aweight = w_t4_cal], cluster(ID_t) safety(off) espre(50) espost(50)

preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/84 {
	rename V`num' V`num'_
	egen V`num' = max(V`num'_)
}

keep if _n == 1
keep b* V*
drop bdate bula bl_birth V*_

* Reshape
gen ID = 1
reshape long b V, i(ID) j(Time)

* Make SE
gen se = sqrt(V)
gen ub = b + 1.96*se
gen lb = b - 1.96*se
gen event = _n - 42

keep if inrange(event, -25, 25) 
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash) ) xline(-1, lwidth(thin) lpattern(dash) ) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(,nogrid) xlab(,nogrid) ///
	title("Lifetime Mobility: State") ///
	legend(off) 

* Save Graph
graph save "Graph" "$results\Event_mig_stock.gph", replace
graph export "$results\Event_mig_stock.pdf", as(pdf) name("Graph") replace
gen var = "mig_stock_Wool"
save "$results\Dataset_Event_mig_stock.gph", replace
restore


