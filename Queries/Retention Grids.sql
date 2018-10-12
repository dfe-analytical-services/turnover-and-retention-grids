set nocount on

USE SWFC_Project

GO

-- Retention grid calculations

-- This code replicates Table 8 of the School Workforce Census publication, which looks at new NQTs in each year and what percentage are still
-- in service in each of the following SWC years.

-- This code breaks those NQTs down by demographics of the teachers, their qualifications and the types of school they are in.

-- The first table gives a record for every NQT and the year they qualified.


BEGIN TRY drop table #NQTs END TRY 
begin catch end catch

SELECT
	DISTINCT
	NQT_Year,
	TRN,
	StaffMatchingReference
INTO 
	#NQTs
FROM
	(
	SELECT
		a.CensusYear as NQT_Year,
		d.TRN,
		a.StaffMatchingReference
	FROM
		SWFC.vw_AggregatedView a
	LEFT JOIN
		SWFC.AllWorkforce d
		on a.StaffMatchingReference = d.StaffMatchingReference
	LEFT JOIN 
		ExternalData.QualifiedEntrants b
		ON a.StaffMatchingReference = b.StaffMatchingReference
		and a.CensusYear = b.CensusYear
	LEFT JOIN
		( 
		SELECT 
			StaffMatchingReference,
			CensusYear,
			QualificationYear,
			YearOfArrivalInSchool,
			Origin
		FROM
			ExternalData.Turnover
		WHERE 
			inSWFC is not null
			and QTStatus = 1
			and CensusYear = 2010
		) c
		ON a.StaffMatchingReference = c.StaffMatchingReference
		and a.CensusYear = c.CensusYear
	WHERE
		QualifiedEntrantType = 'NQT'
		OR c.[QualificationYear] = 2009 
		OR (c.YearOfArrivalInSchool = 2009 
		and c.Origin = 'First employment in teaching - immediately after training')
	) nest
ORDER BY
	NQT_Year


-- The second table gives one record for every subject a teacher is qualified in, along with the year they first received a qualification for this subject.

BEGIN TRY drop table #allQuals END TRY 
begin catch end catch

SELECT
	StaffMatchingReference,
	QualificationYear,
	SubjectDescription_TSM
INTO 
	#allQuals	 
FROM 
(
	SELECT 
		*, 
		row_number () over (partition by StaffMatchingReference, SubjectDescription_TSM order by StaffMatchingReference, SubjectDescription_TSM, QualificationYear) rn  
	FROM
		(
		SELECT 
			DISTINCT
			StaffMatchingReference,
			QualificationYear,
			SubjectDescription_TSM
		FROM 
			SWFC.Qualification q
		LEFT JOIN 
			SWFC.QualificationSubject qs 
			on q.QualificationTableID = qs.QualificationTableID
		LEFT JOIN 
			Lookups.SubjectMappings_Qualifications qsm
			on qs.QualificationCode = qsm.QualificationCode 
		LEFT JOIN 
			Lookups.QualificationSpecialism qps
			on qps.QualificationCode = qsm.QualificationCode
		LEFT JOIN 
			Lookups.SubjectMappings_Curriculum smc
			on qps.GeneralSubjectCode = smc.GeneralSubjectCode
		WHERE 
			SubjectDescription_TSM NOT IN ('N/A', 'Others')
		) z
	) zz
WHERE 
	rn = 1
ORDER BY
	StaffMatchingReference,
	QualificationYear,
	SubjectDescription_TSM

-----------------------------------------------------------------------------------------------------------------------------------------

-- The next tables work out whether an NQT is deemed a specialist in a subject at the time they qualified as a teacher.
-- Temporary tables are set up for each subject as a teacher can be a specialist in multiple subjects.

BEGIN TRY drop table #English END TRY 
begin catch end catch

SELECT
	DISTINCT 
	'English' as SubjectCohort, 
	nqt.*
INTO 
	#English 
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'English' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Mathematics END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Mathematics' as SubjectCohort,
	nqt.*
INTO
	#Mathematics
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Mathematics' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Biology END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Biology' as SubjectCohort,
	nqt.*
INTO
	#Biology
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM IN ('Biology', 'Science') 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Chemistry END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Chemistry' as SubjectCohort,
	nqt.*
INTO
	#Chemistry
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM IN ('Chemistry', 'Science') 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Physics END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Physics' as SubjectCohort,
	nqt.*
INTO
	#Physics
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM IN ('Physics', 'Science') 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Geography END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Geography' as SubjectCohort,
	nqt.*
