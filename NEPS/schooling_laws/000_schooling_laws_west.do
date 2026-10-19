capture log close
log using "$log/000_schooling_laws_dataset.log", replace

set more off
set varabbrev off


/**************************************************
	Generate schooling laws indicators: 
entry           float   %tdD_m_CY             date of school entry (statutory)
exit            float   %tdD_m_CY             date of exit after compulsory schooling (statutory)
stime4          float   %9.0g                 duration of elementary schooling (grades 1-4)
stime8          float   %9.0g                 duration of post-elementary schooling (grades 5-8/9)
stime           float   %9.0g                 statutory time of compulsory schooling
en_size         float   %9.0g                 size of enrollment cohort
entry_y         float   %9.0g                 year of school enrollment (statutory entry cohort)
fall            float   %9.0g                 school enrollment in fall (vs. spring)
fallg           float   %9.0g                 school graduation in fall (vs. spring)
age_entry_m     float   %9.0g                 age at school entry (statutory, detailed)
C9              float   %9.0g                 =1 if exposed to compulsory schooling extension (8->9 yrs)
SSY             float   %9.0g                 no. short school yrs (0, 1, or 2)
SSY_            float   %9.0g                 =1 if exposed to any short school yrs
SSY4            float   %9.0g                 yrs of exposure to short school yrs (grade 1-4)
SSY8            float   %9.0g                 yrs of exposure to short school yrs (grade 5-8/9)
SSY48           float   %9.0g                 yrs of exposure to short school yrs (total)
C9_SSY          float   %9.0g                 =1 if 9th year was a short school yr
SSY_mid         float   %9.0g                 yrs of additional exposure to short school yrs in mid. track
SSY_aca         float   %9.0g                 yrs of additional exposure to short school yrs in acad. track
age_rel         float   %9.0g                 age at school entry (relative to statut. cutoff)  
		
	Author: Kamila Cygan-Rehm
	
	Version: 1.0
	Created: 2022-12-12
	
***************************************************/
clear
set obs 2
gen date =.

replace date = date("1/1/1944","DMY") in 1
replace date = date("31/12/1995","DMY") in 2
tsset date
tsfill 
format %td date

gen yob=year(date)
gen mob=month(date)

duplicates drop yob mob, force

expand 16
sort date
gen bula = .
replace bula = _n in 1/16

replace bula = _n-int(_n/16)*16 in  17/l
recode bula (0=16)
keep if bula<11

lab def bula 1 "1:Schleswig-Holstein" 2 "2:Hamburg" 3 "3:Lower Saxony" 4 "4:Bremen" ///
		5 "5:North Rhine-Westphalia" 6 "6:Hesse" 7 "7:Rhineland-Palatinate" 8 "8:Baden-Wuerttemberg" ///
		9 "9:Bavaria" 10 "10:Saarland"
lab val bula bula

lab var bula "state"
lab var mob "month of birth"
lab var yob "year of birth"
lab var date "date of birth"

rename date bdate


