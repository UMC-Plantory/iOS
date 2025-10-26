//
//  RefreshView.swift
//  Plantory
//
//  Created by 주민영 on 8/6/25.
//

import SwiftUI

fileprivate struct Refreshable {
    private let PENDING_THRESHOLD: CGFloat = 10
    private let READY_THRESHOLD: CGFloat = 20
    
    enum State {
        /// The state where the user has not pulled down.
        case none
        /// The state where the user has slightly pulled down but not enough to trigger a refresh.
        case pending
        /// The state where the user has pulled down sufficiently to be ready to trigger a refresh.
        case ready
        /// The state where the user has pulled down completely, and the refresh action is actively running.
        case loading
        
        var indicatorOpacity: CGFloat {
            switch self {
            case .none:
                return 0
            case .pending:
                return 0.2
            case .ready, .loading:
                return 1
            }
        }
    }
    
    private var previousScrollOffset: CGFloat = 0
    
    var scrollViewHeight: CGFloat = 0
    
    var scrollOffset: CGFloat = 0 {
        didSet {
            previousScrollOffset = oldValue
        }
    }
    
    var differentialOffset: CGFloat {
        scrollOffset - previousScrollOffset
    }
    
    var state: State = .none
    
    mutating func updateState(for scrollOffset: CGFloat) {
        self.scrollOffset = scrollOffset

        // If in pending or ready state and canceled before reaching ready
        if state == .pending || (state == .ready && scrollOffset <= 0) {
            state = .none
        }

        // If pulled to pending state where the refresh indicator is visible
        if state == .none && scrollOffset > PENDING_THRESHOLD {
            state = .pending
        }

        // If pulled to ready state confirming the refresh
        if state == .pending && scrollOffset > READY_THRESHOLD {
            state = .ready
        }

        // If in ready state and the view is released (detected by dy), start refresh loading
        if state == .ready
            && scrollOffset > READY_THRESHOLD
            && isDragEnd(dy: differentialOffset) {
            state = .loading
        }
    }

    mutating func reset() {
        state = .none
    }

    
    /// Considered as the user has released their touch and the scroll view is returning to its original state
    /// if the change in the scroll view's offset is significantly negative.
    func isDragEnd(dy: CGFloat) -> Bool {
        return differentialOffset < -10
    }
}

extension View {
    func asIndicator() -> AnyView {
        return AnyView(self)
    }
}

struct RefreshableView<Content: View>: View {
    private let GEOMETRY_HEIGHT: CGFloat = 15
    private let START_PENDING_OFFSET: CGFloat = 10
    private let START_READY_OFFSET: CGFloat = 20
    
    @Namespace private var namespace
    
    @State private var refreshable: Refreshable = .init()
    @State private var isRefreshing: Bool = false
    @State private var isDragging: Bool = false
    
    private let reverse: Bool
    private let isLastPage: Bool
    @ViewBuilder private var content: () -> Content
    @ViewBuilder private var indicator: () -> AnyView?
    private var onRefresh: () async -> Void
    
    init(
        reverse: Bool = false,
        isLastPage: Bool = false,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder indicator: @escaping () -> AnyView? = { nil },
        onRefresh: @escaping () async -> Void
    ) {
        self.reverse = reverse
        self.isLastPage = isLastPage
        self.content = content
        self.indicator = indicator
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        ScrollView(.vertical) {
            content()
                .rotationEffect(.degrees(reverse ? 180 : 0))
                .scaleEffect(x: -1)
                .background(
                    GeometryReader { geometry in
                        DispatchQueue.main.async {
                            // Set scroll offset to 0.0 when scrolling up to maximum
                            let scrollOffset = reverse
                            ? -geometry.frame(in: .named(namespace)).maxY + refreshable.scrollViewHeight
                            : geometry.frame(in: .named(namespace)).minY
                            
                            if isDragging {
                                refreshable.updateState(for: scrollOffset) // pending/ready 판정만
                            } else {
                                refreshable.scrollOffset = scrollOffset
                                // 드래그 아니면 임의 전이 방지
                                if refreshable.state == .pending || refreshable.state == .ready {
                                    refreshable.reset()
                                }
                            }
                            
                            // If in loading state, start the refresh action
                            if refreshable.state == .loading && !isRefreshing && !isLastPage {
                                isRefreshing = true
                                Task {
                                    await onRefresh()
                                    DispatchQueue.main.async {
                                        refreshable.reset()
                                        isRefreshing = false
                                    }
                                }
                            }
                        }
                        
                        return Color.clear
                    }
                )
        }
        .coordinateSpace(name: namespace)
        .simultaneousGesture(
            DragGesture(minimumDistance: -10)
                .onChanged { _ in
                    isDragging = true
                }
                .onEnded { _ in
                    isDragging = false

                    // 손을 뗀 순간, 임계치(ready)면 바로 로딩 시작
                    if refreshable.state == .ready && !isRefreshing && !isLastPage {
                        isRefreshing = true
                        refreshable.state = .loading
                        Task {
                            await onRefresh()
                            await MainActor.run {
                                refreshable.reset()
                                isRefreshing = false
                            }
                        }
                    } else {
                        // ready까지 못 갔거나 이미 마지막 페이지면 초기화
                        if refreshable.state != .loading {
                            refreshable.reset()
                        }
                    }
                }
        )
        .background(
            GeometryReader { geometry in
                DispatchQueue.main.async {
                    if reverse {
                        refreshable.scrollViewHeight = geometry.size.height
                    }
                }
                return Color.clear
            }
        )
        .overlay {
            VStack {
                Group {
                    if let customIndicator = indicator() {
                        customIndicator
                    } else {
                        basicIndicator
                    }
                }
                .opacity(isLastPage ? 0 : refreshable.state.indicatorOpacity)
                .offset(y: refreshable.scrollOffset * 0.3)
                .animation(.linear, value: refreshable.state)
                .padding(.top, 10)
                Spacer()
            }
            .rotationEffect(.degrees(reverse ? 180 : 0))
            .scaleEffect(x: -1)
        }
        .rotationEffect(.degrees(reverse ? 180 : 0))
        .scaleEffect(x: -1)
    }
    
    private var basicIndicator: some View {
        ProgressView()
            .padding(5)
            .foregroundStyle(.gray02)
    }
}
