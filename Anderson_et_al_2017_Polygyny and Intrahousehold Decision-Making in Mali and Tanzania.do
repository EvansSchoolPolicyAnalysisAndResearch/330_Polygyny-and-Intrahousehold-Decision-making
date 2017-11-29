/*-----------------------------------------------------------------------------------------------------------------------------------------------------
*Title/Purpose 	: This do file was developed by Leigh Anderson, Travis Reynolds, Pierre Biscaye, and Josh Merfeld to analyze the effects
				  of polygyny on wives' share of intrahousehold decision-making authority in Mali and Tanzania.
*Acknowledgments: We thank Melissa Greenaway for excellent research assistance. We also thank the Bill & Melinda Gates Foundation for 
				  supporting the data work underlying the analysis. The findings and conclusions presented here are those of the authors 
				  and do not necessarily reflect the positions or policies of the foundation. All remaining errors are our own.
*Date			: 22 November 2017
----------------------------------------------------------------------------------------------------------------------------------------------------*/


*Data source
*-----------
*The Farmer First data was collected in October 2010 by TNS Research International.

*Summary of Executing the Master do.file
*-----------
*To use the do-file, enter the location of the data on line 33. After adding the location, the do-file should run in its entirety.
*Lines 35-410 are cleaning. Data analysis starts on line 417. The code replicates the analysis conducts in our paper.


clear
clear matrix
clear mata
drop _all
program drop _all
set more off
set trace off
set mem 120m
set maxvar 15000
set matsize 11000
****************************************************************************************************************
*Loading data
use ".../Farmer_First_Mali_Data_Raw.dta" // put location of data here
append using ".../Farmer_First_Tanzania_Data_Raw.dta" // put location of data here

gen hhid = Main						// use "hhid" as the household identifier
gen pid = res_id					// "pid" is the person identifier
gen married = q1_4==1 | q1_4==2
gen polygamous = q1_4==2
gen age = q1_3a
gen male = res_gender==1
gen female = male==0
gen years_as_farmer = q1_11
gen no_debt = q1_17==3
gen any_hiring = q1_18==1
*Renaming
ren Ability ability
ren Asset asset
ren q2_1 country
ren q1_5 educ
ren q1_16 health
*Religion
ren q1_9 religion
recode religion (6=5) (7=5) (99=5)		// Recoding these as "other"
label define religion 1 "Catholic" 2 "Protestant" 4 "Muslim" 5 "Other"
label val religion religion


*Ethnicity
ren q1_7 ethnicity
replace ethnicity=. if ethnicity==999

tab married
tab polygamous
drop if married==0 // To get rid of non-polygamous non-married respondents (93 obs dropped); only looking at monogamous/polygamous (i.e. married) households

tab ethnicity if country==1 & polygamous==1
*Mali: 31.39% of polygamous marriages are Bambara ethnicity, 11.00% Marka, 10.72% Peul
*All ethnic groups in Mali record some polygamy
tab ethnicity if country==2
*Tanzania: Msukuma 17.10%, all others less than 10%
tab ethnicity if country==2 & polygamous==1
*Tanzania: 18.66% of polygamous marriages Msukuma, 13.65% Muha (Muha makes up 5.90% of sample)



****
*Household variables
ren q2_2 region
gen distance_tarmac = q2_5a_1			// Distance variables (to tarmac road, to road open all year, to market)
gen distance_openroad = q2_5a_2
gen distance_market = q2_5a_3
*Plots
foreach i of numlist 1 2 3 4 5 6{		// Up to 6 plots per household
gen plot`i'_size = q4_2a_`i'
gen plot`i'_registered = q4_2b_`i'==1
gen plot`i'_owned = q4_2c_`i'==1
}
gen total_acres_est = q4_3
gen total_acres_cult = q4_4
gen tot_income = q5_3
recode tot_income (98=.)		// 98 is "Don't Know"
gen farm_income = q5_5


*Generate child and elderly HH member variables
*Total Children
gen num_daughters = 0
foreach x of numlist 1/12{
	replace num_daughters = num_daughters + 1 if q3_1a_`x' == 4
}
replace num_daughters = . if q3_1a_1==.

gen num_sons = 0
foreach x of numlist 1/12{
	replace num_sons = num_sons + 1 if q3_1a_`x' == 3
}
replace num_sons = . if q3_1a_1==.

gen num_children = num_sons + num_daughters
la var num_children "Number of children in hh"

*Children under 10
gen girls_under10 = 0
foreach x of numlist 1/12{
	replace girls_under10 = girls_under10 + 1 if q3_1a_`x' == 4 & q3_1b_`x' < 10
}
replace girls_under10 = . if q3_1a_1==.

gen boys_under10 = 0
foreach x of numlist 1/12{
	replace boys_under10 = boys_under10 + 1 if q3_1a_`x' == 3 & q3_1b_`x' < 15
}
replace boys_under10 = . if q3_1a_1==.

gen children_under10 = boys_under10 + girls_under10
la var children_under10 "Number of children under 10 in hh"
la var boys_under10 "Number of boys under 10 in hh"
la var girls_under10 "Number of girls under 10 in hh"

*Children under 3
gen girls_under3binary = 0
foreach x of numlist 1/12{
	replace girls_under3binary = girls_under3binary + 1 if q3_1a_`x' == 4 & q3_1b_`x' < 3
}
replace girls_under3binary = . if q3_1a_1==.

