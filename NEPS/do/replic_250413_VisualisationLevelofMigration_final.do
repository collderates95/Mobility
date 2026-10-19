/**************************************************
  This file will use the final Panel Data Set and produce very beautifull Graphs(both, Bula and Kreis)
  For: Figure 1 (Age-Specific cross-state and cross-county mobility rates)
*/

********************************************************************************
* Weighted [MZ 2011] Collapse At The Start
********************************************************************************
use "$results\Descriptives_FullSample_Merged_Visualize_final.dta", clear 
sort ID_t date

*Use font Times New Roman
graph set window fontface "Times New Roman"

*** Collapse and Make Means so everything is faster ***
collapse (mean) yob mob date bdate ///
mig_stock mig_flow1 mig_flow5 mig_stock_kr mig_flow1_kr mig_flow5_kr /// 
C9 stime bula bula_T bl_birth cohort entry_y wave1 SSY_ ///
female RuralNEPSMZ ///
m_ageb4_T2 m_ageb4_T2_m p_yos_mean p_yos_mean_m p_gerborn_ha_new p_gerborn_ha_new_m fam15 ///
JoinedKita_T2 OlderSibling_T2 D_OlderSibling_T0 D_OlderSibling_T1 D_OlderSibling_T2 D_JoinedKita_T0 D_JoinedKita_T1 D_JoinedKita_T2 ///
abi_sectrack_max abi_sectrack acadt acadt_filled sch_ausland start_foreign ///
dgr_max abi rs1 hs1 uni YOS_Sum  yos_max yoe_grade aase casmin [aweight = w_t4_cal], by(ID_t age) 


*** Create Dummies for export *** 
gen D_JoinedKita_T2_0 = (JoinedKita_T2 == 0)
gen D_JoinedKita_T2_1 = (JoinedKita_T2 == 1)
gen D_JoinedKita_T2_2 = (JoinedKita_T2 == 2)
 
*** Age - Wise *** 
*create means
foreach var in mig_stock mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
	preserve
	collapse (mean) `var' , by (age)
	save "$results\graph_mean_age_`var'_MZ11.dta", replace
	restore
}

*combine to one dataset
use "$results\graph_mean_age_mig_stock_MZ11.dta", clear
foreach var in mig_stock_kr mig_flow1 mig_flow1_kr mig_flow5 mig_flow5_kr {
 merge 1:1 age using "$results\graph_mean_age_`var'_MZ11.dta"
 drop _merge
 replace `var' = 0 if `var' == .
 erase "$results\graph_mean_age_`var'_MZ11.dta"
}

*save final data set
save "$results\graph_mean_age_mig_MZ11.dta", replace
use "$results\graph_mean_age_mig_MZ11.dta", clear

*** *** Ready for export (special, consistent design) *** ***
* Use dataset
use "$results\graph_mean_age_mig_MZ11.dta", clear
sort age

keep if inrange(age, 7, 64)

*Graphs
*For flow
twoway area mig_flow1_kr mig_flow1 age, ///
 xtitle(" ") ytitle(" ") title("{stSerif: (a) 1-year mobility}", color(black) size(medsmall)) xlabel(7 (5) 62, nogrid) ylabel(, glstyle(grid)) ///
 legend(label(1 "Mobility County") label(2 "Mobility State")) legend(off) legend(size(small)) ///
 graphregion(color(white)) color(gs6 gs0) legend(size(medsmall)) saving("$graphs/Area_Mig_age_Flow1_MZ11", replace)

*For flow5
twoway area mig_flow5_kr mig_flow5 age, ///
 xtitle(" ") ytitle(" ") title("{stSerif: (b) 5-year mobility}", color(black) size(medsmall)) xlabel(7 (5) 62, nogrid) ylabel(,glstyle(grid)) ///
 legend(label(1 "Mobility County") label(2 "Mobility State")) legend(off) legend(size(small)) ///
 graphregion(color(white)) color(gs6 gs0) legend(size(medsmall)) saving("$graphs/Area_Mig_age_Flow5_MZ11", replace)

 
 *For mig_stock
 twoway area mig_stock_kr mig_stock age, ///
 xtitle(" ") ytitle(" ") title("{stSerif: (c) Lifetime mobility}", color(black) size(medsmall)) xlabel(7 (5) 62, nogrid) ylabel(, glstyle(grid)) ///
 legend(label(1 "{stSerif: Cross-County}") label(2 "{stSerif: Cross-State}")) legend(on) legend(size(small)) ///
 graphregion(color(white)) color(gs6 gs0) legend(size(medsmall)) legend(ring(0) pos(4) bmargin(zero)) saving("$graphs/Area_Mig_age_Stock_MZ11", replace)
 
*All Combined
graph combine "$graphs/Area_Mig_age_Flow1_MZ11" "$graphs/Area_Mig_age_Flow5_MZ11" "$graphs/Area_Mig_age_Stock_MZ11", title(" ", size(small)) ///
graphregion(color(white)) scheme(s1mono) cols(1) iscale(0.7) imargin(tiny)

graph display, ysize(12) xsize(9)
graph save "$graphs/Area_Mig_age_Combined_MZ11", replace asis
graph export "$graphs/Area_Mig_age_Combined_MZ11.png", replace
graph export "$graphs/Area_Mig_age_Combined_MZ11.pdf", as(pdf) replace