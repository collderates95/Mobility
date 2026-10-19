***** Information about school education on basis of Biography-File and spSchool
use "$data\SC6_Biography_R_13-0-0.dta", clear
merge 1:m ID_t splink using "$data\SC6_spSchool_R_13-0-0.dta"

keep if _merge == 3
drop _merge

keep if subspell == 0
sort ID_t splink

gen day = 14


*** years of schooling 
recode ts11209 (1 6 7 = 8) (3=10) (2=9) (4=12) (5=13) (else = .), gen(yos)
bysort ID_t: egen yos_max=max(yos)  // ca. 500 Personen ohne valide Angaben
label var yos_max "years of schooling (highest degree)" 
recode yos_max (9 .=8)


*** state of schooling
clonevar sbula=ts11202_g2
recode sbula (-98 -97 -55=.)
replace sbula=-21 if sbula==-54 & ts11103_g1==2 // if missing by design and abroad -> code as abroad
replace sbula=. if sbula==-54 & ts11103_g1<1 // unknown
replace sbula=-21 if ts11103_g1==2 // abroad

* state of first school spell 
sort ID_t splink
bysort ID_t: gen sbula_sp1_=sbula if _n==1
bysort ID_t: egen sbula_sp1=min(sbula_sp1_)
lab var sbula_sp1 "state of 1st school spell"

bysort ID_t: egen sbula_1=max(sbula_sp1)
replace sbula_1 = . if sbula_1 == -54 // designbedingt fehlend

* begin of first school spell
sort ID_t splink
gen start_p=mdy(startm, day, starty) // start of period  
gen end_p=mdy(endm, day, endy) // end of period
format %tdD_m_CY start_p end_p
bysort ID_t: egen start_sp1=min(start_p) // starting date of first period ever reported
bysort ID_t: egen end_sp1=min(end_p) // end date of first period ever reported
label var start_sp1 "begin first school spell ever reported"
label var end_sp1 "end first school spell ever reported"
format %tdD_m_CY start_sp1 end_sp1


duplicates drop ID_t, force
keep ID_t wave sbula_1 startm starty start_p start_sp1


save "$results/schoolentry.dta", replace