gen boys_under3binary = 0
foreach x of numlist 1/12{
	replace boys_under3binary = boys_under3binary + 1 if q3_1a_`x' == 3 & q3_1b_`x' < 3
}
replace boys_under3binary = . if q3_1a_1==.

la var boys_under3binary "Number of boys under 3 in hh"
la var girls_under3binary "Number of girls under 3 in hh"
	
*Children under 5
	
gen girls_under5binary = 0
foreach x of numlist 1/12{
	replace girls_under5binary = girls_under5binary + 1 if q3_1a_`x' == 4 & q3_1b_`x' < 5
}
replace girls_under5binary = . if q3_1a_1==.

gen boys_under5binary = 0
foreach x of numlist 1/12{
	replace boys_under5binary = boys_under5binary + 1 if q3_1a_`x' == 3 & q3_1b_`x' < 5
}
replace boys_under5binary = . if q3_1a_1==.

la var boys_under5binary "Number of boys under 5 in hh"
la var girls_under5binary "Number of girls under 5 in hh"

*Elderly HH members (NOTE: age 60 or over)
gen elderly = 0
foreach x of numlist 1/12{
	replace elderly = elderly + 1 if q3_1b_`x' >= 60 & q3_1b_`x' !=.
}
replace elderly = . if q3_1a_1==.

la var elderly "Number of hh members over 60"
 

*Household size
foreach i of numlist 1/12 { // Up to 12 members can be documented 
gen hh_member_p`i' = q3_1a_`i'
gen hh_member_age_`i' = q3_1b_`i'
gen hh_member_gender_`i' = q3_1c_`i'
gen wife`i' = q3_1a_`i'==2 
}


*Decisions - NOTE: All of these are the number of beans (out of 10) to the MAN (can get woman's share by subtracting man's share from 10)
gen overall_farm = q9_1a_1
gen crops_choice = q9_1a_2
gen crops_sale = q9_1a_3
gen crops_spendprofits = q9_1a_4
gen family_food = q9_1a_5
gen livestock_sale = q9_1a_6
gen livestock_spendprofits = q9_1a_7
gen children_school = q9_1a_8
gen seed_choice = q9_1a_9
gen farm_equipment = q9_1a_10
gen farm_training = q9_1a_11
gen information = q9_1a_12
gen overall_hh = q9_1a_13



*Keeping only variables of interest
keep hhid-overall_hh ability asset country educ health religion region boys* girls* 

*Defining decision-making variables
foreach i of varlist overall_farm-overall_hh{
gen m_m_`i' = `i' if male==1		// m_m_ is defined as the counters the man gives to himself
gen m_f_`i' = 10-m_m_`i'			// m_f_ is defined as the counters the man gives to the woman
gen f_m_`i' = `i' if female==1		// f_m_ is defined as the counters the woman gives to the man
gen f_f_`i' = 10-f_m_`i'			// f_f_ is defined as the counters the woman gives to herself
}

foreach i of varlist educ age ability health{
gen m_`i' = `i' if male==1
gen f_`i' = `i' if male==0
}

egen acres = rowtotal(plot*size) if male==1
egen acres_owned = rowtotal(plot*owned) if male==1
egen acres_registered = rowtotal(plot*registered) if male==1


*Now collapse to household level
collapse (sum) acres* (max) num_children num_sons num_daughters boys_* girls_* elderly m_* f_* distance* *income country region any_hiring polygamous asset religion, by(hhid)

foreach i in overall_farm crops_choice crops_sale crops_spendprofits family_food livestock_sale livestock_spendprofits children_school seed_choice farm_equipment farm_training information overall_hh{
gen mf_diff_`i' = m_m_`i'-f_m_`i'
gen fm_diff_`i' = f_f_`i'-m_f_`i'
}

foreach i in educ age ability health{
gen m_diff_`i' = m_`i'-f_`i'
gen f_diff_`i' = f_`i'-m_`i'
}

egen country_region = group(country region)		// For fixed effects

gen log_income = ln(tot_income + 1)
gen log_child = ln(num_children + 1)
gen log_elderly = ln(elderly + 1)
gen log_acres = ln(acres + 1)
gen log_f_age = ln(f_age)
gen log_m_age = ln(m_age)





*Ordering the data to make some things easier to do below
order m_m_* m_f_* f_m_* m_diff* f_diff_* m_* f_* mf_* fm_*



******************************************
******************************************
***									   ***
***      A note on variable names      ***
***									   ***
******************************************
******************************************
/*For decision-making variables, the prefix is composed of two parts, as in "a_b_". "a" can be either "m" or "f" and denotes
the reported. For example, "m_b_" means the male in the household reports b. The second letter, "b", is the individual to whom
the beans are allocated. For example, "a_f_" means that person a allocates beans to the female. Therefore, we have four 
possibilities:
1) m_m_: Male allocates beans to male 
2) m_f_: Male allocates beans to female
3) f_f_: Female allocates beans to female
4) f_m_: Female allocates beans to male
*/


global f_f "f_f_overall_farm f_f_crops_choice f_f_crops_sale f_f_crops_spendprofits f_f_family_food f_f_livestock_sale f_f_livestock_spendprofits f_f_children_school f_f_seed_choice f_f_farm_equipment f_f_farm_training f_f_information"
global m_f "m_f_overall_farm m_f_crops_choice m_f_crops_sale m_f_crops_spendprofits m_f_family_food m_f_livestock_sale m_f_livestock_spendprofits m_f_children_school m_f_seed_choice m_f_farm_equipment m_f_farm_training m_f_information"






