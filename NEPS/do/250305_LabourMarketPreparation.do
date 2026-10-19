/**************************************************
This file will do the Labour Market Preparation To Merge to our Basic_Panel
	
***************************************************/

* Load Data (needs to be provided by FDZ)
use "$lm\AllButPop.dta", clear

* Keep Relevant Stuff and De-String
clonevar County2021_safety = County2021 
rename County2021 kreis
replace kreis = substr(kreis, 1, length(kreis) - 3)
destring LabourNum2021 Metropol2021 kreis, replace
drop AGS2021 ARS2021 AGSNAME2021 
duplicates drop kreis, force

sort kreis
replace kreis = 3152 if kreis == 3159

expand 2 if kreis == 3152, gen(Dup1)
replace kreis = 3156 if Dup1 == 1
drop Dup1

expand 2 if kreis == 16063, gen(Dup2)
replace kreis = 16056 if Dup2 == 1
drop Dup2

sort kreis 

* Final Cleaning
destring LabourIAB2021, replace
drop LongAGS LatAGS County2021_safety

* Save Final Dataset
compress
save "$lm\Merge_LabourMarketMetropol.dta", replace 