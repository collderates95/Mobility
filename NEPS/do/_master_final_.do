/*****************************************************************
	Master file, project: Education and regional mobility 
	over the life cycle

***********************************************************/

version 14.1
clear
set more off
set seed 1258796
set sortseed 32154669 
set linesize 120
set varabbrev off, permanently

* global for date
gen date_current_temp = date("`c(current_date)'","DMY") 
format date_current_temp %tdCCYYNNDD
global date = string(date("`c(current_date)'","DMY"),"%tdCCYYNNDD") 
drop date_current_temp
di "$date"


********************************************************************************
* Set paths
********************************************************************************
cd "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility" // main path

global path "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Mobility"

cap mkdir log
cap mkdir results
cap mkdir log
cap mkdir schooling_laws
cap mkdir export
cap mkdir graphs


*S* global data "Z:\SUF\Download\SC6\SC6_D_13-0-0\Stata"
global data "Z:\SUF\Remote\SC6\SC6_R_13-0-0\Stata" 
global prog "$path\do"
global log "$path\log"
global results "$path\results"
global laws "$path\schooling_laws"
global export "$path\export"
global graphs "$path\graphs"
global frandsen "$path\frandsen"
global ratio "$path\Teacher Student Ratio"
global rural "$path\rural"
global lm "$path\Labour Markets And Metropols"
global MergeUrbanFDZ "Z:\Projects\p000245_DUA_4170_DUA_4612_DUA_4957\Merge Tobias"
global DiDWeights "$path\results\Compulsory Schooling\DiDWeights" 



/********************************************************************************
* STEP 1: Generate basic panel over lifecycle for the relevant cohorts
********************************************************************************/
do "$prog\230301_basic_panel.do" 
save "$results/0_basicpanel.dta", replace

********************************************************************************
* Extract and merge data on the residency spells
********************************************************************************
do "$prog\230301_residency.do" 
save "$results/0_basicpanel.dta", replace


********************************************************************************
* Extract and merge data on the school spells
********************************************************************************
do "$prog\230301_school_prep.do" 
save "$results/0_basicpanel.dta", replace


********************************************************************************
* Extract and merge data on the vocational training spells
********************************************************************************
do "$prog\230301_ausbild_prep_v1.do" 
save "$results/0_basicpanel.dta", replace



********************************************************************************
* Extract and merge data on the employment spells
********************************************************************************
do "$prog\230301_employment_prep.do"
save "$results/0_basicpanel.dta", replace

*/



********************************************************************************
* STEP 2: Create files that will finally be merged to the basicpanel
********************************************************************************

* Weights 
do "$prog\230301_weights.do" 	

*Labor Market regions 
do "$prog\250305_LabourMarketPreparation.do" 	

* Week of birth
do "$prog\230301_weekofbirth.do" // extract data on week of birth 

* Schoolentry
do "$prog\230301_schoolentry.do" // information on date & state of school entry (from school file)

*Education
do "$prog\231207_educ_prep.do" // information on highest degree (from school file)

*Background
do "$prog\250410_background.do" // information on parental background + kindergarden

*Cognitive skills
do "$prog\250410_cognitiveskills_prep.do" // prep cognitive skills data
do "$prog\250410_locrisk_prep.do" // locus of control + risk

*Schooling laws 
do "$laws\000_schooling_laws_west.do" // west germany
do "$laws\000_schooling_laws_east.do" // east germany
do "$laws\000_schooling_laws_merge.do" // merge east + west germany
do "$laws\000_schooling_laws_runningvariable.do" // create dataset with running variable -> contains final dataset (schooling_laws_final)






********************************************************************************
* STEP 3: Create outcome variables within basicpanel
********************************************************************************
do "$prog\250410_basicpanel_outcomes.do"  
save "$results/0_basicpanel_outcomes.dta", replace 


********************************************************************************
* STEP 4: Merge variables 
********************************************************************************
do "$prog\250410_sample_merge.do" // 
save "$results/0_basicpanel_final.dta", replace // final panel dataset; DO NOT overwrite anymore!



********************************************************************************
* STEP 5: SSA analysis
********************************************************************************

*Create variables (running variable, after) and impose restrictions
do "$prog\250410_sample_ssa_new.do" 		// prepares basic dataset for SSA analysis
save "$results\ssa_panel_neu.dta", replace 	// saves sample for SSA analysis (born and enrolled in west germany, 1945-1964) 


***********TABLES

** Table 2
do "$prog\250411_ssa_firststage_donut_new_tab2.do" // effects on educational outcomes

** Table 4
do "$prog\250411_analysis_ssa_all_donut_new_tab4.do" // effect on regional mobility 

** Table A.1
do "$prog\250507_neps_mz_comparison_new_tab_a1.do" // comparison with Micro Census

** Table A.2
do "$prog\250417_ssa_descriptives_donut_new_tab_a2.do" // descriptives enrollment sample

** Table A.3
do "$prog\250417_ssa_balancingtests_donut_new_tab_a3.do" // Balancing test

** Table A.4
do "$prog\251210_compliers_ssa_reg_donut_tab_a4.do" // complier characteristics SSA

