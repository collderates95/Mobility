/*******************************************************************************
					Prepare educational variables
*******************************************************************************/


use "$data\SC6_Biography_R_13-0-0.dta", clear
merge 1:m ID_t splink using "$data\SC6_spSchool_R_13-0-0.dta"

keep if _merge == 3
drop _merge

keep if subspell == 0
sort ID_t splink

bysort ID_t: gen spell_numb = _n
bysort ID_t: gen spell_total = _N


gen day = 14

*any school spell abroad
gen sch_ausland_ = ts11103_g1!=1
bysort ID_t: egen sch_ausland = max(sch_ausland_)
label var sch_ausland "at least one school spell abroad"

*first school spell abroad
bysort ID_t: gen start_foreign_ = sch_ausland_ if _n == 1
bysort ID_t: egen start_foreign = max(start_foreign_)
label var start_foreign "first school spell abroad"

***years of schooling - maximum 
recode ts11209 (1 6 7  = 8) (2=9) (3 = 10) (4 = 12) (5 =13) (else=.), gen(yos)
bysort ID_t: egen yos_max=max(yos) 
recode yos_max (9 . = 8) // "without degree", "basic degree", "special education" etc. set to 8 (ATTENTION: needs to be adjusted to 9 if compulsory schooling reform was in place) 
label var yos_max "years of schooling (of highest degree)"



*** highest school degree
recode ts11209 (-98 -21/0 6 7 = 0) (1 2 = 1) (3 = 2) (4 5 =3) (else=.), gen(dgr)
bysort ID_t: egen dgr_max=max(dgr)
label var dgr_max "highest school degree"

gen abi = dgr_max==3
gen rs1 = dgr_max==2  
gen hs1 = inlist(dgr_max,0,1,.)  
label var abi "academic degree"
label var rs1 "middle degree"
label var hs1 "basic degree and lower"

preserve
duplicates drop ID_t, force
keep ID_t sch_ausland start_foreign abi rs1 hs1 yos_max dgr_max
save "$results\sch_dgr.dta", replace
restore

************************** secondary school track*******************************
** Kamilas coding
recode ts11204_ha (-98 -29=.)
sort ID_t spell subspell
gen grunds=ts11204_ha==1 if ts11204_ha!=.
gen gymn = ts11204_ha==5 & inlist(ts11205,-54,11,14,15,19,20) if ts11204_ha!=. //
replace gymn=1 if ts11204_ha>=8 & inlist(ts11205,11,14,15,19,20)
replace gymn=1 if ts11225==3 

		  
replace gymn=0 if grunds==1
bysort ID_t: gen track=gymn[_n]==1 & grunds[_n-1]==1 if gymn[_n]!=. & grunds[_n-1]!=.
bysort ID_t: egen acadt=max(track)
label var acadt "tracking to Gymnasium (Kamila)"

clonevar acadt_filled = acadt
recode acadt_filled (.=0)
label var acadt_filled "tracking to Gymnasium (Kamila; missings coded as zero)"

preserve
keep ID_t acadt acadt_filled
duplicates drop ID_t, force
save "$results\sch_secondtrack_kamila.dta", replace
restore

*create indicator if school track = high school
gen abi_schulform = .
replace abi_schulform = 0 if inlist(ts11204_ha,1,2,3,4,6,7,8)
replace abi_schulform = 1 if ts11204_ha == 5
replace abi_schulform = 0 if inlist(ts11209,-21,1,2,3,6,7,8) & ts11204_ha == .
replace abi_schulform = 1 if inlist(ts11209,4,5) & ts11204_ha == .

*take maximum
bysort ID_t: egen abi_sectrack_max = max(abi_schulform)
replace abi_sectrack_max = -99 if start_foreign == 1
label var abi_sectrack_max "tracking to Gymnasium (Anton; coded as highest track ever attended)"


* identify every period after primary school
gen second_school_marker = . 
bysort ID_t: replace second_school_marker = 1 if ts11204_ha[_n-1] == 1 & inrange(ts11204_ha,2,8) & sch_ausland_[_n-1] == 0 & sch_ausland_ == 0 // first period after primary school with valid school track
bysort ID_t: egen second_school_ = total(second_school_marker) // calculate total of transitions per individual