INTO
	#Geography
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM IN ('Geography', 'Humanities') 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #History END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'History' as SubjectCohort,
	nqt.*
INTO
	#History
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM IN ('History', 'Humanities') 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #MFL END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Modern Foreign Languages' as SubjectCohort,
	nqt.*
INTO
	#MFL
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Modern Foreign Languages' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Computing END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Computing' as SubjectCohort,
	nqt.*
INTO
	#Computing
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Computing' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Business_Studies END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Business Studies' as SubjectCohort,
	nqt.*
INTO
	#Business_Studies
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Business Studies' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Classics END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Classics' as SubjectCohort,
	nqt.*
INTO
	#Classics
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Classics' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #DT END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Design & Technology' as SubjectCohort,
	nqt.*
INTO
	#DT
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Design & Technology' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Art END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Art & Design' as SubjectCohort,
	nqt.*
INTO
	#Art
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Art & Design' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Drama END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Drama' as SubjectCohort,
	nqt.*
INTO
	#Drama
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Drama' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Food END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Food' as SubjectCohort,
	nqt.*
INTO
	#Food
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Food' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #Music END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Music' as SubjectCohort,
	nqt.*
INTO
	#Music
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Music' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #PE END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Physical Education' as SubjectCohort,
	nqt.*
INTO
	#PE
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Physical Education' 
	AND QualificationYear <= NQT_Year

BEGIN TRY drop table #RE END TRY 
begin catch end catch

SELECT 
	DISTINCT
	'Religious Education' as SubjectCohort,
	nqt.*
INTO
	#RE
FROM 
	#NQTs nqt 
LEFT JOIN 
	#allQuals qu
	on nqt.StaffMatchingReference = qu.StaffMatchingReference
WHERE 
	SubjectDescription_TSM = 'Religious Education' 
	AND QualificationYear <= NQT_Year

------------------------------------------------------------------------------------------------------------------------------------------------------

-- The next table links the data on NQTs with their demographics and the school level details of the school they were employed as an NQT. 

BEGIN TRY drop table #NQT_Demographics END TRY 
begin catch end catch

SELECT
	DISTINCT
	NQT_Year,
	TRN,
	StaffMatchingReference,
	AgeGroup,
	Gender,
	Ethnicity,
	Phase,
	LA_or_Academy,
	Region,
	FT_PT,
	PercentagePermanent,
	ScaledHeadCount
INTO 
	#NQT_Demographics
FROM
	(
	SELECT
		a.CensusYear as NQT_Year,
		d.TRN,
		a.StaffMatchingReference,
		CASE 
			WHEN e.Age <30 THEN 'Under 30'
			WHEN e.Age >=30 THEN '30+'
			ELSE NULL
		END as AgeGroup,
		CASE 
			WHEN Gender NOT IN ('Male', 'Female') THEN NULL
			ELSE Gender
		END as Gender,
		CASE
			WHEN Ethnicity_GG_description = 'White' THEN 'White'
			WHEN Ethnicity_GG_description IN ('Any Other Ethnic Group', 'Asian or Asian British', 
			'Black or Black British', 'Chinese ', 'Mixed / Dual Background') THEN 'BAME'
			WHEN Ethnicity_GG_description IN ('Information Not Yet Obtained', 'Refused ') THEN NULL
			ELSE NULL
		END as Ethnicity,
		CASE 
			WHEN SchoolPhase_Grouped NOT IN ('Primary',  'Secondary', 'Special') THEN NULL 
			ELSE SchoolPhase_Grouped
		END as Phase,
		SchoolType_Grouped as LA_or_Academy,
		Region,
		FT_PT,
		CASE 
			WHEN PercentagePermanent < 90 THEN 'Under 90% permanent staff'
			WHEN PercentagePermanent >= 90 THEN 'At least 90% permanent staff' 
		    ELSE NULL
		END as PercentagePermanent,
		ScaledHeadcount
	FROM
		SWFC.vw_AggregatedView a
	LEFT JOIN
		SWFC.AllWorkforce d
		on a.StaffMatchingReference = d.StaffMatchingReference
	LEFT JOIN
		SWFC.Workforce e
		on a.StaffMatchingReference = e.StaffMatchingReference
		AND a.CensusYear = e.CensusYear
	LEFT JOIN
		Lookups.Ethnicity f
		on e.Ethnicity = f.Ethnicity_code
	LEFT JOIN
		SWFC.School g
		on a.LAEstab = g.LAEstab
		AND a.CensusYear = g.CensusYear
	LEFT JOIN
		Lookups.LAs h
		on g.LA_Code = h.LA_Code
	LEFT JOIN
		(
		SELECT
			CensusYear, 
			LAEstab, 
			ROUND((SUM(CASE WHEN ContractAgreementType = 'Permanent' then 1 else 0 end)/
			CAST (COUNT(*) as float)*100),1) as PercentagePermanent
		FROM
			SWFC.vw_AggregatedView av
		GROUP BY
			CensusYear, 
			LAEstab
		) pc
		on a.CensusYear = pc.CensusYear
		AND g.LAEstab = pc.LAEstab
	LEFT JOIN 
		ExternalData.QualifiedEntrants b
		ON a.StaffMatchingReference = b.StaffMatchingReference
		and a.CensusYear = b.CensusYear
	LEFT JOIN
		( 
		SELECT 
			StaffMatchingReference,
			CensusYear,
			QualificationYear,
			YearOfArrivalInSchool,
			Origin
		FROM
			ExternalData.Turnover
		WHERE 
			inSWFC is not null
			and QTStatus = 1
			and CensusYear = 2010
		) c
		ON a.StaffMatchingReference = c.StaffMatchingReference
		and a.CensusYear = c.CensusYear
	WHERE
		QualifiedEntrantType = 'NQT'
		OR c.[QualificationYear] = 2009 
		OR (c.YearOfArrivalInSchool = 2009 
		and c.Origin = 'First employment in teaching - immediately after training')
	) nest
