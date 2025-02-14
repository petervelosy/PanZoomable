import Foundation
import SwiftUI

public struct PanZoomable: ViewModifier {

    @Binding private var dragZoomState: DragZoomState

    public init(dragZoomState: Binding<DragZoomState>) {
        self._dragZoomState = dragZoomState
    }

    public func body(content: Content) -> some View {
        ZStack {
            // Background to make the whole area responsive to gestures, even if the manipulated object gets smaller than the entire view:
            Color.clear
              .contentShape(Rectangle())

            content
                .scaleEffect(dragZoomState.totalScale, anchor: .center)
                .offset(dragZoomState.totalTranslation)
        }
        .gesture(magnifyGesture.simultaneously(with: dragGesture))
    }

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

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                print("drag change")
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

}

public extension View {
    func panZoomable(state: Binding<DragZoomState>) -> some View {
        self.modifier(PanZoomable(dragZoomState: state))
    }
}
