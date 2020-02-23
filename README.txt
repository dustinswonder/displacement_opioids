Replication folder for "Effects of Job Displacement on Prescription Opioid Demand: Evidence from the Medical Expenditure Panel Survey" by Dustin Swonder

Last modified 2/23/2020

Structure:
	1. SETUP
	2. RUNNING THE CODE
	3. NOTES ON DATA 

Please cite this paper if you use data or code from this folder.

-------

1. SETUP

This folder contains all necessary data and code to replicate the exhibits and analysis in my working paper draft as of 2/19/2020. I have run all the analysis code for this paper on Stata MP 15.1. 

Create a folder entitled "replication" in the folder in which you want to run the code. Structure, the folder as follows:
	- replication
		- data
			- full_year_consolidated
			- longitudinal
			- multum_lexicon
			- prescribed_medicines
		- log
		- out
			- appx_figures
			- appx_tables
			- figures
			- tables
		- stata
			- do
			- dta
			- raw
				- full_year_consolidated
				- longitudinal
				- multum_lexicon
				- prescribed_medicines

Download the files in the github folder "stata/do" into the stata/do folder you've set up, and donate the files in the github "data" folder to the data folder you've set up.

-------

2. RUNNING THE CODE

To replicate the analysis, go to the stata subfolder of the replication folder and open the do-file entitled make.do. Change the global macro replication_root to the file location of the replication folder on your machine (for instance, if you downloaded the replication folder to your Downloads folder on a Macintosh computer, it will be sufficient to change replication_root to "~/Downloads/replication"). Then simply run the do-file from start to finish.

As discussed in the paper, the majority of the analysis data I use for the paper is taken from the Medical Expenditure Panel Survey. The do-file entitled "download_raw.do" downloads all the MEPS data necesssary to replicate my analysis and puts it in the appropriate folders. The raw MEPS data is stored in .dat format and needs to be processed using programming statements to be reformatted into usable .dta files. This process takes place in the various do-files in the build subfolder within the stata subfolder of the replication folder.

-------

3. NOTES ON DATA

I use a few auxiliary data sets in addition to the data I download from the MEPS. The raw versions of these data sets are stored in the data subfolder. I describe their provenance below:
	- I downloaded CDC_Oral_Morphine_Milligram_Equivalents_Sept_2018.xlsx from https://www.cdc.gov/drugoverdose/modules/data-files.html in the Data Files box on November 2019. The official name of the document is "CDC compilation of benzodiazepines, muscle relaxants, stimulants, zolpidem, and opioid analgesics with oral morphine milligram equivalent conversion factors, 2018 version."
	- I compiled opd_strengths.xlsx by hand using the IBM Micromedex Redbook, accessed via the Princeton University Library. I last modified the spreadsheet on December 5, 2019.
	- I compiled opioidlist.xlsx by hand from the MEPS Prescribed Medicines files. I last modified the spreadsheet on December 3, 2019.

-------

Feel free to contact me with questions/feedback regarding the data and code. My current institutional e-mail address is dswonder[at]princeton.edu.