.pragma library

// Every OmaStats setting, its default and the checks applied to a saved value.
// Groups become the tabs of the settings panel. English lives here as the
// fallback; i18n/en.json and i18n/fr.json carry the displayed strings.

var HEX_PALETTE = [
  "#a6e3a1", "#f9e2af", "#f38ba8", "#fab387", "#94e2d5", "#89b4fa",
  "#cba6f7", "#f5c2e7", "#eba0ac", "#f2cdcd", "#b4befe", "#89dceb"
];

var groups = [
  {
    key: "general",
    title: "General",
    items: [
      { key: "interval", label: "Refresh every", hint: "Seconds between two readings. One is responsive, five is lighter on the battery.", kind: "int", fallback: 2, min: 1, max: 30, step: 1, unit: "s" },
      { key: "display", label: "Bar shows", hint: "Text only, bars only, or both. Bars make the load readable without reading numbers.", kind: "enum", fallback: "both", options: ["text", "bar", "both"], optionLabels: { text: "Text", bar: "Bars", both: "Both" } },
      { key: "barOrientation", label: "Bar direction", hint: "Auto draws columns on a horizontal bar and rows on a side bar. Force either direction if you prefer.", kind: "enum", fallback: "auto", options: ["auto", "vertical", "horizontal"], optionLabels: { auto: "Auto", vertical: "Vertical", horizontal: "Horizontal" } },
      { key: "barLength", label: "Bar length", hint: "Long side of each little bar, in pixels.", kind: "int", fallback: 16, min: 6, max: 40, step: 1, unit: "px" },
      { key: "barThickness", label: "Bar thickness", hint: "Short side of each little bar, in pixels.", kind: "int", fallback: 4, min: 2, max: 12, step: 1, unit: "px" },
      { key: "gap", label: "Space between metrics", hint: "Breathing room between CPU, memory, disks and the rest.", kind: "int", fallback: 6, min: 0, max: 20, step: 1, unit: "px" },
      { key: "labels", label: "Metric names", hint: "Show CPU, RAM, DSK and so on. Off leaves only the values and the bars.", kind: "bool", fallback: true },
      { key: "separator", label: "Separator", hint: "Written between metrics when names are shown.", kind: "string", fallback: " · ", maxLength: 5, presets: [" · ", "  ", " | ", " • "] },
      { key: "showUnits", label: "Units", hint: "Show % and °. Off keeps the numbers and lets the colour speak.", kind: "bool", fallback: true },
      { key: "fontScale", label: "Text size", hint: "Size of the bar text, in percent of the theme's size.", kind: "int", fallback: 100, min: 75, max: 140, step: 5, unit: "%" },
      { key: "tooltip", label: "Detailed tooltip", hint: "Hover the widget for every reading, including disk used and free space.", kind: "bool", fallback: true },
      { key: "clickAction", label: "Middle click", hint: "What a middle click opens. Left and right clicks open this settings panel.", kind: "enum", fallback: "btop", options: ["btop", "none"], optionLabels: { btop: "btop", none: "Nothing" } }
    ]
  },
  {
    key: "labels",
    title: "Labels",
    items: [
      { key: "labelCpu", label: "CPU label", hint: "Text shown for the processor. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "CPU", maxLength: 24 },
      { key: "labelGpu", label: "GPU label", hint: "Text shown for graphics. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "GPU", maxLength: 24 },
      { key: "labelRam", label: "Memory label", hint: "Text shown for memory. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "RAM", maxLength: 24 },
      { key: "labelSwap", label: "Swap label", hint: "Text shown for swap. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "SWP", maxLength: 24 },
      { key: "labelDisk", label: "Disk label", hint: "Empty uses the mount name (DSK, HOME...). Leading and trailing spaces are kept as margins.", kind: "string", fallback: "", maxLength: 24 },
      { key: "labelNetDown", label: "Download label", hint: "Text shown for download. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "↓", maxLength: 24 },
      { key: "labelNetUp", label: "Upload label", hint: "Text shown for upload. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "↑", maxLength: 24 },
      { key: "labelTemp", label: "Temperature label", hint: "Marks the temperature bar when bars are shown alone. Leading and trailing spaces are kept as margins.", kind: "string", fallback: "°", maxLength: 24 }
    ]
  },
  {
    key: "colors",
    title: "Colors",
    items: [
      { key: "colorLow", label: "Low colour", hint: "Used below the first threshold.", kind: "color", fallback: "#a6e3a1", presets: HEX_PALETTE },
      { key: "colorMid", label: "Middle colour", hint: "Used from the first threshold to the second.", kind: "color", fallback: "#f9e2af", presets: HEX_PALETTE },
      { key: "colorHigh", label: "High colour", hint: "Used at or above the second threshold.", kind: "color", fallback: "#f38ba8", presets: HEX_PALETTE },
      { key: "colorText", label: "Colour the numbers", hint: "Off keeps the numbers in the bar's own text colour and colours only the bars.", kind: "bool", fallback: true },
      { key: "colorExtra", label: "Colour temperatures", hint: "Colour CPU and GPU temperatures with their own thresholds.", kind: "bool", fallback: true },
      { key: "barTrackOpacity", label: "Track opacity", hint: "How visible the empty part of a bar is, in percent. Zero hides it.", kind: "int", fallback: 18, min: 0, max: 50, step: 2, unit: "%" },
      { key: "barRounding", label: "Bar rounding", hint: "Round the ends of the bars. Zero keeps them square.", kind: "int", fallback: 2, min: 0, max: 6, step: 1, unit: "px" }
    ]
  },
  {
    key: "cpu",
    title: "CPU",
    items: [
      { key: "cpuShow", label: "Show CPU", hint: "Processor load on the bar.", kind: "bool", fallback: true },
      { key: "cpuMin", label: "Bar starts at", hint: "Value at the empty end of the bar. Raise it to make small loads look bigger.", kind: "int", fallback: 0, min: 0, max: 100, step: 1, unit: "%" },
      { key: "cpuMax", label: "Bar ends at", hint: "Value at the full end of the bar.", kind: "int", fallback: 100, min: 0, max: 100, step: 1, unit: "%" },
      { key: "cpuWarn", label: "Middle threshold", hint: "From this load the middle colour is used. Below it, the low colour.", kind: "int", fallback: 60, min: 0, max: 100, step: 1, unit: "%" },
      { key: "cpuCrit", label: "High threshold", hint: "From this load the high colour is used.", kind: "int", fallback: 85, min: 0, max: 100, step: 1, unit: "%" },
      { key: "cpuTempShow", label: "Show temperature", hint: "CPU package temperature beside the load, when the sensor is readable.", kind: "bool", fallback: true },
      { key: "cpuTempMin", label: "Temperature bar starts at", hint: "Empty end of the temperature scale.", kind: "int", fallback: 30, min: 0, max: 120, step: 1, unit: "°" },
      { key: "cpuTempMax", label: "Temperature bar ends at", hint: "Full end of the temperature scale.", kind: "int", fallback: 100, min: 0, max: 120, step: 1, unit: "°" },
      { key: "cpuTempWarn", label: "Temperature middle threshold", hint: "From this temperature the middle colour is used.", kind: "int", fallback: 70, min: 0, max: 120, step: 1, unit: "°" },
      { key: "cpuTempCrit", label: "Temperature high threshold", hint: "From this temperature the high colour is used.", kind: "int", fallback: 90, min: 0, max: 120, step: 1, unit: "°" }
    ]
  },
  {
    key: "gpu",
    title: "GPU",
    items: [
      { key: "gpuShow", label: "Show GPU", hint: "Graphics load on the bar. Hidden by itself when no readable GPU is found.", kind: "bool", fallback: true },
      { key: "gpuMin", label: "Bar starts at", hint: "Value at the empty end of the bar.", kind: "int", fallback: 0, min: 0, max: 100, step: 1, unit: "%" },
      { key: "gpuMax", label: "Bar ends at", hint: "Value at the full end of the bar.", kind: "int", fallback: 100, min: 0, max: 100, step: 1, unit: "%" },
      { key: "gpuWarn", label: "Middle threshold", hint: "From this load the middle colour is used.", kind: "int", fallback: 60, min: 0, max: 100, step: 1, unit: "%" },
      { key: "gpuCrit", label: "High threshold", hint: "From this load the high colour is used.", kind: "int", fallback: 85, min: 0, max: 100, step: 1, unit: "%" },
      { key: "gpuTempShow", label: "Show temperature", hint: "GPU temperature beside the load, when the sensor is readable.", kind: "bool", fallback: true },
      { key: "gpuTempMin", label: "Temperature bar starts at", hint: "Empty end of the temperature scale.", kind: "int", fallback: 30, min: 0, max: 120, step: 1, unit: "°" },
      { key: "gpuTempMax", label: "Temperature bar ends at", hint: "Full end of the temperature scale.", kind: "int", fallback: 105, min: 0, max: 120, step: 1, unit: "°" },
      { key: "gpuTempWarn", label: "Temperature middle threshold", hint: "From this temperature the middle colour is used.", kind: "int", fallback: 70, min: 0, max: 120, step: 1, unit: "°" },
      { key: "gpuTempCrit", label: "Temperature high threshold", hint: "From this temperature the high colour is used.", kind: "int", fallback: 88, min: 0, max: 120, step: 1, unit: "°" }
    ]
  },
  {
    key: "memory",
    title: "Memory",
    items: [
      { key: "ramShow", label: "Show memory", hint: "Used RAM as a share of the total. The tooltip gives the exact GiB.", kind: "bool", fallback: true },
      { key: "ramMin", label: "Bar starts at", hint: "Value at the empty end of the bar.", kind: "int", fallback: 0, min: 0, max: 100, step: 1, unit: "%" },
      { key: "ramMax", label: "Bar ends at", hint: "Value at the full end of the bar.", kind: "int", fallback: 100, min: 0, max: 100, step: 1, unit: "%" },
      { key: "ramWarn", label: "Middle threshold", hint: "From this load the middle colour is used.", kind: "int", fallback: 70, min: 0, max: 100, step: 1, unit: "%" },
      { key: "ramCrit", label: "High threshold", hint: "From this load the high colour is used.", kind: "int", fallback: 90, min: 0, max: 100, step: 1, unit: "%" },
      { key: "swapShow", label: "Show swap", hint: "Swap usage as its own reading. Hidden when the machine has no swap.", kind: "bool", fallback: false },
      { key: "swapMin", label: "Swap bar starts at", hint: "Value at the empty end of the bar.", kind: "int", fallback: 0, min: 0, max: 100, step: 1, unit: "%" },
      { key: "swapMax", label: "Swap bar ends at", hint: "Value at the full end of the bar.", kind: "int", fallback: 100, min: 0, max: 100, step: 1, unit: "%" },
      { key: "swapWarn", label: "Swap middle threshold", hint: "From this load the middle colour is used.", kind: "int", fallback: 50, min: 0, max: 100, step: 1, unit: "%" },
      { key: "swapCrit", label: "Swap high threshold", hint: "From this load the high colour is used.", kind: "int", fallback: 80, min: 0, max: 100, step: 1, unit: "%" }
    ]
  },
  {
    key: "disk",
    title: "Disks",
    items: [
      { key: "diskShow", label: "Show disks", hint: "Usage of the mount points below. Hidden when none can be read.", kind: "bool", fallback: true },
      { key: "diskMounts", label: "Mount points", hint: "Comma separated, for example / or /,/home. Each one gets its own reading.", kind: "string", fallback: "/", maxLength: 256, presets: ["/", "/,/home", "/,/home,/var"] },
      { key: "diskMode", label: "With several disks", hint: "Each mount gets its own reading, or show only the fullest one.", kind: "enum", fallback: "each", options: ["each", "max"], optionLabels: { each: "Each one", max: "Fullest only" } },
      { key: "diskMin", label: "Bar starts at", hint: "Value at the empty end of the bar.", kind: "int", fallback: 0, min: 0, max: 100, step: 1, unit: "%" },
      { key: "diskMax", label: "Bar ends at", hint: "Value at the full end of the bar.", kind: "int", fallback: 100, min: 0, max: 100, step: 1, unit: "%" },
      { key: "diskWarn", label: "Middle threshold", hint: "From this usage the middle colour is used.", kind: "int", fallback: 75, min: 0, max: 100, step: 1, unit: "%" },
      { key: "diskCrit", label: "High threshold", hint: "From this usage the high colour is used.", kind: "int", fallback: 90, min: 0, max: 100, step: 1, unit: "%" }
    ]
  },
  {
    key: "network",
    title: "Network",
    items: [
      { key: "netShow", label: "Show network", hint: "Download and upload rates of one interface.", kind: "bool", fallback: true },
      { key: "netInterface", label: "Interface", hint: "auto follows the default route. Type a name such as wlan0 or eth0 to pin one.", kind: "string", fallback: "auto", maxLength: 32, presets: ["auto", "wlan0", "eth0"] },
      { key: "netRxShow", label: "Show download", hint: "Incoming rate with a downward arrow.", kind: "bool", fallback: true },
      { key: "netTxShow", label: "Show upload", hint: "Outgoing rate with an upward arrow.", kind: "bool", fallback: true },
      { key: "netUnit", label: "Rate unit", hint: "Auto picks B/s, KB/s or MB/s. Mbit/s is the unit ISPs use.", kind: "enum", fallback: "auto", options: ["auto", "mb", "mbit"], optionLabels: { auto: "Auto", mb: "MB/s", mbit: "Mbit/s" } },
      { key: "netDecimals", label: "Decimals", hint: "Digits after the point for network rates.", kind: "int", fallback: 1, min: 0, max: 2, step: 1 },
      { key: "netMin", label: "Bar starts at", hint: "Rate at the empty end of the bar, in MB/s.", kind: "int", fallback: 0, min: 0, max: 500, step: 1, unit: "MB/s" },
      { key: "netMax", label: "Bar ends at", hint: "Rate at the full end of the bar, in MB/s.", kind: "int", fallback: 50, min: 1, max: 1000, step: 1, unit: "MB/s" },
      { key: "netWarn", label: "Middle threshold", hint: "From this rate the middle colour is used, in MB/s.", kind: "int", fallback: 5, min: 0, max: 1000, step: 1, unit: "MB/s" },
      { key: "netCrit", label: "High threshold", hint: "From this rate the high colour is used, in MB/s.", kind: "int", fallback: 20, min: 0, max: 1000, step: 1, unit: "MB/s" }
    ]
  },
  {
    key: "panel",
    title: "Panel",
    items: [
      { key: "openAs", label: "Open as", hint: "The settings can hang under the bar or live in a window of their own.", kind: "enum", fallback: "panel", options: ["panel", "window"], optionLabels: { panel: "Bar panel", window: "Own window" } },
      { key: "panelWidth", label: "Panel width", hint: "How wide the settings open.", kind: "int", fallback: 560, min: 420, max: 1000, step: 10, unit: "px" },
      { key: "panelHeight", label: "Panel height", hint: "How tall the settings open. It still stops where the screen does.", kind: "int", fallback: 640, min: 420, max: 1100, step: 10, unit: "px" },
      { key: "panelOpacity", label: "Window opacity", hint: "Background opacity when the settings are in their own window.", kind: "int", fallback: 100, min: 50, max: 100, step: 1, unit: "%" }
    ]
  }
];

var about = {
  key: "about",
  title: "About"
};

var defaultsCache = null;

function defaults() {
  if (defaultsCache) return defaultsCache;
  var out = {};
  for (var g = 0; g < groups.length; g++) {
    var items = groups[g].items;
    for (var i = 0; i < items.length; i++) out[items[i].key] = items[i].fallback;
  }
  defaultsCache = out;
  return out;
}

var byKeyCache = null;
function byKey() {
  if (byKeyCache) return byKeyCache;
  var m = {};
  for (var g = 0; g < groups.length; g++) {
    var items = groups[g].items;
    for (var i = 0; i < items.length; i++) m[items[i].key] = items[i];
  }
  byKeyCache = m;
  return m;
}

function validHex(value) {
  return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(String(value));
}

function cleanValue(key, value) {
  var item = byKey()[key];
  if (!item) return value;
  if (value === null || value === undefined) return item.fallback;
  switch (item.kind) {
  case "bool":
    return value === true || value === "true" ? true
         : (value === false || value === "false" ? false : item.fallback);
  case "int": {
    var n = typeof value === "number" ? value : parseFloat(value);
    if (!isFinite(n)) return item.fallback;
    return Math.max(item.min, Math.min(item.max, Math.round(n)));
  }
  case "color":
    return validHex(value) ? String(value).toLowerCase() : item.fallback;
  case "string": {
    var s = String(value).replace(/[\u0000-\u001f\u007f]/g, "");
    return item.maxLength ? s.slice(0, item.maxLength) : s;
  }
  default:
    return item.options.indexOf(String(value)) >= 0 ? String(value) : item.fallback;
  }
}

function resolve(shellSettings, local) {
  var out = {};
  var d = defaults();
  for (var k in d) {
    var v;
    if (local && local[k] !== undefined && local[k] !== null) v = local[k];
    else if (shellSettings && shellSettings[k] !== undefined && shellSettings[k] !== null) v = shellSettings[k];
    out[k] = cleanValue(k, v === undefined ? d[k] : v);
  }
  return out;
}

function active(item, values) {
  if (!item || !item.when) return true;
  for (var i = 0; i < item.when.length; i++) {
    var c = item.when[i];
    if (c.is && c.is.map(String).indexOf(String(values[c.key])) < 0) return false;
    if (c.not && c.not.map(String).indexOf(String(values[c.key])) >= 0) return false;
  }
  return true;
}

function matches(item, query) {
  var q = String(query || "").trim().toLowerCase();
  if (q === "") return true;
  var hay = (item.key + " " + (item.label || "") + " " + (item.hint || "")).toLowerCase();
  return q.split(/\s+/).every(function(w) { return hay.indexOf(w) >= 0; });
}
