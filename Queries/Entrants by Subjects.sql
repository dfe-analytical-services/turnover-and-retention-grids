
SELECT
	CensusYear,
	SubjectDescription_TSM as Subject,
	Gender,
	CASE WHEN AgeGroup IN ('24 and less', '25-29', '30-34') THEN 'Less than 35'
		 WHEN AgeGroup IN ('35-39', '40-44', '45-49', '50-54') THEN '35-54'
		 WHEN AgeGroup IN ('55-59', '60-64', '65 and over') THEN '55 and over'
	END as AgeGroup,
	CASE WHEN QualifiedEntrantType IN ('Deferred NQT', 'New to PFSE') THEN 'New to the state funded sector'
	     ELSE QualifiedEntrantType
	END as QualifiedEntrantType,
	SUM(Stocksize) as StockSize
FROM 
	[TAD_UserSpace].[WorkforceModelling].[TSM_Qualified_Entrants_By_Subject]
GROUP BY
	CensusYear,
	SubjectDescription_TSM,
	Gender,
	CASE WHEN AgeGroup IN ('24 and less', '25-29', '30-34') THEN 'Less than 35'
		 WHEN AgeGroup IN ('35-39', '40-44', '45-49', '50-54') THEN '35-54'
		 WHEN AgeGroup IN ('55-59', '60-64', '65 and over') THEN '55 and over'
	END,
	CASE WHEN QualifiedEntrantType IN ('Deferred NQT', 'New to PFSE') THEN 'New to the state funded sector'
	     ELSE QualifiedEntrantType
	END
