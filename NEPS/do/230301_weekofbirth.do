
****This dataset was specifically provided by the Research Data Centre and has to be requested


*****************Merging the week of birth ***************************
use "$results\SC6_pTarget_M_13-0-0_geburtswoche.dta", clear
sort ID_t wave
gen wob = t70000w 
label var wob "week of birth"

* Take response with highest frequency week of birth
bysort ID_t: egen wob_freq = mode(wob)
gen notident = wob_freq == . // some individuals wothout mode

* save individuals with mode
preserve 
keep if wob_freq != .
duplicates drop ID_t if notident == 0, force
save "$results\birthweek_clear.dta", replace
restore

* save individuals without mode
drop if notident == 0
gen valid = wob != .
drop if valid == 0
save "$results\birthweek_unclear.dta", replace

* main datset -> keep one obs per individual
use "$results\0_basicpanel.dta", clear
keep if yob>=1944 & yob<=1986
bysort ID_t: keep if _n==1
save "$results\basicpanel_n1.dta", replace

* merge according to yob & mob  
use "$results\birthweek_unclear.dta", clear
rename t70000y yob
rename t70000m mob
merge m:1 ID_t yob mob using "$results\basicpanel_n1.dta"
keep if _merge == 3
drop _merge
keep ID_t - valid


sort ID_t wave
duplicates drop ID_t, force // still some individuals with multiple observations; they are born in same month but have slight differences in week of birth -> take first reported values 
replace wob_freq = wob

append using "$results\birthweek_clear.dta"

drop wob
clonevar wob = wob_freq
label var wob "week of birth"

keep ID_t wob

save "$results\SC6_birthweek.dta", replace

