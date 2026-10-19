/**************************************************
    Merging data from Employment to the panel 
	
	Author: Sebastian Vogler
	
	Version: 1.1, Created: 06.04.2022	
				  Updated: 28.05.2023 (added Kreise, changed order of deletion)
***************************************************/

ssc inst unique

*loading and merging data from bibliography to spEmp
use "$data\SC6_Biography_R_13-0-0.dta", clear

keep if sptype == 26 | sptype == 27 // keeping only emplyment and unemployment
merge 1:m ID_t splink using "$data\SC6_spEmp_R_13-0-0.dta"
drop _merge

* regional variables (KR and BL)
clonevar bl_emp = ts23237_g2 if ts23237_g2 >= 0
clonevar kr_emp = ts23237_g4R if ts23237_g4R >= 0

label define bl_emp 0 "Ausland"
label define kr_emp 0 "Ausland"

*** URBAN ***
count // 221,085
joinby ID_t spell subspell using "$MergeUrbanFDZ\SC6_spEmp_ts23237_PanelUrbanLatLong_merge.dta", unmatched(master)
drop _merge
count // 221,085

*** creating first and last subspell to fill them up later
sort ID_t spell subspell
bysort ID_t: gen sub_first = spell == spell[_n+1] & subspell == 0
tab bl_emp if sub_first == 1, m // 2172 states missings in harmonized spells
tab kr_emp if sub_first == 1, m // 1930 states missings in harmonized spells

tab subspell // maximum 13 subspells

*Fill for BL
foreach num of numlist 1(1)13 {
	bysort ID_t spell: replace bl_emp=bl_emp[_n+`num'] if bl_emp == . & bl_emp[_n+`num']!= . & subspell==0 
	}
	
*Fill for Kr	
foreach num of numlist 1(1)13 {
	bysort ID_t spell: replace kr_emp=kr_emp[_n+`num'] if kr_emp == . & kr_emp[_n+`num']!= . & subspell==0 
	}

*** Cleaning the data
keep if subspell == 0 
*I am dropping unemployment right here  
drop if spms == -20 // Episode im Prüfmodul annuliert
drop if inlist(spstat,11,31) // Widerspruchskorrektur
drop if bl_emp == . //  drop if no info on BL 
drop if kr_emp == .
drop if sptype == .

* Check: Are we losing data?
bysort ID_t subspell:  tab subspell if kr_emp[_n] != kr_emp[_n+1] & kr_emp != . & spell[_n] == spell[_n+1] // tabbe subspell fall nicht gleicher State wie danach, state aber nicht fehlt und spell der gleiche ist
bysort ID_t:  tab subspell if kr_emp[_n] != kr_emp[_n+1] & kr_emp != . & spell[_n] == spell[_n+1]
* No Info-Loss


***create start_episode & end_episode date of each spell
* if missing replace beginning and end_episode of spell-data with beginning and end_episode of the employment
replace starty = ts2311y if (starty == . | starty == -55) & (ts2311y > 0 & ts2311y < .)
replace startm = ts2311m if (startm == . | startm == -55) & (ts2311m > 0 & ts2311m < .)
replace endy = ts2312y if (endy == . | endy == -55) & (ts2312y > 0 & ts2312y < .)
replace endm = ts2312m if (endm == . | endm == -55) & (ts2312m > 0 & ts2312m < .)

gen start_episode = ym(starty, startm)
gen end_episode = ym(endy, endm)
format *_episode %tm

*drop if no infos on start_episode or end_episode of episodes
drop if start_episode == . & sptype != 27
drop if end_episode == . & sptype != 27

gen wrong_date = 1 if start_episode > end_episode
drop if wrong_date == 1
drop wrong_date

*drop roughly everything not spell-related or necessary
drop ts23511_g1 - ts23410_g1
drop ts23223_g1 - ts23201_g16 
drop ts23210_v1R - ts23222
drop ts23248 - ts23546 
drop ts23218_v1 - ts23234
drop ts23236 ts23236_g1 ts23241 ts23242 ts23243_v1 ts23243 ts23310 ts23320 ts2332m ts2332y ts23244_v1 ts23244 ts23245 ts23246 ts23247
drop splast startm starty endm endy spgen spext spstat disagint disagwave ts2333m ts2333y ts23552  ts23901_v1 ts23901 ts23550 ts23256 ts23257 ts23203_v1 ts23203 ts23204_v1 ts23212 ts23213 ts23208 ts23214 ts23214_ha ts23211
drop ts23910 - ts23237_g4R
drop ts23239_g1R ts23239_g2 nepswave 

*********************************************************************************
**********STEP 1: Save temporarily all people without overlapping spells*****
*********************************************************************************
* drop if their are duplicates regarding start_episode date, end_episode date & state of employment
duplicates drop ID_t start_episode end_episode bl_emp kr_emp, force

* sort according to starting date 
gsort ID_t start_episode - end_episode 

* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n

*sum obs -> max 40 obs
forval i = 1/40 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`i'] & obs > `i'
}

distinct ID_t if overlap == 1 // 11519 overlaps with 5758 distinct individuals
total(overlap)

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges == 0 
distinct ID_t if overlap_ges > 0

*********save all individuals in seperate file, where the spells have no overlaps*****
preserve 
keep if overlap_ges == 0

save "$results\temp_EMPLOYMENT_overlap_0.dta", replace
restore


***************************************************************************************
************STEP 2: Check people with at least one overlapping period******************
***************************************************************************************

drop if overlap_ges == 0
distinct ID_t //  (still) 3841 individual with overlapping spells in my case (mainly because of high levels of overlap in short-time unemployment, mini-jobs and seasonal work)

** create overlap identifier
sum overlap_ges
*I have max 14 overlaps - Therefore, up to 14 iterations

gsort ID_t + start_episode - end_episode
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] != 1) & _n > 1 // only one overlap, before and after t no overlap -> Isolated overlap
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // overlap and period t+1 also has an overlap
bysort ID_t: gen overlap_2 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] != 1) & _n > 2  // overlap and previous period t-1 has an overlap, but not t-2
bysort ID_t: gen overlap_3 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] != 1) & _n > 3 // overlap and previous two periods t-1 and t-2 have an overlap, but not t-3
bysort ID_t: gen overlap_4 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] != 1) & _n > 4 // see above with t-4
bysort ID_t: gen overlap_5 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] != 1) & _n > 5 // see above with t-5
bysort ID_t: gen overlap_6 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 6 // see above with t-6