*Generating three "indices" for these
gen f_f_farm = (f_f_crops_choice + f_f_crops_spend + f_f_crops_sale + f_f_farm_equi + f_f_overall_farm + f_f_seed_choice)/6
gen f_f_livestock = (f_f_livestock_sale + f_f_livestock_spendprofits)/2
gen f_f_farmeduc = (f_f_farm_tra + f_f_informa)/2

gen m_f_farm = (m_f_crops_choice + m_f_crops_spend + m_f_crops_sale + m_f_farm_equi + m_f_overall_farm + m_f_seed_choice)/6
gen m_f_livestock = (m_f_livestock_sale + m_f_livestock_spendprofits)/2
gen m_f_farmeduc = (m_f_farm_tra + m_f_informa)/2



*Defining variable labels and labeling variables
tab religion, gen(religion)
ren num_children children
*Labels
la define country 1 "Mali" 2 "Tanzania"
la val country country
la var country "Country"
la var polygamous "Polygamous"
la var religion1 "Catholic"
la var religion2 "Protestant"
la var religion3 "Muslim"
la var religion4 "Other Religion"
la var acres "Acres"
la var acres_owned "Acres owned"
la var any_hiring "HH hired any labor"
la var girls_under10 "Girls under 10"
la var boys_under10 "Boys under 10"
la var num_daughters "Daughters in HH"
la var num_sons "Sons in HH"
la var children "Children under 10"
la var elderly "Seniors (age>=60)"
la var distance_tarmac "Distance to nearest tarmac road (km)"
la var distance_market "Distance to nearest market (km)"
la var asset "Asset score"
la var f_age "Age (female)"
la var m_age "Age (male)"
la var m_diff_age "Difference in age (male minus female)"
la var f_diff_age "Difference in age (female minus male)"
la var f_health "Health (female)"
la var m_health "Health (male)"
la var m_diff_health "Difference in health (male minus female)"
la var f_diff_health "Difference in health (female minus male)"
la var f_educ "Education (female)"
la var m_educ "Education (male)"
la var m_diff_educ "Difference in education (male minus female)"
la var f_diff_educ "Difference in education (female minus male)"
la var f_ability "Ability (female)"
la var m_ability "Ability (male)"
la var m_diff_ability "Difference in ability (male minus female)"
la var f_diff_ability "Difference in ability (female minus male)"
*Beans to HUSBAND
la var m_m_overall_farm "What happens on the farm generally"
la var m_m_crops_choice "What crops to plant"
la var m_m_crops_sale "Where to sell crops"
la var m_m_crops_spendprofits "How to spend profits from crop sales"
la var m_m_family_food "What foods to feed family"
la var m_m_livestock_sale "When to sell livestock"
la var m_m_livestock_spendprofits "How to spend profits from livestock sales"
la var m_m_children_school "Child schooling"
la var m_m_seed_choice "What seed variety (e.g. high yielding) to buy"
la var m_m_farm_equipment "Whether to buy new farm equipment"
la var m_m_farm_training "Whether to attend farm training"
la var m_m_information "What type of info/training HH needs"
la var f_m_overall_farm "What happens on the farm generally"
la var f_m_crops_choice "What crops to plant"
la var f_m_crops_sale "Where to sell crops"
la var f_m_crops_spendprofits "How to spend profits from crop sales"
la var f_m_family_food "What foods to feed family"
la var f_m_livestock_sale "When to sell livestock"
la var f_m_livestock_spendprofits "How to spend profits from livestock sales"
la var f_m_children_school "Child schooling"
la var f_m_seed_choice "What seed variety (e.g. high yielding) to buy"
la var f_m_farm_equipment "Whether to buy new farm equipment"
la var f_m_farm_training "Whether to attend farm training"
la var f_m_information "What type of info/training HH needs"
*The prefix "mf_" means it is male's report minus female's report (of beans to male)
la var mf_diff_overall_farm "What happens on the farm generally"
la var mf_diff_crops_choice "What crops to plant"
la var mf_diff_crops_sale "Where to sell crops"
la var mf_diff_crops_spendprofits "How to spend profits from crop sales"
la var mf_diff_family_food "What foods to feed family"
la var mf_diff_livestock_sale "When to sell livestock"
la var mf_diff_livestock_spendprofits "How to spend profits from livestock sales"
la var mf_diff_children_school "Child schooling"
la var mf_diff_seed_choice "What seed variety (e.g. high yielding) to buy"
la var mf_diff_farm_equipment "Whether to buy new farm equipment"
la var mf_diff_farm_training "Whether to attend farm training"
la var mf_diff_information "What type of info/training HH needs"
*Beans to WIFE
la var m_f_overall_farm "What happens on the farm generally"
la var m_f_crops_choice "What crops to plant"
la var m_f_crops_sale "Where to sell crops"
la var m_f_crops_spendprofits "How to spend profits from crop sales"
la var m_f_family_food "What foods to feed family"
la var m_f_livestock_sale "When to sell livestock"
la var m_f_livestock_spendprofits "How to spend profits from livestock sales"
la var m_f_children_school "Child schooling"
la var m_f_seed_choice "What seed variety (e.g. high yielding) to buy"
la var m_f_farm_equipment "Whether to buy new farm equipment"
la var m_f_farm_training "Whether to attend farm training"
la var m_f_information "What type of info/training HH needs"
la var f_f_overall_farm "What happens on the farm generally"
la var f_f_crops_choice "What crops to plant"
la var f_f_crops_sale "Where to sell crops"
la var f_f_crops_spendprofits "How to spend profits from crop sales"
la var f_f_family_food "What foods to feed family"
la var f_f_livestock_sale "When to sell livestock"
la var f_f_livestock_spendprofits "How to spend profits from livestock sales"
la var f_f_children_school "Child schooling"
la var f_f_seed_choice "What seed variety (e.g. high yielding) to buy"
la var f_f_farm_equipment "Whether to buy new farm equipment"
la var f_f_farm_training "Whether to attend farm training"
la var f_f_information "What type of info/training HH needs"
*The prefix "fm_" means it is the female's report minus the male's report (of beans to female)
la var fm_diff_overall_farm "What happens on the farm generally"
la var fm_diff_crops_choice "What crops to plant"
la var fm_diff_crops_sale "Where to sell crops"
la var fm_diff_crops_spendprofits "How to spend profits from crop sales"
la var fm_diff_family_food "What foods to feed family"
la var fm_diff_livestock_sale "When to sell livestock"
la var fm_diff_livestock_spendprofits "How to spend profits from livestock sales"
la var fm_diff_children_school "Child schooling"
la var fm_diff_seed_choice "What seed variety (e.g. high yielding) to buy"
la var fm_diff_farm_equipment "Whether to buy new farm equipment"
la var fm_diff_farm_training "Whether to attend farm training"
la var fm_diff_information "What type of info/training HH needs"
*Reduced variables (female's report of beans to self)
la var f_f_farm "Farm Index - Female Reports"
la var f_f_livestock "Livestock Index - Female Reports"
la var f_f_farmeduc "Information and Training Index - Female Reports"

*Labels
label val religion religion






***********
* Table 1 *
***********
*Summary Statistics by Country
global stat_country "polygamous asset acres acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4"
*Summary statistics by marital status
global stat_marital "acres asset acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4"

sum polygamous asset acres acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4 if country==1
sum polygamous asset acres acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4 if country==2







***********
* Table 2 *
***********
sum m_age m_educ m_health m_f_overall_farm-m_f_overall_hh if country==1
sum f_age f_educ f_health f_f_overall_farm-f_f_overall_hh if country==1

sum m_age m_educ m_health m_f_overall_farm-m_f_overall_hh if country==2
sum f_age f_educ f_health f_f_overall_farm-f_f_overall_hh if country==2






***********
* Table 3 *
***********
*Find clusters and then create indices
fac $f_f, fa(3)







***********
* Table 4 *
***********
sum f_f_crops_choice f_f_crops_sale f_f_crops_spendprofits f_f_seed_choice f_f_farm_equipment f_f_overall_farm f_f_farm f_f_livestock_sale f_f_livestock_spendprofits f_f_livestock f_f_farm_training f_f_information f_f_farmeduc







***********
* Table 5 *
***********
areg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum f_f_farm if e(sample) & polygamous
sum f_f_farm if e(sample) & !polygamous
areg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum f_f_livestock if e(sample) & polygamous
sum f_f_livestock if e(sample) & !polygamous
areg f_f_farmeduc polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum f_f_farmeduc if e(sample) & polygamous
sum f_f_farmeduc if e(sample) & !polygamous

areg m_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum m_f_farm if e(sample) & polygamous
sum m_f_farm if e(sample) & !polygamous
areg m_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum m_f_livestock if e(sample) & polygamous
sum m_f_livestock if e(sample) & !polygamous
areg m_f_farmeduc polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion, cluster(country_region) absorb(country_region)
sum m_f_farmeduc if e(sample) & polygamous
sum m_f_farmeduc if e(sample) & !polygamous



*Testing for equality (using suest command)
eststo index1: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo index2: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo index3: reg f_f_farmeduc polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region


eststo index11: reg m_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo index12: reg m_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo index13: reg m_f_farmeduc polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region


suest index1 index11, cluster(country_region)
test _b[index1_mean:polygamous]=_b[index11_mean:polygamous]
test _b[index1_mean:f_age]=_b[index11_mean:f_age]			
test _b[index1_mean:f_educ]=_b[index11_mean:f_educ]			
test _b[index1_mean:f_health]=_b[index11_mean:f_health]		
test _b[index1_mean:m_age]=_b[index11_mean:m_age]	
test _b[index1_mean:m_educ]=_b[index11_mean:m_educ]			
test _b[index1_mean:m_health]=_b[index11_mean:m_health]		
test _b[index1_mean:children]=_b[index11_mean:children]
test _b[index1_mean:elderly]=_b[index11_mean:elderly]
test _b[index1_mean:asset]=_b[index11_mean:asset]
test _b[index1_mean:acres]=_b[index11_mean:acres]
test _b[index1_mean:1.religion]=_b[index11_mean:1.religion]
test _b[index1_mean:2.religion]=_b[index11_mean:2.religion]
test _b[index1_mean:5.religion]=_b[index11_mean:5.religion]


suest index2 index12, cluster(country_region)
test _b[index2_mean:polygamous]=_b[index12_mean:polygamous]
test _b[index2_mean:f_age]=_b[index12_mean:f_age]		
test _b[index2_mean:f_educ]=_b[index12_mean:f_educ]		
test _b[index2_mean:f_health]=_b[index12_mean:f_health]	
test _b[index2_mean:m_age]=_b[index12_mean:m_age]		
test _b[index2_mean:m_educ]=_b[index12_mean:m_educ]		
test _b[index2_mean:m_health]=_b[index12_mean:m_health]	
test _b[index2_mean:children]=_b[index12_mean:children]
test _b[index2_mean:elderly]=_b[index12_mean:elderly]
test _b[index2_mean:asset]=_b[index12_mean:asset]
test _b[index2_mean:acres]=_b[index12_mean:acres]
test _b[index2_mean:1.religion]=_b[index12_mean:1.religion]
test _b[index2_mean:2.religion]=_b[index12_mean:2.religion]
test _b[index2_mean:5.religion]=_b[index12_mean:5.religion]


suest index3 index13, cluster(country_region)
test _b[index3_mean:polygamous]=_b[index13_mean:polygamous]		
test _b[index3_mean:f_age]=_b[index13_mean:f_age]		
test _b[index3_mean:f_educ]=_b[index13_mean:f_educ]		
test _b[index3_mean:f_health]=_b[index13_mean:f_health]	
test _b[index3_mean:m_age]=_b[index13_mean:m_age]		
test _b[index3_mean:m_educ]=_b[index13_mean:m_educ]		
test _b[index3_mean:m_health]=_b[index13_mean:m_health]	
test _b[index3_mean:children]=_b[index13_mean:children]
test _b[index3_mean:elderly]=_b[index13_mean:elderly]
test _b[index3_mean:asset]=_b[index13_mean:asset]
test _b[index3_mean:acres]=_b[index13_mean:acres]
test _b[index3_mean:1.religion]=_b[index13_mean:1.religion]
test _b[index3_mean:2.religion]=_b[index13_mean:2.religion]
test _b[index3_mean:5.religion]=_b[index13_mean:5.religion]








***********
* Table 6 *
***********
reg f_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg f_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)

