/**************************************************
    Extracts and merges data from Vocational Training
	to the basic panel
	
	Author: A. Barabasch
	
	Version: 1.0, Created: 2022-04-05	
	updated Kreise: 2023-03-27
***************************************************/

*load bibliography & merge data from spSchool

*S* use "$data\SC6_Biography_D_13-0-0.dta", clear
use "$data\SC6_Biography_R_13-0-0.dta", clear
keep if sptype == 24 // keep only VocTrain
*S* merge 1:m ID_t splink using "$data\SC6_spVocTrain_D_13-0-0.dta"
merge 1:m ID_t splink using "$data\SC6_spVocTrain_R_13-0-0.dta"
drop _merge

** regional variables
clonevar bl_ausbild = ts15207_g2 if ts15207_g2 > 0
clonevar kr_ausbild = ts15207_g4R if ts15207_g4R > 0
recode bl_ausbild kr_ausbild (. = 0) if ts15206_g1 == 2 // Ausland


*check subspells
sort ID_t spell subspell
bysort ID_t: gen sub_first = spell == spell[_n+1] & subspell == 0
tab bl_ausbild if sub_first == 1, m // 10 bula missings in harmonized spells
tab kr_ausbild if sub_first == 1, m // 13 kreise missings in harmonized spells

tab subspell // maximum 12 13 ( *S* ) subspells 
foreach num of numlist 1(1)13 {
	bysort ID_t spell: replace bl_ausbild=bl_ausbild[_n+`num'] if bl_ausbild ==. & bl_ausbild[_n+`num']!=. & subspell==0 
	}

*S* For Kr
foreach num of numlist 1(1)13 {
	bysort ID_t spell: replace kr_ausbild=kr_ausbild[_n+`num'] if kr_ausbild ==. & kr_ausbild[_n+`num']!=. & subspell==0 
	}

* clean data
keep if subspell == 0
drop if spms == -20 // Episode im Prüfmodul annuliert
drop if inlist(spstat,11,31) // Widerspruchskorrektur
drop if bl_ausbild < 0 | bl_ausbild == . // deletes every cell without valid information about bundesland 
*S* Wichtig: Wir haben mehr Bula als KR, daher bleiben wir bei droppen von BL


* create start & end date of each spell

* if missing replace by data from school spell file
replace starty = ts1511y_g1 if (starty == . | starty == -55) & (ts1511y_g1 > 0 & ts1511y_g1 < .)
replace startm = ts1511m_g1 if (startm == . | startm == -55) & (ts1511m_g1 > 0 & ts1511m_g1 < .)
replace endy = ts1512y_g1 if (endy == . | endy == -55) & (ts1512y_g1 > 0 & ts1511y_g1 < .)
replace endm = ts1512m_g1 if (endm == . | endm == -55) & (ts1512m_g1 > 0 & ts1512m_g1 < .)

gen start = ym(starty, startm) // 25 missings
gen end = ym(endy, endm) // 34 missings
format start end %tm


*br if start == . | end == . // nothing about end date (neither month nor year); can not assume anything because it is voc/further train and consecutiveness of spells can not be assumed
drop if start == . | end == . // 34 cells
gen wrong_date = 1 if start > end // starting date later than end date of spell
drop if wrong_date == 1 

** delete unnecessary variables
keep ID_t - nepswave ts15211  bl_ausbild - end

*********************************************************************************
**********STEP 1: Save temporarily all people without overlapping spells*****
*********************************************************************************

* drop if their are duplicates regarding start date, end date & bula of voctrain
*S* duplicates drop ID_t start end bl_ausbild, force 
duplicates drop ID_t start end bl_ausbild kr_ausbild, force // we delete 17 obs less

* if start end end date is in same month -> drop it (mobility is unlikely; most likely further training course that lasted a couple of weeks)
gsort ID_t start -end 
bysort ID_t: gen dur_1 = (end - start) 
drop if dur_1 == 0


* sort according to starting date 
gsort ID_t start -end 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges == 0 // 10939 people without any overlaps
distinct ID_t if overlap_ges > 0 // 711 people with at least one overlapping period

*********save all individuals in seperate file, where the spells have no overlaps*****
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_0.dta", replace
restore

*************************


***************************************************************************************
************STEP 2: Check people with at least one overlapping period******************
***************************************************************************************

drop if overlap_ges == 0

** create overlap identifier
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
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_ausbild == kr_ausbild[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_ausbild == kr_ausbild[_n-1])  if overlap_inside_allein == 1

foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


**********OVERLAP with end date of prior cell (bula remains the same -> combine periods) **************

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
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_ausbild == kr_ausbild[_n+1]) & (end[_n+1] > end)
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
distinct ID_t if overlap_ges >  0 // 185 people with more than one overlap period remain
*S* with kr, its 326

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_1.dta", replace
restore


**********************************************************************************
***********************STEP 3: Repeat Step 2**************************************
**********************************************************************************
drop if overlap_ges == 0
distinct ID_t // 185 individual with overlapping spells


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
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_ausbild == kr_ausbild[_n-`num']) if overlap_inside_`num' == 1 //
}


bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_ausbild == kr_ausbild[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr

************* OVERLAP with end date of prior cell (bula remains the same -> combine periods) **************

gsort ID_t start -end 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 215 people with more than one overlap period remain

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start -end 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_ausbild == kr_ausbild[_n+1]) & (end[_n+1] > end)
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
distinct ID_t if overlap_ges >  0 // 164 people with more than one overlap period remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_2.dta", replace
restore


**********************************************************************************
***********************STEP 4: Repeat steps 2 & 3*********************************
**********************************************************************************
drop if overlap_ges == 0
distinct ID_t // 164 individual with overlapping spells

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
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_ausbild == kr_ausbild[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_ausbild == kr_ausbild[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


************* OVERLAP with end date of prior cell (bula remains the same -> combine periods) **************

gsort ID_t start -end 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 95 people with more than one overlap period remain
*S* 303 with kr

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start -end 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_ausbild == kr_ausbild[_n+1]) & (end[_n+1] > end)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end = end[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*

gsort ID_t start -end 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 163 people with at least one overlap period remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_3.dta", replace
restore

*S* **************repeat Step 2 & 3 *********************
drop if overlap_ges == 0
distinct ID_t // 

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
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_ausbild == kr_ausbild[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start <= end[_n-1]) & (end <= end[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_ausbild == kr_ausbild[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)6 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


************* OVERLAP with end date of prior cell (bula remains the same -> combine periods) **************

gsort ID_t start -end 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 95 people with more than one overlap period remain
*S* 303 with kr

gsort ID_t start -end 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start -end 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_ausbild == kr_ausbild[_n+1]) & (end[_n+1] > end)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end = end[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*

gsort ID_t start -end 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // *S* 258 with kr remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_3.2.dta", replace
restore

*******************************************************************************
************STEP 5: Look at cases that have overlaps NOT within same bula******
*******************************************************************************

/* two cases can be detected
1. one period lies within other period, but bula are different
	-> if start date == end date -> delete spell (assumption: no mobility because of a couple of weeks)
	-> delete spell with shorter duration if it is not clearly "Hauptereignis"
	
2. end date of cell 1 and start date of cell 2 are overlapping
		-> cell 1 remains unchanged if it is "Hauptereignis" 
		-> start date is adjusted to end date of cell 1 + one month
*/

drop if overlap_ges == 0
distinct ID_t // 163 individual with overlapping spells
*S* 258 with kr


*****************************************************************
gsort ID_t start -end 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 183 people remain

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
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 36 people remain
*S* 59 distinct indiv. remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_4.dta", replace
restore


*******************************************************************************
**************************STEP 6: Repeat step 5********************************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t // 36 individuals with overlapping spells



*****************************************************************
gsort ID_t start -end 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 183 people remain

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
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 20 people remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_5.dta", replace
restore



*******************************************************************************
**************************STEP 7: Repeat step 6********************************
*******************************************************************************


drop if overlap_ges == 0
distinct ID_t // 20 individual with overlapping spells

*****************************************************************
gsort ID_t start -end 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 183 people remain

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
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 16 people remain


*save cases that apply to rules above
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_6.dta", replace
restore



*******************************************************************************
**************************STEP 8: Repeat step 7********************************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t // 16 individual with overlapping spells

*****************************************************************
gsort ID_t start -end 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 183 people remain

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
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6


bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 13 people remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_ausbild_overlap_7.dta", replace
restore



*******************************************************************************
*****************STEP 9: Manual coding of remaining cases**********************
*******************************************************************************
drop if overlap_ges == 0

drop if ID_t == 8000512 & splink == 240003

drop if ID_t == 8001130 & splink == 240002
replace end = (start[_n+1]-1) if ID_t == 8001130 & splink == 240003 

drop if ID_t == 8001987 & splink == 240004 

drop if ID_t == 8005349 & splink == 240008

replace start = (end[_n+1]+1) if ID_t == 8008547 & splink == 240003

drop if ID_t == 8008603 & inlist(splink,240003,240004,240009)
replace start = (end[_n-1]+1) if ID_t == 8008603 & inlist(splink,240006)

drop if ID_t == 8009782 & inlist(splink,240006)
drop if ID_t == 8010581 & inlist(splink,240002,240007)
drop if ID_t == 8020401 & splink == 240006

replace start = (end[_n+1]+1) if ID_t == 8020553 & inlist(splink,240002)
replace start = (end[_n+1]+1) if ID_t == 8020606 & inlist(splink,240002)

drop if ID_t == 8024676 & inlist(splink,240001)
drop if ID_t == 8022422 & inlist(splink,240004,240006,240007)


replace start = (end[_n+1]+1) if ID_t == 8023991 & inlist(splink,240003)
gsort ID_t start -end 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & obs > 1
bysort ID_t: replace overlap = 1 if start <= end[_n-2] & obs > 2 // if multiple periods overlap
bysort ID_t: replace overlap = 1 if start <= end[_n-3] & obs > 3
bysort ID_t: replace overlap = 1 if start <= end[_n-4] & obs > 4
bysort ID_t: replace overlap = 1 if start <= end[_n-5] & obs > 5
bysort ID_t: replace overlap = 1 if start <= end[_n-6] & obs > 6

drop if overlap == 1 // sometimes when running the whole do-file: at this place one individual with one remaining overlap remains -> drop it 
bysort ID_t: egen overlap_ges = total(overlap)  
distinct ID_t if overlap_ges > 0 // 0 overlaps left 


save "$results\temp_ausbild_overlap_manual.dta", replace



*******************************************************************************
*****************STEP 9: Combine all files*************************************
*******************************************************************************
use "$results\temp_ausbild_overlap_0.dta", clear
append using "$results\temp_ausbild_overlap_1.dta" 
append using "$results\temp_ausbild_overlap_2.dta" 
append using "$results\temp_ausbild_overlap_3.dta" 
append using "$results\temp_ausbild_overlap_4.dta" 
append using "$results\temp_ausbild_overlap_5.dta" 
append using "$results\temp_ausbild_overlap_6.dta" 
append using "$results\temp_ausbild_overlap_7.dta" 
append using "$results\temp_ausbild_overlap_manual.dta" 




drop overlap - overlap_ges


**********************Quality check of combined file *******************
*check if there are any overlapping spells
gsort ID_t start -end 
gen overlap = 0 
bysort ID_t: replace overlap = 1 if start <= end[_n-1] & _n > 1
distinct ID_t if overlap == 1 // no overlaps anymore 
drop overlap


*check if there are no negative spell gaps
sort ID_t start 
bysort ID_t: gen spell_gaps = start - end[_n-1]
bysort ID_t: replace spell_gaps = 1 if spell_gaps == . & _n==1 // first spell for each individual has no gap
sum spell_gaps, d // no negative spell gaps

*generate spell duration and expand in order create monthly observations for each spell
gen spell_dur = end-start+1 // +1 is important; else one month gets lost
sort ID_t start
expand spell_dur // expand according to duration of spell


sort ID_t start
bysort ID_t start: gen date = start if _n == 1
bysort ID_t start: replace date = (date[_n-1]+1) if _n > 1 // create consecutive date on monthly basis
format date %tm

duplicates report ID_t date // no duplicates
keep ID_t bl_ausbild kr_ausbild date

label var bl_ausbild "Bundesland of voc train"
label var kr_ausbild "Kreis of voc train"


erase "$results\temp_ausbild_overlap_0.dta"
erase "$results\temp_ausbild_overlap_1.dta" 
erase "$results\temp_ausbild_overlap_2.dta" 
erase "$results\temp_ausbild_overlap_3.dta" 
erase "$results\temp_ausbild_overlap_4.dta" 
erase "$results\temp_ausbild_overlap_5.dta" 
erase "$results\temp_ausbild_overlap_6.dta" 
erase "$results\temp_ausbild_overlap_7.dta" 
erase "$results\temp_ausbild_overlap_manual.dta" 

compress 
save "$results\temp_ausbild.dta", replace

************************************************
*     merging to basic panel
************************************************
use "$results\0_basicpanel.dta", clear

joinby ID_t date using "$results\temp_ausbild.dta", unmatched(master)
tab _merge, mis
drop _merge


compress
sort ID_t date