bysort ID_t: gen overlap_7 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 7 // see above with t-6
bysort ID_t: gen overlap_8 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & _n > 8 // see above with t-6
bysort ID_t: gen overlap_9 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & _n > 9 // see above
bysort ID_t: gen overlap_10 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & _n > 10 // see above with t-6

bysort ID_t: gen overlap_11 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & _n > 11 
bysort ID_t: gen overlap_12 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)  & _n > 12 
bysort ID_t: gen overlap_13 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1) & _n > 13 
bysort ID_t: gen overlap_14 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1)  & (overlap[_n-13] != 1) & _n > 13 

sum overlap_*



************* OVERLAP within other cell (state remains the same) **************
foreach num of numlist 1(1)11 {
	bysort ID_t: gen overlap_inside_`num' = ((start_episode <= end_episode[_n-`num']) & (end_episode <= end_episode[_n-`num']))  if overlap_`num' == 1  // start-episode SMALLER than previous end-episode -> Overlap. Again, with total n periods in the past
}
* For-loop to check if previous overlaps are overlaping 
foreach num of numlist 1(1)11 {
	sum overlap_inside_`num'
}


foreach num of numlist 1(1)11 {
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_emp == kr_emp[_n-`num']) if overlap_inside_`num' == 1 //
}
*For-loop to check whether the overlap happens in the same state. I check if the last n periods happened in the same state

bysort ID_t: gen overlap_inside_allein = ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))  if overlap_allein == 1 // if the overlap really happened isolated from all other periods
bysort ID_t: gen overlap_inside_allein_samekr = (kr_emp == kr_emp[_n-1]) if overlap_inside_allein == 1 // overlap isolated from other overlaps AND state is the same as previously -> then we can kick it out


