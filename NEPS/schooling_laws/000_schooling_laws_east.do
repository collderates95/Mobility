/*******************************************************************************
					Create schooling laws for East Germany
*******************************************************************************/


use "${results}\schooling_laws_west.dta", clear

keep if inrange(yob,1944,1994)
keep bdate yob mob bula

replace bula = 12 if bula == 1
replace bula = 13 if bula == 2
replace bula = 14 if bula == 3
replace bula = 15 if bula == 4
replace bula = 16 if bula == 5

drop if bula <= 11

label def bula 12 "12:Brandenburg" 13 "13:Meck-Vorpommern" 14 "14:Sachsen" 15 "15:Sachsen-Anhalt" 16 "16:Thüringen", modify
label val bula bula

* entry date
gen entry = . 
replace entry = mdy(09,01,yob+6) if mob <=5 & inrange(yob,1944,1984) // assumption - no changes until official fall apart of DDR
replace entry = mdy(09,01,yob+7) if mob >= 6 & inrange(yob,1944,1983) // assumption - no changes until official fall apart of DDR 

replace entry = mdy(08,01,yob+6) if mob <=6 & inrange(yob,1985,1994) // assumption: first change immediately after fall apart of DDR
replace entry = mdy(08,01,yob+7) if mob >= 7 & inrange(yob,1984,1994) // assumption: first change immediately after fall apart of DDR

replace entry = mdy(08,01,yob+6) if mob <= 8 & inrange(yob,1992,1994) & bula == 13 // shift in mecklenburg-Vorpommern
replace entry = mdy(08,01,yob+7) if mob >= 7 & inlist(yob,1991) & bula == 13 // shift in mecklenburg-Vorpommern
replace entry = mdy(08,01,yob+7) if mob >= 9 & inrange(yob,1992,1994) & bula == 13 // shift in mecklenburg-Vorpommern

replace entry = mdy(08,01,yob+7)  if mob == 6 & yob == 1984
format %tdD_m_CY entry

* year of entry
gen entry_y = year(entry)

* cohort size
gen en_size = 12
replace en_size = 13 if entry_y == 1991
replace en_size = 14 if bula == 13 & inrange(mob,7,12) & yob == 1991 // Mecklenburg-Vorpommern
replace en_size = 14 if bula == 13 & inrange(mob,1,8) & yob == 1992 // Mecklenburg-Vorpommern

* age at entry
gen age_entry=int((entry-bdate)/365)
gen age_entry_m=round(((entry-bdate)/365),0.01)

* identify cutoff date
sort bula bdate
bysort bula: gen jump = entry-entry[_n-1]
gen cut_=bdate if jump>0 & jump!=.
replace cut_=date("1/6/1943","DMY") if yob == 1944 & jump == .

bysort bula entry: egen cut=max(cut_)
format %td cut*
lab var cut "statut. cutoff for enrollment"
drop jump cut_

* relative age at enrollment
gen age_rel = (cut - bdate) / 365
lab var age_rel "age at school entry (relative to statut. cutoff)"


*gen birth date in monthly format
gen bdate_ =ym(yob, mob) 
format bdate_ %tm
lab var bdate_ "birth date (monthly format)"


clonevar first_day = cut
bysort bula (bdate): gen transition = first_day != first_day[_n+1]
bysort bula: gen last_day_ = first_day[_n+1]-1 if transition == 1
bysort bula entry: egen last_day = max(last_day_)
format last_day last_day_ %td
gen en_size_days = last_day - first_day + 1
replace en_size_days = 365 if en_size == 12 & (en_size_days < 0 | en_size_days == .) & yob == 1995
drop first_day transition last_day_ last_day

summarize

compress
save "${results}\schooling_laws_east.dta", replace










