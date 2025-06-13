import Foundation
import SwiftUI

public struct PanZoomable: ViewModifier {

    @Binding private var dragZoomState: DragZoomState
    private var entireViewSize: EntireViewSize? // Only required for auto zoom to fit.
    private var autoZoomToFit: Bool

    // Makes sure that auto zoom to fit is just performed once.
    @State private var autoZoomToFitPerformed = false

    public init(
        dragZoomState: Binding<DragZoomState>,
        entireViewSize: EntireViewSize?,
        autoZoomToFit: Bool
    ) {
        self._dragZoomState = dragZoomState
        self.entireViewSize = entireViewSize
        self.autoZoomToFit = autoZoomToFit
    }

    public func body(content: Content) -> some View {
        ZStack {
            // Background to make the whole area responsive to gestures, even if the manipulated object gets smaller than the entire view:
            Color.clear
                .contentShape(Rectangle())

            content
                .scaleEffect(dragZoomState.totalScale, anchor: .center)
                .offset(dragZoomState.totalTranslation)
                .task(id: entireViewSize) {
                    if let entireViewSize {
                        dragZoomState.contentSize = entireViewSize.contentSize
                        dragZoomState.contentFitOffset = entireViewSize.contentFitOffset
                        if autoZoomToFit && !autoZoomToFitPerformed {
                            dragZoomState.zoomToFit()
                            autoZoomToFitPerformed = true
                        }
                    }
                }
        }
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        dragZoomState.visibleAreaSize = proxy.size
                    }
            }
        }
#if !os(watchOS)
        .gesture(magnifyGesture.simultaneously(with: dragGesture))
#else
        .gesture(dragGesture)
        .gesture(doubleTapGesture)
#endif
    }

#if !os(watchOS)
    private var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !dragZoomState.isZooming {
                    dragZoomState.isZooming = true
                    // We are also translating while zooming, in order to make the center of the visible area and not the center of the transformed view the effective zoom anchor:
                    dragZoomState.isDragging = true
                }
                let scale = value.magnification
                dragZoomState.currentlyPerformedScale = scale

                // Zoom translation:
                dragZoomState.currentlyPerformedTranslation = dragZoomState.translationBaseline * scale - dragZoomState.translationBaseline
            }
            .onEnded { value in
                dragZoomState.isZooming = false
                dragZoomState.scaleBaseline *= value.magnification
                dragZoomState.currentlyPerformedScale = 1.0

                // Zoom translation:
                dragZoomState.isDragging = false
                dragZoomState.translationBaseline += dragZoomState.translationBaseline * value.magnification - dragZoomState.translationBaseline
                dragZoomState.currentlyPerformedTranslation = .zero
            }
    }
#endif

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !dragZoomState.isDragging {
                    dragZoomState.isDragging = true
                }
                let translation = value.translation
                dragZoomState.currentlyPerformedTranslation = translation // / dragZoomState.totalScale
            }
            .onEnded { value in
                dragZoomState.isDragging = false
                dragZoomState.translationBaseline += value.translation // / dragZoomState.totalScale
                dragZoomState.currentlyPerformedTranslation = .zero
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                dragZoomState.scaleBaseline *= 1.5
                dragZoomState.currentlyPerformedScale = 1.0
            }
    }

}

public extension View {
    func panZoomable(
        state: Binding<DragZoomState>,
        entireViewSize: EntireViewSize?,
        autoZoomToFit: Bool
    ) -> some View {
        self.modifier(PanZoomable(
            dragZoomState: state,
            entireViewSize: entireViewSize,
            autoZoomToFit: autoZoomToFit
        ))
    }
}
