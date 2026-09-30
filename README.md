# UiBase

A description of this package.

## EvCalendarView layout metrics

`EvCalendarView` keeps its legacy layout by default. Apps that need a denser or
larger calendar can inject `EvCalendarMetrics` without changing UiBase's device
policy.

```swift
let metrics = EvCalendarMetrics(
    dayCellHeight: calculatedCellWidth,
    usesFixedDayCellHeight: true,
    dayNumberSize: 15,
    dayNumberCircleSize: 26,
    eventTextSize: 11,
    rowSpacing: 4,
    columnSpacing: 4
)

EvCalendarView(
    items: items,
    metrics: metrics,
    onDateTap: { date in
        // Handle selection.
    }
)
```

The default value, `.standard`, preserves the original 64-point day cells and
all existing spacing and font sizes. A tablet app can measure its own calendar
container, divide the available width into seven columns, and pass that width
as `dayCellHeight` to produce square cells.