reg f_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg f_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)

reg f_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg f_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)


*Testing for equality
eststo wives1_poly: reg f_f_farm c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo wives1_mono: reg f_f_farm c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest wives1_poly wives1_mono, cluster(country_region)
test _b[wives1_poly_mean:f_educ]==_b[wives1_mono_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[wives1_mono_mean:m_educ]
test _b[wives1_poly_mean:f_age]==_b[wives1_mono_mean:f_age]	
test _b[wives1_poly_mean:m_age]==_b[wives1_mono_mean:m_age]	
test _b[wives1_poly_mean:f_health]==_b[wives1_mono_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[wives1_mono_mean:m_health]
test _b[wives1_poly_mean:children]==_b[wives1_mono_mean:children]
test _b[wives1_poly_mean:elderly]==_b[wives1_mono_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[wives1_mono_mean:asset]	
test _b[wives1_poly_mean:acres]==_b[wives1_mono_mean:acres]	
test _b[wives1_poly_mean:1.religion]==_b[wives1_mono_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[wives1_mono_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[wives1_mono_mean:5.religion]
*Same thing but differently:
reg f_f_farm i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)


eststo wives2_poly: reg f_f_livestock c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo wives2_mono: reg f_f_livestock c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest wives2_poly wives2_mono, cluster(country_region)
test _b[wives2_poly_mean:f_educ]==_b[wives2_mono_mean:f_educ]	
test _b[wives2_poly_mean:m_educ]==_b[wives2_mono_mean:m_educ]	
test _b[wives2_poly_mean:f_age]==_b[wives2_mono_mean:f_age]		
test _b[wives2_poly_mean:m_age]==_b[wives2_mono_mean:m_age]		
test _b[wives2_poly_mean:f_health]==_b[wives2_mono_mean:f_health]
test _b[wives2_poly_mean:m_health]==_b[wives2_mono_mean:m_health]
test _b[wives2_poly_mean:children]==_b[wives2_mono_mean:children]
test _b[wives2_poly_mean:elderly]==_b[wives2_mono_mean:elderly]	
test _b[wives2_poly_mean:asset]==_b[wives2_mono_mean:asset]	
test _b[wives2_poly_mean:acres]==_b[wives2_mono_mean:acres]	
test _b[wives2_poly_mean:1.religion]==_b[wives2_mono_mean:1.religion]
test _b[wives2_poly_mean:2.religion]==_b[wives2_mono_mean:2.religion]
test _b[wives2_poly_mean:5.religion]==_b[wives2_mono_mean:5.religion]
reg f_f_livestock i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)


eststo wives3_poly: reg f_f_farmeduc c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo wives3_mono: reg f_f_farmeduc c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest wives3_poly wives3_mono, cluster(country_region)
test _b[wives3_poly_mean:f_educ]==_b[wives3_mono_mean:f_educ]		
test _b[wives3_poly_mean:m_educ]==_b[wives3_mono_mean:m_educ]		
test _b[wives3_poly_mean:f_age]==_b[wives3_mono_mean:f_age]			
test _b[wives3_poly_mean:m_age]==_b[wives3_mono_mean:m_age]			
test _b[wives3_poly_mean:f_health]==_b[wives3_mono_mean:f_health]	
test _b[wives3_poly_mean:m_health]==_b[wives3_mono_mean:m_health]
test _b[wives3_poly_mean:children]==_b[wives3_mono_mean:children]
test _b[wives3_poly_mean:elderly]==_b[wives3_mono_mean:elderly]
test _b[wives3_poly_mean:asset]==_b[wives3_mono_mean:asset]	
test _b[wives3_poly_mean:acres]==_b[wives3_mono_mean:acres]	
test _b[wives3_poly_mean:1.religion]==_b[wives3_mono_mean:1.religion]
test _b[wives3_poly_mean:2.religion]==_b[wives3_mono_mean:2.religion]
test _b[wives3_poly_mean:5.religion]==_b[wives3_mono_mean:5.religion]
reg f_f_farmeduc i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)





***********
* Table 7 *
***********
reg m_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg m_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)

reg m_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg m_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)

