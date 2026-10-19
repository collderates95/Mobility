/**************************************************
    Extracts and merges data from school spells 
	to the basic panel
***************************************************/


*load bibliography & merge data from spSchool
use "$data\SC6_Biography_R_13-0-0.dta", clear

keep if sptype == 22 // keep only school files
*S* merge 1:m ID_t splink using "$data\SC6_spSchool_D_13-0-0.dta"
merge 1:m ID_t splink using "$data\SC6_spSchool_R_13-0-0.dta"
drop _merge

** regional variables
clonevar bl_sch = ts11202_g2 if ts11202_g2 > 0
*S* clonevar kr_sch = ts11202_g4R if ts11202_g4R > 0
clonevar kr_sch = ts11202_g4R if ts11202_g4R >= 0
recode bl_sch kr_sch (. = 0) if ts11103_g1 == 2 // Ausland


*check subspells
sort ID_t spell subspell
bysort ID_t: gen sub_first = spell == spell[_n+1] & subspell == 0
tab bl_sch if sub_first == 1, m // no bula missings in harmonized spells
tab kr_sch if sub_first == 1, m // no kr missings in harmonized spells
drop sub_first

* clean data
keep if subspell == 0
drop if spms == -20 // Episode im Prüfmodul annuliert
drop if spstat == 11 // Widerspruchskorrektur
count if kr_sch != . & bl_sch == . // 0. nice!
count if kr_sch == . & bl_sch != . // 31 !
count if kr_sch != . & bl_sch != . // 22 713
distinct ID_t if kr_sch == . & bl_sch != . // 28 distinct individuals !

gen BL_KR_ID = 0
replace BL_KR_ID = 1 if kr_sch == . & bl_sch != .
drop if bl_sch < 0 & BL_KR_ID == 0
drop if bl_sch == . & BL_KR_ID == 0 // *S* doesnt change anything

* create start & end date of each spell
* if missing replace by data from school spell file
replace starty = ts1111y_g1 if (starty == . | starty == -55) & (ts1111y_g1 > 0 & ts1111y_g1 < .)
replace startm = ts1111m_g1 if (startm == . | startm == -55) & (ts1111m_g1 > 0 & ts1111m_g1 < .)
replace endy = ts1112y_g1 if (endy == . | endy == -55) & (ts1112y_g1 > 0 & ts1111y_g1 < .)
replace endm = ts1112m_g1 if (endm == . | endm == -55) & (ts1112m_g1 > 0 & ts1112m_g1 < .)

gen start = ym(starty, startm)
gen end = ym(endy, endm)
format start end %tm

tab1 start end, m
drop if start == . | end == . 
gen wrong_date = 1 if start > end 
drop if wrong_date == 1 
keep ID_t - nepswave ts11209 ts11202_*  ts11204_ha bl_sch-end


save "$results\temp_school_before_BLKR.dta", replace
use "$results\temp_school_before_BLKR.dta", clear

*********************************************************************************
**********STEP 1: Save temporarily all people without overlapping spells*****
*********************************************************************************

* drop if their are duplicates regarding start date, end date & place of school
duplicates drop ID_t start end bl_sch kr_sch, force

* sort according to starting date 
gsort ID_t start -end 

* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges == 1 // 106 individuals with one overlap
distinct ID_t if overlap_ges > 1 // 16 people with more than one overlap 


*save all individuals w/o overlaps in seperate file
preserve 
keep if overlap_ges == 0
save "$results\temp_school_overlap_0.dta", replace
restore


***************************************************************************************
************STEP 2: Check people with at least one overlapping period******************
***************************************************************************************
drop if overlap_ges == 0
distinct ID_t // 125 individual with overlapping spells


gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1 
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 
bysort ID_t: gen overlap_2 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] != 1) & _n > 2 
bysort ID_t: gen overlap_3 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] != 1) & _n > 3 
bysort ID_t: gen overlap_4 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] != 1) & _n > 4 
bysort ID_t: gen overlap_5 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] != 1) & _n > 5 
bysort ID_t: gen overlap_6 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 6 


