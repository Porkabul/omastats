.pragma library

// Number and colour helpers shared by the bar widget, the preview and the
// tooltip. Everything is defensive: a missing sensor is null, never zero.

function clamp(v, lo, hi) {
  const n = Number(v)
  if (!isFinite(n)) return lo
  return Math.max(lo, Math.min(hi, n))
}

function clamp01(v) { return clamp(v, 0, 1) }

function validNumber(v) {
  return v !== null && v !== undefined && v !== "" && isFinite(Number(v))
}

// 0 .. 100, rounded. No decimals: a bar that ticks every two seconds does not
// need 48.3.
function pct(v, units) {
  if (!validNumber(v)) return "–"
  const n = Math.round(Number(v))
  return units === false ? String(n) : n + "%"
}

function temp(v, units) {
  if (!validNumber(v)) return "–"
  const n = Math.round(Number(v))
  return units === false ? String(n) : n + "°"
}

function decimal(v, places) {
  if (!validNumber(v)) return "–"
  const p = Math.max(0, Math.min(3, Number(places) || 0))
  return Number(v).toFixed(p)
}

// Bytes per second -> display string. unit: auto | mb | mbit.
function rate(bytes, unit, places) {
  const b = Math.max(0, Number(bytes) || 0)
  const p = Math.max(0, Math.min(2, Number(places) || 0))
  if (unit === "mbit") return (b * 8 / 1000000).toFixed(p) + " Mb/s"
  if (unit === "mb") return (b / 1048576).toFixed(p) + " MB/s"
  if (b >= 1048576) return (b / 1048576).toFixed(p) + " MB/s"
  if (b >= 1024) return (b / 1024).toFixed(p) + " KB/s"
  return Math.round(b) + " B/s"
}

// Network thresholds and min/max are stored in MB/s.
function mbps(bytes) {
  return Math.max(0, Number(bytes) || 0) / 1048576
}

// The three-colour ramp. `warn` and `crit` are normalised by the caller so a
// pair entered the wrong way round still behaves.
function colorFor(value, warn, crit, cfg) {
  const v = Number(value)
  if (!isFinite(v)) return cfg.colorLow
  if (v >= crit) return cfg.colorHigh
  if (v >= warn) return cfg.colorMid
  return cfg.colorLow
}

function thresholds(warn, crit) {
  const a = isFinite(Number(warn)) ? Number(warn) : 0
  const b = isFinite(Number(crit)) ? Number(crit) : 100
  return { warn: Math.min(a, b), crit: Math.max(a, b) }
}

// Fraction of a bar to fill, between min and max.
function fraction(value, min, max) {
  if (!validNumber(value)) return 0
  const lo = Number(min)
  const hi = Number(max)
  if (!isFinite(lo) || !isFinite(hi) || hi <= lo) return 0
  return clamp01((Number(value) - lo) / (hi - lo))
}

// A short, stable name for a mount point: "/" reads DSK, "/home" reads HOME.
function diskLabel(mount) {
  let m = String(mount || "").replace(/\/+$/, "")
  if (m === "") return "DSK"
  const base = m.split("/").pop()
  if (base === "") return "DSK"
  return base.toUpperCase().slice(0, 6)
}

// The single fullest disk, for diskMode "max".
function fullestDisk(disks) {
  if (!Array.isArray(disks) || disks.length === 0) return null
  let best = disks[0]
  for (let i = 1; i < disks.length; i++) {
    if (Number(disks[i].pct) > Number(best.pct)) best = disks[i]
  }
  return best
}

// GiB with one decimal, for the tooltip.
function gib(v) {
  if (!validNumber(v)) return "–"
  return Number(v).toFixed(1)
}
