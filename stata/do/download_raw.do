/*******************************************************************************
Project:		Displacement and Opioids -- Swonder
Last modified: 	01/20/2020
Modified by:	Dustin Swonder
Description:	This file downloads raw datafiles from the MEPS website.
*******************************************************************************/

/*******************************************************************************
	(1) Raw longitudinal data files (extension .dat)
*******************************************************************************/

cd $datadir/longitudinal

foreach filenum in 23 35 48 58 65 71 80 86 98 106 114 122 130 139 148 156 164 ///
	172 183 193 202 {

	copy https://www.meps.ahrq.gov/mepsweb/data_files/pufs/h`filenum'dat.zip ///
		h`filenum'dat.zip, replace

	unzipfile h`filenum'dat.zip, replace
	rm h`filenum'dat.zip
}

/*******************************************************************************
	(2) Raw Prescribed Medicines data files (extension .dat)
*******************************************************************************/

cd $datadir/prescribed_medicines

foreach filenum in 10 16 26 33 51 59 67 77 85 94 102 110 118 126 135 144 152 160 ///
	168 178 188 197 {

	copy https://www.meps.ahrq.gov/mepsweb/data_files/pufs/h`filenum'adat.zip ///
		h`filenum'adat.zip, replace

	unzipfile h`filenum'adat.zip, replace
	rm h`filenum'adat.zip
}

/*******************************************************************************
	(3) Raw Multum Lexicon data files (extension .dat)
*******************************************************************************/

cd $datadir/multum_lexicon

forv filenum = 1/18 {
	copy https://www.meps.ahrq.gov/mepsweb/data_files/pufs/h68f`filenum'dat.zip ///
		h68f`filenum'dat.zip

	unzipfile h68f`filenum'dat.zip, replace
	rm h68f`filenum'dat.zip
}

/*******************************************************************************
	(4) Raw Full Year Consolidated data files (extension .dat) through 2004
*******************************************************************************/

cd $datadir/full_year_consolidated

foreach filenum in 12 20 28 38 50 60 70 79 89 {
	copy https://www.meps.ahrq.gov/mepsweb/data_files/pufs/h`filenum'dat.zip ///
		h`filenum'dat.zip, replace

	unzipfile h`filenum'dat.zip, replace
	rm h`filenum'dat.zip
}