** Table A.6
do "$prog\250411_analysis_ssa_cognitiveskills_new_tab_a6.do" // cognitive skills (columns 1-4)
do "$prog\250411_analysis_ssa_locrisk_new_tab_a6.do" // risk aversion (column 5)

** Table A.8
do "$prog\250411_analysis_ssa_educ_donut_new_tab_a8.do" // long-run educatonal outcomes

** Table A.10
do "$prog\250411_analysis_ssa_all_donut_standarderror_new_tab_a10.do" // different variance-estimators
do "$prog\250411_analysis_ssa_all_donut_robustness_new_tab_a10.do" // Panel A to H

** Table A.12
do "$prog\250509_analysis_ssa_numberofmoves_donut_new_tab_a12.do" // Number of Moves

** Table A.14
do "$prog\250411_analysis_ssa_all_donut_labormarket_tab_a14.do" // alternative geographic units



***********FIGURES

**** Fig A.7 
do "$prog\250411_ssa_enrolment_new_fig_a7.do" // school starters by type of enrollment

**** Fig A.9 
do "$prog\250411_ssa_obs_by_run_fig_a9.do" // distribution of running variable (weekly)

**** Fig A.11 - descriptive figure for school starting age and academic track (by running variable)
do "$prog\250411_educ_graphs_byweek_datasets_new_fig_a11.do" // produces the datasets in excel 
do "$prog\250411_educ_graphs_byweek_full_graphs_new_fig_a11.do" // produces graphs (original figures have been produces locally)

**** Fig A.12 - lifecycle figure for enrollment sample
do "$prog\250411_ssa_lifecycle_analysis_donut_avg3_fig_a12.do" // regressions + datasets with coefficients and CI for export
do "$prog\250411_ssa_lifecycle_graphs_avg3_fig_a12.do" // produces graphs (original figures have been produces locally)




********************************************************************************
* STEP 6: C9 analysis
********************************************************************************


********************************************************************************
* Sample construction for C9 analysis (merge supplementary datasets)
********************************************************************************
do "$prog\replic_250413_Combine_C9_final.do"


********************************************************************************
* Balancing Test and Main Descriptives
********************************************************************************
** Table A.3 - Columns 1 to 4
do "$prog\replic_250413_C9_Descriptives_BalancingTests_final.do" // Does Balancing Test (Bi- and Multivariate) // checked!

** Table A.2 - Column 3
do "$prog\replic_250413_C9_Descripives_Tables_final.do" // Sample means for C9 sample
** Table A.2 - Columns 1 and 2
do "$prog\replic_250413_DescriptivesFullSample_final.do" // Sample means for full and west German sample



***************************** Table 3
do "$prog\replic_250414_C9_TWFE_Migration_final.do" // main results

***************************** Table 1 & Table A.7  ***********************
do "$prog\replic_250417_C9_TWFE_Education_final.do" // Educational outcomes in short and long run

**************** Table A.11  **********************************
do "$prog\replic_250414_C9_NumberMoves_final.do" 

**************** Table A.5  **********************************
do "$prog\replic_250417_CognitiveSkills_Sebastian_final.do" // columns 1 to 4
do "$prog\replic_250417_RiskAversionLocusOfControl_Sebastian_final.do" // column 5

**************** Table A.13  **********************************
*do "$prog\replic_250417_C9_NumberMoves_final.do" // checked
do "$prog\replic_250417_C9_LabourMarketMetropols_final.do" 

**********Life-Cycle Analysis - Fig A.12 **********************
do "$prog\replic_240806_C9_LifeCycle_Avrg3Yrs.do" 

******************* Complier Analysis (Table A.4) *************************
do "$prog\replic_250417_C9_Complier_final.do" 

********************* Robustness - Table A.9 **********************
do "$prog\replic_250417_C9_AlternativeDiD_final.do" // Panel D of Table A.9

***** Different SE
do "$prog\replic_251125_C9_AdditionalClustering.do" // Stanard errors for Table A.9


**** Robustness Checks of Table A.9 (Panel A, B, C, E, F) *****
do "$prog\replic_250417_Sensitivity_Exclusion_final.do" // checked!

**** Robustness Checks of Table A.9 (Panel G) *****
do "$prog\replic_240120_Sensitivity_Exclusion_ReformAssignment.do" 

********************* Robustness - Fig A.13 **********************
do "$prog\replic_250417_C9_TWFE_EventStudy.do" // TWFE 
do "$prog\replic_250417_C9_AlternativeDiD_EventStudy.do" // ETWFE (Wooldridge)
do "$prog\replic_250417_C9_EventStudy_Combine.do" // Combine TWFE and ETWFE




********************************************************************************
* STEP 7: Descriptive figures + results
********************************************************************************
*** Figure 5 and 6
do "$prog\replic_250414_VisualisationCrossStateOLS_final.do" // OLS coefficient plots (cross-state and cross-county)

*** Figure 2, Figure A.1, Figure A.2
do "$prog\replic_250414_VisualisationMigrationGenderOverTime_final.do" // by educational attainment, gender, east/west

*** Figure 1
do "$prog\replic_250413_VisualisationLevelofMigration_final.do" // Age-Specific cross-state and cross-county mobility rates


*** Figure A.3 - Maps (require shape-files)
do "$prog\replic_230511_Maps_final.do"