foreach num of numlist 1(1)11 {
	drop if overlap_inside_samekr_`num' == 1 
}
*for-loop to drop obs if the overlap happens inside the same state - no additional information for us. Thats were reduction of obs happen

drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


**********OVERLAP with end_episode date of prior cell (bula remains the same -> combine periods) **************
gsort ID_t start_episode -end_episode 
* create overlap identifier
gen overlap = 0 
bysort ID_t: gen obs = _n
*sum obs -> 23 obs

foreach num of numlist 1(1)23 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

gsort ID_t +start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1 //again: overlap_allein if there is an overlap, but not the period after or before
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if state remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend 
gsort ID_t +start_episode -end_episode  
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_emp == kr_emp[_n+1]) & (end_episode[_n+1] > end_episode)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end_episode = end_episode[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*

* create overlap identifier
gsort ID_t +start_episode -end_episode  
drop overlap - overlap_1
gen overlap = 0 

bysort ID_t: gen obs = _n

foreach num of numlist 1(1)20 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 1059 *S* 1800 people with more than one overlap period remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_1.dta", replace
restore


**********************************************************************************
***********************STEP 3: Repeat Step 2**************************************
**********************************************************************************


drop if overlap_ges == 0
distinct ID_t // 1059 individual with overlapping spells. Comparison: Anton has 228

gsort ID_t + start_episode - end_episode
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] != 1) & _n > 1 // only one overlap, before and after t no overlap -> Isolated overlap
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // overlap and period t+1 also has an overlap
bysort ID_t: gen overlap_2 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] != 1) & _n > 2  // overlap and previous period t-1 has an overlap, but not t-2
bysort ID_t: gen overlap_3 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] != 1) & _n > 3 // overlap and previous two periods t-1 and t-2 have an overlap, but not t-3
bysort ID_t: gen overlap_4 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] != 1) & _n > 4 // see above with t-4
bysort ID_t: gen overlap_5 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] != 1) & _n > 5 // see above with t-5
bysort ID_t: gen overlap_6 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 6 // see above with t-6

bysort ID_t: gen overlap_7 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 7 // see above with t-6
bysort ID_t: gen overlap_8 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & _n > 8 // see above with t-6
bysort ID_t: gen overlap_9 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & _n > 9 // see above
bysort ID_t: gen overlap_10 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & _n > 10 // see above with t-6

bysort ID_t: gen overlap_11 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & _n > 11 
bysort ID_t: gen overlap_12 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)  & _n > 12 
bysort ID_t: gen overlap_13 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1) & _n > 13 
bysort ID_t: gen overlap_14 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1)  & (overlap[_n-13] != 1) & _n > 13 

sum overlap* // until 11

foreach num of numlist 1(1)11 {
	sum overlap_`num'
}

************* OVERLAP within other cell (bula remains the same) **************
foreach num of numlist 1(1)11 {
	bysort ID_t: gen overlap_inside_`num' = ((start_episode <= end_episode[_n-`num']) & (end_episode <= end_episode[_n-`num']))  if overlap_`num' == 1 //
}

foreach num of numlist 1(1)11 {
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_emp == kr_emp[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_emp == kr_emp[_n-1])  if overlap_inside_allein == 1


foreach num of numlist 1(1)11 {
	drop if overlap_inside_samekr_`num' == 1 
}
drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


************* OVERLAP with end_episode date of prior cell (bula remains the same -> combine periods) **************

gsort ID_t +start_episode -end_episode 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)20 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 788 *S* 1846 people with more than one overlap period remain


gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start_episode -end_episode 

bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_emp == kr_emp[_n+1]) & (end_episode[_n+1] > end_episode)  //overwrite state if there is a single overlap, the state is the same (no loss of info) and the following end-episode is bigger/later than the moment right now (meaning, the two periods have the same bula)

bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end_episode = end_episode[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*


gsort ID_t start_episode -end_episode 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n

foreach num of numlist 1(1)20 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 657 people with more than one overlap period remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_2.dta", replace
restore


**********************************************************************************
***********************STEP 4: Repeat steps 2 & 3*********************************
**********************************************************************************
drop if overlap_ges == 0
distinct ID_t // 657 individual with overlapping spells

gsort ID_t + start_episode - end_episode
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] != 1) & _n > 1 // only one overlap, before and after t no overlap -> Isolated overlap
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // overlap and period t+1 also has an overlap
bysort ID_t: gen overlap_2 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] != 1) & _n > 2  // overlap and previous period t-1 has an overlap, but not t-2
bysort ID_t: gen overlap_3 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] != 1) & _n > 3 // overlap and previous two periods t-1 and t-2 have an overlap, but not t-3
bysort ID_t: gen overlap_4 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] != 1) & _n > 4 // see above with t-4
bysort ID_t: gen overlap_5 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] != 1) & _n > 5 // see above with t-5
bysort ID_t: gen overlap_6 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 6 // see above with t-6

bysort ID_t: gen overlap_7 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & _n > 7 // see above with t-6
bysort ID_t: gen overlap_8 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & _n > 8 // see above with t-6
bysort ID_t: gen overlap_9 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & _n > 9 // see above
bysort ID_t: gen overlap_10 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & _n > 10 // see above with t-6

bysort ID_t: gen overlap_11 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & _n > 11 
bysort ID_t: gen overlap_12 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)  & _n > 12 
bysort ID_t: gen overlap_13 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1) & _n > 13 
bysort ID_t: gen overlap_14 = (overlap == 1) & (overlap[_n-1] == 1) & (overlap[_n-2] == 1) & (overlap[_n-3] == 1) & (overlap[_n-4] == 1) & (overlap[_n-5] == 1) & (overlap[_n-6] != 1) & (overlap[_n-7] != 1) & (overlap[_n-8] != 1) & (overlap[_n-9] != 1) & (overlap[_n-10] != 1) & (overlap[_n-11] != 1)& (overlap[_n-12] != 1)  & (overlap[_n-13] != 1) & _n > 13 

sum overlap* // until 11

************* OVERLAP within other cell (bula remains the same) **************
foreach num of numlist 1(1)11 {
	bysort ID_t: gen overlap_inside_`num' = ((start_episode <= end_episode[_n-`num']) & (end_episode <= end_episode[_n-`num']))  if overlap_`num' == 1 
}

foreach num of numlist 1(1)11 {
	sum overlap_inside_`num'
}

foreach num of numlist 1(1)10 {
	bysort ID_t: gen overlap_inside_samekr_`num' = (kr_emp == kr_emp[_n-`num']) if overlap_inside_`num' == 1 //
}

bysort ID_t: gen overlap_inside_allein = ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))  if overlap_allein == 1
bysort ID_t: gen overlap_inside_allein_samekr = (kr_emp == kr_emp[_n-1])  if overlap_inside_allein == 1

