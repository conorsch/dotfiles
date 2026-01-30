//! Gatus API types and parsing.

use chrono::{DateTime, Utc};
use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
pub struct Endpoint {
    pub name: String,
    pub group: String,
    pub key: String,
    pub results: Vec<CheckResult>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CheckResult {
    pub status: u16,
    pub hostname: String,
    /// Duration in nanoseconds.
    pub duration: u64,
    pub condition_results: Vec<ConditionResult>,
    pub success: bool,
    pub timestamp: DateTime<Utc>,
}

#[derive(Debug, Clone, Deserialize)]
pub struct ConditionResult {
    pub condition: String,
    pub success: bool,
}

impl Endpoint {
    /// Returns the most recent check result, if any.
    pub fn latest_result(&self) -> Option<&CheckResult> {
        self.results.first()
    }

    /// Returns true if the most recent check was successful.
    pub fn is_healthy(&self) -> bool {
        self.latest_result().is_some_and(|r| r.success)
    }

    /// Returns the uptime percentage based on available results.
    pub fn uptime_percent(&self) -> f64 {
        if self.results.is_empty() {
            return 0.0;
        }
        let successful = self.results.iter().filter(|r| r.success).count();
        (successful as f64 / self.results.len() as f64) * 100.0
    }
}

impl CheckResult {
    /// Returns duration in milliseconds.
    pub fn duration_ms(&self) -> f64 {
        self.duration as f64 / 1_000_000.0
    }
}

/// Fetches endpoint statuses from the Gatus API.
pub fn fetch_statuses(url: &str) -> anyhow::Result<Vec<Endpoint>> {
    let response = reqwest::blocking::get(url)?;
    let endpoints: Vec<Endpoint> = response.json()?;
    Ok(endpoints)
}

/// Filters endpoints by hostname or service name (case-insensitive partial match).
pub fn filter_endpoints(endpoints: Vec<Endpoint>, filter: &str) -> Vec<Endpoint> {
    let filter_lower = filter.to_lowercase();
    endpoints
        .into_iter()
        .filter(|e| {
            e.name.to_lowercase().contains(&filter_lower)
                || e.latest_result()
                    .is_some_and(|r| r.hostname.to_lowercase().contains(&filter_lower))
        })
        .collect()
}
