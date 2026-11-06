# OmaStats

CPU, GPU, memory, disks and network in the Omarchy bar. Every reading gets a
three-colour ramp with configurable thresholds, a configurable minimum and
maximum, and can be drawn as text, a bar, or both.

The idea comes from [Pastel Stats](https://github.com/michaelsucks/PastelStats),
minus the wattage, plus memory, disk usage and network rates.

## Features

- CPU and GPU load, plus CPU and GPU temperatures when the sensors exist.
- RAM and optional swap usage, with used / total GiB in the tooltip.
- One reading per mount point (`/`, `/home`, …), or only the fullest disk.
- Download and upload rates for the default-route interface, or a pinned one.
- Bars can be horizontal or vertical, with configurable length, thickness,
  rounding and track opacity.
- Display mode: text only, bars only, or both. Labels and units can be hidden.
- Three colours per metric (low, middle, high) with a middle and a high
  threshold. Threshold pairs entered the wrong way round are normalised.
- A per-metric minimum and maximum scales the bar, so a 40 °C idle temperature
  does not waste half the bar.
- A live preview in the settings panel uses the current colours and thresholds.
- Settings panel docked under the bar or in its own floating window.
- English and French, following the language picked in Omarchy.

## Install

```bash
mkdir -p ~/.config/omarchy/plugins
cp -r io.github.qempexe.omastats ~/.config/omarchy/plugins/
```

Then add the widget to `~/.config/omarchy/shell.json`, for example in the
`center` or `right` section of the bar:

```json
{
  "bar": {
    "layout": {
      "right": [
        { "id": "io.github.qempexe.omastats" }
      ]
    }
  }
}
```

The shell hot-reloads `shell.json` on save. If it does not pick the widget up,
run `omarchy refresh shell` (or `omarchy restart shell`).

The collector can be tested on its own:

```bash
~/.config/omarchy/plugins/io.github.qempexe.omastats/bin/omastats 2 auto /
```

It prints one JSON object per interval. Unreadable values are `null`.

## Using the panel

- Left or right click the widget: open the settings panel.
- Middle click: run `btop` when **Middle click** is set to btop.
- The panel tabs are **General**, **Colors**, **CPU**, **GPU**, **Memory**,
  **Disks**, **Network**, **Panel** and **About**.
- The search field looks through every tab.
- **Own window** pops the settings into a floating window; **Dock to bar**
  puts them back.
- Changes apply immediately and are saved by the plugin itself in
  `~/.local/state/omarchy-omastats/settings.json`. They are never written to
  `shell.json`, so changing a slider cannot freeze the shell with a bar
  config reload.

## Vertical bars

A vertical Omarchy bar is one icon wide. On a vertical bar OmaStats draws a
compact stack of bars with one-letter names and no numbers; the full names and
values remain available in the tooltip. Horizontal bars get the full text.

## Data sources

| Reading | Source |
| --- | --- |
| CPU load | `/proc/stat` |
| CPU temperature | `k10temp`, `zenpower` or `coretemp` hwmon |
| GPU load | `nvidia-smi`, or `gpu_busy_percent` for AMD |
| GPU temperature | `nvidia-smi`, or the amdgpu hwmon |
| Memory / swap | `/proc/meminfo` |
| Disks | `df -P -B1` |
| Network | `/sys/class/net/<iface>/statistics/{rx,tx}_bytes` |

Network rates are the difference between two readings divided by the real
elapsed time, so a delayed tick does not inflate the result.

## License

MIT. See `LICENSE`.
