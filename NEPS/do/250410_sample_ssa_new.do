/**************************************************
    Prepare sample for SSA analysis
	
	Author: A. Barabasch
	
	Version: 1.0, Created: 2022-03-01	
***************************************************/

************************************************
*    load basic panel
************************************************
use "$results\0_basicpanel_final.dta", clear

****************************************************
*  Create variable indicating state of school entry 
****************************************************
gen sbula1 = bl_birth // equated to state of birth
label var sbula1 "federal state of school entry (bula of birth)"

************************************************
*    merge institutional data (schooling laws)
************************************************
sort date
bys ID_t (date): gen bula6_ = bula if _n == 72
by ID_t (date): egen bula6 = max(bula6_)
by ID_t (date): gen bula10_ = bula if _n == 120
by ID_t (date): egen bula10 = max(bula10_)
by ID_t (date): gen bula14_ = bula if _n == 168
by ID_t (date): egen bula14 = max(bula14_)
drop bula6_ bula10_ bula14_

* bula of birth
rename bula bl_living
clonevar bula = bl_birth

merge m:1 bula yob mob using "$results\schooling_laws_final.dta" // merge institutional details
drop if _merge == 2  
drop _merge 
drop bula

foreach var of varlist entry - cutoff_week {
	rename `var' `var'_0
}

*bula at age 6
clonevar bula = bula6

merge m:1 bula yob mob using "$results\schooling_laws_final.dta" // merge institutional details
drop if _merge == 2  
drop _merge 
drop bula

foreach var of varlist entry - cutoff_week {
	rename `var' `var'_6
}


*bula at age 14
clonevar bula = bula14

merge m:1 bula yob mob using "$results\schooling_laws_final.dta" // merge institutional details
drop if _merge == 2  
drop _merge 
drop bula

foreach var of varlist entry - cutoff_week {
	rename `var' `var'_14
}

rename bl_living bula


************************************************
* Generate age at school entry
************************************************
cap drop bdate
gen bdate = mdy(mob,14,yob)
format %tdD_m_CY start_p bdate
gen aase = round(((start_sp1-bdate)/365),.01)
label var aase "age at school entry"


************************************************
* Create running variable
************************************************
*use "$results\ssa_panel.dta", clear

*create year-week of birth and based on this exact birth date
gen birth_week = yw(yob, wob)
format cutoff_week_6 birth_week %tw

gen birthdate = dofw(birth_week)
format birthdate %td

*identify last birth week within a school cohort 
gen last_week_6 = cut_6 + en_size_days_6
format last_week_6 %td
gen final_week_6 = yw(year(last_week_6),week(last_week_6))
format final_week_6 %tw
label var final_week_6 "last birth week within school entry cohort (directly before cutoff day) "

*identify first birth week of next school cohort 
gen first_week_next_6 = last_week_6 + 1
format first_week_next_6 %td
gen first_week_after_6 = yw(year(first_week_next_6),week(first_week_next_6))
format first_week_after_6 %tw
drop first_week_next_6

*identify last week of prior school cohort 
gen last_week_before_6 = cut_6
format last_week_before_6 %td
gen last_before_6 = yw(year(last_week_before_6),week(last_week_before_6))
format last_before_6 %tw


* create marker if individuls are born in cutoff week 
gen cutweek_born_6 = (birth_week == cutoff_week_6 & cutoff_week_6 == last_before_6) | (birth_week == final_week_6 & final_week_6 == first_week_after_6) // 
label var cutweek_born_6 "indicator for birth in cutoff week (if cutoff is overlapping from one to next month)"


* create running variable measured in weeks and in days
gen run_week_6 = birth_week - cutoff_week_6
tab run_week_6 // 3 individuals with negative value wrt run_week -> drop (reason for neg value: birth date according to week and according to month is contradicting) 
drop if run_week_6 < 0

gen run_days_6 = birthdate - cut_6 


