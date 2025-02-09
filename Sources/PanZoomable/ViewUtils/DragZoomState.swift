import Foundation

@Observable
class DragZoomState {

    //Drag:
    var isDragging: Bool = false
    var translationBaseline: CGSize = .zero
    var currentlyPerformedTranslation: CGSize = .zero
    var zoomCompensationTranslation: CGSize = .zero

    var totalTranslation: CGSize {
        translationBaseline + currentlyPerformedTranslation + zoomCompensationTranslation
    }

    func resetTranslation() {
        translationBaseline = .zero
        currentlyPerformedTranslation = .zero
    }

    //Zoom:
    var isZooming: Bool = false
    var scaleBaseline: CGFloat = 1.0
    var currentlyPerformedScale: CGFloat = 1.0

    var totalScale: CGFloat {
        scaleBaseline * currentlyPerformedScale
    }

    func resetScale() {
        scaleBaseline = 1.0
        currentlyPerformedScale = 1.0
        zoomCompensationTranslation = .zero
    }

}