*capture{
***** Schooling laws *****
*capture{
*** 9 - BAYERN ***
* school entry (bitte für Bayern überall den 1.9. für Beginn des Schuljahres annehmen)
gen entry = date("1/9/1950","DMY") if bula == 9 & yob == 1944
format %tdD_m_CY entry
replace entry = date("1/9/1951","DMY") if bula == 9 & yob == 1945 
replace entry = date("1/9/1952","DMY") if bula == 9 & yob == 1946 & mob>=1 & mob<=9  
replace entry = date("1/9/1953","DMY") if bula == 9 & yob == 1946 & mob>=10 & mob<=12 
replace entry = date("1/9/1953","DMY") if bula == 9 & yob == 1947 & mob>=1 & mob<=9  
replace entry = date("1/9/1954","DMY") if bula == 9 & yob == 1947 & mob>=10 & mob<=12 
replace entry = date("1/9/1954","DMY") if bula == 9 & yob == 1948 & mob>=1 & mob<=9  
replace entry = date("1/9/1955","DMY") if bula == 9 & yob == 1948 & mob>=10 & mob<=12 
replace entry = date("1/9/1955","DMY") if bula == 9 & yob == 1949 & mob>=1 & mob<=9  
replace entry = date("1/9/1956","DMY") if bula == 9 & yob == 1949 & mob>=10 & mob<=12 
replace entry = date("1/9/1956","DMY") if bula == 9 & yob == 1950 & mob>=1 & mob<=9  
replace entry = date("1/9/1957","DMY") if bula == 9 & yob == 1950 & mob>=10 & mob<=12 
replace entry = date("1/9/1957","DMY") if bula == 9 & yob == 1951 & mob>=1 & mob<=9  
replace entry = date("1/9/1958","DMY") if bula == 9 & yob == 1951 & mob>=10 & mob<=12 
replace entry = date("1/9/1958","DMY") if bula == 9 & yob == 1952 & mob>=1 & mob<=9  
replace entry = date("1/9/1959","DMY") if bula == 9 & yob == 1952 & mob>=10 & mob<=12 
replace entry = date("1/9/1959","DMY") if bula == 9 & yob == 1953 & mob>=1 & mob<=9  
replace entry = date("1/9/1960","DMY") if bula == 9 & yob == 1953 & mob>=10 & mob<=12 
replace entry = date("1/9/1960","DMY") if bula == 9 & yob == 1954 & mob>=1 & mob<=9  
replace entry = date("1/9/1961","DMY") if bula == 9 & yob == 1954 & mob>=10 & mob<=12 
replace entry = date("1/9/1961","DMY") if bula == 9 & yob == 1955 & mob>=1 & mob<=9  
replace entry = date("1/9/1962","DMY") if bula == 9 & yob == 1955 & mob>=10 & mob<=12 
replace entry = date("1/9/1962","DMY") if bula == 9 & yob == 1956 & mob>=1 & mob<=9  
replace entry = date("1/9/1963","DMY") if bula == 9 & yob == 1956 & mob>=10 & mob<=12 
replace entry = date("1/9/1963","DMY") if bula == 9 & yob == 1957 & mob>=1 & mob<=9  
replace entry = date("1/9/1964","DMY") if bula == 9 & yob == 1957 & mob>=10 & mob<=12 
replace entry = date("1/9/1964","DMY") if bula == 9 & yob == 1958 & mob>=1 & mob<=9  
replace entry = date("1/9/1965","DMY") if bula == 9 & yob == 1958 & mob>=10 & mob<=12 
replace entry = date("1/9/1965","DMY") if bula == 9 & yob == 1959 & mob>=1 & mob<=9  
replace entry = date("1/9/1966","DMY") if bula == 9 & yob == 1959 & mob>=10 & mob<=12 
replace entry = date("1/9/1966","DMY") if bula == 9 & yob == 1960 & mob>=1 & mob<=9  
replace entry = date("1/9/1967","DMY") if bula == 9 & yob == 1960 & mob>=10 & mob<=12 
replace entry = date("1/9/1967","DMY") if bula == 9 & yob == 1961 & mob>=1 & mob<=9  
replace entry = date("1/9/1968","DMY") if bula == 9 & yob == 1961 & mob>=10 & mob<=12 
replace entry = date("1/9/1968","DMY") if bula == 9 & yob == 1962 & mob>=1 & mob<=9  
replace entry = date("1/9/1969","DMY") if bula == 9 & yob == 1962 & mob>=10 & mob<=12 
replace entry = date("1/9/1969","DMY") if bula == 9 & yob == 1963 & mob>=1 & mob<=6 //geändert MH
replace entry = date("1/9/1970","DMY") if bula == 9 & yob == 1963 & mob>=7 & mob<=12 //geändert MH
replace entry = date("1/9/1970","DMY") if bula == 9 & yob == 1964 & mob>=1 & mob<=6 //geändert MH
replace entry = date("1/9/1971","DMY") if bula == 9 & yob == 1964 & mob>=7 & mob<=12 //geändert MH
replace entry = date("1/9/1971","DMY") if bula == 9 & yob == 1965 & mob>=1 & mob<=6 //geändert MH
replace entry = date("1/9/1972","DMY") if bula == 9 & yob == 1965 & mob>=7 & mob<=12 //geändert MH

* school exit (bitte für Bayern überall den 31.8. für Ende des Schuljahres annehmen)
gen exit = date("31/8/1958","DMY") if bula == 9 & yob == 1944
format %tdD_m_CY exit
replace exit = date("31/8/1959","DMY") if bula == 9 & yob == 1945 
replace exit = date("31/8/1960","DMY") if bula == 9 & yob == 1946 & mob>=1 & mob<=9  
replace exit = date("31/8/1961","DMY") if bula == 9 & yob == 1946 & mob>=10 & mob<=12
replace exit = date("31/8/1961","DMY") if bula == 9 & yob == 1947 & mob>=1 & mob<=9  
replace exit = date("31/8/1962","DMY") if bula == 9 & yob == 1947 & mob>=10 & mob<=12 
replace exit = date("31/8/1962","DMY") if bula == 9 & yob == 1948 & mob>=1 & mob<=9  
replace exit = date("31/8/1963","DMY") if bula == 9 & yob == 1948 & mob>=10 & mob<=12 
replace exit = date("31/8/1963","DMY") if bula == 9 & yob == 1949 & mob>=1 & mob<=9  
replace exit = date("31/8/1964","DMY") if bula == 9 & yob == 1949 & mob>=10 & mob<=12 
replace exit = date("31/8/1964","DMY") if bula == 9 & yob == 1950 & mob>=1 & mob<=9  
replace exit = date("31/8/1965","DMY") if bula == 9 & yob == 1950 & mob>=10 & mob<=12 
replace exit = date("31/8/1965","DMY") if bula == 9 & yob == 1951 & mob>=1 & mob<=9  
replace exit = date("31/8/1966","DMY") if bula == 9 & yob == 1951 & mob>=10 & mob<=12 
replace exit = date("31/8/1966","DMY") if bula == 9 & yob == 1952 & mob>=1 & mob<=9  
replace exit = date("31/8/1967","DMY") if bula == 9 & yob == 1952 & mob>=10 & mob<=12 
replace exit = date("31/8/1967","DMY") if bula == 9 & yob == 1953 & mob>=1 & mob<=9  
replace exit = date("31/8/1968","DMY") if bula == 9 & yob == 1953 & mob>=10 & mob<=12 
replace exit = date("31/8/1968","DMY") if bula == 9 & yob == 1954 & mob>=1 & mob<=9  
replace exit = date("31/8/1970","DMY") if bula == 9 & yob == 1954 & mob>=10 & mob<=12 
replace exit = date("31/8/1970","DMY") if bula == 9 & yob == 1955 & mob>=1 & mob<=9  
replace exit = date("31/8/1971","DMY") if bula == 9 & yob == 1955 & mob>=10 & mob<=12 
replace exit = date("31/8/1971","DMY") if bula == 9 & yob == 1956 & mob>=1 & mob<=9  
replace exit = date("31/8/1972","DMY") if bula == 9 & yob == 1956 & mob>=10 & mob<=12 
replace exit = date("31/8/1972","DMY") if bula == 9 & yob == 1957 & mob>=1 & mob<=9  
replace exit = date("31/8/1973","DMY") if bula == 9 & yob == 1957 & mob>=10 & mob<=12 
replace exit = date("31/8/1973","DMY") if bula == 9 & yob == 1958 & mob>=1 & mob<=9  
replace exit = date("31/8/1974","DMY") if bula == 9 & yob == 1958 & mob>=10 & mob<=12 
replace exit = date("31/8/1974","DMY") if bula == 9 & yob == 1959 & mob>=1 & mob<=9  
replace exit = date("31/8/1975","DMY") if bula == 9 & yob == 1959 & mob>=10 & mob<=12 
replace exit = date("31/8/1975","DMY") if bula == 9 & yob == 1960 & mob>=1 & mob<=9  
replace exit = date("31/8/1976","DMY") if bula == 9 & yob == 1960 & mob>=10 & mob<=12 
replace exit = date("31/8/1976","DMY") if bula == 9 & yob == 1961 & mob>=1 & mob<=9  
replace exit = date("31/8/1977","DMY") if bula == 9 & yob == 1961 & mob>=10 & mob<=12 
replace exit = date("31/8/1977","DMY") if bula == 9 & yob == 1962 & mob>=1 & mob<=9  
replace exit = date("31/8/1978","DMY") if bula == 9 & yob == 1962 & mob>=10 & mob<=12 
replace exit = date("31/8/1978","DMY") if bula == 9 & yob == 1963 & mob>=1 & mob<=6 //geändert MH
replace exit = date("31/8/1979","DMY") if bula == 9 & yob == 1963 & mob>=7 & mob<=12 //geändert MH
replace exit = date("31/8/1979","DMY") if bula == 9 & yob == 1964 & mob>=1 & mob<=6 //geändert MH
replace exit = date("31/8/1980","DMY") if bula == 9 & yob == 1964 & mob>=7 & mob<=12 //geändert MH
replace exit = date("31/8/1980","DMY") if bula == 9 & yob == 1965 & mob>=1 & mob<=6 //geändert MH
replace exit = date("31/8/1981","DMY") if bula == 9 & yob == 1965 & mob>=7 & mob<=12 //geändert MH


*** 8 - BADEN-WUERTTEMBERG ***
* school entry
replace entry = date("1/8/1950","DMY") if bula == 8 & yob == 1944
replace entry = date("1/8/1951","DMY") if bula == 8 & yob == 1945 & mob>=1 & mob<=5
replace entry = date("1/4/1952","DMY") if bula == 8 & yob == 1945 & mob>=6 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 8 & yob == 1946 & mob>=1 & mob<=3  
replace entry = date("1/4/1953","DMY") if bula == 8 & yob == 1946 & mob>=4 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 8 & yob == 1947 & mob>=1 & mob<=4  
replace entry = date("1/4/1954","DMY") if bula == 8 & yob == 1947 & mob>=5 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 8 & yob == 1948 & mob>=1 & mob<=4  
replace entry = date("1/4/1955","DMY") if bula == 8 & yob == 1948 & mob>=5 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 8 & yob == 1949 & mob>=1 & mob<=4  
replace entry = date("1/4/1956","DMY") if bula == 8 & yob == 1949 & mob>=5 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 8 & yob == 1950 & mob>=1 & mob<=4  
replace entry = date("1/4/1957","DMY") if bula == 8 & yob == 1950 & mob>=5 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 8 & yob == 1951 & mob>=1 & mob<=4  
replace entry = date("1/4/1958","DMY") if bula == 8 & yob == 1951 & mob>=5 & mob<=12  
replace entry = date("1/4/1959","DMY") if bula == 8 & yob == 1952 
replace entry = date("1/4/1960","DMY") if bula == 8 & yob == 1953 
replace entry = date("1/4/1961","DMY") if bula == 8 & yob == 1954 
replace entry = date("1/4/1962","DMY") if bula == 8 & yob == 1955 
replace entry = date("1/4/1963","DMY") if bula == 8 & yob == 1956 
replace entry = date("1/4/1964","DMY") if bula == 8 & yob == 1957 
replace entry = date("1/4/1965","DMY") if bula == 8 & yob == 1958 
replace entry = date("1/4/1966","DMY") if bula == 8 & yob == 1959 
replace entry = date("1/12/1966","DMY") if bula == 8 & yob == 1960 & mob>=1 & mob<=6
replace entry = date("1/8/1967","DMY") if bula == 8 & yob == 1960 & mob>=7 & mob<=12
replace entry = date("1/8/1967","DMY") if bula == 8 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 8 & yob == 1961 & mob>=7 & mob<=12 
replace entry = date("1/8/1968","DMY") if bula == 8 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 8 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 8 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 8 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 8 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 8 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 8 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 8 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 8 & yob == 1944
replace exit = date("31/3/1959","DMY") if bula == 8 & yob == 1945 & mob>=1 & mob<=5
replace exit = date("31/3/1960","DMY") if bula == 8 & yob == 1945 & mob>=6 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 8 & yob == 1946 & mob>=1 & mob<=3  
replace exit = date("31/3/1961","DMY") if bula == 8 & yob == 1946 & mob>=4 & mob<=12 
replace exit = date("31/3/1961","DMY") if bula == 8 & yob == 1947 & mob>=1 & mob<=4  
replace exit = date("31/3/1962","DMY") if bula == 8 & yob == 1947 & mob>=5 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 8 & yob == 1948 & mob>=1 & mob<=4  
replace exit = date("31/3/1963","DMY") if bula == 8 & yob == 1948 & mob>=5 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 8 & yob == 1949 & mob>=1 & mob<=4  
replace exit = date("31/3/1964","DMY") if bula == 8 & yob == 1949 & mob>=5 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 8 & yob == 1950 & mob>=1 & mob<=4  
replace exit = date("31/3/1965","DMY") if bula == 8 & yob == 1950 & mob>=5 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 8 & yob == 1951 & mob>=1 & mob<=4  
replace exit = date("31/3/1966","DMY") if bula == 8 & yob == 1951 & mob>=5 & mob<=12  
replace exit = date("31/7/1967","DMY") if bula == 8 & yob == 1952 
replace exit = date("31/7/1968","DMY") if bula == 8 & yob == 1953 
replace exit = date("31/7/1969","DMY") if bula == 8 & yob == 1954
replace exit = date("31/7/1970","DMY") if bula == 8 & yob == 1955 
replace exit = date("31/7/1971","DMY") if bula == 8 & yob == 1956
replace exit = date("31/7/1972","DMY") if bula == 8 & yob == 1957 
replace exit = date("31/7/1973","DMY") if bula == 8 & yob == 1958
replace exit = date("31/7/1974","DMY") if bula == 8 & yob == 1959
replace exit = date("31/7/1975","DMY") if bula == 8 & yob == 1960 & mob>=1 & mob<=6
replace exit = date("31/7/1976","DMY") if bula == 8 & yob == 1960 & mob>=7 & mob<=12
replace exit = date("31/7/1976","DMY") if bula == 8 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 8 & yob == 1961 & mob>=7 & mob<=12 
replace exit = date("31/7/1977","DMY") if bula == 8 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 8 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 8 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 8 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 8 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 8 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 8 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 8 & yob == 1965 & mob>=7 & mob<=12

*** 7 - RHEINLAND-PFALZ ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 7 & yob == 1944 & mob>=1 & mob<=3
replace entry = date("1/4/1951","DMY") if bula == 7 & yob == 1944 & mob>=4 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 7 & yob == 1945 & mob>=1 & mob<=3
replace entry = date("1/4/1952","DMY") if bula == 7 & yob == 1945 & mob>=4 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 7 & yob == 1946 & mob>=1 & mob<=3  
replace entry = date("1/4/1953","DMY") if bula == 7 & yob == 1946 & mob>=4 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 7 & yob == 1947 & mob>=1 & mob<=3  
replace entry = date("1/4/1954","DMY") if bula == 7 & yob == 1947 & mob>=4 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 7 & yob == 1948 & mob>=1 & mob<=3  
replace entry = date("1/4/1955","DMY") if bula == 7 & yob == 1948 & mob>=4 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 7 & yob == 1949 & mob>=1 & mob<=3  
replace entry = date("1/4/1956","DMY") if bula == 7 & yob == 1949 & mob>=4 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 7 & yob == 1950 & mob>=1 & mob<=3  
replace entry = date("1/4/1957","DMY") if bula == 7 & yob == 1950 & mob>=4 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 7 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 7 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 7 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 7 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 7 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 7 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 7 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 7 & yob == 1954 & mob>=4 & mob<=12  
replace entry = date("1/4/1961","DMY") if bula == 7 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 7 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 7 & yob == 1956 & mob>=1 & mob<=3 
replace entry = date("1/4/1963","DMY") if bula == 7 & yob == 1956 & mob>=4 & mob<=12  
replace entry = date("1/4/1963","DMY") if bula == 7 & yob == 1957 & mob>=1 & mob<=3 
replace entry = date("1/4/1964","DMY") if bula == 7 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1964","DMY") if bula == 7 & yob == 1958 & mob>=1 & mob<=3  
replace entry = date("1/4/1965","DMY") if bula == 7 & yob == 1958 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 7 & yob == 1959 & mob>=1 & mob<=3 
replace entry = date("1/4/1966","DMY") if bula == 7 & yob == 1959 & mob>=4 & mob<=12
replace entry = date("1/4/1966","DMY") if bula == 7 & yob == 1960 & mob>=1 & mob<=3
replace entry = date("1/12/1966","DMY") if bula == 7 & yob == 1960 & mob>=4 & mob<=11
replace entry = date("1/8/1967","DMY") if bula == 7 & yob == 1960 & mob==12
replace entry = date("1/8/1967","DMY") if bula == 7 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 7 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 7 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 7 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 7 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 7 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 7 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 7 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 7 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 7 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 7 & yob == 1944 & mob>=1 & mob<=3
replace exit = date("31/3/1959","DMY") if bula == 7 & yob == 1944 & mob>=4 & mob<=12
replace exit = date("31/3/1959","DMY") if bula == 7 & yob == 1945 & mob>=1 & mob<=3
replace exit = date("31/3/1960","DMY") if bula == 7 & yob == 1945 & mob>=4 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 7 & yob == 1946 & mob>=1 & mob<=3  
replace exit = date("31/3/1961","DMY") if bula == 7 & yob == 1946 & mob>=4 & mob<=12 
replace exit = date("31/3/1961","DMY") if bula == 7 & yob == 1947 & mob>=1 & mob<=3  
replace exit = date("31/3/1962","DMY") if bula == 7 & yob == 1947 & mob>=4 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 7 & yob == 1948 & mob>=1 & mob<=3  
replace exit = date("31/3/1963","DMY") if bula == 7 & yob == 1948 & mob>=4 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 7 & yob == 1949 & mob>=1 & mob<=3  
replace exit = date("31/3/1964","DMY") if bula == 7 & yob == 1949 & mob>=4 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 7 & yob == 1950 & mob>=1 & mob<=3  
replace exit = date("31/3/1965","DMY") if bula == 7 & yob == 1950 & mob>=4 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 7 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("31/3/1966","DMY") if bula == 7 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("31/3/1966","DMY") if bula == 7 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/7/1967","DMY") if bula == 7 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 7 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/7/1968","DMY") if bula == 7 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 7 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/7/1969","DMY") if bula == 7 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 7 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 7 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1970","DMY") if bula == 7 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/7/1971","DMY") if bula == 7 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/7/1971","DMY") if bula == 7 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/7/1972","DMY") if bula == 7 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/7/1972","DMY") if bula == 7 & yob == 1958 & mob>=1 & mob<=3  
replace exit = date("31/7/1973","DMY") if bula == 7 & yob == 1958 & mob>=4 & mob<=12
replace exit = date("31/7/1973","DMY") if bula == 7 & yob == 1959 & mob>=1 & mob<=3 
replace exit = date("31/7/1974","DMY") if bula == 7 & yob == 1959 & mob>=4 & mob<=12
replace exit = date("31/7/1974","DMY") if bula == 7 & yob == 1960 & mob>=1 & mob<=3
replace exit = date("31/7/1975","DMY") if bula == 7 & yob == 1960 & mob>=4 & mob<=11
replace exit = date("31/7/1976","DMY") if bula == 7 & yob == 1960 & mob==12
replace exit = date("31/7/1976","DMY") if bula == 7 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 7 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 7 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 7 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 7 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 7 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 7 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 7 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 7 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 7 & yob == 1965 & mob>=7 & mob<=12

