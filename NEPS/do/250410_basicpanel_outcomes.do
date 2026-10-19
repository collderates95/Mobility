************************************************
*    load basic panel
************************************************
use "$results\0_basicpanel.dta", clear
keep if yob>=1944 & yob<=1986
drop if casmin==-55 // 7 individuals

sort ID_t date

cap drop bl_birth2 
bysort ID_t: gen bl_birth2=bl_birth if _n==1

cap drop kr_birth2 
bysort ID_t: gen kr_birth2=kr_birth if _n==1


************************************************
*    Aggregate at age level // New in 2024/05/14
************************************************
*S* For Bula
sort ID_t age date
foreach var of varlist bl_interw bl_resid bl_sch bl_ausbild bl_emp bl_samp kr_interw kr_resid kr_sch kr_ausbild kr_emp {
	gen bulaexists=(`var'!=.)
	
by ID_t age: egen minbulaex=min(date) if bulaexists==1	
by ID_t age: gen firstbula=`var' if minbulaex==date
by ID_t age: egen f_`var'=max(firstbula) 

drop bulaexists minbulaex firstbula
}

*S* For Kreise
foreach var of varlist kr_interw kr_resid kr_sch kr_ausbild kr_emp {
	gen kreisexists=(`var'!=.)
	
by ID_t age: egen minkreisex=min(date) if kreisexists ==1	
by ID_t age: gen firstkreis=`var' if minkreisex==date
by ID_t age: egen f_`var'_2 = max(firstkreis) 

drop kreisexists minkreisex firstkreis
}

************************************************
*    Define state of residence
************************************************
egen bula_preint = rowfirst(bl_birth2 f_bl_interw f_bl_resid f_bl_sch f_bl_ausbild f_bl_emp) if (date < idate1) 	// bula before first interview
bysort ID_t: replace bula_preint = bula_preint[_n-1] if missing(bula_preint) & (date < idate1) 			// fill in missings before interview

gen bula_int = f_bl_interw if date >= idate1  					// bula at interview 
replace bula_int = f_bl_samp if bula_int == . & date == idate1 	// not all individuals contain information about bundesland at first interview -> replace with bl_samp

cap drop bula
clonevar bula = bula_preint
replace bula = bula_int if bula == . 
bysort ID_t: replace bula = bula[_n-1] if missing(bula) & (date > idate1) 	// fill in spells after first interview
replace bula=99 if date> idate99 											// all spells occuring after last interview

drop bula_preint bula_int 

label var bula "bula of residence"

************************************************
*  *S*  Define state of residence for Kreis
************************************************
*S* (date < idate1) zu (date <= idate1) geändert
cap drop kr_preint
* egen kr_preint = rowfirst (kr_birth2 f_kr_interw f_kr_resid f_kr_sch f_kr_ausbild f_kr_emp) if (date <= idate1) 	// kreis before first interview // De- Comment This For "basicalpanel_new.dta"
egen kr_preint = rowfirst (kr_birth2 f_kr_interw_2 f_kr_resid_2 f_kr_sch_2 f_kr_ausbild_2 f_kr_emp_2) if (date <= idate1) 	// Here: New! 2024 / 06 / 07 // De- Comment This For "basicalpanel_new_2.dta"
bysort ID_t: replace kr_preint = kr_preint[_n-1] if missing(kr_preint) & (date < idate1) 			// fill in missings before interview; some missings remain as we do not observe people from beginning of life


gen kr_int = f_kr_interw if date >= idate1  					// kreis at interview *S* Achtung: Fehlt per default im NEPS
*replace kr_int = kr_samp if kr_int == . & date == idate1 	// no information about kreis at first interview -> replace with kr_samp
replace kr_int = f_kr_resid if kr_int == . & date == idate1 	// not all individuals contain information about kreis at first interview -> fill in with other information
replace kr_int = f_kr_ausbild if kr_int == . & date == idate1 	
replace kr_int = f_kr_emp if kr_int == . & date == idate1 	


cap drop kreis
clonevar kreis = kr_preint
replace kreis = kr_int if kreis == . 
bysort ID_t: replace kreis = kreis[_n-1] if missing(kreis) // & (date > idate1)
*we do not observe the Kreis for first interview -> we just fill this information vertically from the last information prior to first interview (slightly different to Bundesland; but only for 9 individuals)	
replace kreis=99 if date> idate99 											// all spells occuring after last interview

drop kr_int //kreis_preint

label var kreis "kreis/district of residence"

************************************************
*    Define mobility measures
************************************************
*stock
cap drop mig_stock
gen mig_stock=bula!=bl_birth if bula!=.
replace mig_stock=99 if bula==99
label var mig_stock "lifetime mobility (vs. state of birth)"

*flow
cap drop mig_flow1
bysort ID_t: gen bula_pre12 = bula[_n-12] if date <= idate99  	// information on bula 12 months before
gen mig_flow1 = bula!=bula_pre12 if bula_pre12 != .
bysort ID_t: replace mig_flow1 = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1 = 99 if date > idate99			 // no info after last interview 
label var mig_flow1 "1-year mobility (vs. 12 months prior)"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on bula 60 months before
cap drop mig_flow5
bysort ID_t: gen bula_pre60 = bula[_n-60] if date <= idate99
gen mig_flow5 = bula!=bula_pre60 if bula_pre60 != .
bysort ID_t: replace mig_flow5 = 99 if age < 5 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow5 = 99 if date > idate99			 // no info after last interview 
label var mig_flow5 "5-year mobility (vs. 60 months prior)"

* number of moves 
bysort ID_t: gen mig_number_ = bula != bula[_n-1] 
bysort ID_t: replace mig_number_ = . if date > idate99 
bysort ID_t: replace mig_number_ = 0 if _n==1
bysort ID_t age: egen mig_number_age = total(mig_number_)
bysort ID_t age: replace mig_number_age = . if date > idate99 
bysort ID_t: egen mig_number_2555 = total(mig_number_) if inrange(age,25,55)
sort ID_t date

label var mig_number_ "=1, if bula different to bula in t-1"
label var mig_number_age "number of cross-state moves per year"
label var mig_number_2555 "number of cross-state moves in age range 25-55"

*S* drop bula_pre12 
drop bula_pre12 bula_pre60

*label variables and define dummies
lab def mig_def 0 "0: no mig" 1 "1: mig" 99 "99: no valid info", modify 

cap drop mig_stock1 - mig_flow5_kr4
foreach var of varlist mig_stock mig_flow1 mig_flow5 {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	


gen 	commute_bl_cond = . if  bl_emp == . & bula == .   
replace commute_bl_cond = 0 if (bula == bl_emp) & bl_emp != . & bula != .   
replace commute_bl_cond = 1 if (bula != bl_emp) & bl_emp != . & bula != .   

  
gen 	commute_bl_uncond = 0 if (bula == bl_emp) & bl_emp != . & bula != .   
replace commute_bl_uncond = 1 if (bula != bl_emp) & bl_emp != . & bula != . 
replace commute_bl_uncond = 0 if (bl_emp == . | bula == .)

************************************************
* Define mobility measures for Kreis
************************************************
*stock
cap drop mig_stock_kr
gen mig_stock_kr =kreis!=kr_birth if kreis!=.
replace mig_stock_kr =99 if kreis==99
label var mig_stock_kr "lifetime mobility (vs. kreis/district of birth)"

*flow
cap drop mig_flow1_kr
bysort ID_t: gen kreis_pre12 = kreis[_n-12] if date <= idate99  	// information on kreis 12 months before
gen mig_flow1_kr = kreis!=kreis_pre12 if kreis_pre12 != .
bysort ID_t: replace mig_flow1_kr = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1_kr = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_kr "1-mobility (vs. 12 months prior) for kreis/district"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_kr
bysort ID_t: gen kreis_pre60 = kreis[_n-60] if date <= idate99
gen mig_flow5_kr = kreis!=kreis_pre60 if kreis_pre60 != .
bysort ID_t: replace mig_flow5_kr = 99 if age < 5 					// not measurable for children ithin first year of their life
bysort ID_t: replace mig_flow5_kr = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_kr "5-year mobility (vs. 60 months prior) for kreis/district"

* number of moves 
bysort ID_t: gen mig_number_kr_ = kreis != kreis[_n-1] 
bysort ID_t: replace mig_number_kr_ = . if date > idate99 
bysort ID_t: replace mig_number_kr_ = 0 if _n==1
bysort ID_t age: egen mig_number_kr_age = total(mig_number_kr_)
bysort ID_t age: replace mig_number_kr_age = . if date > idate99 
bysort ID_t: egen mig_number_kr_2555 = total(mig_number_kr_) if inrange(age,25,55)
label var mig_number_kr_2555
sort ID_t date

label var mig_number_kr_ "=1, if kreis different to kreis in t-1"
label var mig_number_kr_age "number of cross-county moves per year"
label var mig_number_kr_2555 "number of cross-county moves in age range 25-55"

drop kreis_pre12 kreis_pre60

foreach var of varlist mig_stock_kr mig_flow1_kr mig_flow5_kr {
	label value `var' mig_def
	qui tab `var', gen(`var') mis
}	


gen 	commute_kr_cond = . if  kr_emp == . & kreis == .   
replace commute_kr_cond = 0 if (kreis == kr_emp) & kr_emp != . & kreis != .   
replace commute_kr_cond = 1 if (kreis != kr_emp) & kr_emp != . & kreis != .   

  
gen 	commute_kr_uncond = 0 if (kreis == kr_emp) & kr_emp != . & kreis != .   
replace commute_kr_uncond = 1 if (kreis != kr_emp) & kr_emp != . & kreis != . 
replace commute_kr_uncond = 0 if (kr_emp == . | kreis == .)

************************************************
*  *S*  Merge mobility measures for Labor Market regions
************************************************

***This dataset was created onsite and has to be requested at the Research Data Centre of the Leibniz Institute for Educational Trajectories (FDZ-LIfBi)
***After receipt it has to be manually copied to the folder "$results"
merge m:1 kreis using "$results\Merge_LabourMarketMetropol.dta" 
tab _merge
drop if _merge == 2
tab kreis if _merge == 1 & kreis != 99 & kreis != 0 
drop _merge
count 

foreach var in CountyNameIAB2021 MetropolName2021 LabourName2021 CountyName2021 {
	replace `var' = "Ausland" if kreis == 0
	replace `var' = "99: No valid info" if kreis == 99
}

foreach var in LabourNum2021 Metropol2021 LabourIAB2021 LongCounty LatCounty {
	replace `var' = 0 if kreis == 0
	replace `var' = 99 if kreis == 99
}

replace LabourNum2021 = 999 if LabourName2021 == "Main-Tauber-Kreis"


count if kreis == .
count if Metropol2021 == .
count if LabourNum2021 == .

count if kreis == 99
count if Metropol2021 == 99
count if LabourNum2021 == 99 

****************************** Labor market region ************************************

* Gen labour_birth
sort ID_t date
bysort ID_t: gen labour_birth_ = LabourNum2021 if (_n == 1 & kr_birth != .)
bysort ID_t: egen labour_birth = max(labour_birth_) 

*stock
cap drop mig_stock_labour
gen mig_stock_labour = LabourNum2021 != labour_birth if kreis != .
replace mig_stock_labour = 99 if LabourNum2021 == 99
label var mig_stock_labour "lifetime mobility (vs. labour market of birth)"

*flow
cap drop mig_flow1_labour
bysort ID_t: gen mig_flow1_labour_pre12 = LabourNum2021[_n-12] if date <= idate99  	// information on kreis 12 months before
gen mig_flow1_labour = LabourNum2021!= mig_flow1_labour_pre12 if mig_flow1_labour_pre12 != .
bysort ID_t: replace mig_flow1_labour = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1_labour = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_labour "1-mobility (vs. 12 months prior) for labour market"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_labour
bysort ID_t: gen mig_flow5_labour_pre60 = LabourNum2021[_n-60] if date <= idate99
gen mig_flow5_labour = LabourNum2021 != mig_flow5_labour_pre60 if mig_flow5_labour_pre60 != .
bysort ID_t: replace mig_flow5_labour = 99 if age < 5 					// not measurable for children ithin first year of their life
bysort ID_t: replace mig_flow5_labour = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_labour "5-year mobility (vs. 60 months prior) for labour market"

drop mig_flow1_labour_pre12 mig_flow5_labour_pre60 labour_birth_

foreach var of varlist mig_stock_labour mig_flow1_labour mig_flow5_labour {
	capture label value `var' mig_def
	capture qui tab `var', gen(`var') mis
}	

