**************Table 2************************************************


** Load dataset with one observation
use "$results\ssa_panel_obs1_neu.dta", clear

estimates drop _all

* define globals
global instr i.after_week
global lin_plain run_week i.after_week#c.run_week 
global lin_full run_week i.after_week#c.run_week i.female i.bula6 i.yob  p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m m_ageb4_T2 m_ageb4_T2_m ib1.JoinedKita_T2 ib1.OlderSibling_T2  SSY__6 i.RuralNEPSMZ

***** Restrictions
keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0 
drop if inlist(run_week,-1,0,1,2)

****** Generate/label variables
label var aase "SSA (orig)"

* old for grade
gen entry_year_act = year(start_sp1)
gen older = entry_year_act >= yob +7 & entry_year_act != .
label var older "Old for grade"


**** 1st Stage results - maintable
cap erase "${results}\ssa_1ststage_maintable_neu_$date.csv"
estimates drop _all
foreach var of varlist aase older acadt_filled { //

qui ivreg2 `var' $instr $lin_plain [aw=w_t4_cal],  robust partial($lin_plain)  //  2011 weighted
estimates store lin_plain_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value 

qui ivreg2 `var' $instr $lin_full [aw=w_t4_cal],  robust partial($lin_full)  //  2011 weighted
estimates store lin_full_`var'
qui sum `var' [aw=w_t4_cal] if e(sample)
scalar y_mean=r(mean) 
scalar F_value = e(F)
qui estadd scalar y_mean 
qui estadd scalar F_value
}
*local name: variable label `var'
esttab lin_plain_* using "$results\ssa_1ststage_maintable_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression without controls") nodepvars mtitle("School starting age" "Old for grade" "Academic track") 

esttab lin_full_* using "$results\ssa_1ststage_maintable_neu_$date", append scsv keep(1.after_week) cells(b(fmt(3) star) se(par) p) scalar(y_mean F_value) starlevels(* 0.1 ** 0.05 *** 0.01) stardetach title("RDD regression without controls") nodepvars mtitle("School starting age" "Old for grade" "Academic track")