foreach num of numlist 1(1)10 {
	drop if overlap_inside_samekr_`num' == 1 
}

drop if overlap_inside_allein_samekr == 1

drop overlap - overlap_inside_allein_samekr


************* OVERLAP with end_episode date of prior cell (bula remains the same -> combine periods) **************

gsort ID_t +start_episode -end_episode 
* check if there are overlapping spells
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs // -> 19 left

foreach num of numlist 1(1)19 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 606 people with more than one overlap period remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


** combine periods if bula remains same and there is an overlap -> schreibe das ende der periode hoch und lösche die Zeile anschließend
gsort ID_t start_episode -end_episode 
bysort ID_t: gen hochschreiben = 1 if ((overlap_allein[_n+1] == 1) | (overlap_1[_n+1] == 1)) & (kr_emp == kr_emp[_n+1]) & (end_episode[_n+1] > end_episode)
bysort ID_t: gen hochschreiben_drop = 0 if hochschreiben[_n-1] == 1
bysort ID_t: replace end_episode = end_episode[_n+1] if hochschreiben == 1
drop if hochschreiben_drop == 0 
drop hochschreiben*


gsort ID_t start_episode -end_episode 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)18 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges >  0 // 593 people with more than one overlap period remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_3.dta", replace
restore


*******************************************************************************
************STEP 5: Look at cases that have overlaps NOT within same state******
*******************************************************************************
/* two cases can be detected
1. one period lies within other period, but bula are different
	-> if start_episode date == end_episode date -> delete spell (assumption: no mobility because of a couple of weeks)
	-> delete spell with shorter duration if it is not clearly "Hauptereignis"
	
2. end_episode date of cell 1 and start_episode date of cell 2 are overlapping
		-> cell 1 remains unchanged if it is "Hauptereignis" 
		-> start_episode date is adjusted to end_episode date of cell 1 + one month
*/

drop if overlap_ges == 0
distinct ID_t // 593 individual with overlapping spells

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1 // if overlap, but no overlap in the period before and after
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a overlap in the following period as well

*****************************************************************
gsort ID_t start_episode -end_episode 
drop overlap - overlap_1
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)18 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 593 people remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode > end_episode[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & (spms == 1) & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & (spms == 1) & (spms[_n-1] == 2)


bysort ID_t: replace start_episode = (end_episode[_n-1]+1) if crossover_clear == 1
bysort ID_t: replace end_episode  = (start_episode[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1


gsort ID_t start_episode -end_episode 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs // -> 17 left

foreach num of numlist 1(1)17 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 205 *S* 613 people remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_4.dta", replace
restore


*******************************************************************************
**************************STEP 6: Repeat step 5********************************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t // 205 individuals with overlapping spells

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 


* there are spells where end_episode date == start_episode date -> i do not consider it as mobility if that lies within a period of a different cell because it is unlikely that someone moves because of a course that lasts some weeks (independent if there is bundesland variation or not)
gsort ID_t start_episode -end_episode 
bysort ID_t: gen dur_1 = (end_episode - start_episode) if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1])) & spms != 1   
drop if dur_1 == 0


*****************************************************************
gsort ID_t start_episode -end_episode 
drop overlap - dur_1
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)16 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 205 people remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 


* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode > end_episode[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & spms == 1 & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & spms == 1 & (spms[_n-1] == 2)

bysort ID_t: replace start_episode = (end_episode[_n-1]+1) if crossover_clear == 1
bysort ID_t: replace end_episode  = (start_episode[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1


gsort ID_t start_episode -end_episode 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)15 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 101 *S* 314 people remain


*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_5.dta", replace
restore


*******************************************************************************
**************************STEP 7: Repeat step 6********************************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t // 101 individual with overlapping spells

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 


* there are spells where end_episode date == start_episode date -> i do not consider it as mobility if that lies within a period of a different cell because it is unlikely that someone moves because of a course that lasts some weeks (independent if there is bundesland variation or not)
gsort ID_t start_episode -end_episode 
bysort ID_t: gen dur_1 = (end_episode - start_episode) if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1])) & spms != 1   
drop if dur_1 == 0


*****************************************************************
gsort ID_t start_episode -end_episode 
drop overlap - dur_1
gen overlap = 0 
bysort ID_t: gen obs = _n

foreach num of numlist 1(1)15 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 101 people remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 



* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode > end_episode[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & spms == 1 & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & spms == 1 & (spms[_n-1] == 2)

bysort ID_t: replace start_episode = (end_episode[_n-1]+1) if crossover_clear == 1
bysort ID_t: replace end_episode  = (start_episode[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1


gsort ID_t start_episode -end_episode 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)14 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 72 *210* people remain

*save cases that apply to rules above
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_6.dta", replace
restore



*******************************************************************************
**************************STEP 8: Repeat step 7********************************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t // 74 individual with overlapping spells

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1


* there are spells where end_episode date == start_episode date -> i do not consider it as mobility if that lies within a period of a different cell because it is unlikely that someone moves because of a course that lasts some weeks (independent if there is bundesland variation or not)
gsort ID_t start_episode -end_episode 
bysort ID_t: gen dur_1 = (end_episode - start_episode) if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1])) & spms != 1   
drop if dur_1 == 0


*****************************************************************
gsort ID_t start_episode -end_episode 
drop overlap - dur_1
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)14 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 74 people remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 



* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode > end_episode[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & spms == 1 & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & spms == 1 & (spms[_n-1] == 2)

bysort ID_t: replace start_episode = (end_episode[_n-1]+1) if crossover_clear == 1
bysort ID_t: replace end_episode  = (start_episode[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1


gsort ID_t start_episode -end_episode 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)13 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 46 *S* 152 people remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_7.dta", replace
restore

**************************STEP 8.2: Repeat step 8********************************
*******************************************************************************

drop if overlap_ges == 0
distinct ID_t // 74 individual with overlapping spells

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1


* there are spells where end_episode date == start_episode date -> i do not consider it as mobility if that lies within a period of a different cell because it is unlikely that someone moves because of a course that lasts some weeks (independent if there is bundesland variation or not)
gsort ID_t start_episode -end_episode 
bysort ID_t: gen dur_1 = (end_episode - start_episode) if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1])) & spms != 1   
drop if dur_1 == 0


*****************************************************************
gsort ID_t start_episode -end_episode 
drop overlap - dur_1
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)14 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 74 people remain

gsort ID_t start_episode -end_episode 
bysort ID_t: gen overlap_allein = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] !=1) & _n > 1
bysort ID_t: gen overlap_1 = (overlap == 1) & (overlap[_n-1] != 1) & (overlap[_n+1] == 1) & _n > 1 // identify first spell if there is a 

* look if overlapping period lies within previous cell or is only overlapping
bysort ID_t: gen within = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode <= end_episode[_n-1]))   
bysort ID_t: gen crossover = 1 if (overlap_allein == 1 | overlap_1 == 1) & ((start_episode <= end_episode[_n-1]) & (end_episode > end_episode[_n-1]))   

* apply the rules for Hauptereignis
bysort ID_t: gen within_clear = (within == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen within_unclear = (within == 1) & spms == 1 & (spms[_n-1] == 2)

* apply the rules for Hauptereignis
bysort ID_t: gen crossover_clear = (crossover == 1) & ((spms[_n-1] == 1) | ((spms[_n-1] == 2) & (spms !=1))) 
bysort ID_t: gen crossover_unclear = (crossover == 1) & spms == 1 & (spms[_n-1] == 2)

bysort ID_t: replace start_episode = (end_episode[_n-1]+1) if crossover_clear == 1
bysort ID_t: replace end_episode  = (start_episode[_n+1]-1) if crossover_unclear[_n+1] == 1
drop if within_clear == 1


gsort ID_t start_episode -end_episode 
drop overlap - crossover_unclear
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs

foreach num of numlist 1(1)13 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

bysort ID_t: egen overlap_ges = total(overlap) // 
distinct ID_t if overlap_ges > 0 // 46 *S* 127 people remain

*save cases that apply to rules above*
preserve 
keep if overlap_ges == 0
save "$results\temp_EMPLOYMENT_overlap_8.dta", replace
restore


*******************************************************************************
*****************STEP 9: Manual coding of remaining cases**********************
*******************************************************************************
drop if overlap_ges == 0
distinct ID_t if overlap_ges > 0
total overlap // -> 92 *S* 230 overlaps left

gsort ID_t start_episode -end_episode 
bysort ID_t: drop if bl_emp == bl_emp[_n-1] & overlap == 1
*drop for each 
total overlap // -> 48 left

*Do Double-Occupations exist?
gen DoubleOcc = 0
bysort ID_t: replace DoubleOcc = 1 if overlap == 1 & ts23240_g1 != ts23240_g1[_n-1] // If overlap exists and in the period the occupation changes

*overlap rauswerfen bei Doppelbeschäftigungen, falls Bundesland gleich bleibt
bysort ID_t: drop if DoubleOcc == 1 & kr_emp[_n] == kr_emp[_n-1]
bysort ID_t: drop if DoubleOcc == 1 & kr_emp[_n] == kr_emp[_n+1]

gsort ID_t start_episode -end_episode 
drop overlap - overlap_ges
gen overlap = 0 
bysort ID_t: gen obs = _n
sum obs // -> 11 left

foreach num of numlist 1(1)11 {
	bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-`num'] & obs > `num'
}