*** Quality Check ***
tab mig_stock_labour, m // slightly less mobility into labour markets than counties
tab mig_stock_kr, m


********************************* Metropol region ***********************************

* Gen metropol_birth
sort ID_t date
bysort ID_t: gen metropol_birth_ = Metropol2021 if (_n == 1 & kr_birth != .)
bysort ID_t: egen metropol_birth = max(metropol_birth_) 

*stock
cap drop mig_stock_metropol
gen mig_stock_metropol = Metropol2021 != metropol_birth if kreis != .
replace mig_stock_metropol = 99 if Metropol2021 == 99
label var mig_stock_metropol "lifetime mobility (vs. metropol region of birth)"

*flow
cap drop mig_flow1_metropol
bysort ID_t: gen mig_flow1_metropol_pre12 = Metropol2021[_n-12] if date <= idate99  	// information on kreis 12 months before
gen mig_flow1_metropol = Metropol2021 != mig_flow1_metropol_pre12 if mig_flow1_metropol_pre12 != .
bysort ID_t: replace mig_flow1_metropol = 99 if age == 0 					// not measurable for children within first year of their life
bysort ID_t: replace mig_flow1_metropol = 99 if date > idate99			 // no info after last interview 
label var mig_flow1_metropol "1-mobility (vs. 12 months prior) for metropol region"

