/*
This file defines all paths needed to run the replication code.

Before running the replication files, users should edit the paths below so that
they point to the NFHS/DHS data files and project folders on their own computer.

The raw NFHS/DHS data are not included in this replication package. They must be
downloaded separately from the DHS Program. After downloading the required files,
replace the placeholder paths below with the local paths to those files.

All other do-files call this file to locate the raw data, the final analytic
dataset, and the folders where tables and figures are saved.
*/

// global nfhs3hr  "INSERT PATH TO NFHS-3 HOUSEHOLD RECODE FILE: IAHR52FL.DTA"
// global nfhs3hmr "INSERT PATH TO NFHS-3 HOUSEHOLD MEMBER RECODE FILE: IAPR52FL.DTA"
// global nfhs3ir  "INSERT PATH TO NFHS-3 INDIVIDUAL RECODE FILE: IAIR52FL.DTA"
//
// global nfhs4hr  "INSERT PATH TO NFHS-4 HOUSEHOLD RECODE FILE: IAHR74FL.DTA"
// global nfhs4hmr "INSERT PATH TO NFHS-4 HOUSEHOLD MEMBER RECODE FILE: IAPR74FL.DTA"
// global nfhs4ir  "INSERT PATH TO NFHS-4 INDIVIDUAL RECODE FILE: IAIR74FL.DTA"	
//
// global nfhs5ir  "INSERT PATH TO NFHS-5 INDIVIDUAL RECODE FILE: IAIR7EFL.DTA"
// global nfhs5hr  "INSERT PATH TO NFHS-5 HOUSEHOLD RECODE FILE: IAHR7EFL.DTA"
// global nfhs5hmr "INSERT PATH TO NFHS-5 HOUSEHOLD MEMBER RECODE FILE: IAPR7EFL.DTA"
// global nfhs5br  "INSERT PATH TO NFHS-5 BIRTH RECODE FILE: IABR7EFL.DTA"
// global nfhs3mr "INSERT PATH TO NFHS-3 MEN'S RECODE FILE: IAMR52FL.DTA"
// global nfhs4mr "INSERT PATH TO NFHS-4 MEN'S RECODE FILE: IAMR74FL.DTA"
// global nfhs5mr "INSERT PATH TO NFHS-5 MEN'S RECODE FILE: IAMR7EFL.DTA"
//
// global all_nfhs_ir "INSERT PATH WHERE THE COMBINED NFHS INDIVIDUAL RECODE DATASET SHOULD BE SAVED: all_nfhs_ir.dta"
//
// global paths "INSERT PATH TO THIS FILE: 00_paths.do"
//
// cd "INSERT PATH TO PROJECT ROOT FOLDER"


* We can delete the rest of this before submitting.