clonevar bl_emp2 = bl_emp
bysort ID_t: replace bl_emp2 = bl_emp[_n+1] if overlap[_n+1] == 1 & bl_emp2[_n+1] != bl_emp

clonevar kr_emp2 = kr_emp
bysort ID_t: replace kr_emp2 = kr_emp[_n+1] if overlap[_n+1] == 1 & kr_emp2[_n+1] != kr_emp


drop if DoubleOcc
total(overlap) 

*Manual Overwrite 
br ID_t ID_t bl_emp kr_emp start_episode end_episode if overlap == 1

drop if overlap == 1 

bysort ID_t: egen overlap_ges = total(overlap)  
distinct ID_t if overlap_ges > 0 // 0 overlaps left 

save "$results\temp_EMPLOYMENT_overlap_manual.dta", replace


*******************************************************************************
*****************STEP 9: Combine all files*************************************
*******************************************************************************
use "$results\temp_EMPLOYMENT_overlap_0.dta", clear
append using "$results\temp_EMPLOYMENT_overlap_1.dta" 
append using "$results\temp_EMPLOYMENT_overlap_2.dta" 
append using "$results\temp_EMPLOYMENT_overlap_3.dta" 
append using "$results\temp_EMPLOYMENT_overlap_4.dta" 
append using "$results\temp_EMPLOYMENT_overlap_5.dta" 
append using "$results\temp_EMPLOYMENT_overlap_6.dta" 
append using "$results\temp_EMPLOYMENT_overlap_7.dta" 
append using "$results\temp_EMPLOYMENT_overlap_8.dta" 
append using "$results\temp_EMPLOYMENT_overlap_manual.dta" 