*S* bysort ID_t: gen bula_pre12 = bula[_n-60] if date <= idate99  	// information on kreis 12 months before
cap drop mig_flow5_metropol
bysort ID_t: gen mig_flow5_metropol_pre60 = Metropol2021[_n-60] if date <= idate99
gen mig_flow5_metropol = Metropol2021 != mig_flow5_metropol_pre60 if mig_flow5_metropol_pre60 != .
bysort ID_t: replace mig_flow5_metropol = 99 if age < 5 					// not measurable for children ithin first year of their life
bysort ID_t: replace mig_flow5_metropol = 99 if date > idate99			 // no info after last interview 
label var mig_flow5_metropol "5-year mobility (vs. 60 months prior) for metropol region"

drop mig_flow1_metropol_pre12 mig_flow5_metropol_pre60 metropol_birth_

foreach var of varlist mig_stock_metropol mig_flow1_metropol mig_flow5_metropol {
	capture label value `var' mig_def
	capture qui tab `var', gen(`var') mis
}	

*** Quality Check ***
tab mig_stock_metropol, m // least mobility into metropolian areas !
tab mig_stock_labour, m
tab mig_stock_kr, m


************************Create outcomes on a person-age-level*******************

*migstock
sort ID_t date
bysort ID_t age: egen migstock =mean(mig_stock) 