*** 5 - NORDRHEIN-WESTFALEN ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 5 & yob == 1944 & mob>=1 & mob<=6
replace entry = date("1/4/1951","DMY") if bula == 5 & yob == 1944 & mob>=7 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 5 & yob == 1945 & mob>=1 & mob<=6
replace entry = date("1/4/1952","DMY") if bula == 5 & yob == 1945 & mob>=7 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 5 & yob == 1946 & mob>=1 & mob<=6  
replace entry = date("1/4/1953","DMY") if bula == 5 & yob == 1946 & mob>=7 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 5 & yob == 1947 & mob>=1 & mob<=6  
replace entry = date("1/4/1954","DMY") if bula == 5 & yob == 1947 & mob>=7 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 5 & yob == 1948 & mob>=1 & mob<=6  
replace entry = date("1/4/1955","DMY") if bula == 5 & yob == 1948 & mob>=7 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 5 & yob == 1949 & mob>=1 & mob<=6  
replace entry = date("1/4/1956","DMY") if bula == 5 & yob == 1949 & mob>=7 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 5 & yob == 1950 & mob>=1 & mob<=6  
replace entry = date("1/4/1957","DMY") if bula == 5 & yob == 1950 & mob>=7 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 5 & yob == 1951 & mob>=1 & mob<=6  
replace entry = date("1/4/1958","DMY") if bula == 5 & yob == 1951 & mob>=7 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 5 & yob == 1952 & mob>=1 & mob<=6
replace entry = date("1/4/1959","DMY") if bula == 5 & yob == 1952 & mob>=7 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 5 & yob == 1953 & mob>=1 & mob<=6 
replace entry = date("1/4/1960","DMY") if bula == 5 & yob == 1953 & mob>=7 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 5 & yob == 1954 & mob>=1 & mob<=6 
replace entry = date("1/4/1961","DMY") if bula == 5 & yob == 1954 & mob>=7 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 5 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 5 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 5 & yob == 1956 & mob>=1 & mob<=3 
replace entry = date("1/4/1963","DMY") if bula == 5 & yob == 1956 & mob>=4 & mob<=12  
replace entry = date("1/4/1963","DMY") if bula == 5 & yob == 1957 & mob>=1 & mob<=3 
replace entry = date("1/4/1964","DMY") if bula == 5 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1964","DMY") if bula == 5 & yob == 1958 & mob>=1 & mob<=3  
replace entry = date("1/4/1965","DMY") if bula == 5 & yob == 1958 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 5 & yob == 1959 & mob>=1 & mob<=3 
replace entry = date("1/4/1966","DMY") if bula == 5 & yob == 1959 & mob>=4 & mob<=12
replace entry = date("1/4/1966","DMY") if bula == 5 & yob == 1960 & mob>=1 & mob<=3
replace entry = date("1/12/1966","DMY") if bula == 5 & yob == 1960 & mob>=4 & mob<=11
replace entry = date("1/8/1967","DMY") if bula == 5 & yob == 1960 & mob==12
replace entry = date("1/8/1967","DMY") if bula == 5 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 5 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 5 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 5 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 5 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 5 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 5 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 5 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 5 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 5 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 5 & yob == 1944 & mob>=1 & mob<=6
replace exit = date("31/3/1959","DMY") if bula == 5 & yob == 1944 & mob>=7 & mob<=12
replace exit = date("31/3/1959","DMY") if bula == 5 & yob == 1945 & mob>=1 & mob<=6
replace exit = date("31/3/1960","DMY") if bula == 5 & yob == 1945 & mob>=7 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 5 & yob == 1946 & mob>=1 & mob<=6  
replace exit = date("31/3/1961","DMY") if bula == 5 & yob == 1946 & mob>=7 & mob<=12 
replace exit = date("31/3/1961","DMY") if bula == 5 & yob == 1947 & mob>=1 & mob<=6  
replace exit = date("31/3/1962","DMY") if bula == 5 & yob == 1947 & mob>=7 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 5 & yob == 1948 & mob>=1 & mob<=6  
replace exit = date("31/3/1963","DMY") if bula == 5 & yob == 1948 & mob>=7 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 5 & yob == 1949 & mob>=1 & mob<=6  
replace exit = date("31/3/1964","DMY") if bula == 5 & yob == 1949 & mob>=7 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 5 & yob == 1950 & mob>=1 & mob<=6  
replace exit = date("31/3/1965","DMY") if bula == 5 & yob == 1950 & mob>=7 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 5 & yob == 1951 & mob>=1 & mob<=6  
replace exit = date("31/3/1966","DMY") if bula == 5 & yob == 1951 & mob>=7 & mob<=12
replace exit = date("31/3/1966","DMY") if bula == 5 & yob == 1952 & mob>=1 & mob<=6
replace exit = date("31/7/1967","DMY") if bula == 5 & yob == 1952 & mob>=7 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 5 & yob == 1953 & mob>=1 & mob<=6 
replace exit = date("31/7/1968","DMY") if bula == 5 & yob == 1953 & mob>=7 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 5 & yob == 1954 & mob>=1 & mob<=6 
replace exit = date("31/7/1969","DMY") if bula == 5 & yob == 1954 & mob>=7 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 5 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 5 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1970","DMY") if bula == 5 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/7/1971","DMY") if bula == 5 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/7/1971","DMY") if bula == 5 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/7/1972","DMY") if bula == 5 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/7/1972","DMY") if bula == 5 & yob == 1958 & mob>=1 & mob<=3  
replace exit = date("31/7/1973","DMY") if bula == 5 & yob == 1958 & mob>=4 & mob<=12
replace exit = date("31/7/1973","DMY") if bula == 5 & yob == 1959 & mob>=1 & mob<=3 
replace exit = date("31/7/1974","DMY") if bula == 5 & yob == 1959 & mob>=4 & mob<=12
replace exit = date("31/7/1974","DMY") if bula == 5 & yob == 1960 & mob>=1 & mob<=3
replace exit = date("31/7/1975","DMY") if bula == 5 & yob == 1960 & mob>=4 & mob<=11
replace exit = date("31/7/1976","DMY") if bula == 5 & yob == 1960 & mob==12
replace exit = date("31/7/1976","DMY") if bula == 5 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 5 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 5 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 5 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 5 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 5 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 5 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 5 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 5 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 5 & yob == 1965 & mob>=7 & mob<=12

