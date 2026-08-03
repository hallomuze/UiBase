//
//  EvCalendarView.swift
//
//  재사용 가능한 SwiftUI 달력 컴포넌트.
//  각 날짜 셀에 최대 2~3개의 이벤트 타이틀을 표시할 수 있다.
//  (기본 Apple 컴포넌트는 셀 커스터마이즈가 불가능하므로 직접 구현)
//
//  사용 예:
//      EvCalendarView(items: myItems, maxTitlesPerDay: 3) { date in
//          print("탭한 날짜: \(date)")
//      }
//

import SwiftUI

// MARK: - Model

/// 달력에 표시할 이벤트 하나
public struct EvCalendarItem: Identifiable, Hashable {
    public let id: UUID
    public let date: Date        // 이벤트 날짜 (시간은 무시됨)
    public let title: String
    public let color: Color

    public init(id: UUID = UUID(), date: Date, title: String, color: Color = .blue) {
        self.id = id
        self.date = date
        self.title = title
        self.color = color
    }
}

// MARK: - Style

/// 달력 색상 커스터마이즈 (nil이면 시스템 기본 색 사용) — 앱 타입에 의존하지 않는 순수 색 토큰
public struct EvCalendarStyle {
    public var accent: Color          // 오늘 배경, 선택 보더, 월 경계 라벨
    public var text: Color            // 날짜 숫자
    public var subText: Color         // 요일, +n 표시
    public var border: Color          // 셀 보더
    public var pillBackground: Color  // 이벤트 태그 배경
    public var pillText: Color        // 이벤트 태그 텍스트
    public var selectedBackground: Color

    public init(accent: Color, text: Color, subText: Color, border: Color,
                pillBackground: Color, pillText: Color, selectedBackground: Color) {
        self.accent = accent
        self.text = text
        self.subText = subText
        self.border = border
        self.pillBackground = pillBackground
        self.pillText = pillText
        self.selectedBackground = selectedBackground
    }
}

/// 스와이프로 달을 넘기는 방향
public enum EvCalendarSwipeAxis {
    case none, horizontal, vertical
}

/// `EvCalendarView`에 "오늘로 이동" 같은 외부 명령을 보낼 때 쓰는 컨트롤러.
/// SwiftUI View는 값 타입이라 외부에서 직접 메서드를 호출할 수 없으므로, 이 클래스 인스턴스를
/// 만들어 `EvCalendarView(controller:)`에 넘긴 뒤 `controller.moveToToday()`를 호출하면 된다.
public final class EvCalendarController: ObservableObject {
    @Published var jumpToTodayToken = 0

    public init() {}

    /// 오늘이 있는 달로 즉시 이동
    public func moveToToday() {
        jumpToTodayToken += 1
    }
}

// MARK: - EvCalendarView

public struct EvCalendarView: View {
    private let items: [EvCalendarItem]
    private let maxTitlesPerDay: Int
    private let swipeAxis: EvCalendarSwipeAxis
    private let style: EvCalendarStyle?
    private let monthTitleProvider: ((Date) -> String)?
    private let headerAccessory: ((Date) -> String)?
    private let onDateTap: ((Date) -> Void)?

    @State private var displayedMonth: Date
    @State private var selectedDate: Date?
    @State private var months: [Date]
    @State private var scrollTargetID: Date?
    @ObservedObject private var controller: EvCalendarController

    private let calendar = Calendar.current
    private static let rowHeight: CGFloat = DayCell.minHeight
    private static let rowSpacing: CGFloat = 2
    private static let monthLabelHeight: CGFloat = 24
    private static let defaultPastMonths = 12
    private static let initialFutureMonths = 12
    private static let extendFutureBy = 12

