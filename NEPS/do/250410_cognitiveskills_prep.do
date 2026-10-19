********************************************************************************
* Step 1: Prepare Original Data- Set, Standardize and Mean there and Later Merge it on RDD and C9 - Samples
********************************************************************************
*** Open Competencies ***
use "$data\SC6_xTargetCompetencies_R_13-0-0.dta", clear

*** Check Variables ***
*** WLE
sum *_sc1
foreach var in rea3_sc1 rea5_sc1 rea9_sc1 sca5_sc1 maa3_sc1 maa9_sc1 ica5_sc1 {
	recode `var' (-56 = .) (-55 = .)
}

*** Score
sum *_sc3*
foreach var in rsa3_sc3 rsa5_sc3 voa7_sc3 dga7_sc3b dga7_sc3a {
	recode `var' (-97 = .) (-91 = .) (-55 = .) (-56 = .)
}

*** Meta-Cognition ( Self - Assesment )
sum mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6
foreach var in mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6 {
	recode `var' (-97 = .) (-95 = .) (-94 = .) (-90 = .) (-56 = .) (-55 = .) (-54 = .)
}

* Rename Variables
rename (rea3_sc1 rea5_sc1 rea9_sc1 sca5_sc1 maa3_sc1 maa9_sc1 ica5_sc1) (Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5)
rename (rsa3_sc3 rsa5_sc3 voa7_sc3 dga7_sc3b dga7_sc3a) (ReadSpeed3 ReadSpeed5 Vocabulary7 CogConclude7 CogAwareness7)
rename (mpa3re_sc6 mpa5re_sc6  mpa9re_sc6 mpa3ma_sc6 mpa9ma_sc6 mpa5sc_sc6 mpa5ic_sc6 mpa7vo_sc6) (SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 SelfVocabulary7)

*** Keep and Further Prepare
keep ID_t Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary7 CogConclude7 CogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 SelfVocabulary7 wave_w3 wave_w5 wave_w7 wave_w9 

********************************************************************************
* Step 2: Prepare Wave Specific Z - Scores and THEN take mean from these Z - Scores
********************************************************************************
*** Wave Specific z- Score
foreach var in Reading3 Reading5 Reading9 Science5 Math3 Math9 Computer5 ReadSpeed3 ReadSpeed5 Vocabulary7 SelfVocabulary7 CogConclude7 CogAwareness7 SelfRead3 SelfRead5 SelfRead9 SelfMath3 SelfMath9 SelfScience5 SelfComputer5 {
	center `var', generate(z`var') standardize // No Weight So far
	drop `var'
}

*** Mean From all Wave - Specific z-Scores
egen zmReading = rowmean(zReading3 zReading5 zReading9)
egen zmMath = rowmean(zMath3 zMath9)
egen zmReadSpeed = rowmean(zReadSpeed3 zReadSpeed5)
egen zmSelfRead = rowmean(zSelfRead3 zSelfRead5 zSelfRead9)
egen zmSelfMath = rowmean(zSelfMath3 zSelfMath9)

********************************************************************************
* Step 3: New Label and Export
********************************************************************************
label var zReading3 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 3."
label var zReading5 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 5."
label var zReading9 "WLE No. Corr. Answ. Text Compreh. Standard. Within Wave 9."
label var zScience5 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 5."
label var zMath3 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 3."
label var zMath9 "WLE No. Corr. Answ. Science Questions. Standard. Within Wave 9."
label var zComputer5 "WLE No. Corr. Answ. ICT Questions. Standard. Within Wave 9."
label var zReadSpeed3 "Score Reading Speed. Standard. Within Wave 3."
label var zReadSpeed5 "Score Reading Speed. Standard. Within Wave 9."
label var zVocabulary7 "Score Vocabulary Depth. Standard. Within Wave 3."
label var zSelfVocabulary7 "Self-Assed Share of Corr. Answ. Vocabulary Depth. Stand. With. Wave 7"
label var zCogConclude7 "WLE No. Corr. Answ. Logic Test. Standard. Within Wave 7."
label var zCogAwareness7 "WLE No. Corr. Answ. Awareness Test. Standard. Within Wave 7."
label var zSelfRead3 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 3."
label var zSelfRead5 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 5."
label var zSelfRead9 "Self-Assed Share of Corr. Answ. Text Compreh. Standard. Within Wave 9."
label var zSelfMath3 "Self-Assed Share of Corr. Answ. Math. Standard. Within Wave 3."
label var zSelfMath9 "Self-Assed Share of Corr. Answ. Math. Standard. Within Wave 9."
label var zSelfScience5 "Self-Assed Share of Corr. Answ. Science. Standard. Within Wave 5."
label var zSelfComputer5 "Self-Assed Share of Corr. Answ. ICT. Standard. Within Wave 5."
label var zmReading "Mean of all avail. waves Reading Competence."
label var zmMath "Mean of all avail. waves Math Competence."
label var zmReadSpeed "Mean of all avail. waves Reading Speed Competence."
label var zmSelfRead "Mean of all avail. waves Self-Asses. Reading Competence."
label var zmSelfMath "Mean of all avail. waves Self-Asses. Math Competence."


*************************
* gen First Observation per Individual
*************************
egen first_Reading = rowfirst( zReading3 zReading5 zReading9 ) // 
egen first_Science = rowfirst( zScience5 ) // 
egen first_Math = rowfirst( zMath3 zMath9 ) // 
egen first_Computer = rowfirst( zComputer5 ) // 
egen first_ReadSpeed = rowfirst( zReadSpeed3 zReadSpeed5 ) // 
egen first_Vocabulary = rowfirst( zVocabulary7 ) // 
egen first_CogConclude = rowfirst( zCogConclude7 ) // 
egen first_CogAwareness = rowfirst( zCogAwareness7 ) // 
egen first_SelfRead = rowfirst( zSelfRead3 zSelfRead5 zSelfRead9 ) // 
egen first_SelfMath = rowfirst( zSelfMath3 zSelfMath9 ) // 
egen first_SelfScience = rowfirst( zSelfScience5 ) // 
egen first_SelfComputer = rowfirst( zSelfComputer5 ) // 
egen first_SelfVocabulary = rowfirst( zSelfVocabulary7 )

*************************
*** Gen Wave Fixed Effect
*************************
*** Make Categorical Variables for our Means: When was the First Participation? ***
*** Define Earliest Participation ***
gen FirstWave_Reading = 0
replace FirstWave_Reading = 9 if zReading9 != .
replace FirstWave_Reading = 5 if zReading5 != .
replace FirstWave_Reading = 3 if zReading3 != .

gen FirstWave_Math = 0
replace FirstWave_Math = 9 if zMath9 != .
replace FirstWave_Math = 3 if zMath3 != .

gen FirstWave_ReadingSpeed = 0
replace FirstWave_ReadingSpeed = 5 if zReadSpeed5 != .
replace FirstWave_ReadingSpeed = 3 if zReadSpeed3 != .

gen FirstWave_SelfRead = 0
replace FirstWave_SelfRead = 9 if zSelfRead9 != .
replace FirstWave_SelfRead = 5 if zSelfRead5 != .
replace FirstWave_SelfRead = 3 if zSelfRead3 != .


gen FirstWave_SelfMath = 0
replace FirstWave_SelfMath = 9 if zSelfMath9 != .
replace FirstWave_SelfMath = 3 if zSelfMath3 != .

*** Export
save "$results/CognitiveSkills_new.dta", replace