*** 6 - HESSEN ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 6 & yob == 1944 & mob>=1 & mob<=6
replace entry = date("1/4/1951","DMY") if bula == 6 & yob == 1944 & mob>=7 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 6 & yob == 1945 & mob>=1 & mob<=6
replace entry = date("1/4/1952","DMY") if bula == 6 & yob == 1945 & mob>=7 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 6 & yob == 1946 & mob>=1 & mob<=6  
replace entry = date("1/4/1953","DMY") if bula == 6 & yob == 1946 & mob>=7 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 6 & yob == 1947 & mob>=1 & mob<=6  
replace entry = date("1/4/1954","DMY") if bula == 6 & yob == 1947 & mob>=7 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 6 & yob == 1948 & mob>=1 & mob<=6  
replace entry = date("1/4/1955","DMY") if bula == 6 & yob == 1948 & mob>=7 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 6 & yob == 1949 & mob>=1 & mob<=6  
replace entry = date("1/4/1956","DMY") if bula == 6 & yob == 1949 & mob>=7 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 6 & yob == 1950 & mob>=1 & mob<=6  
replace entry = date("1/4/1957","DMY") if bula == 6 & yob == 1950 & mob>=7 & mob<=12
replace entry = date("1/4/1957","DMY") if bula == 6 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 6 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 6 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 6 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 6 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 6 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 6 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 6 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 6 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 6 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1963","DMY") if bula == 6 & yob == 1956 
replace entry = date("1/4/1964","DMY") if bula == 6 & yob == 1957 
replace entry = date("1/4/1965","DMY") if bula == 6 & yob == 1958 
replace entry = date("1/4/1966","DMY") if bula == 6 & yob == 1959 
replace entry = date("1/4/1966","DMY") if bula == 6 & yob == 1960 & mob>=1 & mob<=3    
replace entry = date("1/12/1966","DMY") if bula == 6 & yob == 1960 & mob>=4 & mob<=11
replace entry = date("1/8/1967","DMY") if bula == 6 & yob == 1960 & mob==12
replace entry = date("1/8/1967","DMY") if bula == 6 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 6 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 6 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 6 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 6 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 6 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 6 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 6 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 6 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 6 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 6 & yob == 1944 & mob>=1 & mob<=6
replace exit = date("31/3/1959","DMY") if bula == 6 & yob == 1944 & mob>=7 & mob<=12
replace exit = date("31/3/1959","DMY") if bula == 6 & yob == 1945 & mob>=1 & mob<=6
replace exit = date("31/3/1960","DMY") if bula == 6 & yob == 1945 & mob>=7 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 6 & yob == 1946 & mob>=1 & mob<=6  
replace exit = date("31/3/1961","DMY") if bula == 6 & yob == 1946 & mob>=7 & mob<=12 
replace exit = date("31/3/1961","DMY") if bula == 6 & yob == 1947 & mob>=1 & mob<=6  
replace exit = date("31/3/1962","DMY") if bula == 6 & yob == 1947 & mob>=7 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 6 & yob == 1948 & mob>=1 & mob<=6  
replace exit = date("31/3/1963","DMY") if bula == 6 & yob == 1948 & mob>=7 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 6 & yob == 1949 & mob>=1 & mob<=6  
replace exit = date("31/3/1964","DMY") if bula == 6 & yob == 1949 & mob>=7 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 6 & yob == 1950 & mob>=1 & mob<=6  
replace exit = date("31/3/1965","DMY") if bula == 6 & yob == 1950 & mob>=7 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 6 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("30/11/1966","DMY") if bula == 6 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("30/11/1966","DMY") if bula == 6 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/7/1967","DMY") if bula == 6 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 6 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/7/1968","DMY") if bula == 6 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 6 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/7/1969","DMY") if bula == 6 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 6 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 6 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1971","DMY") if bula == 6 & yob == 1956   
replace exit = date("31/7/1972","DMY") if bula == 6 & yob == 1957   
replace exit = date("31/7/1973","DMY") if bula == 6 & yob == 1958  
replace exit = date("31/7/1974","DMY") if bula == 6 & yob == 1959 
replace exit = date("31/7/1974","DMY") if bula == 6 & yob == 1960 & mob>=1 & mob<=3    
replace exit = date("31/7/1975","DMY") if bula == 6 & yob == 1960 & mob>=4 & mob<=11
replace exit = date("31/7/1976","DMY") if bula == 6 & yob == 1960 & mob==12
replace exit = date("31/7/1976","DMY") if bula == 6 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 6 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 6 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 6 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 6 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 6 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 6 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 6 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 6 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 6 & yob == 1965 & mob>=7 & mob<=12

*** 10 - SAARLAND ***
* school entry
replace entry = date("1/9/1950","DMY") if bula == 10 & yob == 1944 
replace entry = date("1/9/1951","DMY") if bula == 10 & yob == 1945 
replace entry = date("1/9/1952","DMY") if bula == 10 & yob == 1946 
replace entry = date("1/9/1953","DMY") if bula == 10 & yob == 1947
replace entry = date("1/9/1954","DMY") if bula == 10 & yob == 1948 & mob>=1 & mob<=9 
replace entry = date("1/9/1955","DMY") if bula == 10 & yob == 1948 & mob>=10 & mob<=12 
replace entry = date("1/9/1955","DMY") if bula == 10 & yob == 1949 & mob>=1 & mob<=9  
replace entry = date("1/9/1956","DMY") if bula == 10 & yob == 1949 & mob>=10 & mob<=12 
replace entry = date("1/9/1956","DMY") if bula == 10 & yob == 1950 & mob>=1 & mob<=9
replace entry = date("1/4/1957","DMY") if bula == 10 & yob == 1950 & mob>=10 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 10 & yob == 1951 & mob>=1 & mob<=9  
replace entry = date("1/4/1959","DMY") if bula == 10 & yob == 1951 & mob>=10 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 10 & yob == 1952 & mob>=1 & mob<=3 
replace entry = date("1/4/1959","DMY") if bula == 10 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 10 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 10 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 10 & yob == 1954 & mob>=1 & mob<=6 
replace entry = date("1/4/1961","DMY") if bula == 10 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 10 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 10 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 10 & yob == 1956 & mob>=1 & mob<=3 
replace entry = date("1/4/1963","DMY") if bula == 10 & yob == 1956 & mob>=4 & mob<=12  
replace entry = date("1/4/1963","DMY") if bula == 10 & yob == 1957 & mob>=1 & mob<=3 
replace entry = date("1/4/1964","DMY") if bula == 10 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1964","DMY") if bula == 10 & yob == 1958 & mob>=1 & mob<=3  
replace entry = date("1/4/1965","DMY") if bula == 10 & yob == 1958 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 10 & yob == 1959 & mob>=1 & mob<=3 
replace entry = date("1/4/1966","DMY") if bula == 10 & yob == 1959 & mob>=4 & mob<=12
replace entry = date("1/4/1966","DMY") if bula == 10 & yob == 1960 & mob>=1 & mob<=3
replace entry = date("1/12/1966","DMY") if bula == 10 & yob == 1960 & mob>=4 & mob<=12
replace entry = date("1/8/1967","DMY") if bula == 10 & yob == 1961 & mob>=1 & mob<=9
replace entry = date("1/8/1968","DMY") if bula == 10 & yob == 1961 & mob>=10 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 10 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 10 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 10 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 10 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 10 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 10 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 10 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 10 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1959","DMY") if bula == 10 & yob == 1944 
replace exit = date("31/3/1960","DMY") if bula == 10 & yob == 1945 
replace exit = date("31/3/1961","DMY") if bula == 10 & yob == 1946 
replace exit = date("31/3/1962","DMY") if bula == 10 & yob == 1947   
replace exit = date("31/3/1963","DMY") if bula == 10 & yob == 1948 & mob>=1 & mob<=9
replace exit = date("31/3/1964","DMY") if bula == 10 & yob == 1948 & mob>=10 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 10 & yob == 1949 & mob>=1 & mob<=9  
replace exit = date("31/3/1965","DMY") if bula == 10 & yob == 1949 & mob>=10 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 10 & yob == 1950 & mob>=1 & mob<=9  
replace exit = date("31/3/1966","DMY") if bula == 10 & yob == 1950 & mob>=10 & mob<=12 
replace exit = date("31/3/1966","DMY") if bula == 10 & yob == 1951 & mob>=1 & mob<=9  
replace exit = date("31/7/1967","DMY") if bula == 10 & yob == 1951 & mob>=10 & mob<=12
replace exit = date("31/7/1967","DMY") if bula == 10 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/7/1967","DMY") if bula == 10 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 10 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/7/1968","DMY") if bula == 10 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 10 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/7/1969","DMY") if bula == 10 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 10 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 10 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1970","DMY") if bula == 10 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/7/1971","DMY") if bula == 10 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/7/1971","DMY") if bula == 10 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/7/1972","DMY") if bula == 10 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/7/1972","DMY") if bula == 10 & yob == 1958 & mob>=1 & mob<=3  
replace exit = date("31/7/1973","DMY") if bula == 10 & yob == 1958 & mob>=4 & mob<=12
replace exit = date("31/7/1973","DMY") if bula == 10 & yob == 1959 & mob>=1 & mob<=3 
replace exit = date("31/7/1974","DMY") if bula == 10 & yob == 1959 & mob>=4 & mob<=12
replace exit = date("31/7/1974","DMY") if bula == 10 & yob == 1960 & mob>=1 & mob<=3
replace exit = date("31/7/1975","DMY") if bula == 10 & yob == 1960 & mob>=4 & mob<=12
replace exit = date("31/7/1976","DMY") if bula == 10 & yob == 1961 & mob>=1 & mob<=9
replace exit = date("31/7/1977","DMY") if bula == 10 & yob == 1961 & mob>=10 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 10 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 10 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 10 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 10 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 10 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 10 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 10 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 10 & yob == 1965 & mob>=7 & mob<=12

