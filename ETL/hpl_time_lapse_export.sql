--Create tables

--DROP TABLE pr_ui_equity_msdc.time_lapse_s;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.time_lapse_s
(
	ssn_id INTEGER,
	last_employer_acct_id INTEGER,
	bnft_yr_start_wk DATE,
	bnft_yr_start_mo DATE,
	bdate DATE,
	gender SMALLINT,
	race SMALLINT,
	ethnicity SMALLINT,
	race_eth_cat VARCHAR(18),
	disability SMALLINT,
	education SMALLINT,
	education_cat VARCHAR(12),
	veteran SMALLINT,
	county_fips VARCHAR(3),
	lwia SMALLINT,
	industry VARCHAR(6),
	sector VARCHAR(6),
	first_comp_week_end_dt DATE,
	first_comp_certification_week DATE,
	first_paid_week_end_dt DATE,
	first_paid_certification_week DATE,
	cert_time_lapse INTEGER,
	pmt_time_lapse INTEGER
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104
(
	bnft_yr_start_mo DATE,
	lwia SMALLINT,
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104
(
	bnft_yr_start_mo DATE,
	race_eth_cat VARCHAR(18),
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104
(
	bnft_yr_start_mo DATE,
	sector VARCHAR(6),
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104_export;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104_export
(
	bnft_yr_start_mo DATE,
	lwia SMALLINT,
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104_export;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104_export
(
	bnft_yr_start_mo DATE,
	race_eth_cat VARCHAR(18),
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--DROP TABLE pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104_export;

CREATE TABLE IF NOT EXISTS pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104_export
(
	bnft_yr_start_mo DATE,
	sector VARCHAR(6),
	claimant_count BIGINT,
	employer_count BIGINT,
	avg_cert_time_lapse BIGINT,
	avg_pmt_time_lapse BIGINT
);

--Main time lapse logic

TRUNCATE TABLE pr_ui_equity_msdc.time_lapse_s;

INSERT INTO pr_ui_equity_msdc.time_lapse_s
WITH bnft_wk_num AS (
	--Select new claims for regular state UI, number sequence of benefit week within benefit year
	SELECT *,
		substring(industry,1,2) AS industry2,
		row_number() OVER (PARTITION BY ssn_id, bnft_yr_start_wk 
			ORDER BY week_end_dt) AS bnft_wk_num
	FROM pr_il_iled.certified_claim cc
	WHERE program_type = 1
	AND sub_program_type = 1
	AND claim_type = 1
	AND bnft_yr_start_wk >= '2020-01-01'
),
paid_wk_num AS (
	--Number paid weeks
	SELECT *,
		row_number() OVER (PARTITION BY ssn_id, bnft_yr_start_wk 
			ORDER BY week_end_dt) AS paid_wk_num
	FROM bnft_wk_num
	WHERE total_paid > 0
),
first_comp_week AS (
	--Select the "first compensable week", which is the second week in the benfit year
	SELECT *
	FROM bnft_wk_num
	WHERE bnft_wk_num = 2
),
first_paid_week AS (
	--Select first paid week
	SELECT *
	FROM paid_wk_num
	WHERE paid_wk_num = 1
)
--Join the first compensable week to the first paid week, calculate time lapse
--indicators based on the benefit week and certification week values on these two records.
SELECT fcw.ssn_id,
	fcw.last_employer_acct_id,
	fcw.bnft_yr_start_wk,
	date_trunc('month',fcw.bnft_yr_start_wk)::date AS bnft_yr_start_mo,
	fcw.bdate,
	fcw.gender,
	fcw.race,
	fcw.ethnicity,
	CASE WHEN fcw.ethnicity = 1 THEN 'Hispanic or Latino'
			WHEN fcw.race = 1 THEN 'White (NH)'
			WHEN fcw.race = 2 THEN 'Black (NH)'
			WHEN fcw.race = 4 THEN 'Asian (NH)'
			ELSE 'Other (NH)' END AS race_eth_cat,
	fcw.disability,
	fcw.education,
	CASE WHEN fcw.education IN (1,2,3,4,5,6,7,8,9,10,11,12,13) THEN 'Less than HS'
			WHEN fcw.education IN (14,15,16,17) THEN 'HS'
			WHEN fcw.education = 18 THEN 'Vocational'
			WHEN fcw.education IN (19,20) THEN 'Associates'
			WHEN fcw.education IN (21,22) THEN 'Bachelors'
			WHEN fcw.education = 23 THEN 'Masters'
			WHEN fcw.education = 24 THEN 'Doctorate'
			WHEN fcw.education = 25 THEN 'MD'
			WHEN fcw.education = 26 THEN 'JD'
		END AS education_cat,
	fcw.veteran,
	fcw.county_fips,
	fcw.lwia,
	fcw.industry,
	CASE WHEN fcw.industry2 IN ('31','32','33') THEN '31-33'
			WHEN fcw.industry2 IN ('44','45') THEN '44-45'
			WHEN fcw.industry2 IN ('48','49') THEN '48-49'
			ELSE fcw.industry2
		END AS sector,
	fcw.week_end_dt AS first_comp_week_end_dt,
	fcw.certification_week AS first_comp_certification_week,
	fpw.week_end_dt AS first_paid_week_end_dt,
	fpw.certification_week AS first_paid_certification_week,
	fcw.certification_week - fcw.week_end_dt AS cert_time_lapse, --Certification time lapse is the certification week
																	--minus the week ending date of the first compensable week 
	fpw.certification_week - fcw.week_end_dt AS pmt_time_lapse --Payment time lapse is the certification week of the first
																	--paid record (which is also the payment week) minus the 
																	--week ending date on the first compensable week
FROM first_comp_week fcw
LEFT JOIN first_paid_week fpw 
ON fcw.ssn_id = fpw.ssn_id
AND fcw.bnft_yr_start_wk = fpw.bnft_yr_start_wk;


--Aggregate by several dimensions

TRUNCATE TABLE pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104
SELECT bnft_yr_start_mo,
	lwia,
	count(DISTINCT ssn_id) AS claimant_count,
	count(DISTINCT last_employer_acct_id) AS employer_count,
	avg(cert_time_lapse) AS avg_cert_time_lapse,
	avg(pmt_time_lapse) AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.time_lapse_s
GROUP BY bnft_yr_start_mo,
	lwia
ORDER BY bnft_yr_start_mo,
	lwia;


TRUNCATE TABLE pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104
SELECT bnft_yr_start_mo,
	race_eth_cat,
	count(DISTINCT ssn_id) AS claimant_count,
	count(DISTINCT last_employer_acct_id) AS employer_count,
	avg(cert_time_lapse) AS avg_cert_time_lapse,
	avg(pmt_time_lapse) AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.time_lapse_s
GROUP BY bnft_yr_start_mo,
	race_eth_cat
ORDER BY bnft_yr_start_mo,
	race_eth_cat;


TRUNCATE TABLE pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104
SELECT bnft_yr_start_mo,
	sector,
	count(DISTINCT ssn_id) AS claimant_count,
	count(DISTINCT last_employer_acct_id) AS employer_count,
	avg(cert_time_lapse) AS avg_cert_time_lapse,
	avg(pmt_time_lapse) AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.time_lapse_s
GROUP BY bnft_yr_start_mo,
	sector
ORDER BY bnft_yr_start_mo,
	sector;


--Create export versions

TRUNCATE TABLE  pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104_export;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104_export
SELECT bnft_yr_start_mo,
	lwia,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN claimant_count END AS claimant_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN employer_count END AS employer_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_cert_time_lapse END AS avg_cert_time_lapse,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_pmt_time_lapse END AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.hpl_time_lapse_lwia_mo_20241104;


TRUNCATE TABLE pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104_export;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104_export
SELECT bnft_yr_start_mo,
	race_eth_cat,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN claimant_count END AS claimant_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN employer_count END AS employer_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_cert_time_lapse END AS avg_cert_time_lapse,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_pmt_time_lapse END AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.hpl_time_lapse_race_eth_mo_20241104;


TRUNCATE TABLE pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104_export;

INSERT INTO pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104_export
SELECT bnft_yr_start_mo,
	sector,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN claimant_count END AS claimant_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN employer_count END AS employer_count,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_cert_time_lapse END AS avg_cert_time_lapse,
	CASE WHEN claimant_count >= 10 AND employer_count >= 3 THEN avg_pmt_time_lapse END AS avg_pmt_time_lapse
FROM pr_ui_equity_msdc.hpl_time_lapse_sector_mo_20241104;
