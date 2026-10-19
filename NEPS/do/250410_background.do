**********************Background variables

* Load dataset
use "$data\SC6_pTarget_R_13-0-0.dta", clear

************************************************
* Information on Siblings (Both Older and Younger)
************************************************
* Younger Sibs
clonevar NumberOfSibs_ = t732101 if t732101 >= 0 & t732101 != . // no. of siblings
bysort ID_t: egen NumberOfSibs = max(NumberOfSibs_)
drop NumberOfSibs_
lab var NumberOfSibs "Number of siblings"

gen NumberOfSibs_m = (NumberOfSibs == .)
lab var NumberOfSibs_m "Dummy Number of siblings Missing"

recode NumberOfSibs (. = 0), gen(NumberOfSibs_T)  // Missing 332
lab var NumberOfSibs_T "Number of siblings, Missing Absorbed to 0

*Oldest Sibs
clonevar NumberOfOlderSibs_ = t732102 if t732102 >= 0 & t732102 != . // no. of siblings
bysort ID_t: egen NumberOfOlderSibs = max(NumberOfOlderSibs_)
drop NumberOfOlderSibs_
lab var NumberOfOlderSibs "Number of older siblings"

replace NumberOfOlderSibs = 0 if NumberOfOlderSibs == . & NumberOfSibs == 0
replace NumberOfOlderSibs = NumberOfSibs if NumberOfOlderSibs > NumberOfSibs 

gen NumberOfOlderSibs_m = (NumberOfOlderSibs == .)
lab var NumberOfOlderSibs_m "Dummy Number of Older siblings Missing"
*S* Attention: Less Number of observations for Older Sibs (more Missing)

recode NumberOfOlderSibs (. = 0), gen(NumberOfOlderSibs_T)  // Missing 332
lab var NumberOfOlderSibs_T "Number of Older siblings, Missing Absorbed to 0"

*Dummy at least one older sibling
recode NumberOfOlderSibs_T (1/99 = 1), gen(OlderSibling)
lab var OlderSibling "Dummy: Individual has at least one older Sibling"
recode NumberOfOlderSibs (. = 0) (0 = 1) (1/99 = 2), gen(OlderSibling_T2)
label define l_OlderSibling_T2 0 "At least one older sibling: Missing" 1 "At least one older sibling: No" 2 "At least one older sibling: Yes"
label values OlderSibling_T2 l_OlderSibling_T2

************************************************
* Information on Migration Background of Parents (Born in Germany)
************************************************

gen m_gerborn_=inlist(t405060_g1,1,2) if t405060_g1>0 & t405060_g1!=. // born in Germany
bysort ID_t: egen m_gerborn=min(m_gerborn_)
gen f_gerborn_=inlist(t405090_g1,1,2) if t405090_g1>0 & t405090_g1!=.
bysort ID_t: egen f_gerborn=min(f_gerborn_)
lab var m_gerborn "Mother: born in Germany"
lab var f_gerborn "Father: born in Germany"

recode m_gerborn (. = 0) (0 = 1) (1 = 2), gen(m_gerborn_T2)
recode f_gerborn (. = 0) (0 = 1) (1 = 2), gen(f_gerborn_T2)
lab var m_gerborn_T2 "Mother: born in Germany. 0 Missing 1 Yes 2 No"
lab var f_gerborn_T2 "Father: born in Germany. 0 Missing 1 Yes 2 No"

gen m_gerborn_T2_m = (m_gerborn_T2 == 0)
gen f_gerborn_T2_m = (f_gerborn_T2 == 0)
lab var m_gerborn_T2_m "Father: born in Germany. Dummy Missing"
lab var f_gerborn_T2_m "Father: born in Germany. Dummy Missing"

label define l_m_gerborn_T2 0 "Mother Born in Germany: Missing" 1 "Mother Born in Germany: No" 2 "Mother Born in Germany: Yes" 
label define l_f_gerborn_T2 0 "Father Born in Germany: Missing" 1 "Father Born in Germany: No" 2 "Father Born in Germany: Yes" 

label values m_gerborn_T2 l_m_gerborn_T2
label values f_gerborn_T2 l_f_gerborn_T2