************* OVERLAP within other cell (bula remains the same) **************
foreach num of numlist 1(1)6 {
	bysort ID_t: gen overlap_inside_`num' = ((start <= end[_n-`num']) & (end <= end[_n-`num']))  if overlap_`num' == 1 //
}

foreach num of numlist 1(1)6 {
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_sch == kr_sch[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_sch == kr_sch[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1 // *S* 59 obs deleted

drop overlap - overlap_inside_allein_samekr 

**********OVERLAP with end date of prior cell (bula/kr remains the same -> combine periods) **************
gsort ID_t start -end 
* create overlap identifier
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 

** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend 
gsort ID_t start -end 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_sch == kr_sch[_n+1]) & (end[_n+1] > end)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end = end[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*

* create overlap identifier
gsort ID_t start -end 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 20 people with more than one overlap period remain
*S* with kr: 37 people with more than one overlap period remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_school_overlap_1.dta", replace
restore

**********************************************************************************
***********************STEP 3: Repeat Step 2**************************************
**********************************************************************************
drop if overlap_ges == 0
distinct ID_t // 20 individual with overlapping spells

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 
bysort ID_t: gen overlap_2 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] != 1) & _n > 2 
bysort ID_t: gen overlap_3 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] != 1) & _n > 3 
bysort ID_t: gen overlap_4 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] != 1) & _n > 4 
bysort ID_t: gen overlap_5 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] != 1) & _n > 5 
bysort ID_t: gen overlap_6 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 6 



************* OVERLAP within other cell (bula remains the same) **************
foreach num of numlist 1(1)6 {
	bysort ID_t: gen overlap_inside_`num' = ((start <= end[_n-`num']) & (end <= end[_n-`num']))  if overlap_`num' == 1 //
}


foreach num of numlist 1(1)6 {
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_sch == kr_sch[_n-`num']) if overlap_inside_`num' == 1 //
}


bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_sch == kr_sch[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


************* OVERLAP with end date of prior cell (bula remains the same -> combine periods) **************
gsort ID_t start -end 
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) 
distinct ID_t if overlap_ges >  0 


gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start -end 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_sch == kr_sch[_n+1]) & (end[_n+1] > end)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end = end[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*


gsort ID_t start -end 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_school_overlap_2.dta", replace
restore


*******************************************************************************
************STEP 4: Look at cases that have overlaps NOT within same bula******
*******************************************************************************

/* two cases can be detected
1. one period lies within other period, but bula are different
	-> delete spell with shorter duration if it is not clearly "Hauptereignis"
	
2. end date of cell 1 and start date of cell 2 are overlapping
		-> cell 1 remains unchanged if it is "Hauptereignis" 
		-> start date in cell 2 is adjusted to end date of cell 1 + one month
*/

drop if overlap_ges == 0
distinct ID_t // 18 individuals with overlapping spells

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 



* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start <= end[_n-1]) & (end <= end[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start <= end[_n-1]) & (end > end[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & (spms == 1) & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & (spms == 1) & (spms[_n-1] == 2)


bysort ID_t: replace start = (end[_n-1]+1) if crossover_clear == 1 
bysort ID_t: replace end  = (start[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1 


gsort ID_t start -end 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 4 people remain 

preserve 
keep if overlap_ges == 0
save "$results\temp_school_overlap_3.dta", replace
restore

***

*******************************************************************************
************STEP 5: Manual coding of 4 remaining cases*************************
*******************************************************************************
drop if overlap_ges == 0

replace start = (end[_n-1]+1) if ID_t == 8009198 & splink == 220003
replace end = (start[_n+1] - 1) if ID_t == 8022708 & splink == 220001 
replace end = (start[_n+1] - 1) if ID_t == 8024966 & splink == 220001 

save "$results\temp_school_overlap_manual.dta", replace



*******************************************************************************
*****************STEP 6: Combine all files*************************************
*******************************************************************************

use "$results\temp_school_overlap_0.dta"
append using "$results\temp_school_overlap_1.dta" 
append using "$results\temp_school_overlap_2.dta" 
append using "$results\temp_school_overlap_3.dta" 
append using "$results\temp_school_overlap_manual.dta" 

drop overlap - overlap_ges


**********************Quality check of combined file *******************
*check if there are any overlapping spells
gsort ID_t start -end 
gen overlap = 0 
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & _n > 1
distinct ID_t if overlap == 1 // no overlaps anymore *S* still!
drop overlap

*check if there are no negative spell gaps
sort ID_t start 
bysort ID_t: gen spell_gaps = start - end[_n-1]
bysort ID_t: replace spell_gaps = 1 if spell_gaps == . & _n==1 // first spell for each individual has no gap
sum spell_gaps, d // no negative spell gaps


*generate spell duration and expand in order create monthly observations for each spell
gen spell_dur = end-start+1 // +1 is important; else one month gets lost
bysort ID_t: egen spell_dur_max = max(spell_dur)
sum spell_dur_max, d // only very few observations with unrealistic spell duration

sort ID_t start
expand spell_dur // expand according to duration of spell

sort ID_t start
bysort ID_t start: gen date = start if _n == 1
bysort ID_t start: replace date = (date[_n-1]+1) if _n > 1 // create consecutive date on monthly basis
format date %tm

bysort ID_t: gen gaps = date - date[_n-1]
bysort ID_t: replace gaps = 1 if gaps == .
bysort ID_t: egen gaps_max = max(gaps)
tab gaps_max 


*** check duplicates in months per person	
duplicates report ID_t date 
duplicates drop ID_t date, force

keep ID_t bl_sch kr_sch date

label var bl_sch "Bundesland of school"
label var kr_sch "Kreis of school"

erase "$results\temp_school_overlap_manual.dta"
erase "$results\temp_school_overlap_0.dta"
erase "$results\temp_school_overlap_1.dta"
erase "$results\temp_school_overlap_2.dta"
erase "$results\temp_school_overlap_3.dta"



compress
save "$results\temp_school.dta", replace

************************************************
*     merging to basic panel
************************************************
use "$results\0_basicpanel.dta", clear

joinby ID_t date using "$results\temp_school.dta", unmatched(master)
tab _merge, mis
drop _merge


compress
sort ID_t date
