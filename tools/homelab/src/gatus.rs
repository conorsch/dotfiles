//! Gatus API types and parsing.

use std::collections::HashMap;

use chrono::{DateTime, Utc};
use serde::Deserialize;
use serde_json::Value;
use tracing::warn;

/// Known set of fields in the Gatus API response, used for detecting API drift.
/// Update these when upgrading to a new Gatus version.
const KNOWN_ENDPOINT_FIELDS: &[&str] = &["name", "group", "key", "results"];
const KNOWN_RESULT_FIELDS: &[&str] = &[
    "status",
    "hostname",
    "duration",
    "errors",
    "conditionResults",
    "success",
    "timestamp",
];

#[derive(Debug, Clone, Deserialize)]
pub struct Endpoint {
    pub name: String,
    pub group: String,
    pub key: String,
    pub results: Vec<CheckResult>,
    /// Captures any fields not explicitly modeled, for forward-compatibility.
    #[serde(flatten)]
    pub extra: HashMap<String, Value>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct CheckResult {
    /// HTTP status code. Absent when the check failed before getting a response
    /// (e.g. connection refused, DNS failure).
    pub status: Option<u16>,
    pub hostname: String,
    /// Duration in nanoseconds.
    pub duration: u64,
    /// Error messages, present when the check failed.
    #[serde(default)]
    pub errors: Vec<String>,
    pub condition_results: Vec<ConditionResult>,
    pub success: bool,
    pub timestamp: DateTime<Utc>,
    /// Captures any fields not explicitly modeled, for forward-compatibility.
    #[serde(flatten)]
    pub extra: HashMap<String, Value>,
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

/// Log warnings if the API response contains fields we don't explicitly handle.
/// This helps detect Gatus API changes before they cause breakage.
fn warn_unknown_fields(endpoints: &[Endpoint]) {
    for ep in endpoints {
        for key in ep.extra.keys() {
            if !KNOWN_ENDPOINT_FIELDS.contains(&key.as_str()) {
                warn!(
                    endpoint = %ep.name,
                    field = %key,
                    "unknown field in Gatus endpoint response; the upstream API may have changed"
                );
            }
        }
        for result in &ep.results {
            for key in result.extra.keys() {
                if !KNOWN_RESULT_FIELDS.contains(&key.as_str()) {
                    warn!(
                        endpoint = %ep.name,
                        field = %key,
                        "unknown field in Gatus check result; the upstream API may have changed"
                    );
                }
            }
        }
    }
}

/// Fetches endpoint statuses from the Gatus API.
pub fn fetch_statuses(url: &str) -> anyhow::Result<Vec<Endpoint>> {
    let response = reqwest::blocking::get(url)?;
    let endpoints: Vec<Endpoint> = response.json()?;
    warn_unknown_fields(&endpoints);
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

#[cfg(test)]
mod tests {
    use super::*;

    /// A successful check result with all fields present.
    const FULL_RESPONSE: &str = r#"[
        {
            "name": "Test Service",
            "group": "core",
            "key": "core_test-service",
            "results": [
                {
                    "status": 200,
                    "hostname": "example.com",
                    "duration": 150000000,
                    "conditionResults": [
                        {"condition": "[STATUS] == 200", "success": true}
                    ],
                    "success": true,
                    "timestamp": "2026-03-06T01:00:00Z"
                }
            ]
        }
    ]"#;

    /// A failed check where `status` is absent and `errors` is present.
    const FAILED_RESPONSE: &str = r#"[
        {
            "name": "Broken Service",
            "group": "core",
            "key": "core_broken-service",
            "results": [
                {
                    "hostname": "broken.example.com",
                    "duration": 5000000,
                    "errors": ["connection refused"],
                    "conditionResults": [
                        {"condition": "[CONNECTED] (false) == true", "success": false}
                    ],
                    "success": false,
                    "timestamp": "2026-03-06T01:00:00Z"
                }
            ]
        }
    ]"#;

    /// Response with an unknown field, simulating a newer Gatus version.
    const RESPONSE_WITH_UNKNOWN_FIELD: &str = r#"[
        {
            "name": "Future Service",
            "group": "core",
            "key": "core_future",
            "newApiField": "surprise",
            "results": [
                {
                    "status": 200,
                    "hostname": "future.example.com",
                    "duration": 100000000,
                    "conditionResults": [],
                    "success": true,
                    "timestamp": "2026-03-06T01:00:00Z",
                    "someNewMetric": 42
                }
            ]
        }
    ]"#;

    #[test]
    fn parse_successful_response() {
        let endpoints: Vec<Endpoint> = serde_json::from_str(FULL_RESPONSE).unwrap();
        assert_eq!(endpoints.len(), 1);

        let ep = &endpoints[0];
        assert_eq!(ep.name, "Test Service");
        assert_eq!(ep.group, "core");
        assert!(ep.is_healthy());
        assert!((ep.uptime_percent() - 100.0).abs() < f64::EPSILON);

        let result = ep.latest_result().unwrap();
        assert_eq!(result.status, Some(200));
        assert_eq!(result.hostname, "example.com");
        assert!((result.duration_ms() - 150.0).abs() < f64::EPSILON);
        assert!(result.errors.is_empty());
    }

    #[test]
    fn parse_failed_response_without_status() {
        let endpoints: Vec<Endpoint> = serde_json::from_str(FAILED_RESPONSE).unwrap();
        assert_eq!(endpoints.len(), 1);

        let ep = &endpoints[0];
        assert!(!ep.is_healthy());

        let result = ep.latest_result().unwrap();
        assert_eq!(result.status, None);
        assert_eq!(result.errors, vec!["connection refused"]);
        assert!(!result.success);
    }

    #[test]
    fn parse_response_with_unknown_fields() {
        let endpoints: Vec<Endpoint> =
            serde_json::from_str(RESPONSE_WITH_UNKNOWN_FIELD).unwrap();
        assert_eq!(endpoints.len(), 1);

        let ep = &endpoints[0];
        assert!(ep.extra.contains_key("newApiField"));
        assert_eq!(ep.extra["newApiField"], "surprise");

        let result = ep.latest_result().unwrap();
        assert!(result.extra.contains_key("someNewMetric"));
        assert_eq!(result.extra["someNewMetric"], 42);
    }

    #[test]
    fn uptime_with_no_results() {
        let ep = Endpoint {
            name: "Empty".into(),
            group: "test".into(),
            key: "test_empty".into(),
            results: vec![],
            extra: HashMap::new(),
        };
        assert!((ep.uptime_percent()).abs() < f64::EPSILON);
        assert!(!ep.is_healthy());
        assert!(ep.latest_result().is_none());
    }

    #[test]
    fn filter_by_name() {
        let endpoints: Vec<Endpoint> = serde_json::from_str(FULL_RESPONSE).unwrap();
        let filtered = filter_endpoints(endpoints.clone(), "test");
        assert_eq!(filtered.len(), 1);

        let filtered = filter_endpoints(endpoints, "nonexistent");
        assert!(filtered.is_empty());
    }

    #[test]
    fn filter_by_hostname() {
        let endpoints: Vec<Endpoint> = serde_json::from_str(FULL_RESPONSE).unwrap();
        let filtered = filter_endpoints(endpoints, "example.com");
        assert_eq!(filtered.len(), 1);
    }
}
