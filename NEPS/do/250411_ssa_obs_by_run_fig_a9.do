******************Fig A.9****************************


**** Number of observations per week of birth relative to cutoff is displayed
**** Figure A.9 is based on these numbers, but was created locally!


use "$results\ssa_panel_obs1_neu.dta", clear		


keep if w_t4_cal != 0
keep if inrange(yob,1945,1964)

preserve
gen N = 1
collapse (count) N, by(run_week_unchanged)
export excel using "$results\obs_by_runorig.xls", firstrow(variables) replace
restore



**************Density test is performed -> computes the p-value in the note of Fig A.9
preserve

keep if inrange(yob,1945,1964)
keep if w_t4_cal != 0

*weighted
putexcel set "$results\rddensity_full_neu.xlsx", replace

putexcel A1 = "RD density - Full (one observation)"

putexcel B3 = "Left of cutoff"
putexcel C3 = "Right of cutoff"
putexcel A4 = "Number of observations"
putexcel A5 = "Effective number of observations"
putexcel A6 = "p-value"

rddensity run_week_unchanged, c(1) 
matrix density = e(N_l) , e(N_r) \ e(N_h_l) , e(N_h_r) \ e(pv_q), . 
putexcel B4 = matrix(density)
restore