ORDER BY
	NQT_Year


------------------------------------------------------------------------------------------------------------------------------------------------------------

-- The next table adds in the qualifications data to see if each NQT is a specialist in each subject.

BEGIN TRY drop table #allNQTs END TRY 
begin catch end catch


SELECT 
	nqt.*,
	PG_or_UG,
	Provider_Name,
    Provider_Type,
	IIF(mat.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Mathematics') as Maths_Cohort,
	IIF(eng.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'English') as English_Cohort,
	IIF(bio.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Biology') as Biology_Cohort,
	IIF(che.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Chemistry') as Chemistry_Cohort,
	IIF(phy.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Physics') as Physics_Cohort,
	IIF(com.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Computing') as Computing_Cohort,
	IIF(mfl.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Modern Foreign Languages') as MFL_Cohort,
	IIF(geo.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Geography') as Geography_Cohort,
	IIF(his.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'History') as History_Cohort,
	IIF(cla.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Classics') as Classics_Cohort,
	IIF(bs.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Business Studies') as BusinessStudies_Cohort,
	IIF(re.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Religious Education') as RE_Cohort,
	IIF(pe.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Physical Education') as PE_Cohort,
	IIF(art.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Art & Design') as Art_Cohort,
	IIF(dra.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Drama') as Drama_Cohort,
	IIF(mus.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Music') as Music_Cohort,
	IIF(dt.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Design & Technology') as DT_Cohort,
	IIF(foo.StaffMatchingReference IS NULL OR nqt.Phase <> 'Secondary', NULL, 'Food') as Food_Cohort
INTO
	#allNQTs
FROM 
	#NQT_Demographics nqt
LEFT JOIN 
	#Mathematics mat
	on nqt.StaffMatchingReference = mat.StaffMatchingReference
	AND nqt.NQT_Year = mat.NQT_Year
LEFT JOIN 
	#English eng
	on nqt.StaffMatchingReference = eng.StaffMatchingReference
	AND nqt.NQT_Year = eng.NQT_Year
LEFT JOIN 
	#Biology bio
	on nqt.StaffMatchingReference = bio.StaffMatchingReference
	AND nqt.NQT_Year = bio.NQT_Year
LEFT JOIN 
	#Chemistry che
	on nqt.StaffMatchingReference = che.StaffMatchingReference
	AND nqt.NQT_Year = che.NQT_Year
LEFT JOIN 
	#Physics phy
	on nqt.StaffMatchingReference = phy.StaffMatchingReference
	AND nqt.NQT_Year = phy.NQT_Year
LEFT JOIN 
	#Computing com
	on nqt.StaffMatchingReference = com.StaffMatchingReference
	AND nqt.NQT_Year = com.NQT_Year
LEFT JOIN 
	#MFL mfl
	on nqt.StaffMatchingReference = mfl.StaffMatchingReference
	AND nqt.NQT_Year = mfl.NQT_Year
LEFT JOIN 
	#Geography geo
	on nqt.StaffMatchingReference = geo.StaffMatchingReference
	AND nqt.NQT_Year = geo.NQT_Year
LEFT JOIN 
	#History his
	on nqt.StaffMatchingReference = his.StaffMatchingReference
	AND nqt.NQT_Year = his.NQT_Year
LEFT JOIN 
	#Business_Studies bs
	on nqt.StaffMatchingReference = bs.StaffMatchingReference
	AND nqt.NQT_Year = bs.NQT_Year
LEFT JOIN 
	#RE re
	on nqt.StaffMatchingReference = re.StaffMatchingReference
	AND nqt.NQT_Year = re.NQT_Year
LEFT JOIN 
	#PE pe
	on nqt.StaffMatchingReference = pe.StaffMatchingReference
	AND nqt.NQT_Year = pe.NQT_Year
LEFT JOIN 
	#Classics cla
	on nqt.StaffMatchingReference = cla.StaffMatchingReference
	AND nqt.NQT_Year = cla.NQT_Year
LEFT JOIN 
	#Art art
	on nqt.StaffMatchingReference = art.StaffMatchingReference
	AND nqt.NQT_Year = art.NQT_Year
LEFT JOIN 
	#Drama dra
	on nqt.StaffMatchingReference = dra.StaffMatchingReference
	AND nqt.NQT_Year = dra.NQT_Year
LEFT JOIN 
	#Music mus
	on nqt.StaffMatchingReference = mus.StaffMatchingReference
	AND nqt.NQT_Year = mus.NQT_Year
LEFT JOIN 
	#DT dt
	on nqt.StaffMatchingReference = dt.StaffMatchingReference
	AND nqt.NQT_Year = dt.NQT_Year
LEFT JOIN 
	#Food foo
	on nqt.StaffMatchingReference = foo.StaffMatchingReference
	AND nqt.NQT_Year = foo.NQT_Year
LEFT JOIN
	[TAD_PerformanceProfiles].[Output].[PP_FinalYear_AwardedQTS] pp
	on nqt.TRN = pp.TRN
	AND nqt.NQT_Year = RIGHT(PP_Year,4)-1
WHERE
	Duplicate_Flag_1 = 0 OR Duplicate_Flag_1 IS NULL 

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- This table just adds an additional record for every census year after an NQT is recorded in service, it is used for the next table.

BEGIN TRY drop table #allInstances END TRY 
begin catch end catch

SELECT 
    b.NQT_Year as YearChecked,
	a.*
INTO
	#allInstances
FROM
	#allNQTs a
LEFT JOIN
	(
	SELECT 
		DISTINCT 
		NQT_Year
	FROM 
		#allNQTs
	) b
	ON a.NQT_Year <= b.NQT_Year

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- This table checks whether a teacher was in service in each year following their NQT year.

BEGIN TRY drop table #InServiceHistory END TRY 
begin catch end catch

SELECT
    IIF(CensusYear is null, 0, 1) as InService, 
	a.*
INTO 
    #InServiceHistory
FROM
	#allInstances a
LEFT JOIN
	( 
	SELECT 
		a.StaffMatchingReference,
		CensusYear
	FROM 
		#allNQTs a
	INNER JOIN
		(
		SELECT 
			StaffMatchingReference,
			CensusYear 
		FROM 
			SWFC.vw_AggregatedView
		) TrackedYear
		ON a.NQT_Year <= TrackedYear.CensusYear
		and a.StaffMatchingReference = TrackedYear.StaffMatchingReference
	WHERE
		a.NQT_Year >= 2010
	) nest
	ON a.StaffMatchingReference = nest.StaffMatchingReference
	and a.YearChecked = nest.CensusYear

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- This table is used to removes record that are deemed to be unreliable. 
-- This is schools who have returned a difference of more than 20% in staff or didn't return any data in a SWC year.
-- This is because we wouldn't want to assume an NQT left because a school they were in didn't return data correctly.
-- This is in line with the methodology used in the School Workforce Census Publication.

BEGIN TRY drop table #toBeRemovedFromTheCohort END TRY 
begin catch end catch

SELECT
	av.CensusYear + 1 as InServiceYearToBeRemovedFrom,
	TRN,
	av.StaffMatchingReference
INTO 
	#toBeRemovedFromTheCohort
FROM
	SWFC.vw_AggregatedView av
LEFT JOIN
	SWFC.AllWorkforce d
	on av.StaffMatchingReference = d.StaffMatchingReference
LEFT JOIN                             
	SWFC.vw_SchoolLevelStocks w1                                              
	ON av.LAestab = w1.LAestab
	and av.CensusYear = w1.CensusYear                                                                                         
LEFT JOIN                           
	SWFC.vw_SchoolLevelStocks w2                                              
	ON av.LAestab = w2.LAestab 
	and av.CensusYear+1 = w2.CensusYear       
WHERE 
	CASE 
	WHEN 
	CASE                                            
		WHEN av.laestab is null and w2.AllTeachersHC = 0 THEN 'No return in year 2'                                  
		WHEN av.laestab is null and abs((cast(w2.AllTeachersHC as float)-cast(w1.AllTeachersHC as float))/cast(w1.AllTeachersHC as float)) >= 0.20 THEN '>=20%'                                  
		WHEN av.laestab is null and abs((cast(w2.AllTeachersHC as float)-cast(w1.AllTeachersHC as float))/cast(w1.AllTeachersHC as float)) < 0.20 THEN '<20%'                                     
		WHEN w2.AllTeachersHC is null THEN 'School closed'                                     
		WHEN w2.AllTeachersHC = 0 THEN 'No return in year 2'                                   
		WHEN abs((cast(w2.AllTeachersHC as float)-cast(w1.AllTeachersHC as float))/cast(w1.AllTeachersHC as float)) >= 0.20 THEN '>=20%'                                 
		WHEN abs((cast(w2.AllTeachersHC as float)-cast(w1.AllTeachersHC as float))/cast(w1.AllTeachersHC as float)) < 0.20 THEN '<20%'                                     
		END  in ('<20%', 'School closed', 'Centrally Employed teachers')  THEN 1
		ELSE 0
	END= 0
	and av.CensusYear <> 2017

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- This table brings together the service history table with the filters for unreliable data.

BEGIN TRY drop table #CreateFilter END TRY 
begin catch end catch

SELECT 
	a.*,
	CASE 
		WHEN NQT_Year = YearChecked and NQT_Year = 2010 THEN 1
		WHEN NQT_Year = YearChecked and NQT_Year > 2010 and b.StaffMatchingReference is null THEN 1
		WHEN NQT_Year = YearChecked and NQT_Year > 2010 and b.StaffMatchingReference is not null THEN 0
		WHEN NQT_Year >= 2010 and YearChecked >= 2011 and b.StaffMatchingReference is null THEN 1
		WHEN NQT_Year >= 2010 and YearChecked >= 2011 and b.StaffMatchingReference is not null THEN 0
	END as Filter
INTO 
	#CreateFilter
FROM 
	#InServiceHistory a 
LEFT JOIN
	#toBeRemovedFromTheCohort b
	ON a.StaffMatchingReference = b.StaffMatchingReference
	and a.YearChecked = b.InServiceYearToBeRemovedFrom

-------------------------------------------------------------------------------------------------------------------------------------------------------

-- This is the final table used for the retention grids, that calculates the number of NQTs from each year that were still in service for each of the 
-- demographic groups.
-- Scaled Headcount has been used here to give national totals that are more representative, given the filter that has been applied.


SELECT 
	NQT_Year,
	YearChecked - NQT_Year as YearsFrom,
	InService,
	FT_PT,
	Phase,
	LA_or_Academy,
	Region as RegionOfSchool,
	PercentagePermanent,
	IIF(PG_or_UG = 12, 'Postgraduate Trainee',
		IIF(PG_or_UG = 20, 'Undergraduate Trainee',NULL))
	as PG_or_UG,
    Provider_Type,
	Maths_Cohort,
	English_Cohort,
	Biology_Cohort,
	Chemistry_Cohort,
	Physics_Cohort,
	Computing_Cohort,
	MFL_Cohort,
	Geography_Cohort,
	History_Cohort,
	Classics_Cohort,
	BusinessStudies_Cohort,
	RE_Cohort,
	PE_Cohort,
	Art_Cohort,
	Drama_Cohort,
	Music_Cohort,
	DT_Cohort,
	Food_Cohort,
	IIF(NQT_Year=2010,COUNT(*),SUM(ScaledHeadCount)) as Headcount
FROM 
	#CreateFilter 
GROUP BY 
	NQT_Year,
	YearChecked - NQT_Year,
	InService,
	FT_PT,
	Phase,
	LA_or_Academy,
	Region,
	PercentagePermanent,
	PG_or_UG,
    Provider_Type,
	Maths_Cohort,
	English_Cohort,
	Biology_Cohort,
	Chemistry_Cohort,
	Physics_Cohort,
	Computing_Cohort,
	MFL_Cohort,
	Geography_Cohort,
	History_Cohort,
	Classics_Cohort,
	BusinessStudies_Cohort,
	RE_Cohort,
	PE_Cohort,
	Art_Cohort,
	Drama_Cohort,
	Music_Cohort,
	DT_Cohort,
	Food_Cohort