reg m_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if polygamous, cluster(country_region) absorb(country_region)
reg m_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion if !polygamous, cluster(country_region) absorb(country_region)


*Testing for equality
eststo husbands1_poly: reg m_f_farm c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo husbands1_mono: reg m_f_farm c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest husbands1_poly husbands1_mono, cluster(country_region)
test _b[husbands1_poly_mean:m_educ]==_b[husbands1_mono_mean:m_educ]		
test _b[husbands1_poly_mean:f_age]==_b[husbands1_mono_mean:f_age]		
test _b[husbands1_poly_mean:m_age]==_b[husbands1_mono_mean:m_age]		
test _b[husbands1_poly_mean:f_health]==_b[husbands1_mono_mean:f_health]	
test _b[husbands1_poly_mean:m_health]==_b[husbands1_mono_mean:m_health]	
test _b[husbands1_poly_mean:children]==_b[husbands1_mono_mean:children]	
test _b[husbands1_poly_mean:elderly]==_b[husbands1_mono_mean:elderly]	
test _b[husbands1_poly_mean:asset]==_b[husbands1_mono_mean:asset]	
test _b[husbands1_poly_mean:acres]==_b[husbands1_mono_mean:acres]	
test _b[husbands1_poly_mean:1.religion]==_b[husbands1_mono_mean:1.religion]
test _b[husbands1_poly_mean:2.religion]==_b[husbands1_mono_mean:2.religion]
test _b[husbands1_poly_mean:5.religion]==_b[husbands1_mono_mean:5.religion]
reg m_f_farm i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)

