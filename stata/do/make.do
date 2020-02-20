/*******************************************************************************
Project: 		Effects of Job Displacement on Prescription Opiate Use: Evidence 
		 			from the Medical Expenditure Panel Survey -- Swonder
Created by: 	Dustin Swonder
Last modified: 	01/25/2020
Description: 	Master do-file for project.
*******************************************************************************/

capture log close
clear all

/*******************************************************************************
	ENVIRONMENT
*******************************************************************************/

global replication_root "~/Dropbox/Misc/displacement_and_opioids/replication"
global logdir "$replication_root/log"
global datadir "$replication_root/data"
global statadir "$replication_root/stata"
global rawdir "$statadir/raw"
global dodir "$statadir/do"
global dtadir "$statadir/dta"
global tables "$replication_root/out/tables"
global figs "$replication_root/out/figures"
global appxtables "$replication_root/out/appx_tables"
global appxfigures "$replication_root/out/appx_figures"

/*******************************************************************************
	PACKAGES
*******************************************************************************/

ssc install coefplot
ssc install copydesc

/*******************************************************************************
	PROGRAMS
*******************************************************************************/

do "$dodir/programs/het_regtable.do"

/*******************************************************************************
	DOWNLOAD DATA FILES FROM MEPS WEBSITE
*******************************************************************************/

do "$dodir/download_raw.do"

/*******************************************************************************
	BUILD
*******************************************************************************/

do "$dodir/build/merge_longitudinal_files.do"
do "$dodir/build/clean_longitudinal_files.do"
do "$dodir/build/build_prescribed_medicines.do"
do "$dodir/build/build_analysis.do"

/*******************************************************************************
	ANALYSIS
*******************************************************************************/

do "$dodir/tables.do"
do "$dodir/figures.do"

do "$dodir/appx_figures.do"
do "$dodir/appx_tables.do"