sort ID_t date
bysort ID_t age: egen migstock_kr =mean(mig_stock_kr)
bysort ID_t age: egen migstock_kr_max =max(mig_stock_kr)

*migflow1
sort ID_t date
bysort ID_t age: egen migflow1 =mean(mig_flow1) 

sort ID_t date
bysort ID_t age: egen migflow1_kr =mean(mig_flow1_kr)
bysort ID_t age: egen migflow1_kr_max =max(mig_flow1_kr)

*migflow5
sort ID_t date
bysort ID_t age: egen migflow5 =mean(mig_flow5) 

sort ID_t date
bysort ID_t age: egen migflow5_kr =mean(mig_flow5_kr)
bysort ID_t age: egen migflow5_kr_max =max(mig_flow5_kr)


*commuting
sort ID_t date
bysort ID_t age: egen pendel_br_cond =mean(commute_bl_cond)
bysort ID_t age: egen pendel_br_uncond =mean(commute_bl_uncond)
bysort ID_t age: egen pendel_kr_cond =mean(commute_kr_cond)
bysort ID_t age: egen pendel_kr_uncond =mean(commute_kr_uncond)

label var pendel_br_cond "Commuting (across states, missings excluded)"
label var pendel_br_uncond "Commuting (across states, missings as 0)"
label var pendel_kr_cond "Commuting (across counties, missings excluded)"
label var pendel_kr_uncond "Commuting (across counties, missings as 0)"


* labor market regions

sort ID_t date
bysort ID_t age: egen migstock_labour =mean(mig_stock_labour) 
bysort ID_t age: egen migflow1_labour =mean(mig_flow1_labour) 
bysort ID_t age: egen migflow5_labour =mean(mig_flow5_labour) 


label var migstock_labour "Lifetime mobility (labor market regions)"
label var migflow1_labour "1 year mobility (labor market regions)"
label var migflow5_labour "5 year mobility (labor market regions)"

* metropol regions

sort ID_t date
bysort ID_t age: egen migstock_metropol =mean(mig_stock_metropol) 
bysort ID_t age: egen migflow1_metropol =mean(mig_flow1_metropol) 
bysort ID_t age: egen migflow5_metropol =mean(mig_flow5_metropol) 

label var migstock_metropol "Lifetime mobility (metropol regions)"
label var migflow1_metropol "1 year mobility (metropol regions)"
label var migflow5_metropol "5 year mobility (metropol regions)"


compress

