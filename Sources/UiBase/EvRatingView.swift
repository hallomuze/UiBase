import SwiftUI

// MARK: - 재사용 컴포넌트: 1~N 별점

public struct EvRatingView: View {
    @Binding public var rating: Int
    public var isEditable: Bool
    public var maxRating: Int
    public var filledColor: Color
    public var emptyColor: Color

    public init(rating: Binding<Int>, isEditable: Bool = true, maxRating: Int = 5,
                filledColor: Color, emptyColor: Color) {
        self._rating = rating
        self.isEditable = isEditable
        self.maxRating = maxRating
        self.filledColor = filledColor
        self.emptyColor = emptyColor
    }

    public var body: some View {
        HStack {
            ForEach(1...maxRating, id: \.self) { value in
                Image(systemName: value <= rating ? "star.fill" : "star")
                    .foregroundStyle(value <= rating ? filledColor : emptyColor)
                    .onTapGesture {
                        if isEditable { rating = value }
                    }
            }
        }
    }
}