*Harmonized Spell 
gen m_gerborn2_=inlist(t405060_ha,1) if t405060_ha>0 & t405060_ha !=. // born in Germany
bysort ID_t: egen m_gerborn_ha =min(m_gerborn2_)
gen f_gerborn2_=inlist(t405090_ha,1) if t405090_ha>0 & t405090_ha !=.
bysort ID_t: egen f_gerborn_ha =min(f_gerborn2_)
lab var m_gerborn_ha "Mother: born in Germany. From _ha"
lab var f_gerborn_ha "Father: born in Germany. From _ha"

recode m_gerborn_ha (. = -1) (0 = 0) (1 = 1), gen(D_m_gerborn_ha) 
recode f_gerborn_ha (. = -1) (0 = 0) (1 = 1), gen(D_f_gerborn_ha) 

gen D_m_gerborn_ha_m = (D_m_gerborn_ha == -1)
gen D_f_gerborn_ha_m = (D_f_gerborn_ha == -1)

egen p_gerborn_ha_new = rowmax(D_m_gerborn_ha D_f_gerborn_ha)
gen p_gerborn_ha_new_m = (D_m_gerborn_ha_m == 1 & D_f_gerborn_ha_m == 1)

*"At least one parent has migration background"
egen p_gerborn_max = rowmax(f_gerborn_T2 m_gerborn_T2) // *_gerborn_T2: Born in Germany: YES! Max() == 1  mean ""
recode p_gerborn_max (0 = 0) (1 = 2) (2 = 1)
label define l_p_gerborn_max 0 "Parental Migrantion: Missing" 1 "Parental Migrantion: One or both Parents Migrants" 2 "Parental Migrantion: One or Both Parents German" 
label values p_gerborn_max l_p_gerborn_max

*Main Control-Variable: "At least one parent is German"
* At least one parent German (0 = No 1 = Yes)
recode m_gerborn_T2 (0 = 0) (1 = 0) (2 =1), gen(D_m_gerborn) // wichtig dazu: miss nicht vergessen! m_gerborn_T2_m
recode f_gerborn_T2 (0 = 0) (1 = 0) (2 =1), gen(D_f_gerborn) // wichtig dazu: miss nicht vergessen! f_gerborn_T2_m

egen p_gerborn2_new = rowmax(D_m_gerborn D_f_gerborn)
gen p_gerborn2_new_mis = (m_gerborn_T2_m == 1 & f_gerborn_T2_m == 1)

label var p_gerborn2_new "Dummy: At least one parent German"
label var p_gerborn2_new_mis "Dummy: At least one parent German: Missing" 

************************************************
* Individual visited Kita
************************************************
clonevar JoinedKita = t712001
foreach var in JoinedKita {
	recode `var' (-99/-1 = .)
	recode `var' (1=1 "Yes") (2=0 "No"), gen(`var'2)
	bysort ID_t: egen `var'3 = max(`var'2)
	drop `var' `var'2
	rename `var'3 `var'
	tab `var'
	lab var JoinedKita "Dummy Individual Joined Kita"
}

gen JoinedKita_m = (JoinedKita == .)
lab var JoinedKita_m "Dummy Individual Joined Kita is Missing"

recode JoinedKita (. = 0), gen(JoinedKita_T) // Missing 92
recode JoinedKita (. = 0 "Missing") (0=1 "No") (1=2 "Yes"), gen(JoinedKita_T2) // Missing 92
lab var JoinedKita_T2 "Dummy Individual Joined Kita. 0 Missing 1 No 2 Yes"

label define l_JoinedKita_T2 0 "Joined Kita: Missing" 1 "Joined Kita: No" 2 "Joined Kita: Yes" 
label values JoinedKita_T2 l_JoinedKita_T2


************************************************
* *Keep Relevant Variables and Save .dta for later merge
************************************************
keep ID_t OlderSibling_T2 JoinedKita_T2 p_gerborn_ha_new p_gerborn_ha_new_m
*DELETE: NumberOfSibs NumberOfSibs_m NumberOfSibs_T NumberOfOlderSibs NumberOfOlderSibs_T NumberOfOlderSibs_m OlderSibling JoinedKita JoinedKita_T JoinedKita_m m_gerborn_T2 m_gerborn_T2_m f_gerborn_T2 f_gerborn_T2_m p_gerborn_max p_gerborn2_new p_gerborn2_new_mis
duplicates drop ID_t, force
save "$results\background_temp.dta", replace