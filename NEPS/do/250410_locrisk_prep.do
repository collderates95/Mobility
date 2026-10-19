********************************************************************************
* Step 1: Prepare Data
********************************************************************************
*** Prepare pTarget
use "$data\SC6_pTarget_R_13-0-0.dta", clear

*** Risk-Aversion and Locus of Controll *** 
* Risk Aversion: t515052 t515053 t515054 t515051
recode t515052 (-99/-1 = .), gen(RiskAffMoney)
recode t515053 (-99/-1 = .), gen(RiskAffHobbySport)
recode t515054 (-99/-1 = .), gen(RiskAffJob)
recode t515051 (-99/-1 = .), gen(RiskAffGeneral)

* Locus Of Controll: t67010a t67010a_g1 t67010b t67010b_g1 t67010c t67010d
* Internal Locus of Controll
recode t67010a_g1 (-99/0 = .), gen(LOCinternal)
recode t67010a (-99/0 = .), gen(LOCOwnDestiny)
recode t67010c (-99/0 = .), gen(LOCSucessWithWork)

* External Locus of Controll
recode t67010b_g1 (-99/0 = .), gen(LOCexternal)
recode t67010b (-99/0 = .), gen(LOCDestinyUnfair)
recode t67010d (-99/0 = .), gen(LOCLifeDestOther)

* keep and make beautifull panel
keep ID_t wave LOC* RiskAff*
sort ID_t wave

* clean for later merge
drop if RiskAffGeneral == . & LOCinternal == . & LOCexternal == .

* Reshape Data
reshape wide RiskAffGeneral RiskAffMoney RiskAffHobbySport RiskAffJob LOCinternal LOCOwnDestiny LOCSucessWithWork LOCexternal LOCDestinyUnfair LOCLifeDestOther, i(ID_t) j(wave)

* Clean Risk Affinity
drop RiskAffMoney6 RiskAffMoney7 RiskAffMoney10 RiskAffMoney12 RiskAffMoney13
drop RiskAffHobbySport6 RiskAffHobbySport7 RiskAffHobbySport10 RiskAffHobbySport12 RiskAffHobbySport13
drop RiskAffJob6 RiskAffJob7 RiskAffJob10 RiskAffJob12 RiskAffJob13
drop RiskAffGeneral6

* Clean LOC
drop LOCinternal7 LOCinternal8 LOCinternal10 LOCinternal12
drop LOCSucessWithWork7 LOCSucessWithWork8 LOCSucessWithWork10 LOCSucessWithWork12
drop LOCOwnDestiny7 LOCOwnDestiny8 LOCOwnDestiny10 LOCOwnDestiny12
drop LOCexternal7 LOCexternal8 LOCexternal10 LOCexternal12
drop LOCLifeDestOther7 LOCLifeDestOther8 LOCLifeDestOther10 LOCLifeDestOther12
drop LOCDestinyUnfair7 LOCDestinyUnfair8 LOCDestinyUnfair10 LOCDestinyUnfair12

* Order
order ID_t Risk* LOC*

********************************************************************************
* Step 2: Prepare Wave Specific Z - Scores and THEN take mean from these Z - Scores
********************************************************************************
*** Wave Specific z- Score
foreach var in RiskAffGeneral7 RiskAffGeneral8 RiskAffGeneral10 RiskAffGeneral12 RiskAffGeneral13 RiskAffMoney8 RiskAffHobbySport8 RiskAffJob8 LOCinternal6 LOCOwnDestiny6 LOCSucessWithWork6 LOCexternal6 LOCDestinyUnfair6 LOCLifeDestOther6 LOCinternal13 LOCOwnDestiny13 LOCSucessWithWork13 LOCexternal13 LOCDestinyUnfair13 LOCLifeDestOther13 {
	center `var', generate(z`var') standardize // No Weight So far
	drop `var'
}

*** Mean From all Wave - Specific z-Scores
*** Risk Affinity 
egen zmRiskAffGeneral = rowmean(zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13)
egen zmLOCinternal = rowmean(zLOCinternal6 zLOCinternal13)
egen zmLOCOwnDestiny = rowmean(zLOCOwnDestiny6 zLOCOwnDestiny13)
egen zmLOCSucessWithWork = rowmean(zLOCSucessWithWork6 zLOCSucessWithWork13)
egen zmLOCexternal = rowmean(zLOCexternal6 zLOCexternal13)
egen zmLOCDestinyUnfair = rowmean(zLOCDestinyUnfair6 zLOCDestinyUnfair13)
egen zmLOCLifeDestOther = rowmean(zLOCLifeDestOther6 zLOCLifeDestOther13)

*************************
* gen First Observation per Individual
*************************
*** Risk Affinity 
egen first_RiskAffGeneral = rowfirst(  zRiskAffGeneral7 zRiskAffGeneral8 zRiskAffGeneral10 zRiskAffGeneral12 zRiskAffGeneral13)  // 

*** LOC
egen first_LOCinternal = rowfirst( zLOCinternal6 zLOCinternal13 ) // 
egen first_LOCOwnDestiny = rowfirst( zLOCOwnDestiny6 zLOCOwnDestiny13 ) // 
egen first_LOCSucessWithWork = rowfirst( zLOCSucessWithWork6 zLOCSucessWithWork13 ) // 
egen first_LOCexternal = rowfirst( zLOCexternal6 zLOCexternal13 ) // 
egen first_LOCDestinyUnfair = rowfirst( zLOCDestinyUnfair6 zLOCDestinyUnfair13 ) // 
egen first_LOCLifeDestOther = rowfirst( zLOCLifeDestOther6 zLOCLifeDestOther13 ) // 

*************************
*** Gen Wave Fixed Effect
*************************
*** Make Categorical Variables for our Means: When was the First Participation? ***
*** Define Earliest Participation ***
*** Risk Affinity 
gen FirstWave_RiskAffGeneral = 0
replace FirstWave_RiskAffGeneral = 13 if zRiskAffGeneral13 != .
replace FirstWave_RiskAffGeneral = 12 if zRiskAffGeneral12 != .
replace FirstWave_RiskAffGeneral = 10 if zRiskAffGeneral10 != .
replace FirstWave_RiskAffGeneral = 8 if zRiskAffGeneral8 != .
replace FirstWave_RiskAffGeneral = 7 if zRiskAffGeneral7 != .

*** LOC
gen FirstWave_LOCinternal = 0
replace FirstWave_LOCinternal = 13 if zLOCinternal13 != .
replace FirstWave_LOCinternal = 6 if zLOCinternal6 != .

gen FirstWave_LOCSucessWithWork = 0
replace FirstWave_LOCSucessWithWork = 13 if zLOCSucessWithWork13 != .
replace FirstWave_LOCSucessWithWork = 6 if zLOCSucessWithWork6 != .

gen FirstWave_LOCexternal = 0
replace FirstWave_LOCexternal = 13 if zLOCexternal13 != .
replace FirstWave_LOCexternal = 6 if zLOCexternal6 != .

gen FirstWave_LOCDestinyUnfair = 0
replace FirstWave_LOCDestinyUnfair = 13 if zLOCDestinyUnfair13 != .
replace FirstWave_LOCDestinyUnfair = 6 if zLOCDestinyUnfair6 != .

gen FirstWave_LOCLifeDestOther = 0
replace FirstWave_LOCLifeDestOther = 13 if zLOCLifeDestOther13 != .
replace FirstWave_LOCLifeDestOther = 6 if zLOCLifeDestOther6 != .

*** Save for later Merge
save "$results\RiskAndLocus.dta", replace