eststo husbands2_poly: reg m_f_livestock c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo husbands2_mono: reg m_f_livestock c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest husbands2_poly husbands2_mono, cluster(country_region)
test _b[husbands2_poly_mean:f_educ]==_b[husbands2_mono_mean:f_educ]		
test _b[husbands2_poly_mean:m_educ]==_b[husbands2_mono_mean:m_educ]		
test _b[husbands2_poly_mean:f_age]==_b[husbands2_mono_mean:f_age]		
test _b[husbands2_poly_mean:m_age]==_b[husbands2_mono_mean:m_age]		
test _b[husbands2_poly_mean:f_health]==_b[husbands2_mono_mean:f_health]	
test _b[husbands2_poly_mean:m_health]==_b[husbands2_mono_mean:m_health]	
test _b[husbands2_poly_mean:children]==_b[husbands2_mono_mean:children]
test _b[husbands2_poly_mean:elderly]==_b[husbands2_mono_mean:elderly]
test _b[husbands2_poly_mean:asset]==_b[husbands2_mono_mean:asset]
test _b[husbands2_poly_mean:acres]==_b[husbands2_mono_mean:acres]
test _b[husbands2_poly_mean:1.religion]==_b[husbands2_mono_mean:1.religion]	
test _b[husbands2_poly_mean:2.religion]==_b[husbands2_mono_mean:2.religion]	
test _b[husbands2_poly_mean:5.religion]==_b[husbands2_mono_mean:5.religion]	
reg m_f_livestock i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)

eststo husbands3_poly: reg m_f_farmeduc c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if polygamous
eststo husbands3_mono: reg m_f_farmeduc c.f_educ asset acres children elderly f_age m_age m_educ f_health m_health ib4.religion i.country_region if !polygamous
suest husbands3_poly husbands3_mono, cluster(country_region)
test _b[husbands3_poly_mean:f_educ]==_b[husbands3_mono_mean:f_educ]		
test _b[husbands3_poly_mean:m_educ]==_b[husbands3_mono_mean:m_educ]		
test _b[husbands3_poly_mean:f_age]==_b[husbands3_mono_mean:f_age]		
test _b[husbands3_poly_mean:m_age]==_b[husbands3_mono_mean:m_age]		
test _b[husbands3_poly_mean:f_health]==_b[husbands3_mono_mean:f_health]	
test _b[husbands3_poly_mean:m_health]==_b[husbands3_mono_mean:m_health]	
test _b[husbands3_poly_mean:children]==_b[husbands3_mono_mean:children]	
test _b[husbands3_poly_mean:elderly]==_b[husbands3_mono_mean:elderly]	
test _b[husbands3_poly_mean:asset]==_b[husbands3_mono_mean:asset]	
test _b[husbands3_poly_mean:acres]==_b[husbands3_mono_mean:acres]	
test _b[husbands3_poly_mean:1.religion]==_b[husbands3_mono_mean:1.religion]	
test _b[husbands3_poly_mean:2.religion]==_b[husbands3_mono_mean:2.religion]	
test _b[husbands3_poly_mean:5.religion]==_b[husbands3_mono_mean:5.religion]	
reg m_f_farmeduc i.polygamous##(c.f_educ c.asset c.acres c.children c.elderly c.f_age c.m_age c.m_educ c.f_health c.m_health i.religion i.country_region), cluster(country_region)







