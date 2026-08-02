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
    public var accent: Color          // 오늘 배경, 선택 보더
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

// MARK: - EvCalendarView

public struct EvCalendarView: View {
    private let items: [EvCalendarItem]
    private let maxTitlesPerDay: Int
    private let style: EvCalendarStyle?
    private let monthTitleProvider: ((Date) -> String)?
    private let headerAccessory: ((Date) -> String)?
    private let onDateTap: ((Date) -> Void)?

    @State private var displayedMonth: Date
    @State private var selectedDate: Date?

    private let calendar = Calendar.current

    /// - Parameters:
    ///   - initialMonth: 처음 표시할 월 (기본: 이번 달)
    ///   - items: 표시할 이벤트 목록
    ///   - maxTitlesPerDay: 셀 하나에 표시할 최대 타이틀 개수 (2~3 권장, 기본 3)
    ///   - monthTitle: 헤더 좌측 타이틀 커스텀 (기본: "yyyy MMMM")
    ///   - headerAccessory: 헤더 우측에 표시할 텍스트 (예: 월 합계). nil이면 표시 안 함
    ///   - onDateTap: 날짜 탭 콜백
    public init(
        initialMonth: Date = Date(),
        items: [EvCalendarItem],
        maxTitlesPerDay: Int = 3,
        style: EvCalendarStyle? = nil,
        monthTitle: ((Date) -> String)? = nil,
        headerAccessory: ((Date) -> String)? = nil,
        onDateTap: ((Date) -> Void)? = nil
    ) {
        self.items = items
        self.maxTitlesPerDay = max(1, maxTitlesPerDay)
        self.style = style
        self.monthTitleProvider = monthTitle
        self.headerAccessory = headerAccessory
        self.onDateTap = onDateTap
        _displayedMonth = State(initialValue: initialMonth)
    }

    public var body: some View {
        VStack(spacing: 8) {
            header
            weekdayHeader
            monthGrid
        }
        .padding(.horizontal, 8)
    }

    // MARK: 상단 헤더 (이전/다음 달 이동 + 우측 액세서리)

    private var header: some View {
        HStack(spacing: 12) {
            Button { moveMonth(by: -1) } label: {
                Image(systemName: "chevron.left")
            }
            Text(monthTitle)
                .font(.headline)
            Button { moveMonth(by: 1) } label: {
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

    // MARK: 날짜 그리드

    private var monthGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(daysInMonthGrid.enumerated()), id: \.offset) { _, date in
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
        if let monthTitleProvider {
            return monthTitleProvider(displayedMonth)
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "yyyy MMMM"
        return formatter.string(from: displayedMonth)
    }

    /// 요일 심볼을 calendar.firstWeekday 기준으로 정렬
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    /// 해당 월의 날짜들. 첫 주 앞의 빈 칸은 nil.
    private var daysInMonthGrid: [Date?] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
            let dayRange = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in dayRange {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }
        return days
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
