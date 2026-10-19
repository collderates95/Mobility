/**************************************************
This file provides results on the standard TWFE estimations
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

************************************************
* Prepare Time-Variables
************************************************

*** Rel-Time != Ei_T14
bysort bula cohort: gen reltime = cohort - Ei_T14
tab reltime

* gen lead
bysort bula cohort: gen lead = reltime if reltime < 0
recode lead (0 =.)
bysort bula cohort: replace lead = -lead
tab lead, gen(lead)
recode lead* (.=0)
rename lead1 ref 
* gen lag
bysort bula cohort: gen lag = reltime if reltime >= 0
tab lag, gen(lag)

sum lag 
forvalues num = 1/250 {
	local j = `num'-1
	rename lag`num' lag`j'
}
recode lag* (.=0)

drop lag lead

************************************************ ************************************************
*** *** *** TWFE *** *** ***
************************************************ ************************************************
*** Mig_stock
reg mig_stock lead* lag* [aweight = w_t4_cal], cluster(ID_t) // same as xtreg
ereturn list

*** ***
preserve
ereturn list
svmat e(b), names(b)
svmat e(V), names(V)

forvalues num = 1/365 {
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
keep if inrange(Time,1,26) | inrange(Time,115,139)

gen event = _n
replace event = event * (-1) if event < 27
sort event
replace event = event +26 if event < 27 
sort event

replace event = event -1 if event > 25 
replace event = event -25 
sort event



keep if inrange(event, -25, 25) 
replace b = . if event == -1
replace se = . if event == -1
replace ub = . if event == -1
replace lb = . if event == -1
replace V = . if event == -1

* Graph
twoway ///
	(rcap ub lb event, lcolor(gs8)) ///
	(scatter b event, mcolor(black) msymbol(0)), ///
	yline(0, lwidth(thin) lpattern(dash)) xline(-1, lwidth(thin) lpattern(dash)) ///
	xtitle("Event Time (Reform)") ///
	ytitle("ATT") ylab(-0.6 (0.2) 0.6 ,nogrid) xlab(,nogrid) ///
	title("Lifetime Mobility: State") ///
	legend(off) yscale(range(-0.2 0.05 0.2))
	

* Save Graph and dataset
graph save "Graph" "$results\Event_TWFE_mig_stock.gph", replace
graph export "$results\Event_TWFE_mig_stock.pdf", as(pdf) name("Graph") replace
gen var = "mig_stock"
save "$results\Dataset_Event_TWFE_mig_stock.gph", replace
restore