****** create running_variable and after-dummy before conducting any changes
gen run_days_6_unchanged_ = birthdate - cut_6
clonevar run_days_6_unchanged = run_days_6_unchanged_
replace run_days_6_unchanged = run_days_6_unchanged-en_size_days_6 if run_days_6_unchanged>=en_size_days_6/2+1 & run_days_6_unchanged<=(en_size_days_6)
gen after_days_6_unchanged = .
replace after_days_6_unchanged = 1 if inrange(run_days_6_unchanged,1,182) 
replace after_days_6_unchanged = 0 if inrange(run_days_6_unchanged,-181,0)
local low=1
local high =7
cap drop run_week_unchanged
gen run_week_unchanged = . 
forvalues i = 1(1)26 {
	replace run_week_unchanged = `i' if inrange(run_days_6_unchanged,`low',`high') & after_days_6_unchanged == 1
	local low = `low'+7
	local high = `high'+7

}
replace run_week_unchanged = 26 if run_days_6_unchanged == 183

local low=-6
local high =0
forvalues i = 0(-1)-25 {
	replace run_week_unchanged = `i' if inrange(run_days_6_unchanged,`low',`high') & after_days_6_unchanged == 0
	local low = `low'-7
	local high = `high'-7
}
replace run_week_unchanged = -25 if run_days_6_unchanged == -182
gen after_week_unchanged = inrange(run_week_unchanged,1,26)
label var after_week_unchanged "born after cutoff (based on unchanged weekly running variable)"


*********************adjust running variable
tab after_6 if run_week_6 == 0 											// only people that are born directly after cutoff
replace birthdate = mdy(mob,1,yob) if after_6 == 1 & run_week_6 == 0 	// correction of birthdate 
replace run_days_6 = birthdate - cut_6 									// update running variable (measured in days)


*split running variable into two equal halfs
replace run_days_6 = run_days_6-en_size_days_6 if run_days_6>=en_size_days_6/2+1 & run_days_6<=(en_size_days_6)
gen after_days_6 = .
replace after_days_6 = 1 if inrange(run_days_6,1,182) 
replace after_days_6 = 0 if inrange(run_days_6,-181,0)

local low=1
local high =7
cap drop run_week
gen run_week = . 
forvalues i = 1(1)26 {
	replace run_week = `i' if inrange(run_days_6,`low',`high') & after_days_6 == 1
	local low = `low'+7
	local high = `high'+7

}
replace run_week = 26 if run_days_6 == 183

local low=-6
local high =0
forvalues i = 0(-1)-25 {
	replace run_week = `i' if inrange(run_days_6,`low',`high') & after_days_6 == 0
	local low = `low'-7
	local high = `high'-7
}
replace run_week = -25 if run_days_6 == -182
gen run_week2 = run_week*run_week
gen after_week = inrange(run_week,1,26)
label var after_week "born after cutoff (based on weekly running variable)"


save "$results\ssa_all_total_neu.dta", replace



************************************************
* Define edge weeks
************************************************
gen edgeweek = inlist(run_week,-25,26)


************************************************
* Define donut weeks
************************************************
gen donut = inlist(run_week,-1,0,1,2) 



************************************************
* Sample restrictions
************************************************
* applying to west and east


*drop if bl_birth == 11 // exclude individuals born in Berlin
keep if wob != . // exclude individuals without week of birth
keep if start_sp1 != . // exclude everyone with unknown age at school entry
drop if sbula_1 == -21 // exclude everyone with first school period abroad


*save dataset before excluding individuals that were born in east Germany 
save "$results\ssa_eastandwest_19441986_neu.dta", replace

preserve 
duplicates drop ID_t, force
save "$results\ssa_eastandwest_19441986_obs1_neu.dta", replace
restore

*restricting to west
keep if inrange(yob,1945,1964) // focus on birth cohorts from 1945-1964
keep if inrange(bula6,1,10) // exclude individuals not enrolled into school in West germany
keep if inrange(bl_birth,1,10) // exclude individuals not born in West germany
keep if inrange(run_week,-25,26) // drop edge weeks
save "$results\ssa_panel_neu.dta", replace



************************************************
* Save datasets
************************************************
use "$results\ssa_panel_neu.dta", replace

*all with mobility outcomes
preserve
keep if edgeweek == 0
keep if inrange(bula6,1,10)
keep if inrange(yob,1945,1964)


gen mig_samp = inlist(migstock_kr_max,0,1) & inlist(migflow1_kr_max,0,1) & inlist(migflow5_kr_max,0,1)


duplicates drop ID_t age, force 
compress
save "$results\ssa_panel_all_neu.dta", replace		// age_year

duplicates drop ID_t, force 
save "$results\ssa_panel_obs1_neu.dta", replace		// one observation per individual

restore