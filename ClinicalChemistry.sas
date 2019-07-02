
/*Read in the cleaned csv file of clinical chemistry data.*/
OPTIONS MISSING='';
PROC IMPORT DATAFILE= '/folders/myfolders/SASData/CLINICAL_CHEMISTRY_NCT.csv' 
OUT=WORK.CLINICAL_CHEMISTRY
DBMS=TAB REPLACE;
GETNAMES=YES;
GUESSINGROWS=MAX;
RUN;

/*Remove the quotes for the accession number values */
DATA WORK.CLINICAL_CHEMISTRY;
	SET WORK.CLINICAL_CHEMISTRY;
    ACCESSION_NUMBER = COMPRESS(ACCESSION_NUMBER, """");
RUN;

/*Also read in the keys dictionary for the different assays.*/
PROC IMPORT DATAFILE= '/folders/myfolders/SASData/keys.csv'
OUT=WORK.KEYS
DBMS=TAB REPLACE;
GETNAMES=YES;
GUESSINGROWS=MAX;
RUN;

/*Focus only on the data involving acetaminophen*/
PROC SQL;
CREATE TABLE Acetaminophen AS
SELECT * 
FROM 
WORK.CLINICAL_CHEMISTRY
WHERE CHEMICAL_NAME= "Acetaminophen"
;
QUIT;


/*Do a two-way anova comparing albumin levels for 3 different
acetaminophen dosages (150,1500 and 2000 mg/kg) and 3 different
study durations for each study subject (6,24,48 hours).*/
ODS GRAPHICS ON;
PROC ANOVA DATA=WORK.ACETAMINOPHEN PLOTS=all;
CLASS DOSE TIME_IN_STUDY;
MODEL ALB=DOSE TIME_IN_STUDY DOSE*TIME_IN_STUDY;
MEANS DOSE TIME_IN_STUDY DOSE*TIME_IN_STUDY / TUKEY;
RUN;
ODS GRAPHICS OFF;
