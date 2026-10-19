use "$data\schooling_laws_west.dta", clear 
append using "$results\schooling_laws_east.dta"
label def bula 12 "12:Brandenburg" 13 "13:Meck-Vorpommern" 14 "14:Sachsen" 15 "15:Sachsen-Anhalt" 16 "16:Thüringen", modify // label bulas in east germany
label val bula bula
save "$results\schooling_laws_all.dta", replace 