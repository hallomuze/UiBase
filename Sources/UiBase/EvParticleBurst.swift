//
//  EvParticleBurst.swift
//
//  탭한 지점에서 파티클(하트, 별 등)이 화면 위로 퍼지며 사라지는 연출.
//  "좋아요 탭탭" 인터랙션 같은 곳에 여러 앱에서 재사용하기 위해 범용으로 만들었다.
//
//  사용 예:
//      @State private var bursts: [EvParticleBurstTrigger] = []
//
//      SomeTappableView()
//          .overlay { EvParticleBurstContainer(bursts: $bursts) }
//          .onTapGesture(coordinateSpace: .local) { location in
//              bursts.append(EvParticleBurstTrigger(origin: location, style: .hearts))
//          }
//

import SwiftUI

/// 파티클 하나의 모양/색/움직임 프리셋. 앱마다 다른 룩(하트, 별, 코인 등)에 재사용 가능.
public struct EvParticleStyle: Sendable {
    public var symbols: [String]
    public var colors: [Color]
    public var particleCount: Int
    public var sizeRange: ClosedRange<CGFloat>
    public var riseDistance: ClosedRange<CGFloat>
    public var spreadX: ClosedRange<CGFloat>
    public var duration: Double

    public init(
        symbols: [String] = ["heart.fill"],
        colors: [Color] = [.pink, .red],
        particleCount: Int = 6,
        sizeRange: ClosedRange<CGFloat> = 12...22,
        riseDistance: ClosedRange<CGFloat> = 50...100,
        spreadX: ClosedRange<CGFloat> = -30...30,
        duration: Double = 0.9
    ) {
        self.symbols = symbols
        self.colors = colors
        self.particleCount = particleCount
        self.sizeRange = sizeRange
        self.riseDistance = riseDistance
        self.spreadX = spreadX
        self.duration = duration
    }

    /// "사랑 가득" 하트 버스트 프리셋 — 하트 + 반짝임을 섞어 풍성한 느낌을 준다.
    public static let hearts = EvParticleStyle(
        symbols: ["heart.fill", "heart.fill", "sparkle"],
        colors: [.pink, .red, .purple, .pink.opacity(0.85)],
        particleCount: 7,
        sizeRange: 12...24,
        riseDistance: 55...110,
        spreadX: -36...36,
        duration: 0.95
    )

    /// 별/반짝임 버스트 프리셋 (포인트 적립, 성취 등에 활용 가능)
    public static let sparkles = EvParticleStyle(
        symbols: ["sparkle", "star.fill"],
        colors: [.yellow, .orange, .white],
        particleCount: 8,
        sizeRange: 10...18,
        riseDistance: 40...90,
        spreadX: -40...40,
        duration: 0.8
    )
}

/// 화면 위 특정 지점에서 발생시킬 버스트 하나. 배열에 append하고, 컨테이너가 자동으로 제거한다.
public struct EvParticleBurstTrigger: Identifiable, Sendable {
    public let id = UUID()
    public let origin: CGPoint
    public let style: EvParticleStyle

    public init(origin: CGPoint, style: EvParticleStyle = .hearts) {
        self.origin = origin
        self.style = style
    }
}

/// 탭한 지점에서 파티클이 위로 퍼지며 사라지는 1회성 버스트 하나.
public struct EvParticleBurst: View {
    let origin: CGPoint
    let style: EvParticleStyle
    let onComplete: () -> Void

    public init(origin: CGPoint, style: EvParticleStyle = .hearts, onComplete: @escaping () -> Void = {}) {
        self.origin = origin
        self.style = style
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            ForEach(0..<style.particleCount, id: \.self) { index in
                EvParticleDot(style: style, index: index)
            }
        }
        .position(origin)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + style.duration + 0.15) {
                onComplete()
            }
        }
    }
}

/// 여러 개의 버스트를 동시에 띄우기 위한 컨테이너. 완료된 버스트는 스스로 배열에서 제거된다.
public struct EvParticleBurstContainer: View {
    @Binding var bursts: [EvParticleBurstTrigger]

    public init(bursts: Binding<[EvParticleBurstTrigger]>) {
        self._bursts = bursts
    }

    public var body: some View {
        ForEach(bursts) { burst in
            EvParticleBurst(origin: burst.origin, style: burst.style) {
                bursts.removeAll { $0.id == burst.id }
            }
        }
    }
}

// MARK: - "+1" 같은 플로팅 점수 라벨 (탭탭 게임의 콤보 표시용)

/// 화면 위 특정 지점에서 발생시킬 점수 팝업 하나("+1", "+10" 등). 배열에 append하고,
/// 컨테이너가 자동으로 제거한다. EvParticleBurstTrigger와 함께 써서 하트+점수를 같이 띄울 수 있다.
public struct EvFloatingLabelTrigger: Identifiable, Sendable {
    public let id = UUID()
    public let origin: CGPoint
    public let text: String
    public let color: Color

    public init(origin: CGPoint, text: String, color: Color = .pink) {
        self.origin = origin
        self.text = text
        self.color = color
    }
}

public struct EvFloatingLabelContainer: View {
    @Binding var labels: [EvFloatingLabelTrigger]

    public init(labels: Binding<[EvFloatingLabelTrigger]>) {
        self._labels = labels
    }

    public var body: some View {
        ForEach(labels) { label in
            EvFloatingLabel(origin: label.origin, text: label.text, color: label.color) {
                labels.removeAll { $0.id == label.id }
            }
        }
    }
}

/// "+1" 같은 텍스트가 위로 떠오르며 사라지는 1회성 팝업.
public struct EvFloatingLabel: View {
    let origin: CGPoint
    let text: String
    let color: Color
    let onComplete: () -> Void

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.6

    public init(origin: CGPoint, text: String, color: Color = .pink, onComplete: @escaping () -> Void = {}) {
        self.origin = origin
        self.text = text
        self.color = color
        self.onComplete = onComplete
    }

    public var body: some View {
        Text(text)
            .font(.callout.bold())
            .foregroundStyle(color)
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: offsetY)
            .position(origin)
            .onAppear {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                    scale = 1.0
                }
                withAnimation(.easeOut(duration: 0.7)) {
                    offsetY = -40
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    onComplete()
                }
            }
    }
}

// MARK: - 파티클 하나

private struct EvParticleDot: View {
    let style: EvParticleStyle
    let index: Int

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 0.4
    @State private var rotation: Double = 0

    var body: some View {
        let symbol = style.symbols[index % style.symbols.count]
        let color = style.colors[index % style.colors.count]
        let size = CGFloat.random(in: style.sizeRange)

        Image(systemName: symbol)
            .font(.system(size: size))
            .foregroundStyle(color)
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .offset(offset)
            .onAppear {
                let delay = Double.random(in: 0...0.08)
                let rise = CGFloat.random(in: style.riseDistance)
                let drift = CGFloat.random(in: style.spreadX)
                let spin = Double.random(in: -35...35)

                withAnimation(.easeOut(duration: 0.15).delay(delay)) {
                    scale = CGFloat.random(in: 0.9...1.3)
                }
                withAnimation(.easeOut(duration: style.duration).delay(delay)) {
                    offset = CGSize(width: drift, height: -rise)
                    opacity = 0
                    rotation = spin
                }
            }
    }
}
