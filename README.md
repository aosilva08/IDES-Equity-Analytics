## IDES Equity Analytics

This project supports the Illinois Department of Employment Security (IDES) in evaluating equity gaps in Unemployment Insurance (UI) access, as part of a broader modernization effort funded by the U.S. Department of Labor Equity Grant.

### Objective

To identify and analyze disparities in UI benefit processing—specifically, delays in certification and payment—across regions, racial/ethnic groups, and industries. The goal is to uncover systemic inefficiencies and inform targeted interventions to improve equity in service delivery.

---

### Folder Structure

#### `ETL/`
Contains SQL export script and files generated from IDES administrative data.

- `hpl_time_lapse_export`: Master dataset for time lapse analysis.
- `time_lapse_lwia_mo`: Monthly data by Local Workforce Investment Areas (LWIAs).
- `time_lapse_sector_mo`: Monthly data by industry sectors.

#### `Power BI/`
Includes the `.pbix` file used to visualize trends and disparities.

- **Key visuals**: Time lapse by region, race/ethnicity, and industry.
- **Interactive filters**: Explore data by city, county, LWIA, and time period.
- **Map**: Displays geographic disparities in processing times.

---

### Insights

- Black claimants experience the longest and most volatile payment delays.
- Southern and rural LWIAs show consistently higher certification and payment time lapses.
- Education Services sector reports the highest average delays due to complex eligibility requirements.
- Factors such as language proficiency, education level, and unemployment rates are linked to longer delays, highlighting the importance of tailored administrative support.

---

### Policy Memo Summary

This analysis supports IDES in meeting ETA equity benchmarks and improving operational performance. It introduces two key metrics:

- **Certification time lapse**: From first compensable week to first certification.
- **First payment time lapse**: From first compensable week to first payment.

Key findings include:

- Regional disparities persist despite high internet access, suggesting digital tools alone are insufficient.
- Black and Hispanic/Latino populations make up nearly half of all UI claims from 2021–2024, yet Black claimants face significantly longer payment delays.
- Seasonal industries like Accommodation and Food Services show cyclical peaks in delays.
- Socioeconomic factors—such as limited English proficiency and lower education levels—drive structural barriers to timely access.

Recommendations emphasize targeted outreach, multilingual support tools, and geographic prioritization of resources.

 
