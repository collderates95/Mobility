*********************Figure A.7***************************************

****This file produces the means for Fig A.7
*** The figure is absed on these numbers and was created locally


**********************1944-1986*************************************************
use "$results\ssa_eastandwest_19441986_obs1_neu.dta", clear

cap drop entry_year_act entry_year_exp compliers
gen entry_year_act = year(start_sp1)
gen entry_year_exp = year(entry_6) 
gen compliers = entry_year_act == entry_year_exp
tab compliers 

gen early = (entry_year_act < entry_year_exp)
gen regular = (entry_year_act == entry_year_exp)
gen late = (entry_year_act > entry_year_exp)

*school enrollment in West Germany
preserve
keep if inlist(entry_year_act,1976,1980,1985,1990)
keep if inrange(bula6,1,10)
keep if inrange(bl_birth,1,10)
keep if w_t4_cal != 0


gen N = 1
collapse early regular late (count) N [aweight = w_t4_cal], by(entry_year_act)
tabstat early regular late N, by(entry_year_act) nototal save format(%9.3f)
return list
putexcel set "$results\enrolment_neu_$date.xlsx", replace
putexcel I2 = "early"
putexcel J2 = "regular"
putexcel K2 = "late"
putexcel L2 = "N"
putexcel H1 = "School enrolment (WEST Germany; 1944 - 1986; weighted)"
putexcel I4 = matrix(r(Stat2))
putexcel I3 = matrix(r(Stat1))
putexcel I5 = matrix(r(Stat3))
putexcel I6 = matrix(r(Stat4))

restore



								