drop overlap - overlap_ges


**********************Quality check of combined file *******************
*check if there are any overlapping spells
gsort ID_t start_episode -end_episode 
gen overlap = 0 
bysort ID_t: replace overlap = 1 if start_episode <= end_episode[_n-1] & _n > 1
distinct ID_t if overlap == 1 // no overlaps anymore 
drop overlap


*check if there are no negative spell gaps
sort ID_t start_episode 
bysort ID_t: gen spell_gaps = start_episode - end_episode[_n-1]
bysort ID_t: replace spell_gaps = 1 if spell_gaps == . & _n==1 // first spell for each individual has no gap
sum spell_gaps, d // no negative spell gaps

*generate spell duration and expand in order create monthly observations for each spell
gen spell_dur = end_episode-start_episode+1 // +1 is important; else one month gets lost
sort ID_t start_episode
expand spell_dur // expand according to duration of spell


sort ID_t start_episode
bysort ID_t start_episode: gen date = start_episode if _n == 1
bysort ID_t start_episode: replace date = (date[_n-1]+1) if _n > 1 // create consecutive date on monthly basis
format date %tm

duplicates report ID_t date // no duplicates

label var bl_emp2 "State of Employment if more than one job"
label var kr_emp2 "District of Employment if more than one job"


erase "$results\temp_EMPLOYMENT_overlap_0.dta"
erase "$results\temp_EMPLOYMENT_overlap_1.dta" 
erase "$results\temp_EMPLOYMENT_overlap_2.dta" 
erase "$results\temp_EMPLOYMENT_overlap_3.dta" 
erase "$results\temp_EMPLOYMENT_overlap_4.dta" 
erase "$results\temp_EMPLOYMENT_overlap_5.dta" 
erase "$results\temp_EMPLOYMENT_overlap_6.dta" 
erase "$results\temp_EMPLOYMENT_overlap_7.dta" 
erase "$results\temp_EMPLOYMENT_overlap_8.dta" 
erase "$results\temp_EMPLOYMENT_overlap_manual.dta" 

*drop everything that is finally unnecessary
keep ID_t bl_emp  kr_emp bl_emp2 kr_emp2 date


compress 
save "$results\temp_EMPLOYMENT_UrbanRural.dta", replace