***********
* Table 8 *
***********
eststo wives1_poly: reg f_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
eststo husb1_poly: reg m_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]

eststo wives1_poly: reg f_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
eststo husb1_poly: reg m_f_farm f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]


eststo wives1_poly: reg f_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
eststo husb1_poly: reg m_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]

eststo wives1_poly: reg f_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
eststo husb1_poly: reg m_f_livestock f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]



eststo wives1_poly: reg f_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
eststo husb1_poly: reg m_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]

eststo wives1_poly: reg f_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
eststo husb1_poly: reg m_f_farmeduc f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region if !polygamous
suest wives1_poly husb1_poly, cluster(country_region)
test _b[wives1_poly_mean:f_age]==_b[husb1_poly_mean:f_age]
test _b[wives1_poly_mean:m_age]==_b[husb1_poly_mean:m_age]
test _b[wives1_poly_mean:f_educ]==_b[husb1_poly_mean:f_educ]
test _b[wives1_poly_mean:m_educ]==_b[husb1_poly_mean:m_educ]
test _b[wives1_poly_mean:f_health]==_b[husb1_poly_mean:f_health]
test _b[wives1_poly_mean:m_health]==_b[husb1_poly_mean:m_health]
test _b[wives1_poly_mean:children]==_b[husb1_poly_mean:children]
test _b[wives1_poly_mean:elderly]==_b[husb1_poly_mean:elderly]
test _b[wives1_poly_mean:asset]==_b[husb1_poly_mean:asset]
test _b[wives1_poly_mean:acres]==_b[husb1_poly_mean:acres]
test _b[wives1_poly_mean:1.religion]==_b[husb1_poly_mean:1.religion]
test _b[wives1_poly_mean:2.religion]==_b[husb1_poly_mean:2.religion]
test _b[wives1_poly_mean:5.religion]==_b[husb1_poly_mean:5.religion]




*******************
* Appendix Tables *
*******************
*Appendix A - Selection into Polygamy
egen cropgroups = group(crop_*)
bys cropgroups: egen groups_count = count(cropgroups)
replace cropgroups = 0 if groups_count<5


*Adding crops
forvalues i=1(1)37{
	bys district: egen dist_crop_`i' = mean(crop_`i')
}

eststo crop1: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion i.crop_*, cluster(country_region)
eststo crop2: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion i.crop_*, cluster(country_region)
eststo crop3: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion i.crop_*, cluster(country_region)

eststo crop4: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion c.dist_crop_*, cluster(country_region)
eststo crop5: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion c.dist_crop_*, cluster(country_region)
eststo crop6: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres ib4.religion i.country_region ib4.religion c.dist_crop_*, cluster(country_region)



*Checking number of wives based on characteristics
la def more_harv 1 "Harvest: very dissimilar from neighbors" 2 "Harvest: somewhat similar to neighbors" 3 "Harvest: very similar to neighbors"
la val more_harv more_harv
la def more_wealth 1 "Wealth: very dissimilar from neighbors" 2 "Wealth: somewhat similar to neighbors" 3 "Wealth: very similar to neighbors"
la val more_wealth more_wealth
la def more_fert 1 "Fertilizer use: very dissimilar from neighbors" 2 "Fertilizer use: somewhat similar to neighbors" 3 "Fertilizer use: very similar to neighbors"
la val more_fert more_fert
la def more_self_sufficient 1 "Self-sufficiency: very dissimilar from neighbors" 2 "Self-sufficiency: somewhat similar to neighbors" 3 "Self-sufficiency: very similar to neighbors"
la val more_self_sufficient more_self_sufficient

la var high_quality "High quality land (acres)"
la var average_quality "Average quality land (acres)"
la var poor_quality "Poor quality land (acres)"
la var acres_registered "Registered land (acres)"


eststo chars1: areg wives m_age m_educ m_health asset high_quality average_quality poor_quality acres_owned acres_registered i.more_* ib4.religion, cluster(country_region) absorb(country_region)
test 2.more_harvest 3.more_harvest 2.more_wealth 3.more_wealth 2.more_fert 3.more_fert 2.more_self_sufficient 3.more_self_sufficient
estadd scalar f_p_more = r(p): chars1

eststo chars2: areg wives m_age m_educ m_health asset high_quality average_quality poor_quality acres_owned acres_registered i.more_* ib4.religion, cluster(district) absorb(district)
test 2.more_harvest 3.more_harvest 2.more_wealth 3.more_wealth 2.more_fert 3.more_fert 2.more_self_sufficient 3.more_self_sufficient
estadd scalar f_p_more = r(p): chars2

eststo chars3: areg wives m_age m_educ m_health asset high_quality average_quality poor_quality acres_owned acres_registered i.more_* c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)
test 2.more_harvest 3.more_harvest 2.more_wealth 3.more_wealth 2.more_fert 3.more_fert 2.more_self_sufficient 3.more_self_sufficient
estadd scalar f_p_more = r(p): chars3
test 1.country#c.m_outside_option 2.country#c.m_outside_option
estadd scalar f_p_outside = r(p): chars3

