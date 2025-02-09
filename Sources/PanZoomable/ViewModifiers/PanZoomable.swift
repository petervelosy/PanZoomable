import Foundation
import SwiftUI

public struct PanZoomable: ViewModifier {

    @State private var dragZoomState = DragZoomState()

    public func body(content: Content) -> some View {
        ZStack {
            content
                .scaleEffect(dragZoomState.totalScale, anchor: .center)
                .offset(dragZoomState.totalTranslation)

            // Overlay to make the whole area responsive to gestures:
            Color.clear
                .contentShape(Rectangle())
            // If these are highPriorityGestures, magnify before drag works, but not vice versa.
                .highPriorityGesture(
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
                            dragZoomState.translationBaseline += dragZoomState.currentlyPerformedTranslation
                            dragZoomState.currentlyPerformedTranslation = .zero
                        }
                )
                .highPriorityGesture( // TODO: Take precedence over tapping and long-tapping nodes // TODO: Replaced this block with zoomable
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
                )
        }
    }

}

public extension View {
    func panZoomable() -> some View {
        self.modifier(PanZoomable())
    }
}