*** 3 - NIEDERSACHSEN ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 3 & yob == 1944 & mob>=1 & mob<=6
replace entry = date("1/4/1951","DMY") if bula == 3 & yob == 1944 & mob>=7 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 3 & yob == 1945 & mob>=1 & mob<=6
replace entry = date("1/4/1952","DMY") if bula == 3 & yob == 1945 & mob>=7 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 3 & yob == 1946 & mob>=1 & mob<=6  
replace entry = date("1/4/1953","DMY") if bula == 3 & yob == 1946 & mob>=7 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 3 & yob == 1947 & mob>=1 & mob<=6  
replace entry = date("1/4/1954","DMY") if bula == 3 & yob == 1947 & mob>=7 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 3 & yob == 1948 & mob>=1 & mob<=6  
replace entry = date("1/4/1955","DMY") if bula == 3 & yob == 1948 & mob>=7 & mob<=12
replace entry = date("1/4/1955","DMY") if bula == 3 & yob == 1949 & mob>=1 & mob<=3  
replace entry = date("1/4/1956","DMY") if bula == 3 & yob == 1949 & mob>=4 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 3 & yob == 1950 & mob>=1 & mob<=3  
replace entry = date("1/4/1957","DMY") if bula == 3 & yob == 1950 & mob>=4 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 3 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 3 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 3 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 3 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 3 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 3 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 3 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 3 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 3 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 3 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 3 & yob == 1956 & mob>=1 & mob<=3 
replace entry = date("1/4/1963","DMY") if bula == 3 & yob == 1956 & mob>=4 & mob<=12  
replace entry = date("1/4/1963","DMY") if bula == 3 & yob == 1957 & mob>=1 & mob<=3 
replace entry = date("1/4/1964","DMY") if bula == 3 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1964","DMY") if bula == 3 & yob == 1958 & mob>=1 & mob<=3  
replace entry = date("1/4/1965","DMY") if bula == 3 & yob == 1958 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 3 & yob == 1959 & mob>=1 & mob<=3 
replace entry = date("1/4/1966","DMY") if bula == 3 & yob == 1959 & mob>=4 & mob<=12
replace entry = date("1/4/1966","DMY") if bula == 3 & yob == 1960 & mob>=1 & mob<=3
replace entry = date("1/8/1967","DMY") if bula == 3 & yob == 1960 & mob>=4 & mob<=12
replace entry = date("1/8/1967","DMY") if bula == 3 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 3 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 3 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 3 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 3 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 3 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 3 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 3 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 3 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 3 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 3 & yob == 1944 & mob>=1 & mob<=6
replace exit = date("31/3/1959","DMY") if bula == 3 & yob == 1944 & mob>=7 & mob<=12
replace exit = date("31/3/1959","DMY") if bula == 3 & yob == 1945 & mob>=1 & mob<=6
replace exit = date("31/3/1960","DMY") if bula == 3 & yob == 1945 & mob>=7 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 3 & yob == 1946 & mob>=1 & mob<=6  
replace exit = date("31/3/1961","DMY") if bula == 3 & yob == 1946 & mob>=7 & mob<=12 
replace exit = date("31/3/1961","DMY") if bula == 3 & yob == 1947 & mob>=1 & mob<=6 
replace exit = date("31/3/1963","DMY") if bula == 3 & yob == 1947 & mob>=7 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 3 & yob == 1948 & mob>=1 & mob<=6  
replace exit = date("31/3/1964","DMY") if bula == 3 & yob == 1948 & mob>=7 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 3 & yob == 1949 & mob>=1 & mob<=3  
replace exit = date("31/3/1965","DMY") if bula == 3 & yob == 1949 & mob>=4 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 3 & yob == 1950 & mob>=1 & mob<=3  
replace exit = date("31/3/1966","DMY") if bula == 3 & yob == 1950 & mob>=4 & mob<=12 
replace exit = date("31/3/1966","DMY") if bula == 3 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("31/3/1967","DMY") if bula == 3 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("31/3/1967","DMY") if bula == 3 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/3/1968","DMY") if bula == 3 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/3/1968","DMY") if bula == 3 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/3/1969","DMY") if bula == 3 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/3/1969","DMY") if bula == 3 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/3/1970","DMY") if bula == 3 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/3/1970","DMY") if bula == 3 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/3/1971","DMY") if bula == 3 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/3/1971","DMY") if bula == 3 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/3/1972","DMY") if bula == 3 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/3/1972","DMY") if bula == 3 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/3/1973","DMY") if bula == 3 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/3/1973","DMY") if bula == 3 & yob == 1958 & mob>=1 & mob<=3  
replace exit = date("31/3/1974","DMY") if bula == 3 & yob == 1958 & mob>=4 & mob<=12
replace exit = date("31/3/1974","DMY") if bula == 3 & yob == 1959 & mob>=1 & mob<=3 
replace exit = date("31/3/1975","DMY") if bula == 3 & yob == 1959 & mob>=4 & mob<=12
replace exit = date("31/3/1975","DMY") if bula == 3 & yob == 1960 & mob>=1 & mob<=3
replace exit = date("31/7/1976","DMY") if bula == 3 & yob == 1960 & mob>=4 & mob<=12
replace exit = date("31/7/1976","DMY") if bula == 3 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 3 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 3 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 3 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 3 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 3 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 3 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 3 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 3 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 3 & yob == 1965 & mob>=7 & mob<=12

*** 2 - HAMBURG ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 2 & yob == 1944 & mob>=1 & mob<=3
replace entry = date("1/4/1951","DMY") if bula == 2 & yob == 1944 & mob>=4 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 2 & yob == 1945 & mob>=1 & mob<=3
replace entry = date("1/4/1952","DMY") if bula == 2 & yob == 1945 & mob>=4 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 2 & yob == 1946 & mob>=1 & mob<=3  
replace entry = date("1/4/1953","DMY") if bula == 2 & yob == 1946 & mob>=4 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 2 & yob == 1947 & mob>=1 & mob<=3  
replace entry = date("1/4/1954","DMY") if bula == 2 & yob == 1947 & mob>=4 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 2 & yob == 1948 & mob>=1 & mob<=3  
replace entry = date("1/4/1955","DMY") if bula == 2 & yob == 1948 & mob>=4 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 2 & yob == 1949 & mob>=1 & mob<=3  
replace entry = date("1/4/1956","DMY") if bula == 2 & yob == 1949 & mob>=4 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 2 & yob == 1950 & mob>=1 & mob<=3  
replace entry = date("1/4/1957","DMY") if bula == 2 & yob == 1950 & mob>=4 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 2 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 2 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 2 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 2 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 2 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 2 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 2 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 2 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 2 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 2 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1963","DMY") if bula == 2 & yob == 1956  
replace entry = date("1/4/1964","DMY") if bula == 2 & yob == 1957 
replace entry = date("1/4/1965","DMY") if bula == 2 & yob == 1958 
replace entry = date("1/4/1966","DMY") if bula == 2 & yob == 1959 
replace entry = date("1/8/1967","DMY") if bula == 2 & yob == 1960 
replace entry = date("1/8/1967","DMY") if bula == 2 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 2 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 2 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 2 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 2 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 2 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 2 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 2 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 2 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 2 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1959","DMY") if bula == 2 & yob == 1944 & mob>=1 & mob<=3
replace exit = date("31/3/1960","DMY") if bula == 2 & yob == 1944 & mob>=4 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 2 & yob == 1945 & mob>=1 & mob<=3
replace exit = date("31/3/1961","DMY") if bula == 2 & yob == 1945 & mob>=4 & mob<=12
replace exit = date("31/3/1961","DMY") if bula == 2 & yob == 1946 & mob>=1 & mob<=3  
replace exit = date("31/3/1962","DMY") if bula == 2 & yob == 1946 & mob>=4 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 2 & yob == 1947 & mob>=1 & mob<=3  
replace exit = date("31/3/1963","DMY") if bula == 2 & yob == 1947 & mob>=4 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 2 & yob == 1948 & mob>=1 & mob<=3  
replace exit = date("31/3/1964","DMY") if bula == 2 & yob == 1948 & mob>=4 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 2 & yob == 1949 & mob>=1 & mob<=3  
replace exit = date("31/3/1965","DMY") if bula == 2 & yob == 1949 & mob>=4 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 2 & yob == 1950 & mob>=1 & mob<=3  
replace exit = date("31/3/1966","DMY") if bula == 2 & yob == 1950 & mob>=4 & mob<=12 
replace exit = date("31/3/1966","DMY") if bula == 2 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("31/3/1967","DMY") if bula == 2 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("31/3/1967","DMY") if bula == 2 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/3/1968","DMY") if bula == 2 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/3/1968","DMY") if bula == 2 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/3/1969","DMY") if bula == 2 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/3/1969","DMY") if bula == 2 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/3/1970","DMY") if bula == 2 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/3/1970","DMY") if bula == 2 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/3/1971","DMY") if bula == 2 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/3/1972","DMY") if bula == 2 & yob == 1956 
replace exit = date("31/3/1973","DMY") if bula == 2 & yob == 1957
replace exit = date("31/3/1974","DMY") if bula == 2 & yob == 1958 
replace exit = date("31/3/1975","DMY") if bula == 2 & yob == 1959
replace exit = date("31/7/1976","DMY") if bula == 2 & yob == 1960
replace exit = date("31/7/1976","DMY") if bula == 2 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 2 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 2 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 2 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 2 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 2 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 2 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 2 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 2 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 2 & yob == 1965 & mob>=7 & mob<=12

