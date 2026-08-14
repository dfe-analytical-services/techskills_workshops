/* 
This .sql file query the SQL table catalog_40_copper_analyst_training.steam

This attempts to recreate some common SQL code that would need to be converted from MSSQL to Spark SQL when migrating to databricks 


Common SQL to databricks migration issues to cover:
tamporary tables



*/

/*
select 
2024 as [Year], --- this is the first year for which individual level data is usable - data for 2023 was subject to a high degree of amendments post publication 
[LEA],
[StartDate],
[PersonTableID],
[NamedPlanTableID],
case ---- recodes ethnic groups to the ones used in the publication 
when [ethnicity_minor] = 'African' then 'Black - Black African'
when [ethnicity_minor] = 'AOEG' then 'Any other ethnic group'
when [ethnicity_minor] = 'Bangladeshi' then 'Asian - Bangladeshi'
when [ethnicity_minor] = 'Caribbean' then 'Black - Black Caribbean'
when [ethnicity_minor] = 'Chinese' then 'Asian - Chinese'
when [ethnicity_minor] = 'GypsyRoma' then 'White - Gypsy/Roma'
when [ethnicity_minor] = 'Indian' then 'Asian - Indian'
when [ethnicity_minor] = 'Irish' then 'White - Irish'
when [ethnicity_minor] = 'Irish_Traveller' then 'White - Traveller of Irish heritage'
when [ethnicity_minor] = 'Other_Asian' then 'Asian - Any other Asian background'
when [ethnicity_minor] = 'Other_Black' then 'Black - Any other Black background'
when [ethnicity_minor] = 'Other_Mixed' then 'Mixed - Any other Mixed background'
when [ethnicity_minor] = 'Other_White' then 'White - Any other White background'
when [ethnicity_minor] = 'Pakistani' then 'Asian - Pakistani'
when [ethnicity_minor] = 'UNCL' then 'Unclassified'
when [ethnicity_minor] = 'White_British' then 'White - White British'
when [ethnicity_minor] = 'WhiteAsian' then 'Mixed - White and Asian'
when [ethnicity_minor] = 'WhiteBlackAfrican' then 'Mixed - White and Black African'
when [ethnicity_minor] = 'WhiteBlackCaribbean' then 'Mixed - White and Black Caribbean'
end as [ethnicity_minor],
case --- recodes sex 
when [Sex] in ('Not known') then 'Unknown'
else [Sex]
end as [Sex],
case -- recodes individual age variable - grops those at younger and older sections
when [age_integer] in (0,1,2) then 'under 3'
when [age_integer] in (3) then 'age 3'
when [age_integer] in (4) then 'age 4'
when [age_integer] in (5) then 'age 5'
when [age_integer] in (6) then 'age 6'
when [age_integer] in (7) then 'age 7'
when [age_integer] in (8) then 'age 8'
when [age_integer] in (9) then 'age 9'
when [age_integer] in (10) then 'age 10'
when [age_integer] in (11) then 'age 11'
when [age_integer] in (12) then 'age 12'
when [age_integer] in (13) then 'age 13'
when [age_integer] in (14) then 'age 14'
when [age_integer] in (15) then 'age 15'
when [age_integer] in (16) then 'age 16'
when [age_integer] in (17) then 'age 17'
when [age_integer] in (18) then 'age 18'
when [age_integer] in (19) then 'age 19'
when [age_integer] in (20) then 'age 20'
when [age_integer] in (21) then 'age 21'
when [age_integer] in (22) then 'age 22'
when [age_integer] in (23) then 'age 23'
when [age_integer] in (24) then 'age 24'
when [age_integer] > 24 then 'age 25'
else 'unknown'
end as [age],
(CONVERT(int, CONVERT(varchar, [StartDate], 112)) - CONVERT(int, CONVERT(varchar, [PersonBirthDate], 112)))/10000 AS AgePlanStarted, --- calculates how old the CYP was when the plan started 
case 
when [StartDate] is not null then (CONVERT(int, CONVERT(varchar, '20241801', 112)) - CONVERT(int, CONVERT(varchar, [StartDate], 112)))/10000 
else 99 
end AS years_plan, -- calcuates length the plan has been in place as at census date 
[sen_establishment] as [PlacementGroup],
[sen_establishment_detail] as [Placement],
1 as EHCPlans

into
#matched

from 
[SEN2_2024].[caseload]


-- Investigate the data
SELECT TOP 100 *
FROM [SEN2_2024].[caseload]

-- Check distinct genres within the table
SELECT DISTINCT genre
FROM [SEN2_2024].[caseload]

*/


SELECT * FROM catalog_40_copper_analyst_training.steam.steam_game_reviews LIMIT 1000

/*
SELECT *
--INTO #action
FROM catalog_40_copper_analyst_training.steam.games_ranking
WHERE genre IN ('Action', '')
*/