***** 1. Identify everyone with first school spell abroad 
preserve 
keep if start_foreign == 1
gen abi_sectrack = -99
duplicates drop ID_t, force
save "$results\temp\secondtrack_temp_ausl.dta", replace
restore
drop if start_foreign == 1


***** 2. Identification and saving of temporary dataset for individuals with one school spell only
preserve
keep if spell_total == 1
gen abi_sectrack = abi_schulform
save "$results\temp\secondtrack_temp0.dta", replace
restore


****3. Identification of individuals that have EXACTLY one valid transition from primary to secondary school track
* keep only individuals with more than one spell
keep if spell_total > 1

*save temporary dataset for individuals with ONE transition spell
preserve
keep if second_school_ == 1
gen abi_sectrack_ = abi_schulform if second_school_marker == 1 
bysort ID_t: egen abi_sectrack = max(abi_sectrack_)
duplicates drop ID_t, force
save "$results\temp\secondtrack_temp1.dta", replace
restore

drop if second_school_ == 1


****4. Identification of individuals that have more than one transition from primary track to secondary school track
* keep first transition
preserve 
keep if second_school_ == 2
keep if second_school_marker == 1
duplicates drop ID_t, force
gen abi_sectrack = abi_schulform 
save "$results\temp\secondtrack_temp2.dta", replace
restore


drop if second_school_ == 2


****5. For remaining individuals: take second school spell (assumption: end of first school spell goes usually along with progression from primary to secondary school track)
gen first_spell_dur = endy-starty if spell_numb == 1
tab first_spell_dur // duration of first spell is in most of the cases 4,8 or 10 years -> 4 in west germany; 8 or 10 in East germany (POS)

preserve 
keep if spell_numb == 2
gen abi_sectrack = abi_schulform
duplicates drop ID_t, force
save "$results\temp\secondtrack_temp3.dta", replace
restore


use "$results\temp\secondtrack_temp_ausl.dta", clear
append using "$results\temp\secondtrack_temp0.dta"
append using "$results\temp\secondtrack_temp1.dta"
append using "$results\temp\secondtrack_temp2.dta"
append using "$results\temp\secondtrack_temp3.dta"

label def abi_sectrack -99 "school start abroad" 0 "no" 1 "yes"
label val abi_sectrack abi_sectrack
label var abi_sectrack "tracking to Gymnasium (Anton)"

preserve
keep ID_t abi_sectrack abi_sectrack_max
save "$results\sch_secondtrack_anton.dta", replace
restore




*******************Uni + Years of Education*************************************
use "$data\SC6_Basics_R_13-0-0.dta", clear

recode tx28101 (7 8 = 1) (else=0), gen(uni)
label var uni "university/FH degree"

recode tx28101 (-55 0 1 2 = 8) (3 4 = 10) (5 6 7 8 = 13), gen(yoe_grade) //attention: if value = 8 and compulsory schooling reform was not in place yet -> adjust to 9
label var yoe_grade "years of education (in grades)"

recode tx28102 (-55 -20 0 =8), gen(yoe) //attention: if value = 8 and compulsory schooling reform was not in place yet -> adjust to 9
label var yoe "years of education"

*S* NEW
recode tx28101 (2 4 6 = 1) (else=0), gen(profes)
label var profes "Professional Qualification"

recode tx28101 (2 4 6 7 8= 1) (else=0), gen(profes_uni)


preserve
keep ID_t uni yoe_grade yoe profes profes_uni
save "$results\casmin.dta", replace
restore 


use "$results\sch_secondtrack_anton.dta", clear
merge 1:1 ID_t using "$results\sch_secondtrack_kamila.dta"
drop _merge
merge 1:1 ID_t using "$results\sch_dgr.dta"
drop _merge
merge 1:1 ID_t using "$results\casmin.dta"
drop if _merge == 2
drop _merge
save "$results\educ_temp.dta", replace


*********************Sebastian Teil********************************************
use "$data\SC6_Biography_R_13-0-0.dta", clear
tab sptype

*Identifier if school-spells are not consecutively following
bysort ID_t: gen Consec = (sptype[_n] == sptype[_n-1])
bysort ID_t: replace Consec = 1 if _n == 1