*** 1 - SCHLESWIG-HOLSTEIN ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 1 & yob == 1944 & mob>=1 & mob<=3
replace entry = date("1/4/1951","DMY") if bula == 1 & yob == 1944 & mob>=4 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 1 & yob == 1945 & mob>=1 & mob<=3
replace entry = date("1/4/1952","DMY") if bula == 1 & yob == 1945 & mob>=4 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 1 & yob == 1946 & mob>=1 & mob<=3  
replace entry = date("1/4/1953","DMY") if bula == 1 & yob == 1946 & mob>=4 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 1 & yob == 1947 & mob>=1 & mob<=3  
replace entry = date("1/4/1954","DMY") if bula == 1 & yob == 1947 & mob>=4 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 1 & yob == 1948 & mob>=1 & mob<=3  
replace entry = date("1/4/1955","DMY") if bula == 1 & yob == 1948 & mob>=4 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 1 & yob == 1949 & mob>=1 & mob<=3  
replace entry = date("1/4/1956","DMY") if bula == 1 & yob == 1949 & mob>=4 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 1 & yob == 1950 & mob>=1 & mob<=3  
replace entry = date("1/4/1957","DMY") if bula == 1 & yob == 1950 & mob>=4 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 1 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 1 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 1 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 1 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 1 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 1 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 1 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 1 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 1 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 1 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 1 & yob == 1956 & mob>=1 & mob<=3
replace entry = date("1/4/1963","DMY") if bula == 1 & yob == 1956 & mob>=4 & mob<=12
replace entry = date("1/4/1963","DMY") if bula == 1 & yob == 1957 & mob>=1 & mob<=3
replace entry = date("1/4/1964","DMY") if bula == 1 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 1 & yob == 1958 
replace entry = date("1/4/1966","DMY") if bula == 1 & yob == 1959 
replace entry = date("1/12/1966","DMY") if bula == 1 & yob == 1960 & mob>=1 & mob<=11
replace entry = date("1/8/1967","DMY") if bula == 1 & yob == 1960 & mob==12
replace entry = date("1/8/1967","DMY") if bula == 1 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 1 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 1 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 1 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 1 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 1 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 1 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 1 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 1 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 1 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1959","DMY") if bula == 1 & yob == 1944 & mob>=1 & mob<=3
replace exit = date("31/3/1960","DMY") if bula == 1 & yob == 1944 & mob>=4 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 1 & yob == 1945 & mob>=1 & mob<=3
replace exit = date("31/3/1961","DMY") if bula == 1 & yob == 1945 & mob>=4 & mob<=12
replace exit = date("31/3/1961","DMY") if bula == 1 & yob == 1946 & mob>=1 & mob<=3  
replace exit = date("31/3/1962","DMY") if bula == 1 & yob == 1946 & mob>=4 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 1 & yob == 1947 & mob>=1 & mob<=3  
replace exit = date("31/3/1963","DMY") if bula == 1 & yob == 1947 & mob>=4 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 1 & yob == 1948 & mob>=1 & mob<=3  
replace exit = date("31/3/1964","DMY") if bula == 1 & yob == 1948 & mob>=4 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 1 & yob == 1949 & mob>=1 & mob<=3  
replace exit = date("31/3/1965","DMY") if bula == 1 & yob == 1949 & mob>=4 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 1 & yob == 1950 & mob>=1 & mob<=3  
replace exit = date("31/3/1966","DMY") if bula == 1 & yob == 1950 & mob>=4 & mob<=12 
replace exit = date("31/3/1966","DMY") if bula == 1 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("30/11/1966","DMY") if bula == 1 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("30/11/1966","DMY") if bula == 1 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/7/1967","DMY") if bula == 1 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 1 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/7/1968","DMY") if bula == 1 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 1 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/7/1969","DMY") if bula == 1 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 1 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 1 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1970","DMY") if bula == 1 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/7/1971","DMY") if bula == 1 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/7/1971","DMY") if bula == 1 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/7/1972","DMY") if bula == 1 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/7/1973","DMY") if bula == 1 & yob == 1958 
replace exit = date("31/7/1974","DMY") if bula == 1 & yob == 1959  
replace exit = date("31/7/1975","DMY") if bula == 1 & yob == 1960 & mob>=1 & mob<=11
replace exit = date("31/7/1976","DMY") if bula == 1 & yob == 1960 & mob==12
replace exit = date("31/7/1976","DMY") if bula == 1 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 1 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 1 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 1 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 1 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 1 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 1 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 1 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 1 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 1 & yob == 1965 & mob>=7 & mob<=12

*** 4 - BREMEN ***
* school entry
replace entry = date("1/4/1950","DMY") if bula == 4 & yob == 1944 & mob>=1 & mob<=3
replace entry = date("1/4/1951","DMY") if bula == 4 & yob == 1944 & mob>=4 & mob<=12
replace entry = date("1/4/1951","DMY") if bula == 4 & yob == 1945 & mob>=1 & mob<=3
replace entry = date("1/4/1952","DMY") if bula == 4 & yob == 1945 & mob>=4 & mob<=12
replace entry = date("1/4/1952","DMY") if bula == 4 & yob == 1946 & mob>=1 & mob<=3  
replace entry = date("1/4/1953","DMY") if bula == 4 & yob == 1946 & mob>=4 & mob<=12 
replace entry = date("1/4/1953","DMY") if bula == 4 & yob == 1947 & mob>=1 & mob<=3  
replace entry = date("1/4/1954","DMY") if bula == 4 & yob == 1947 & mob>=4 & mob<=12 
replace entry = date("1/4/1954","DMY") if bula == 4 & yob == 1948 & mob>=1 & mob<=3  
replace entry = date("1/4/1955","DMY") if bula == 4 & yob == 1948 & mob>=4 & mob<=12 
replace entry = date("1/4/1955","DMY") if bula == 4 & yob == 1949 & mob>=1 & mob<=3  
replace entry = date("1/4/1956","DMY") if bula == 4 & yob == 1949 & mob>=4 & mob<=12 
replace entry = date("1/4/1956","DMY") if bula == 4 & yob == 1950 & mob>=1 & mob<=3  
replace entry = date("1/4/1957","DMY") if bula == 4 & yob == 1950 & mob>=4 & mob<=12 
replace entry = date("1/4/1957","DMY") if bula == 4 & yob == 1951 & mob>=1 & mob<=3  
replace entry = date("1/4/1958","DMY") if bula == 4 & yob == 1951 & mob>=4 & mob<=12
replace entry = date("1/4/1958","DMY") if bula == 4 & yob == 1952 & mob>=1 & mob<=3
replace entry = date("1/4/1959","DMY") if bula == 4 & yob == 1952 & mob>=4 & mob<=12 
replace entry = date("1/4/1959","DMY") if bula == 4 & yob == 1953 & mob>=1 & mob<=3 
replace entry = date("1/4/1960","DMY") if bula == 4 & yob == 1953 & mob>=4 & mob<=12 
replace entry = date("1/4/1960","DMY") if bula == 4 & yob == 1954 & mob>=1 & mob<=3 
replace entry = date("1/4/1961","DMY") if bula == 4 & yob == 1954 & mob>=4 & mob<=12
replace entry = date("1/4/1961","DMY") if bula == 4 & yob == 1955 & mob>=1 & mob<=3 
replace entry = date("1/4/1962","DMY") if bula == 4 & yob == 1955 & mob>=4 & mob<=12
replace entry = date("1/4/1962","DMY") if bula == 4 & yob == 1956 & mob>=1 & mob<=3 
replace entry = date("1/4/1963","DMY") if bula == 4 & yob == 1956 & mob>=4 & mob<=12  
replace entry = date("1/4/1963","DMY") if bula == 4 & yob == 1957 & mob>=1 & mob<=3 
replace entry = date("1/4/1964","DMY") if bula == 4 & yob == 1957 & mob>=4 & mob<=12
replace entry = date("1/4/1964","DMY") if bula == 4 & yob == 1958 & mob>=1 & mob<=3  
replace entry = date("1/4/1965","DMY") if bula == 4 & yob == 1958 & mob>=4 & mob<=12
replace entry = date("1/4/1965","DMY") if bula == 4 & yob == 1959 & mob>=1 & mob<=3 
replace entry = date("1/4/1966","DMY") if bula == 4 & yob == 1959 & mob>=4 & mob<=12
replace entry = date("1/4/1966","DMY") if bula == 4 & yob == 1960 & mob>=1 & mob<=5
replace entry = date("1/12/1966","DMY") if bula == 4 & yob == 1960 & mob>=6 & mob<=11
replace entry = date("1/8/1967","DMY") if bula == 4 & yob == 1960 & mob==12
replace entry = date("1/8/1967","DMY") if bula == 4 & yob == 1961 & mob>=1 & mob<=6
replace entry = date("1/8/1968","DMY") if bula == 4 & yob == 1961 & mob>=7 & mob<=12
replace entry = date("1/8/1968","DMY") if bula == 4 & yob == 1962 & mob>=1 & mob<=6  
replace entry = date("1/8/1969","DMY") if bula == 4 & yob == 1962 & mob>=7 & mob<=12 
replace entry = date("1/8/1969","DMY") if bula == 4 & yob == 1963 & mob>=1 & mob<=6  
replace entry = date("1/8/1970","DMY") if bula == 4 & yob == 1963 & mob>=7 & mob<=12 
replace entry = date("1/8/1970","DMY") if bula == 4 & yob == 1964 & mob>=1 & mob<=6  
replace entry = date("1/8/1971","DMY") if bula == 4 & yob == 1964 & mob>=7 & mob<=12
replace entry = date("1/8/1971","DMY") if bula == 4 & yob == 1965 & mob>=1 & mob<=6
replace entry = date("1/8/1972","DMY") if bula == 4 & yob == 1965 & mob>=7 & mob<=12
* school exit
replace exit = date("31/3/1958","DMY") if bula == 4 & yob == 1944 & mob>=1 & mob<=3
replace exit = date("31/3/1960","DMY") if bula == 4 & yob == 1944 & mob>=4 & mob<=12
replace exit = date("31/3/1960","DMY") if bula == 4 & yob == 1945 & mob>=1 & mob<=3
replace exit = date("31/3/1961","DMY") if bula == 4 & yob == 1945 & mob>=4 & mob<=12
replace exit = date("31/3/1961","DMY") if bula == 4 & yob == 1946 & mob>=1 & mob<=3  
replace exit = date("31/3/1962","DMY") if bula == 4 & yob == 1946 & mob>=4 & mob<=12 
replace exit = date("31/3/1962","DMY") if bula == 4 & yob == 1947 & mob>=1 & mob<=3  
replace exit = date("31/3/1963","DMY") if bula == 4 & yob == 1947 & mob>=4 & mob<=12 
replace exit = date("31/3/1963","DMY") if bula == 4 & yob == 1948 & mob>=1 & mob<=3  
replace exit = date("31/3/1964","DMY") if bula == 4 & yob == 1948 & mob>=4 & mob<=12 
replace exit = date("31/3/1964","DMY") if bula == 4 & yob == 1949 & mob>=1 & mob<=3  
replace exit = date("31/3/1965","DMY") if bula == 4 & yob == 1949 & mob>=4 & mob<=12 
replace exit = date("31/3/1965","DMY") if bula == 4 & yob == 1950 & mob>=1 & mob<=3  
replace exit = date("31/3/1966","DMY") if bula == 4 & yob == 1950 & mob>=4 & mob<=12 
replace exit = date("31/3/1966","DMY") if bula == 4 & yob == 1951 & mob>=1 & mob<=3  
replace exit = date("30/11/1966","DMY") if bula == 4 & yob == 1951 & mob>=4 & mob<=12
replace exit = date("30/11/1966","DMY") if bula == 4 & yob == 1952 & mob>=1 & mob<=3
replace exit = date("31/7/1967","DMY") if bula == 4 & yob == 1952 & mob>=4 & mob<=12 
replace exit = date("31/7/1967","DMY") if bula == 4 & yob == 1953 & mob>=1 & mob<=3 
replace exit = date("31/7/1968","DMY") if bula == 4 & yob == 1953 & mob>=4 & mob<=12 
replace exit = date("31/7/1968","DMY") if bula == 4 & yob == 1954 & mob>=1 & mob<=3 
replace exit = date("31/7/1969","DMY") if bula == 4 & yob == 1954 & mob>=4 & mob<=12  
replace exit = date("31/7/1969","DMY") if bula == 4 & yob == 1955 & mob>=1 & mob<=3 
replace exit = date("31/7/1970","DMY") if bula == 4 & yob == 1955 & mob>=4 & mob<=12
replace exit = date("31/7/1970","DMY") if bula == 4 & yob == 1956 & mob>=1 & mob<=3 
replace exit = date("31/7/1971","DMY") if bula == 4 & yob == 1956 & mob>=4 & mob<=12  
replace exit = date("31/7/1971","DMY") if bula == 4 & yob == 1957 & mob>=1 & mob<=3 
replace exit = date("31/7/1972","DMY") if bula == 4 & yob == 1957 & mob>=4 & mob<=12
replace exit = date("31/7/1972","DMY") if bula == 4 & yob == 1958 & mob>=1 & mob<=3  
replace exit = date("31/7/1973","DMY") if bula == 4 & yob == 1958 & mob>=4 & mob<=12
replace exit = date("31/7/1973","DMY") if bula == 4 & yob == 1959 & mob>=1 & mob<=3 
replace exit = date("31/7/1974","DMY") if bula == 4 & yob == 1959 & mob>=4 & mob<=12
replace exit = date("31/7/1974","DMY") if bula == 4 & yob == 1960 & mob>=1 & mob<=5 //geändert MH
replace exit = date("31/7/1975","DMY") if bula == 4 & yob == 1960 & mob>=6 & mob<=11 //geändert MH
replace exit = date("31/7/1976","DMY") if bula == 4 & yob == 1960 & mob==12
replace exit = date("31/7/1976","DMY") if bula == 4 & yob == 1961 & mob>=1 & mob<=6
replace exit = date("31/7/1977","DMY") if bula == 4 & yob == 1961 & mob>=7 & mob<=12
replace exit = date("31/7/1977","DMY") if bula == 4 & yob == 1962 & mob>=1 & mob<=6  
replace exit = date("31/7/1978","DMY") if bula == 4 & yob == 1962 & mob>=7 & mob<=12 
replace exit = date("31/7/1978","DMY") if bula == 4 & yob == 1963 & mob>=1 & mob<=6  
replace exit = date("31/7/1979","DMY") if bula == 4 & yob == 1963 & mob>=7 & mob<=12 
replace exit = date("31/7/1979","DMY") if bula == 4 & yob == 1964 & mob>=1 & mob<=6  
replace exit = date("31/7/1980","DMY") if bula == 4 & yob == 1964 & mob>=7 & mob<=12
replace exit = date("31/7/1980","DMY") if bula == 4 & yob == 1965 & mob>=1 & mob<=6
replace exit = date("31/7/1981","DMY") if bula == 4 & yob == 1965 & mob>=7 & mob<=12
*}

