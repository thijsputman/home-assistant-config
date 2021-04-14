import "date"
import "experimental"

yesterday = date.truncate(t: experimental.subDuration(d: 1d, from: now()), unit: 1d)
today = date.truncate(t: now(), unit: 1d)

// Cumulative (yesterday)
from(bucket: "home-assistant")
  |> range(start: yesterday, stop: today)
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: integral, createEmpty: false)
  |> cumulativeSum(columns: ["_value"])

// Daily total consumption (past year)
from(bucket: "home-assistant")
  |> range(start: -365, stop: today)
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)

// Daily consumption one minute resolution (past week)
from(bucket: "home-assistant")
  |> range(start: -7d, stop: today)
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  // Data reported every 30-40s, 1m average gives most stable result
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
