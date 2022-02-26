/* 
Homework 5
Fatima, Karthik, Victoria 
*/

/*CREATING LIBRARY FOR DATASET*/
libname HW5 "~/vriverap_Homework";
ods rtf file="~/vriverap_Homework/Assignment_5.rtf";
title "Assignment 5: Exploring the relationship between cardiovascular risk factors";
/*KEEPING VARIABLES OF INTEREST*/
data outpatient;
	set HW5.nhamcsopd2010;
	keep RACEUN ETHUN AGER SEX REGION HTN 
	HYPLIPID OBESITY BMI CHF MAJOR  
	CLINTYPE HINCOMER AGE BPSYS BPDIAS AGE;
run;

/*RECODING VARIABLES VALUES FOR INTERPRABILITY*/
/*Values came from documentation provided*/
proc format; 
VALUE RACEUN
	1 = "White"
	2 = "Black/African American"
	3 = "Asian"
	4 = "Native Hawaiian/Other Pacific Islander"
	5 = "American Indian/Alaska Native"
	6 = "More than one race reported"
	-9 = "Unknown";
run; 

proc format; 
VALUE ETHUN
	-9= "Uknown"
	1 = "Hispanic or Latino" 
	2 = "Not Hispanic or Latino";
run;

proc format; 
VALUE AGE
	1 = "Under 15 years"
	2 = "15-24 years"
	3 = "25-44 years"
	4 = "45-64 years" 
	5 = "65-74 years" 
	6 = "75 years and over";
run;

proc format;
VALUE SEX
	1 = "Female"
	2 = "Male";
run;

proc format;
VALUE REGION
	1 = "Northeast" 
	2 = "Midwest" 
	3 = "South" 
	4 = "West";
run;

proc format;
VALUE MAJOR
	-9 = "Unknown" 
	1 = "New problem"
	2 = "Chronic problem, routine"
	3 = "Chronic problem, flare up" 
	4 = "Pre-/Post-surgery" 
	5 = "Preventive care";
run;

proc format;
VALUE CLINTYPE
	1 = "General medicine"
	2 = "Surgery" 
	3 = "Pediatric"
	4 = "Obstetrics and Gynecology" 
	5 = "Substance abuse"
	6 = "Other";
run;

proc format;
VALUE HINCOMER
	-9 = "Missing" 
	1 = "Q1 ($32,793 or less)" 
	2 = "Q2 ($32,794-$40,626)"
	3 = "Q3 ($40,627-$52,387)"
	4 = "Q4 ($52,388 or more)";
run;
/*SETTING FORMATED VALUES TO DATASET*/
data outpatient_coded;
set outpatient;
format HINCOMER hincomer. CLINTYPE CLINTYPE. MAJOR MAJOR.
		REGION REGION. SEX SEX. AGER AGE. ETHUN ETHUN. RACEUN RACEUN.;
run;

/*NEW CHF RISK VARIABLE*/
data outpatient_risk; set outpatient_coded; *creating a new dataset containing new varibale;
		
	/*creating new risk variables*/
	if HYPLIPID =1 AND OBESITY =1 AND HTN=1 then chf_risk = 'High Risk';
	else if HTN=1 AND (HYPLIPID =1 OR OBESITY =1) then chf_risk = 'Moderate Risk';
	else chf_risk = 'Low Risk';
run;


/*Background:
The analysis uses the NHAMCS Outpatient Department Patient Records dataset. The dataset included contains patient demographics, general health, 
and the location they sought their visit. We want to explore whether patients that currently have Hyperlipidemia, Obesity, and Hypertension 
are at high risk of Congestive Heart Failure (CHF). Hypertension is common among aging populations and Hyperlipidemia and Obesity are common
in western diets such as the United States. We hypothesize that if there are no signs of any three of these conditions, they are not at risk for CHF.

A new variable 'chf_risk' is created to categorize the dataset into 'High risk', 'Moderate risk', and 'Low risk'
based on the condition that if the patient has Hyperlipidemia, Obesity, Hypertension.*/

/*GENERAL REVIEW OF WHAT DATA LOOKS LIKE*/
PROC CONTENTS data=outpatient_coded;
run;