***** extend to later cohorts
gen e_d=1
gen e_m=8
replace e_m=9 if bula==9
gen e_y=.
gen ex_d=31
gen ex_m=7
replace ex_m=8 if bula==9
gen ex_y=.

foreach num of numlist 1966(1)1995 {
    replace e_y=`num'+6 if yob == `num' & mob>=1 & mob<=6
    replace e_y=`num'+7 if yob == `num' & mob>=7 & mob<=12

    replace ex_y = `num'+15 if yob == `num' & mob>=1 & mob<=6
    replace ex_y = `num'+16 if yob == `num' & mob>=7 & mob<=12
}

replace entry=mdy(e_m,e_d,e_y) if entry==. & e_y!=.

replace entry = mdy(8,e_d,1972) if bula == 9 & yob == 1965 & inrange(mob,7,12) // Hamburger Abkommen (in Bayern: Änderung auf den 1. August -> ab wann? vorläufig erstmal ab 1965 eingetragen -> Jonas rechechiert)
replace entry = mdy(8,e_d,e_y) if bula == 9 & yob >= 1966 

replace exit=mdy(ex_m,ex_d,ex_y) if exit==. & ex_y!=.
drop e_* ex_*

lab var entry "date of school entry (statutory)"
lab var exit "date of exit after compulsory schooling (statutory)"


* generate duration of elementary schooling (grades 1-4)
gen stime4 = 4 
lab var stime4 "duration of elementary schooling (grades 1-4)"
* 8 - Baden-W.
replace stime4 = 3.666 if bula == 8 & yob == 1944
replace stime4 = 3.666 if bula == 8 & yob == 1945 & mob>=1 & mob<=5
replace stime4 = 3.666 if bula == 8 & yob == 1956 
replace stime4 = 3.333 if bula == 8 & yob >= 1957 & yob <= 1959
replace stime4 = 3.666 if bula == 8 & yob == 1960 & mob>=1 & mob<=6
* 7 - Reihnland-Pfalz
replace stime4 = 3.666 if bula == 7 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 7 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 7 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 7 & yob >= 1958 & yob <= 1959
replace stime4 = 3.333 if bula == 7 & yob == 1960 & mob>=1 & mob<=3
replace stime4 = 3.666 if bula == 7 & yob == 1960 & mob>=4 & mob<=11
* 5 - NRW
replace stime4 = 3.666 if bula == 5 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 5 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 5 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 5 & yob >= 1958 & yob <= 1959
replace stime4 = 3.333 if bula == 5 & yob == 1960 & mob>=1 & mob<=3
replace stime4 = 3.666 if bula == 5 & yob == 1960 & mob>=4 & mob<=11
* 6 - Hessen
replace stime4 = 3.666 if bula == 6 & yob == 1956 & mob>=1 & mob<=12
replace stime4 = 3.333 if bula == 6 & yob >= 1957 & yob <= 1959
replace stime4 = 3.333 if bula == 6 & yob == 1960 & mob>=1 & mob<=3
replace stime4 = 3.666 if bula == 6 & yob == 1960 & mob>=4 & mob<=11
* 10 - Saarland
replace stime4 = 3.585 if bula == 10 & yob >= 1947 & yob <= 1949
replace stime4 = 3.585 if bula == 10 & yob == 1950 & mob>=1 & mob<=9
replace stime4 = 3.666 if bula == 10 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 10 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 10 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 10 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 10 & yob >= 1958 & yob <= 1960
replace stime4 = 3.666 if bula == 10 & yob == 1960 & mob>=4 & mob<=12
* 3 - Niedersachsen
replace stime4 = 3.666 if bula == 3 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 3 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 3 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 3 & yob >= 1958 & yob <= 1960
replace stime4 = 4 if bula == 3 & yob == 1960 & mob>=4 & mob<=12
* 2- Hamburg
replace stime4 = 4.333 if bula == 2 & yob >= 1956 & yob <= 1959
* 1 - Schl-H
replace stime4 = 3.666 if bula == 1 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 1 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 1 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 1 & yob >= 1958 & yob <= 1959
replace stime4 = 3.666 if bula == 1 & yob == 1960 & mob >= 1 & mob <=11
* 4 - Bremen
replace stime4 = 3.666 if bula == 4 & yob == 1956 & mob>=4 & mob<=12
replace stime4 = 3.666 if bula == 4 & yob == 1957 & mob>=1 & mob<=3
replace stime4 = 3.333 if bula == 4 & yob == 1957 & mob>=4 & mob<=12
replace stime4 = 3.333 if bula == 4 & yob >= 1958 & yob <= 1959
replace stime4 = 3.333 if bula == 4 & yob == 1960 & mob >= 1 & mob <=5
replace stime4 = 3.666 if bula == 4 & yob == 1960 & mob >= 6 & mob <=11

* generate statutory time of compulsory schooling
gen stime=round(((exit-entry)/365),0.001)
tab stime, mis
recode stime (7.6/7.7=7.666) (8/8.1=8) (8.3/8.4=8.333) (8.5/8.59=8.585) (8.6/8.8=8.666) (9/9.1=9)
gen stime8=stime-stime4
tab stime8, mis
recode stime8 (4/4.1=4) (4.3/4.4=4.333) (4.5/4.6=4.585) (4.65/4.68=4.666) (5/5.1=5) (5.3/5.4=5.333) (5.6/5.7=5.666)
lab var stime8 "duration of post-elementary schooling (grades 5-8/9)"

tab1 stime*, mis
lab var stime "statutory time of compulsory schooling"

* generate indicators for schooling extensions (8->9 yrs) and short school yrs
gen C9=stime>8
recode stime (7/7.7=1) (8.3/8.4=2) (8.5/8.7=1) (else=0),gen(SSY)
gen SSY_=SSY>0

tab stime C9, mis
tab stime SSY, mis
lab var C9 "=1 if exposed to compulsory schooling extension (8->9 yrs)"
lab var SSY "no. short school yrs (0, 1, or 2)"
lab var SSY_ "=1 if exposed to any short school yrs"


