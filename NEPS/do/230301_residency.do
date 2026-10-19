/**************************************************
    Extracts and merges data on the residency spells 
	to the basic panel
	
***************************************************/


************************************************
*     place of residence at the interview
************************************************

****** panel data from pTarget ******
use "$data\SC6_pTarget_R_13-0-0.dta", clear
sort ID_t wave 

*** place of residence at interview
clonevar bl_interw =t751001_g2 if t751001_g2>0 // Bundesland
lab var bl_interw "Bundesland of residence at interview" // ggf. mit bl_samp in der 1.Welle aufüllen?

clonevar bl_interw2 =t751011_g2 if t751011_g2>0 // Bundesland Zweitwohnsitz
lab var bl_interw2 "Bundesland of residence at interview, Zweitwohnsitz" 

clonevar kr_interw =t751001_g4R if t751001_g4R >= 0 // Kreis
lab var kr_interw "Kreis of residence at interview"

clonevar kr_interw2 =t751011_g4R if t751011_g4R >= 0
lab var kr_interw2 "Kreis of residence at interview, Zweitwohnsitz"

sort ID_t wave
foreach var of varlist bl_interw bl_interw2 kr_interw bl_interw2 {
bysort ID_t: replace `var'=`var'[_n-1] if `var'==. & `var'[_n-1]==`var'[_n+1] & `var'[_n-1]!=.
}

keep ID_t wave bl_* kr_*

****** merge panel data from CohortProfile ******
joinby ID_t wave using "$data\SC6_CohortProfile_R_13-0-0.dta", unmatched(master)

*** interview date 
recode tx8600m  (-100/0=.)
gen date =ym(tx8600y, tx8600m)
format *date* %tm

keep ID_t bl_* kr_* date

*** check duplicates in months per person	
sort ID_t date
duplicates report ID_t date // no duplicates
duplicates drop ID_t date, force

compress
save "$results\temp_residint.dta", replace


************************************************
*     residencial spells 
************************************************
**** SC6_spResidence_D_11-1-0 /*only for selected cohorts >=1956*/
use "$data\SC6_spResidence_R_13-0-0.dta", clear

*** place of residence 
clonevar bl_resid = th21111_g2 if th21111_g2>0
clonevar kr_resid = th21111_g4R if th21111_g4R >= 0
recode bl_resid kr_resid (.=0) if th21102_g1==2 // Ausland
clonevar inter_resid = th21109
recode inter_resid (2=0)

*** check subspells
sort ID_t spell subspell
tab subspell bl_resid, mis
bysort ID_t spell: replace bl_resid=bl_resid[_n+1] if bl_resid==. & bl_resid[_n+1]!=. & subspell==0 // OK

sort ID_t spell subspell
bysort ID_t spell: replace kr_resid=kr_resid[_n+1] if kr_resid==. & kr_resid[_n+1]!=. & subspell==0 // *S* looks good, too. 0 changes made

*S* Subspells for kr_ and bl_
keep if subspell==0

*** end/start dates of the spells
recode th21105 th21106 th21107 th21108 (-100/0=.)
recode th21105 th21107 (21=1) (24=4) (27=7) (30=10) (32=12) // recode seasons to months
replace th21105=1 if th21105==. & th21106!=. // replace starting date by Jan if month mis
replace th21107=12 if th21107==. & th21108!=. // replace end date by Dec if month mis

gen date_s=ym(th21106, th21105)  // start and end dates
gen date_e=ym(th21108, th21107) 
format *date* %tm

*** impute missing end/start dates from the previous/next spell
sort ID_t spell date_s date_e
bysort ID_t:replace date_e=date_s[_n+1]-1 if date_e==. & date_s[_n+1]!=. & date_s[_n+1]>=date_s
bysort ID_t:replace date_s=date_e[_n-1]+1 if date_s==. & date_e[_n-1]!=. & date_e[_n-1]<=date_e
keep ID_t spell date_e date_s bl_* kr_* inter_resid

*** generate monthly panel
gen months = date_e-date_s + 1 //temp variable counting the spell duration in months 
sum months

br ID_t spell date_s date_e bl* kr* months if months<=0 // check negative spell durations
br ID_t spell date_s date_e bl* kr* months if ID_t==8010171 // selected examples ID_t: 8005530 8012722 

replace date_e = date_s if months==0 // cleaning
recode months (0=1)

replace date_e = ym(1996, 12) if months<0 & ID_t==8005306 // manual cleaning ID_t 8005280 8005306 8010171
replace date_e = ym(2011, 12) if months<0 & ID_t==8005280
drop if months<0 & ID_t==8010171 

replace months = date_e-date_s + 1 if months<0
keep if months>=0


expand months // generate separate observations for each month
compress

sort ID_t spell

bysort ID_t spell: gen date = date_s[1] + _n - 1 // generate consecutive monthly date
format *date* %tm
drop date_s date_e
	
*** check duplicates in months per person	
sort ID_t date bl_resid kr_resid
duplicates drop ID_t date bl_resid kr_resid, force 

duplicates tag ID_t date bl_resid kr_resid, gen(duple)
tab duple, mis
drop duple


duplicates tag ID_t date, gen(duple) // check duplicates in dates where Bundesland is different
tab duple, mis
gsort +ID_t +date +bl_resid +kr_resid -months // if duplicates in dates, select the longer spell

duplicates drop ID_t date, force

drop duple months spell
compress
save "$results\temp_residsp.dta", replace

br if bl_resid == 0 & kr_resid != 0
br if bl_resid != 0 & kr_resid == 0
count if kr_resid == . // 56152 without kreis
count if bl_resid == . // 1366 without bula

************************************************/
*     merging to basic panel
************************************************
use "$results\0_basicpanel.dta", clear

joinby ID_t date using "$results\temp_residint.dta", unmatched(master)
tab _merge, mis
drop _merge

joinby ID_t date using "$results\temp_residsp.dta", unmatched(master)
tab _merge, mis
drop _merge

compress
sort ID_t date
drop wave


