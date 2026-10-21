# Philadelphia L&I violations

This repository contains an Azure Data Factory pipeline for ingesting the City
of Philadelphia's public Licenses & Inspections code violations dataset
(Socrata dataset `wjz9-h9sj`) into Azure Data Lake Storage Gen2, plus example
SQL analyses.

## Ingestion

Import the JSON files under `adf/` into an Azure Data Factory. Configure the
`ADLSGen2` linked service with the factory's system-assigned managed identity
and grant it write access to the target storage account. Set the pipeline
`storageUrl` parameter to the account URL
(`https://<account>.dfs.core.windows.net/`), then run
`CopyPhiladelphiaLIViolations`. The pipeline requests pages of up to 50,000
records and writes JSON objects to `raw/li-violations/page-<offset>.json` in
the `raw` file system. Its `storageUrl` and `pageSize` pipeline parameters can
be overridden at run time; the page size must not exceed the API's 50,000-row
limit.

The public endpoint is accessed anonymously. No API key is required. The ADF
managed identity needs Storage Blob Data Contributor access on the destination.
Repeated runs overwrite the same page files; archive or copy them to a
date-partitioned location first if historical snapshots are required.

## Analysis

`sql/analysis.sql` contains sample queries for monthly volume, common violation
codes, and open violations by ZIP. Run them against a SQL staging table
`dbo.LIViolations` populated from the raw JSON files. Expected fields are
`violationdate`, `violationcode`, `violationdescription`, `status`, and `zip`,
matching the Socrata dataset.
