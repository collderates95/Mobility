************************Table A.1********************************



*****************Create cross-sectional data sets*************************

foreach num of numlist 2008 2011 { // 
use "$results\0_basicpanel_final.dta", clear
local x = `num'-55
local y = `num'-25


* Impose restrictions to ensure comparability with Microcensus
preserve
keep if inlist(year,`num')
keep if inrange(age,25,55)
keep if inrange(yob,`x',`y')

replace abi = 0 if inrange(casmin,0,4) & abi == .
replace abi = 1 if inrange(casmin,5,8) & abi == .

save "$results\neps_`num'.dta", replace
restore

}


****Produce descriptives

****2008

use "$results\neps_2008.dta", clear

cap drop migflow1
recode mig_flow1 (99=.) (0=0) (1=1), gen(migflow1)
label val migflow1 mig_def
label var migflow1 "1-year mobility (vs. 12 months prior)

preserve 
drop if w_t2_cal == 0
keep if migflow1 != .

** unweighted
est drop _all
sum migflow1 age yob mob female abi if w_t2_cal != 0
estpost sum migflow1 age yob mob female abi if w_t2_cal != 0
esttab . using "$results\neps2008_comparison_crosssectionweights.csv", append scsv cells("mean(fmt(3))sd(fmt(3)) min(fmt(1)) max(fmt(1)) count(fmt(0))")  nonumbers title("NEPS - 12 month mobility (2008 unweighted)")

** weighted
est drop _all
sum migflow1 age yob mob female abi [aweight=w_t2_cal] 
estpost sum migflow1 age yob mob female abi [aweight=w_t2_cal]
esttab . using "$results\neps2008_comparison_crosssectionweights.csv", replace scsv cells("mean(fmt(3))sd(fmt(3)) min(fmt(1)) max(fmt(1)) count(fmt(0))") nonumbers title("NEPS - 12 month mobility (2008 weighted)")


restore 
 




****2011
use "$results\neps_2011.dta", clear

cap drop migflow1
recode mig_flow1 (99=.) (0=0) (1=1), gen(migflow1)
label val migflow1 mig_def
label var migflow1 "1-year mobility (vs. 12 months prior)"

preserve 
drop if w_t4_cal == 0
keep if migflow1 != .

** unweighted
sum migflow1 age yob mob female abi if w_t4_cal != 0
estpost sum migflow1 age yob mob female abi if w_t4_cal != 0
esttab . using "$results\neps2011_comparison_crosssectionweights.csv", append cells("mean(fmt(3))sd(fmt(3)) min(fmt(1)) max(fmt(1)) count(fmt(0))") scsv nonumbers title("NEPS - 12 month mobility (2011 unweighted)")


** weighted
sum migflow1 age yob mob female abi [aweight=w_t4_cal] 
estpost sum migflow1 age yob mob female abi [aweight=w_t4_cal]
esttab . using "$results\neps2011_comparison_crosssectionweights.csv", replace cells("mean(fmt(3))sd(fmt(3)) min(fmt(1)) max(fmt(1)) count(fmt(0))") scsv nonumbers title("NEPS - 12 month mobility (2011 weighted)")


restore 
 