* generate size of enrollment cohort
gen en_size = 12 
lab var en_size "size of enrollment cohort"
* 9 - Bayern ***
replace en_size = 9 if bula == 9 & (yob == 1946 & mob>=1 & mob<=9)
replace en_size = 9 if bula == 9 & (yob == 1962 & mob>=10 & mob<=12)
replace en_size = 9 if bula == 9 & (yob == 1963 & mob>=1 & mob<=6)
* 8 - Baden-W.
replace en_size = 5 if bula == 8 & yob == 1945 & mob>=1 & mob<=5
replace en_size = 10 if bula == 8 & yob == 1945 & mob>=6 & mob<=12
replace en_size = 10 if bula == 8 & yob == 1946 & mob>=1 & mob<=3
replace en_size = 13 if bula == 8 & yob == 1946 & mob>=4 & mob<=12
replace en_size = 13 if bula == 8 & yob == 1947 & mob>=1 & mob<=4
replace en_size = 8 if bula == 8 & yob == 1951 & mob>=5 & mob<=12
replace en_size = 6 if bula == 8 & yob == 1960 & mob>=1 & mob<=6
* 7 - Reihnland-Pfalz
replace en_size = 15 if bula == 7 & yob == 1944 & mob>=1 & mob<=3
replace en_size = 8 if bula == 7 & yob == 1960 & mob>=4 & mob<=11
replace en_size = 7 if bula == 7 & yob == 1960 & mob==12 
replace en_size = 7 if bula == 7 & yob == 1961 & mob>=1 & mob<=6
* 5 - NRW
replace en_size = 6 if bula == 5 & yob == 1944 & mob>=1 & mob<=6
replace en_size = 9 if bula == 5 & yob == 1954 & mob>=7 & mob<=12
replace en_size = 9 if bula == 5 & yob == 1955 & mob>=1 & mob<=3
replace en_size = 8 if bula == 5 & yob == 1960 & mob>=4 & mob<=11
replace en_size = 7 if bula == 5 & yob == 1960 & mob==12 
replace en_size = 7 if bula == 5 & yob == 1961 & mob>=1 & mob<=6
* 6 - Hessen
replace en_size = 9 if bula == 6 & yob == 1950 & mob>=7 & mob<=12
replace en_size = 9 if bula == 6 & yob == 1951 & mob>=1 & mob<=3
replace en_size = 9 if bula == 6 & yob == 1955 & mob>=4 & mob<=12
replace en_size = 15 if bula == 6 & yob == 1959 & mob>=1 & mob<=12
replace en_size = 15 if bula == 6 & yob == 1960 & mob>=1 & mob<=3
replace en_size = 8 if bula == 6 & yob == 1960 & mob>=4 & mob<=11
replace en_size = 7 if bula == 6 & yob == 1960 & mob==12
replace en_size = 7 if bula == 6 & yob == 1961 & mob>=1 & mob<=6
* 10 - Saarland
replace en_size = 9 if bula == 10 & yob == 1948 & mob>=1 & mob<=9
replace en_size = 18 if bula == 10 & yob == 1951 & mob>=10 & mob<=12
replace en_size = 18 if bula == 10 & yob == 1952
replace en_size = 18 if bula == 10 & yob == 1953 & mob>=1 & mob<=3
replace en_size = 9 if bula == 10 & yob == 1960 & mob>=4 & mob<=12
replace en_size = 9 if bula == 10 & yob == 1961
replace en_size = 9 if bula == 10 & yob == 1962 & mob>=1 & mob<=6
* 3 - Niedersachsen
replace en_size = 9 if bula == 3 & yob == 1948 & mob>=7 & mob<=12
replace en_size = 9 if bula == 3 & yob == 1949 & mob>=1 & mob<=3
replace en_size = 15 if bula == 3 & yob == 1960 & mob>=4 & mob<=12
replace en_size = 15 if bula == 3 & yob == 1961 & mob>=1 & mob<=6
* 2- Hamburg
replace en_size = 9 if bula == 2 & yob == 1955 & mob>=4 & mob<=12
replace en_size = 18 if bula == 2 & yob == 1960
replace en_size = 18 if bula == 2 & yob == 1961 & mob>=1 & mob<=6
* 1 - Schl-H
replace en_size = 9 if bula == 1 & yob == 1957 & mob>=4 & mob<=12
replace en_size = 11 if bula == 1 & yob == 1960 & mob>=1 & mob<=11
replace en_size = 7 if bula == 1 & yob == 1960 & mob==12
replace en_size = 7 if bula == 1 & yob == 1961 & mob>=1 & mob<=6
* 4 - Bremen
replace en_size = 14 if bula == 4 & yob == 1959 & mob>=4 & mob<=12
replace en_size = 14 if bula == 4 & yob == 1960 & mob>=1 & mob<=5
replace en_size = 6 if bula == 4 & yob == 1960 & mob>=6 & mob<=11
replace en_size = 7 if bula == 4 & yob == 1960 & mob==12
replace en_size = 7 if bula == 4 & yob == 1961 & mob>=1 & mob<=6


* generate statutory school entry cohort
gen entry_y=year(entry)
lab var entry_y "year of school enrollment (statutory entry cohort)"

* generate statutory age at school entry
gen age_entry=int((entry-bdate)/365)
gen age_entry_m=round(((entry-bdate)/365),0.01)
lab var age_entry "age at school entry (statutory, completed)"
lab var age_entry_m "age at school entry (statutory, detailed)"

* relative age at enrollment
sort bula bdate
bysort bula: gen jump = entry-entry[_n-1]
gen cut_=bdate if jump>0 & jump!=.
replace cut_=date("1/4/1943","DMY") if bula == 1 & yob == 1944 & jump==.
replace cut_=date("1/4/1943","DMY") if bula == 2 & yob == 1944 & jump==.
replace cut_=date("1/7/1943","DMY") if bula == 3 & yob == 1944 & jump==.
replace cut_=date("1/4/1943","DMY") if bula == 4 & yob == 1944 & jump==.
replace cut_=date("1/1/1944","DMY") if bula == 5 & yob == 1944 & jump==.
replace cut_=date("1/7/1943","DMY") if bula == 6 & yob == 1944 & jump==.
replace cut_=date("1/1/1943","DMY") if bula == 7 & yob == 1944 & jump==.
replace cut_=date("1/1/1944","DMY") if bula == 8 & yob == 1944 & jump==.
replace cut_=date("1/1/1944","DMY") if bula == 9 & yob == 1944 & jump==.
replace cut_=date("1/1/1944","DMY") if bula == 10 & yob == 1944 & jump==.
bysort bula entry: egen cut=max(cut_)
format %td cut*
lab var cut "statut. cutoff for enrollment"

gen age_rel = (cut - bdate) / 365
drop jump cut_
lab var age_rel "age at school entry (relative to statut. cutoff)"
*}

*gen birth date in monthly format
gen bdate_ =ym(yob, mob) 
format bdate_ %tm
lab var bdate_ "birth date (monthly format)"



**generate indicator for early enrolment**
gen kann = 0
replace kann = 1 if yob >= 1965 & inrange(mob,7,12) // from 1965 onwards early enrolment was granted for almost everyone born after the cutoff (slight deviations are adjusted below)

*Bayern
replace kann = 1 if bula == 9  & yob >= 1951 & yob <= 1955 & mob >= 10
replace kann = 1 if bula == 9  & yob >= 1963 & yob <= 1965 & mob >= 7 

*BawÜ
replace kann = 1 if bula == 8  & yob == 1946 & mob >= 4 & mob <= 6
replace kann = 1 if bula == 8  & yob >= 1947 & yob <= 1951 & mob >= 4 & mob <= 6 
replace kann = 1 if bula == 8  & yob >= 1953 & yob <= 1960 & mob >= 1 & mob <= 3
replace kann = 1 if bula == 8  & yob == 1960 & mob >= 7 & mob <= 11
replace kann = 1 if bula == 8  & yob >= 1961 & yob <= 1965 & mob >= 7 & mob <= 8 
replace kann = 0 if bula == 8  & inrange(yob,1965,1969) & inrange(mob,9,12) 

*RLP
replace kann = 1 if bula == 7  & yob >= 1946 & yob <= 1960 & mob >= 4 & mob <= 6 
replace kann = 1 if bula == 7  & yob == 1960 & mob == 12
replace kann = 1 if bula == 7  & yob == 1961 & mob == 1 & mob >=7 & mob <=9
replace kann = 1 if bula == 7  & yob >= 1962 & yob <= 1965 & mob >=7 & mob <=12 

*NRW
replace kann = 1 if bula == 5  & yob >= 1955 & yob <= 1960 & mob >=4 & mob <=6
replace kann = 1 if bula == 5  & yob == 1960 & mob == 12
replace kann = 1 if bula == 5  & yob == 1961 & mob == 1 & mob == 2 & mob >= 7 & mob <= 9
replace kann = 1 if bula == 5  & yob >= 1962 & yob <= 1965 & mob >7 

*Hessen
replace kann = 1 if bula == 6  & yob >= 1944 & yob <= 1950 & mob == 7
replace kann = 1 if bula == 6  & yob >= 1951 & yob <= 1955 & mob >=4 & mob <=6
replace kann = 1 if bula == 6  & yob >= 1957 & yob <= 1960 & mob >=1 & mob <=3
replace kann = 1 if bula == 6  & yob == 1960 & mob == 12
replace kann = 1 if bula == 6  & yob == 1961 & mob >=7 & mob <=9
replace kann = 1 if bula == 6  & yob >= 1962 & yob <= 1965 & mob >7 

*Saarland
replace kann = 1 if bula == 10 & yob >= 1962 & yob <= 1965 & mob >7 

*Niedersachsen
replace kann = 1 if bula == 3  & yob >= 1949 & yob <= 1952 & mob >=4 & mob <=9
replace kann = 1 if bula == 3  & yob >= 1953 & yob <= 1960 & mob >=4 & mob <=6
replace kann = 1 if bula == 3  & yob == 1961 & mob >=7 & mob <=9
replace kann = 1 if bula == 3  & yob >= 1962 & yob <= 1965 & mob >7 

*Hamburg
replace kann = 1 if bula == 2  & yob >= 1944 & yob <= 1955 & mob >=4 & mob <=6
replace kann = 1 if bula == 2  & yob >= 1957 & yob <= 1961 & mob >=1 & mob <=3 
replace kann = 1 if bula == 2  & yob == 1961 & mob >=7 & mob <=9
replace kann = 1 if bula == 2  & yob >= 1962 & yob <= 1965 & mob >7 

*Schleswig-Holstein
replace kann = 1 if bula == 1  & yob >= 1944 & yob <= 1957 & mob >=4 & mob <=6
replace kann = 1 if bula == 1  & yob == 1959 & mob >=1 & mob <=6
replace kann = 1 if bula == 1  & yob == 1960 & mob >=1 & mob <=6 & mob == 12
replace kann = 1 if bula == 1  & yob == 1961 & mob ==1 & mob >=7 & mob <= 10
replace kann = 1 if bula == 1  & yob >= 1962 & yob <= 1965 & mob >7 

*Bremen
replace kann = 1 if bula == 4  & yob >= 1944 & yob <= 1950 & mob >=4 & mob <=6
replace kann = 1 if bula == 4  & yob >= 1961 & yob <= 1965 & mob >=7 & mob <=9 
replace kann = 0 if bula == 4  & inrange(yob,1965,1968) & inrange(mob,10,12) // early enrolment only for July to September between 1965 to 1968

label var kann "possibility of early enrolment"




clonevar first_day = cut
bysort bula (bdate): gen transition = first_day != first_day[_n+1]
bysort bula: gen last_day_ = first_day[_n+1]-1 if transition == 1
bysort bula entry: egen last_day = max(last_day_)
format last_day last_day_ %td
gen en_size_days = last_day - first_day + 1
replace en_size_days = 365 if en_size == 12 & (en_size_days < 0 | en_size_days == .) & yob == 1995
drop first_day transition last_day_ last_day



summarize


compress
save "${results}\schooling_laws_west.dta", replace

log close

