/**************************************************
    Creates a balanced panel over the life cycle 
	(ages 0-75, monthly) for every individual 
	born 1944-1986
	
	Author: K. Cygan-Rehm + A. Barabasch + S. Vogler
	
	Version: 2.0, 	created: 2022-03-28
					updated: 2023-02-27	
					updated Kreise: 2023 - 03 - 27
***************************************************/

****** Data from Basics ******
use "$data\SC6_Basics_R_13-0-0.dta", clear
sort ID_t 

*** date of birth
clonevar yob=tx2900y
clonevar mob=tx2900m 
gen bdate =ym(yob, mob)
format *date* %tm
lab var bdate "date of birth"

*** female
gen female=t700001==2

*** born in Germany
keep if t405000_g2==1 | t405000_g2==2
gen west=t405000_g2==1
lab var west "born in West Germany"

*** last educational degree
clonevar casmin=tx28101
replace casmin=1 if casmin==-55 & tx28103==1

*** keep only relevant variables 
sort ID_t
duplicates drop ID_t, force
keep ID_t yob mob bdate female west casmin


****** merge panel data from Methods ******
joinby ID_t using "$data\SC6_Methods_R_13-0-0.dta", unmatched(master)
clonevar bl_samp = tx80101
clonevar wave1 = tx80107


sort ID_t wave
duplicates drop ID_t, force

keep ID_t yob mob bdate female west casmin bl_samp wave1 


****** merge panel data from pTarget ******
joinby ID_t using "$data\SC6_pTarget_R_13-0-0.dta", unmatched(master)
sort ID_t wave

*** place of birth
clonevar bl_birth_ = t700101_g2 if t700101_g2>0 // Bundesland
xtset ID_t wave /*check if time-invariant*/
xtsum bl_birth_

bysort ID_t: egen bl_birth=mean(bl_birth_) 
drop bl_birth_
drop if bl_birth==.
lab var bl_birth "Bundesland of birth"

clonevar kr_birth_ = t700101_g4R if t700101_g4R >= -53 // Kreis
xtsum kr_birth_

bysort ID_t: egen kr_birth=mean(kr_birth_) 
drop kr_birth_	
lab var kr_birth "Kreis of birth"

*** family background
clonevar sibl_=t732101 if t732101>0 & t732101!=. // no. of siblings
bysort ID_t: egen sibl=max(sibl_)
drop sibl_
lab var sibl "No. of siblings"

clonevar m_yob_=t73120y if t73120y>0  // parental year of birth
bysort ID_t: egen m_yob=min(m_yob_)
clonevar f_yob_=t73125y if t73125y>0
bysort ID_t: egen f_yob=min(f_yob_)
drop m_yob_ f_yob_
lab var m_yob "Mother: yr of birth"
lab var f_yob "Father: yr of birth"

gen m_gerborn_=inlist(t405060_g1,1,2) if t405060_g1>0 & t405060_g1!=. // born in Germany
bysort ID_t: egen m_gerborn=min(m_gerborn_)
gen f_gerborn_=inlist(t405090_g1,1,2) if t405090_g1>0 & t405090_g1!=.
bysort ID_t: egen f_gerborn=min(f_gerborn_)
lab var m_gerborn "Mother: born in Germany"
lab var f_gerborn "Father: born in Germany"

gen m_yos_=t731301_g3 if t731301_g3>=-20 & t731301_g3!=. // yrs of schooling
recode m_yos_ (-20=8)
bysort ID_t: egen m_yos=max(m_yos_)
gen f_yos_=t731351_g3 if t731351_g3>=-20 & t731351_g3!=.
recode f_yos_ (-20=8)
bysort ID_t: egen f_yos=max(f_yos_)
lab var m_yos "Mother: yrs of schooling"
lab var f_yos "Father: yrs of schooling"

gen fam15_=t731101==1 if t731101>0 & t731101!=.  // intact family at age 15
bysort ID_t: egen fam15=max(fam15_)
drop *_
lab var fam15 "Family intact at age 15"


****** merge panel data from CohortProfile ******
drop _merge
joinby ID_t wave using "$data\SC6_CohortProfile_R_13-0-0.dta", unmatched(master)

clonevar ADIAB = tx80533 // NEPS-ADIAB Datenverknüpfung

*** first/last interview date 
recode tx8600m  (-100/0=.)

gen idate =ym(tx8600y, tx8600m)
format *date* %tm
bysort ID_t: egen idate1=min(idate)
bysort ID_t: egen idate99=max(idate)
lab var idate1 "first interview: date"
lab var idate99 "last interview: date"
format *date* %tm

keep ID_t wave yob mob bdate female west casmin m_* f_* bl_samp wave1 bl_* kr_* sibl fam15 ADIAB idate1 idate99 
sort ID_t wave
duplicates drop ID_t, force

*** save file with time-invariant variables
sum
count // 15,274 individuals
compress
save "$results\0_basicpanel.dta", replace


*** create monthly panel for each age years 0-75 ***
use "$results\0_basicpanel.dta", clear
clonevar date = bdate // date
lab var date "consecutive date"

expand 77*12 // expand 77 age years * 12 months
sort ID_t

bysort ID_t: replace date = bdate + _n - 1
gen date_=dofm(date) 
format date_ %td

gen year=year(date_) 
gen month=month(date_)
drop date_

gen age = int((date-bdate)/12) // age
lab var age "completed age"

*** drop observations after last possible interview
sum year month age
keep if year<=2021 // last NEPS interviews

sum
sort ID_t date
compress

*** save file with time-invariant variables
sum
count // 15,274 individuals
compress
save "$results\0_basicpanel.dta", replace