    /// - Parameters:
    ///   - initialMonth: 처음 표시할 월 (기본: 이번 달)
    ///   - minStartMonth: 과거로 이동 가능한 최소 달(이 달까지만 스크롤 가능). nil이면 최소
    ///     `defaultPastMonths`(12개월) 전까지는 항상 이동 가능
    ///   - items: 표시할 이벤트 목록
    ///   - maxTitlesPerDay: 셀 하나에 표시할 최대 타이틀 개수 (2~3 권장, 기본 3)
    ///   - swipeAxis: 달 이동 스와이프 방향 (기본 세로 — 애플 캘린더처럼 여러 달이 이어붙어
    ///     연속 스크롤되다가 가장 가까운 달의 시작 지점으로 스냅됨. `.horizontal`/`.none`은
    ///     기존처럼 그리드 한 장만 보여주고 좌우 스와이프 또는 버튼으로만 이동)
    ///   - monthTitle: 헤더 좌측 타이틀 커스텀 (기본: "yyyy MMMM")
    ///   - headerAccessory: 헤더 우측에 표시할 텍스트 (예: 월 합계). nil이면 표시 안 함
    ///   - controller: "오늘로 이동" 등 외부 명령을 보낼 `EvCalendarController`. 안 넘기면
    ///     내부적으로 하나 생성(외부에서 제어할 필요 없을 때는 신경 쓰지 않아도 됨).
    ///   - onDateTap: 날짜 탭 콜백
    public init(
        initialMonth: Date = Date(),
        minStartMonth: Date? = nil,
        items: [EvCalendarItem],
        maxTitlesPerDay: Int = 3,
        swipeAxis: EvCalendarSwipeAxis = .vertical,
        style: EvCalendarStyle? = nil,
        monthTitle: ((Date) -> String)? = nil,
        headerAccessory: ((Date) -> String)? = nil,
        controller: EvCalendarController = EvCalendarController(),
        onDateTap: ((Date) -> Void)? = nil
    ) {
        self.items = items
        self.maxTitlesPerDay = max(1, maxTitlesPerDay)
        self.swipeAxis = swipeAxis
        self.style = style
        self.monthTitleProvider = monthTitle
        self.headerAccessory = headerAccessory
        self.onDateTap = onDateTap
        _controller = ObservedObject(wrappedValue: controller)

        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: initialMonth)) ?? initialMonth
        _displayedMonth = State(initialValue: start)
        _scrollTargetID = State(initialValue: start)

        let pastMonths: Int
        if let minStartMonth {
            let clampedMin = cal.date(from: cal.dateComponents([.year, .month], from: minStartMonth)) ?? minStartMonth
            let diff = cal.dateComponents([.month], from: clampedMin, to: start).month ?? Self.defaultPastMonths
            pastMonths = max(0, diff)
        } else {
            pastMonths = Self.defaultPastMonths
        }

        let initialMonths = (-pastMonths...Self.initialFutureMonths).compactMap {
            cal.date(byAdding: .month, value: $0, to: start)
        }
        _months = State(initialValue: initialMonths)
    }

    public var body: some View {
        VStack(spacing: 8) {
            header
            VStack(spacing: 0) {
                weekdayHeader
                if swipeAxis == .vertical {
                    pagingScroll
                } else {
                    monthGrid
                        .gesture(swipeGesture)
                }
            }
        }
        .onChange(of: controller.jumpToTodayToken) { _, _ in
            jumpToToday()
        }
    }

    private func jumpToToday() {
        let today = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        if swipeAxis == .vertical {
            if !months.contains(where: { calendar.isDate($0, equalTo: today, toGranularity: .month) }) {
                if today > months.last ?? today {
                    let newMonths = stride(from: 1, through: Self.extendFutureBy, by: 1).compactMap {
                        calendar.date(byAdding: .month, value: $0, to: months.last ?? today)
                    }
                    months.append(contentsOf: newMonths)
                } else {
                    return
                }
            }
            withAnimation { scrollTargetID = today }
        } else {
            withAnimation(.easeInOut) { displayedMonth = today }
        }
    }

    // MARK: 세로 페이징 스크롤 (달마다 실제 높이(5주/6주)만큼만 차지 — 남는 공백 없음)

    private var pagingScroll: some View {
        let layout = monthLayout
        return ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(months, id: \.self) { month in
                    monthBlock(for: month)
                        .id(month)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: currentViewportHeight)
        .animation(.default, value: currentViewportHeight)
        .scrollTargetBehavior(MonthSnapBehavior(offsets: layout.map(\.y)))
        .scrollPosition(id: $scrollTargetID, anchor: .top)
        .onChange(of: scrollTargetID) { _, newID in
            guard let newID else { return }
            if newID != displayedMonth { displayedMonth = newID }
            extendRangeIfNeeded(current: newID)
        }
    }

    /// 화면에 할당하는 세로 공간 = 현재 달의 실제 높이(달마다 다름). 이래야 짧은 달(5주) 아래
    /// 불필요한 빈 공간이 남지 않고, 캘린더 바로 아래 배치한 다른 뷰가 딱 붙게 된다.
    private var currentViewportHeight: CGFloat {
        Self.gridHeight(forRows: rowCount(for: displayedMonth)) + Self.monthLabelHeight
    }

    private func monthBlock(for monthStart: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(monthTitleProvider?(monthStart) ?? Self.defaultMonthTitle(monthStart, calendar: calendar))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(style.map { AnyShapeStyle($0.accent) } ?? AnyShapeStyle(.primary))
                .padding(.leading, 4)
                .frame(height: Self.monthLabelHeight, alignment: .bottomLeading)
            LazyVGrid(columns: gridColumns, spacing: Self.rowSpacing) {
                ForEach(Array(daysInGrid(for: monthStart, padTo42: false).enumerated()), id: \.offset) { _, date in
                    if let date {
                        DayCell(
                            date: date,
                            items: items(on: date),
                            maxTitles: maxTitlesPerDay,
                            isToday: calendar.isDateInToday(date),
                            isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                            style: style
                        )
                        .onTapGesture {
                            selectedDate = date
                            onDateTap?(date)
                        }
                    } else {
                        Color.clear.frame(minHeight: DayCell.minHeight)
                    }
                }
            }
        }
    }

    /// 각 달의 시작 y좌표(스냅 지점) 테이블 — 실제 렌더 없이 달력 수학만으로 미리 계산
    private var monthLayout: [(month: Date, y: CGFloat)] {
        var result: [(Date, CGFloat)] = []
        var y: CGFloat = 0
        for month in months {
            result.append((month, y))
            y += Self.monthLabelHeight + Self.gridHeight(forRows: rowCount(for: month))
        }
        return result
    }

    /// 스크롤이 미래 방향 끝에 가까워지면 달을 더 이어붙인다(과거 방향은 초기/`minStartMonth`
    /// 범위로 고정 — 요청한 "최소 N개월 전까지"는 초기 배열에 이미 포함돼 있으므로 충분함)
    private func extendRangeIfNeeded(current: Date) {
        guard let lastMonth = months.last,
              let idx = months.firstIndex(where: { calendar.isDate($0, equalTo: current, toGranularity: .month) })
        else { return }
        let remaining = months.count - 1 - idx
        guard remaining <= 3 else { return }
        let newMonths = (1...Self.extendFutureBy).compactMap {
            calendar.date(byAdding: .month, value: $0, to: lastMonth)
        }
        months.append(contentsOf: newMonths)
    }

    // MARK: 좌우 스와이프 (좌: 다음 달, 우: 이전 달) — .horizontal 모드 전용

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard swipeAxis == .horizontal else { return }
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical) else { return }
                withAnimation(.easeInOut) {
                    moveMonth(by: horizontal < 0 ? 1 : -1)
                }
            }
    }

    // MARK: 상단 헤더 (이전/다음 달 이동 + 우측 액세서리)

    private var header: some View {
        HStack(spacing: 12) {
            Button { jump(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Text(monthTitle)
                .font(.headline)
            Button { jump(by: 1) } label: {
                Image(systemName: "chevron.right")
            }
            Spacer()
            if let headerAccessory {
                Text(headerAccessory(displayedMonth))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(style.map { AnyShapeStyle($0.subText) }
                                     ?? AnyShapeStyle(.secondary))
            }
        }
        .padding(.horizontal, 4)
        .buttonStyle(.plain)
        .foregroundStyle(style.map { AnyShapeStyle($0.text) } ?? AnyShapeStyle(.primary))
    }

    private func jump(by value: Int) {
        guard let target = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        if swipeAxis == .vertical {
            guard months.contains(where: { calendar.isDate($0, equalTo: target, toGranularity: .month) }) else { return }
            withAnimation { scrollTargetID = target }
        } else {
            withAnimation(.easeInOut) { moveMonth(by: value) }
        }
    }

    // MARK: 요일 헤더

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(style.map { AnyShapeStyle($0.subText) }
                                     ?? AnyShapeStyle(.secondary))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: 날짜 그리드 (.horizontal / .none 모드 — 그리드 한 장)

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    }

    private var monthGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: Self.rowSpacing) {
            ForEach(Array(daysInGrid(for: displayedMonth, padTo42: true).enumerated()), id: \.offset) { _, date in
                if let date {
                    DayCell(
                        date: date,
                        items: items(on: date),
                        maxTitles: maxTitlesPerDay,
                        isToday: calendar.isDateInToday(date),
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        style: style
                    )
                    .onTapGesture {
                        selectedDate = date
                        onDateTap?(date)
                    }
                } else {
                    Color.clear
                        .frame(minHeight: DayCell.minHeight)
                }
            }
        }
    }

    // MARK: - Helpers

    private var monthTitle: String {
        monthTitleProvider?(displayedMonth) ?? Self.defaultMonthTitle(displayedMonth, calendar: calendar)
    }

    private static func defaultMonthTitle(_ month: Date, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: month)
    }

    /// 요일 심볼을 calendar.firstWeekday 기준으로 정렬
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    /// 해당 월의 날짜들. padTo42면 6주(42칸) 고정(.horizontal/.none 모드용), 아니면 실제
    /// 주 수(5주 또는 6주)만큼만 반환해 달마다 그리드 높이가 다르게 한다.
    private func daysInGrid(for monthStart: Date, padTo42: Bool) -> [Date?] {
        guard let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in dayRange {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }

        let totalCells = padTo42 ? 42 : ((days.count + 6) / 7) * 7
        if days.count < totalCells {
            days.append(contentsOf: Array(repeating: nil, count: totalCells - days.count))
        }
        return days
    }

    private func rowCount(for monthStart: Date) -> Int {
        daysInGrid(for: monthStart, padTo42: false).count / 7
    }

    private static func gridHeight(forRows rows: Int) -> CGFloat {
        CGFloat(rows) * rowHeight + CGFloat(max(0, rows - 1)) * rowSpacing
    }

    private func items(on date: Date) -> [EvCalendarItem] {
        items.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

// MARK: - 달 스냅 (비균일 페이징) — 달마다 높이가 달라 커스텀 ScrollTargetBehavior로 처리

private struct MonthSnapBehavior: ScrollTargetBehavior {
    let offsets: [CGFloat]   // 오름차순 정렬된 각 달의 시작 y좌표

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        guard !offsets.isEmpty else { return }
        let proposedY = target.rect.minY
        var nearest = offsets[0]
        var smallestDiff = abs(offsets[0] - proposedY)
        for y in offsets {
            let diff = abs(y - proposedY)
            if diff < smallestDiff {
                smallestDiff = diff
                nearest = y
            }
        }
        target.rect.origin.y = nearest
    }
}