/*The dataset contains 34718 observations and 16 variables.*/

proc tabulate data=outpatient_coded;
	class region HTN obesity chf;
	table region, obesity HTN chf;
	TITLE "Cardiovascular risk factors by region";
run;

proc tabulate data=outpatient_coded;
	class region HTN obesity chf sex;
	table region *sex, obesity HTN chf;
	TITLE "Cardiovascular risk factors by region and sex";
run;

proc tabulate data=outpatient_coded (where=(region=3));
	class raceun HTN obesity chf;
	table raceun, obesity HTN chf;
	TITLE "Cardiovascular risk factors South region and Race";
run;

*
Cardiovascular risk factors by region show us that majority of patients with obesity, hypertension, and
congestive heart failure is in the South. 
Cardiovascular risk factors by region and sex show us a higher count of obesity and hypertension in all regions is 
higher in women. Also demonstrated, the South has the highest count in both Hypertension and CHF.
Digging deeper into the South region, ethnic groups that identify as White or
Black/African American has the highest count in Hyperlipidemia, Obesity, and Hypertension.;


PROC FREQ DATA=OUTPATIENT_RISK;
	TABLES chf_risk;
	title "Congestive Heart Failure risk frequency";
run;

PROC FREQ DATA=OUTPATIENT_RISK;
	TABLES raceun * chf_risk /nofreq norow nocol;
	title "Congestive Heart Failure risk frequency by Race"; 
run;
*Based on the results from FREQ procedure, the dataset contains 89.18 % patients with low
risk, 9.16% moderate risk and 1.65% patients with high risk.
Among the high risk group, the greatest percentage (1.06%) is made up of those who identify as White.;


proc means data=outpatient_risk (where= (bmi ^= -9 and BMI ^=-7)) n mean; *excluding -9 and -7, they're categorized as missing or not applicable;
class ager chf_risk ;
var chf; 
title "CHF by age group and risk";
run;

/*proc means is used to see the average count of CHF within each age group and their risk level.
As age increases the chance of having CHF is higher. Those who are 75 years and over have a higher chance
of having CHF across all three risk categories.*/

/*GRAPHS*/
PROC SGPLOT DATA= OUTPATIENT_RISK;
	SCATTER X=AGE Y=BMI / 
	GROUP=CHF_RISK;
	TITLE "Age by bmi color coded by risk";
RUN;
*The teal color respresenting high risk individuals tend to cluster in higher age groups and higher BMI.;


PROC SGPLOT DATA=outpatient_risk (where=(chf=1));
VBAR region / GROUP = sex stat=sum datalabel; 
LABEL region='Regions';
title "CHF count by region and sex";
RUN; 
*CHF is higher in the South region followed by Northeast, Midwest, and West. Within each region CHF appears 
to be equally distributed between each sex.;

/*tests*/
*Null hypothesis:
There is no difference in mean values of congestive heart failure 
between the groups with obesity and no obesity.

*Alternate hypothesis:
There is a difference in mean values of congestive heart failure value
between the groups with obesity and no obesity;

proc ttest data=outpatient_risk;
	var obesity;
	class chf;
	title "ttest between CHF and obesity";
run;


/*Based on the ttest results, we can see that the t-value is greater than
1.96(95% Confidence Interval) and significant meaning there is a difference
in the mean values of CHF between the groups with obesity and no obesity. 

Hence, we reject the null hypothesis that there is no difference. Patients
with obesity have higher instances of CHF compared to those that are not obese.*/


/*Correlation*/
proc corr data=outpatient_risk;
var age bmi obesity;
title "correlations between age, BMI, and obesity";
run;
*BMI and obesity have a correlation value of 0.25479. The correlation between other variables was lower.; 


/*simple linear regression: regressing hypertension against age*/
proc reg data=outpatient_risk;
	model AGE =  HTN; 
	title "simple linear regression: regressing hypertension against age";
run;

quit;


/*multiple linear regression: regressing diastolic blood pressure, hyperlipidemia, and obesity against BMI*/
proc reg data=outpatient_risk;
	model BMI = HYPLIPID OBESITY AGE; 
	title "multiple linear regression of age, hyperlipidemia, and obesity against BMI";
run;

quit;

ods rtf close;