*Drop not school-spells
keep if sptype == 22
drop if Consec == 0
drop Consec

* Merge with info on schooling-spells
* relevant dates: ts1111m (Startdate month) ts1111y (startdate year) ts1112m (end month) ts1112y (end year)
joinby ID_t splink using "$data\SC6_spSchool_R_13-0-0.dta"

* Recode periods of schooling
drop if subspell != 0

*Drop School that have not been Primary or Secondary
drop if ts11204_ha == 6

*recode School-Types
recode ts11204_ha (-99/0 = 0) (. = 0) (1 = 1) (2 3 4 7 8 = 2) ( 5 = 3 ), gen(School) // *S* Neu: Grundschule als eigenene Kategory neukodiert (Für Rise-Dummy)

*Code: After Indivual attended Haupt- or Realschule, I am not interested in Gymnasium after certain years anymore
bysort ID_t: gen Rise_Sch = (School[_n] == 2  & School[_n+1] == 3) // *S* Neu: Rise ausgetauscht damit es mit der neuen Grundschule funktioniert
drop if Rise_Sch == 1


*Compute actual Years of Schooling (No time in between)
tab ts1111m
tab ts1111y
tab ts1112m
tab ts1112y

recode ts1111m (-99/0 . = 7) (21 = 1) (24 = 4) (27 = 7) (30 = 10) (32 = 12), gen(Month_Start)
recode ts1112m (-99/0 . = 7) (21 = 1) (24 = 4) (27 = 7) (30 = 10) (32 = 12), gen(Month_End)

recode ts1111y (-99/0 = .), gen(Year_Start)
recode ts1112y (-99/0 = .), gen(Year_End)

gen Day = 1

*Generate End and Start-Spell for schooling
gen Start_Date_Sch = mdy(Month_Start, Day, Year_Start)
gen End_Date_Sch = mdy(Month_End, Day, Year_End)

*Change format
format *_Date_Sch %d
sort ID_t splink

*Generate final years of schooling variablen
bysort ID_t: gen DOS = End_Date_Sch - Start_Date_Sch
bysort ID_t: gen YOS = DOS/365

*** Before we can summarize our total years of schooling (yos), we have to kick out overlapping spells that lead to an high number of yos
bysort ID_t: gen Overlap = (Start_Date_Sch[_n+1] < End_Date_Sch[_n] )
order ID_t splink ts1111m Month_Start ts1112m Month_End ts1111y Year_Start ts1112y Year_End Start_Date_Sch End_Date_Sch DOS YOS Overlap
drop if Overlap == 1

bysort ID_t: gen Overlap2 = (Start_Date_Sch[_n+1] < End_Date_Sch[_n] )
order ID_t splink ts1111m Month_Start ts1112m Month_End ts1111y Year_Start ts1112y Year_End Start_Date_Sch End_Date_Sch DOS YOS Overlap2
drop if Overlap2 == 1

bysort ID_t: gen Overlap3 = (Start_Date_Sch[_n+1] < End_Date_Sch[_n] )
order ID_t splink ts1111m Month_Start ts1112m Month_End ts1111y Year_Start ts1112y Year_End Start_Date_Sch End_Date_Sch DOS YOS Overlap3
drop if Overlap3 == 1

bysort ID_t: egen DOS_Sum = sum(DOS)
bysort ID_t: gen YOS_Sum = DOS_Sum/365 
sort ID_t splink
order ID_t splink ts1111m Month_Start ts1112m Month_End ts1111y Year_Start ts1112y Year_End Start_Date_Sch End_Date_Sch DOS YOS DOS_Sum YOS_Sum 
*keep ID_t YOS_Sum
label var YOS_Sum "Years of schooling (C9 first stage). No Outlier Correction"

*Clean Data-Set for Merging with Main-Panel
duplicates drop ID_t, force
keep ID_t YOS_Sum

tab YOS_Sum, m
save "$results\yos_seb_temp.dta", replace 

*** Merge Everything ***
use "$results\educ_temp.dta", replace
merge 1:1 ID_t using "$results\yos_seb_temp.dta"
drop _merge

save "$results\educ_final.dta", replace