// MARK: - DayCell (커스텀 날짜 셀)

private struct DayCell: View {
    static let minHeight: CGFloat = 64

    let date: Date
    let items: [EvCalendarItem]
    let maxTitles: Int
    let isToday: Bool
    let isSelected: Bool
    let style: EvCalendarStyle?

    private var dayNumber: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    // style 미지정 시 기존 시스템 색 유지
    private var todayFill: Color { style?.accent ?? .red }
    private var numberColor: Color { style?.text ?? .primary }
    private var selectedBorder: Color { style?.accent ?? .accentColor }
    private var normalBorder: Color { style?.border ?? Color.gray.opacity(0.2) }
    private var selectedFill: Color {
        style?.selectedBackground ?? Color.accentColor.opacity(0.15)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(dayNumber)
                .font(.caption)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? Color.white : numberColor)
                .frame(width: 20, height: 20)
                .background(isToday ? todayFill : Color.clear, in: Circle())

            ForEach(items.prefix(maxTitles)) { item in
                Text(item.title)
                    .font(.system(size: 9))
                    .lineLimit(1)
                    .foregroundStyle(style?.pillText ?? .white)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(style?.pillBackground ?? item.color,
                                in: RoundedRectangle(cornerRadius: 3))
            }

            // 표시 못한 이벤트 개수
            if items.count > maxTitles {
                Text("+\(items.count - maxTitles)")
                    .font(.system(size: 8))
                    .foregroundStyle(style.map { AnyShapeStyle($0.subText) }
                                     ?? AnyShapeStyle(.secondary))
            }

            Spacer(minLength: 0)
        }
        .padding(2)
        .frame(maxWidth: .infinity, minHeight: Self.minHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? selectedFill : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? selectedBorder : normalBorder,
                        lineWidth: isSelected ? 2 : 0.5)
        )
        .contentShape(Rectangle())
    }
}