eststo chars4: areg wives m_age m_educ m_health asset high_quality average_quality poor_quality acres_owned acres_registered i.more_* c.m_outside#i.country ib4.religion, cluster(district) absorb(district)
test 2.more_harvest 3.more_harvest 2.more_wealth 3.more_wealth 2.more_fert 3.more_fert 2.more_self_sufficient 3.more_self_sufficient
estadd scalar f_p_more = r(p): chars4
test 1.country#c.m_outside_option 2.country#c.m_outside_option
estadd scalar f_p_outside = r(p): chars4




*Adding community ranking variables
eststo robust1: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank ib4.religion, cluster(country_region) absorb(country_region)
eststo robust2: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank ib4.religion, cluster(country_region) absorb(country_region)
eststo robust3: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank ib4.religion, cluster(country_region) absorb(country_region)

*Adding neighbor comparison variables
eststo robust4: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* ib4.religion, cluster(country_region) absorb(country_region)
eststo robust5: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* ib4.religion, cluster(country_region) absorb(country_region)
eststo robust6: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* ib4.religion, cluster(country_region) absorb(country_region)

*Adding their "outside option"
eststo robust7: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)
eststo robust8: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)
eststo robust9: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)


 
*Adding plot quality variables
eststo robust10: reg f_f_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset high_quality average_quality poor_quality acres_owned acres_registered i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)
eststo robust11: reg f_f_livestock polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset high_quality average_quality poor_quality acres_owned acres_registered i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)
eststo robust12: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset high_quality average_quality poor_quality acres_owned acres_registered i.community_rank i.more_* c.f_outside#i.country c.m_outside#i.country ib4.religion, cluster(country_region) absorb(country_region)





************
* Table B1 *
************
sum asset acres acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4 if polygamous
sum asset acres acres_owned any_hiring girls_under10 boys_under10 children elderly religion1 religion2 religion3 religion4 if !polygamous







************
* Table B2 *
************
sum m_age m_educ m_health m_f_overall_farm-m_f_overall_hh if polygamous
sum f_age f_educ f_health f_f_overall_farm-f_f_overall_hh if !polygamous

sum m_age m_educ m_health m_f_overall_farm-m_f_overall_hh if polygamous
sum f_age f_educ f_health f_f_overall_farm-f_f_overall_hh if !polygamous









************
* Table C1 *
************
eststo indiv1: reg f_f_overall_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_overall_farm if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_overall_farm if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv2: reg f_f_livestock_spendprofits polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_livestock if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_livestock if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv3: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_information if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_information if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv4: reg f_f_family_food polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_family_food if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_family_food if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv5: reg f_f_children_school polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_children_school if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_children_school if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv6: reg f_f_overall_hh polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum f_f_overall_hh if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum f_f_overall_hh if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)









************
* Table C2 *
************
eststo indiv11: reg m_f_overall_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_overall_farm if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_overall_farm if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv12: reg m_f_livestock_spendprofits polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_livestock if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_livestock if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv13: reg m_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_information if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_information if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv14: reg m_f_family_food polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_family_food if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_family_food if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv15: reg m_f_children_school polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_children_school if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_children_school if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)

eststo indiv16: reg m_f_overall_hh polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region, cluster(country_region)
sum m_f_overall_hh if e(sample) & polygamous
estadd scalar dv_mean_p = r(mean)
sum m_f_overall_hh if e(sample) & !polygamous
estadd scalar dv_mean_m = r(mean)








*Testing for equality across tables C1 and C2
*Wife Reports
eststo indiv1: reg f_f_overall_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv2: reg f_f_livestock_spendprofits polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv3: reg f_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv4: reg f_f_family_food polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv5: reg f_f_children_school polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv6: reg f_f_overall_hh polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region

*Husband Reports
eststo indiv11: reg m_f_overall_farm polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv12: reg m_f_livestock_spendprofits polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv13: reg m_f_information polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv14: reg m_f_family_food polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv15: reg m_f_children_school polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region
eststo indiv16: reg m_f_overall_hh polygamous f_age m_age f_educ m_educ f_health m_health children elderly asset acres  ib4.religion i.country_region

forvalues i = 1(1)6{
	suest indiv`i' indiv1`i', cluster(country_region) coefl
	test _b[indiv`i'_mean:polygamous]==_b[indiv1`i'_mean:polygamous]
	test _b[indiv`i'_mean:f_age]==_b[indiv1`i'_mean:f_age]
	test _b[indiv`i'_mean:m_age]==_b[indiv1`i'_mean:m_age]
	test _b[indiv`i'_mean:f_educ]==_b[indiv1`i'_mean:f_educ]
	test _b[indiv`i'_mean:m_educ]==_b[indiv1`i'_mean:m_educ]
	test _b[indiv`i'_mean:f_health]==_b[indiv1`i'_mean:f_health]
	test _b[indiv`i'_mean:m_health]==_b[indiv1`i'_mean:m_health]
	test _b[indiv`i'_mean:children]==_b[indiv1`i'_mean:children]
	test _b[indiv`i'_mean:elderly]==_b[indiv1`i'_mean:elderly]
	test _b[indiv`i'_mean:asset]==_b[indiv1`i'_mean:asset]
	test _b[indiv`i'_mean:acres]==_b[indiv1`i'_mean:acres]
	test _b[indiv`i'_mean:1.religion]==_b[indiv1`i'_mean:1.religion]
	test _b[indiv`i'_mean:2.religion]==_b[indiv1`i'_mean:2.religion]
	test _b[indiv`i'_mean:5.religion]==_b[indiv1`i'_mean:5.religion]
}


























