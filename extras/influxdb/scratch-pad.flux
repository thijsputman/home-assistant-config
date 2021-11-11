import "timezone"
import "date"
import "experimental"

ehv = timezone.location(name: "Europe/Amsterdam")
yesterday = date.truncate(
  t: experimental.subDuration(d: 1d, from: now()),
  unit: 1d
)

// The below is using one hour aggregate-window mean as poor man's way of
// turning kW into kWh (better solutions exist – haven't really figured them out
// yet though 😉). Still, this (rough) approach approximates the actual numbers
// quite well...
// Additionally, everything is a bit messed up timezone-wise: "today()" and
// "yesterday" are offset by either one (CET) or two (CEST) hours with regards
// to UTC. Although the data is correctly aggregated, I haven't yet managed to
// get the dynamic "today()/yesterday" time windows to work (hard-coding
// timestamps works fine).

// Cumulative energy (yesterday)
from(bucket: "home-assistant")
  |> range(start: yesterday, stop: today())
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false, location: ehv)
  |> cumulativeSum(columns: ["_value"])

// Daily total energy consumption (past year)
from(bucket: "home-assistant")
  |> range(start: -365d, stop: today())
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false, location: ehv)
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false, location: ehv)

// Daily energy consumption one minute resolution (past week)
from(bucket: "home-assistant")
  |> range(start: -7d, stop: today())
  |> filter(fn: (r) => r["entity_id"] == "power_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  // Data reported every 30-40s, 1m average gives most stable result
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false, location: ehv)

// Daily total gas consumption (past year)
// Based on `aggregate.rate()`, but expanded as to include `location: ehv` in
// the first `aggregateWindow` to prevent offsetting the daily totals by either
// one (CET) or two (CEST) hours...
from(bucket: "home-assistant")
  |> range(start: -365d, stop: today())
  |> filter(fn: (r) => r["entity_id"] == "gas_consumption")
  |> filter(fn: (r) => r["_field"] == "value")
  |> derivative(unit: 1h, nonNegative:true)
  |> aggregateWindow(every: 1h, createEmpty: false, location: ehv,
    fn : (tables=<-, column) =>
      tables
        |> mean(column: column)
        |> experimental.group(columns: ["_start", "_stop"], mode:"extend")
        |> sum()
      )
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)