if "`c(username)'" == "dc42724" {

	global nfhs3hr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\all india household recode\IAHR52FL.dta"
	global nfhs3hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\hhmr\IAPR52FL.dta"
	global nfhs3ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\ir\IAIR52FL.dta"
	
	global nfhs4hr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\hr\IAHR71FL.DTA"
	global nfhs4hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\hhmr\IAPR71FL.DTA"
	global nfhs4ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\ir\IAIR74FL.DTA"	
	
	global nfhs5ir "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAIR7DDT\IAIR7DFL.DTA"
	global nfhs5hr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAHR7DDT\IAHR7DFL.DTA"
	global nfhs5hmr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAPR7DDT\IAPR7DFL.DTA"
	global nfhs5br "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IABR7EDT\IABR7EFL.DTA"
	
	global nfhs5mr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS19\IAMR7DDT\IAMR7DFL.DTA"
	global nfhs4mr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS15\all india male recode\IAMR74FL.DTA"
	global nfhs3mr "C:\Users\dc42724\Dropbox\Data\NFHS\NFHS06\all india male recode\IAMR52FL.dta"
	
	global all_nfhs_ir "C:\Users\dc42724\Dropbox\Data\combined nfhs for hh structure paper.dta"
	
	global paths "C:\Users\dc42724\Documents\GitHub\health-household-structure\code\00_paths.do"
	
	cd "C:\Users\dc42724\Documents\GitHub\health-household-structure"

}
/*

if "`c(username)'" == "sidhpandit" {
	
	global nfhs1hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs1hmr/IAPR23FL.DTA"
	global nfhs1hr "/Users/sidhpandit/Desktop/data/nfhs/nfhs1hr/IAHR23FL.DTA"
	global nfhs1ir "/Users/sidhpandit/Desktop/data/nfhs/nfhs1ir/IAIR23FL.DTA"
	
	global nfhs2hr "/Users/sidhpandit/Desktop/data/nfhs/nfhs2hr/IAHR42FL.DTA"
	global nfhs2ir "/Users/sidhpandit/Desktop/data/nfhs/nfhs2ir/IAIR42FL.DTA"
	global nfhs2hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs2hmr/IAPR42FL.DTA"
	
	global nfhs3hr "/Users/sidhpandit/Desktop/data/nfhs/nfhs3hr/IAHR52FL.dta"
	global nfhs3hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs3hmr/IAPR52FL.DTA"
	global nfhs3ir "/Users/sidhpandit/Desktop/data/nfhs/nfhs3ir/IAIR52FL.dta"
	
	global nfhs4hr "/Users/sidhpandit/Desktop/data/nfhs/nfhs4hr/IAHR74FL.DTA"
	global nfhs4hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs4hmr/IAPR74FL.DTA"
	global nfhs4ir "/Users/sidhpandit/Desktop/data/nfhs/nfhs4ir/IAIR74FL.DTA"	
	
	global nfhs5ir "/Users/sidhpandit/Desktop/data/nfhs/nfhs5ir/IAIR7EFL.DTA"
	global nfhs5hr "/Users/sidhpandit/Desktop/data/nfhs/nfhs5hr/IAHR7EFL.DTA"
	global nfhs5hmr "/Users/sidhpandit/Desktop/data/nfhs/nfhs5hmr/IAPR7EFL.DTA"
	global nfhs5br "/Users/sidhpandit/Desktop/data/nfhs/nfhs5br/IABR7EFL.DTA"
	
	global nfhs5mr "/Users/sidhpandit/Desktop/data/nfhs/nfhs5mr/IAMR7EFL.DTA"
	global nfhs4mr "/Users/sidhpandit/Desktop/data/nfhs/nfhs4mr/IAMR74FL.DTA"
	global nfhs3mr "/Users/sidhpandit/Desktop/data/nfhs/nfhs3mr/IAMR52FL.dta"
	
	global all_nfhs_ir "/Users/sidhpandit/Desktop/data/nfhs/all_nfhs_ir.dta"
	
	global paths "/Users/sidhpandit/Documents/GitHub/health-household-structure/code/00_paths.do"
	
	cd "/Users/sidhpandit/Documents/GitHub/health-household-structure"
	

if "`c(username)'" == "bipasabanerjee" {
	global nfhs1hmr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS 1/NFHS1_Householdmemberrecode/IAPR23FL.DTA"
	global nfhs1hr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS 1/NFHS1_Householdrecode/IAHR23FL.DTA"
	global nfhs1ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS 1/NFHS1_Individualrecode/IAIR23FL.DTA"
	
	global nfhs2hr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3,Fall2025/Research/NFHS2/NFHS2_Householdrecode/IAHR42FL.DTA"
	global nfhs2ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS2/NFHS2_Individualrecode/IAIR42FL.DTA"
	global nfhs2hmr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3,Fall2025/Research/NFHS2/NFHS2_Householdmemberrecode/IAPR42FL.DTA"
	
	global nfhs3hr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS3/Household/IAHR52FL.dta"
	global nfhs3hmr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS3/Household member recode/IAPR52FL.DTA"
	global nfhs3ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS3/Individual/IAIR52FL.dta"
	
	global nfhs4hr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3,Fall2025/Research/NFHS 4/Household recode/IAHR74FL.DTA"
	global nfhs4hmr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS 4/Household member recode/IAPR74FL.DTA"
	global nfhs4ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS 4/Individual recode/IAIR74FL.DTA"	
	
	global nfhs5ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS-5/Individual/IAIR7EFL.DTA"
	global nfhs5hr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS-5/Household/IAHR7EFL.DTA"
	global nfhs5hmr "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS-5/Household member/IAPR7EFL.DTA"
	global nfhs5br "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/NFHS-5/Birth/IABR7EFL.DTA"
	
	global nfhs5mr "ADD"
	global nfhs4mr "ADD"
	global nfhs3mr "ADD"
	
	global all_nfhs_ir "/Users/bipasabanerjee/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/PHD/Semester3Fall2025/Research/all_nfhs_ir.dta"
	
	cd"/Users/bipasabanerjee/Documents/GitHub/health-household-structure" 
	
}
