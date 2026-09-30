import XCTest
@testable import UiBase

final class UiBaseTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(UiBase().text, "Hello, World!")
    }

    func testCalendarMetricsPreserveLegacyDefaults() {
        let metrics = EvCalendarMetrics.standard

        XCTAssertEqual(metrics.dayCellHeight, 64)
        XCTAssertFalse(metrics.usesFixedDayCellHeight)
        XCTAssertNil(metrics.dayNumberSize)
        XCTAssertEqual(metrics.dayNumberCircleSize, 20)
        XCTAssertEqual(metrics.eventTextSize, 9)
        XCTAssertEqual(metrics.overflowTextSize, 8)
        XCTAssertEqual(metrics.cellPadding, 2)
        XCTAssertEqual(metrics.cellCornerRadius, 6)
        XCTAssertEqual(metrics.rowSpacing, 2)
        XCTAssertEqual(metrics.columnSpacing, 2)
        XCTAssertEqual(metrics.eventHorizontalPadding, 3)
        XCTAssertEqual(metrics.eventVerticalPadding, 1)
        XCTAssertEqual(metrics.eventCornerRadius, 3)
        XCTAssertEqual(metrics.cellContentSpacing, 2)
    }

    func testCalendarMetricsClampInvalidValues() {
        let metrics = EvCalendarMetrics(
            dayCellHeight: 0,
            dayNumberSize: -1,
            rowSpacing: -2,
            columnSpacing: -3
        )

        XCTAssertEqual(metrics.dayCellHeight, 1)
        XCTAssertEqual(metrics.dayNumberSize, 1)
        XCTAssertEqual(metrics.rowSpacing, 0)
        XCTAssertEqual(metrics.columnSpacing, 0)
    }
}
