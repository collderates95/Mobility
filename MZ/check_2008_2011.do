/********************************************************************************************************************/
/*** I.  Check Erwachsene - Mobilität über BL hinweg 												  ***/
/********************************************************************************************************************/


/********************************************************************************************************************/
/*** a.Choice of variables and years	(2008 + 2011)												              ***/


foreach year of numlist 2008 2011 2011 { /***  			    	  ***/
	use EF1 EF12 EF44 EF46 EF47 EF48 EF310 EF366 EF451-EF453 EF455 EF951 EF952 ///
	using "$datenpfad\mz`year'_5015_2024.dta" , clear

				
/********************************************************************************************************************/
/*** b. Data preparation***/

clonevar bula = EF1
clonevar intq = EF12
clonevar age = EF44
clonevar sex = EF46
clonevar yob = EF47
clonevar mob = EF48
clonevar schooldgr = EF310
clonevar german = EF366
clonevar res_change = EF451
clonevar bula_prev_german = EF452
clonevar bula_old = EF453
clonevar bula_prev_foreign = EF455
clonevar gewicht`year' = EF952


numlabel _all, add
				
/********************************************************************************************************************/
/*** c. Sample restrictrions	  				  																  ***/

* German born
keep if german == 1

* Drop if not lived in germany 12 montha before
drop if inrange(bula_prev_foreign,1,999)

*Restrict to age range
local x = `year'-55
local y = `year'-25

keep if inrange(age,25,55)
keep if inrange(yob,`x',`y')


/********************************************************************************************************************/
/*** d. Zentrale Variablen			  																  ***/

* Federal state of current residency
gen bula_now = bula if inrange(bula,1,16)
label var bula_now "Bundesland (aktuell)"

* Federal state of residency 12 months ago
gen bula_prev = .
replace bula_prev = bula_now if inlist(res_change,1,9)
replace bula_prev = bula_old if res_change == 8 & inrange(bula_old,1,16)
label var bula_prev "Bundesland vor 12 Monaten (ohne Angabe = kein Umzug)"

gen bula_prev2 = .
replace bula_prev2 = bula_now if res_change == 1
replace bula_prev2 = bula_old if res_change == 8 & inrange(bula_old,1,16)
label var bula_prev2 "Bundesland vor 12 Monaten (ohne Angabe = missing)"


*Migration Dummies
gen mig12_v1 = bula_now!=bula_prev if !missing(bula_now, bula_prev)
label def mig12_v1 0 "nein" 1 "ja"
label val mig12_v1 mig12_v1
label var mig12_v1 "Bundeslandwechsel (im Vgl. zu 12 Monaten vorher; ohne Angabe als kein Umzug)"


gen mig12_v2 = bula_now!=bula_prev2 if !missing(bula_now, bula_prev2)
label def mig12_v2 0 "nein" 1 "ja"
label val mig12_v2 mig12_v2
label var mig12_v2 "Bundeslandwechsel (im Vgl. zu 12 Monaten vorher; ohne Angabe als missing)"

*Sociodeomgraohic characteristics
recode sex (1=0) (2=1), gen(female)
label var female "Weiblich"

recode schooldgr (1 2 3 6 7 9 . = 0) (4 5 = 1), gen(abi)
label var abi "Abitur"

label var age "Alter"
label var yob "Geburtsjahr"
label var mob "Geburtsmonat"

tab bula, gen(bula)

/********************************************************************************************************************/
/*** e. Save dataset			  																  ***/
save "$data_prep\mz`year'_prep.dta", replace



}


/********************************************************************************************************************/
/*** f. Create descriptive statistics seperately in two excel files																		*/


foreach year of numlist 2008 2011 {

use "$data_prep\mz`year'_prep.dta", clear

putexcel set "$results\mig12_`year'.xlsx", replace


**** ungewichtet

putexcel A1 = "Deskriptive Statistiken für das Jahr `year' (ungewichtet)"


putexcel J3 = "Mean"
putexcel K3 = "SD"
putexcel L3 = "N"

putexcel B2 = "Ohne Einschränkung" , bold
putexcel F2 = "Wenn mig12_v1 != ." , bold
putexcel J2 = "Wenn mig12_v2 != ." , bold

local i = 4
foreach var of varlist age yob mob female abi  {
	local colname: variable label `var'
	putexcel A`i' = "`colname'"
	local i `++i'
}


tabstat age yob mob female abi if mig12_v2 !=., stat(mean sd n) save
matrix stats_all = r(StatTotal)'
putexcel J4 = matrix(stats_all), nformat(#.###)


}
