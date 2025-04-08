import Foundation

@Observable
public class DragZoomState {

    // Drag:
    var isDragging: Bool = false
    var translationBaseline: CGSize = .zero
    var currentlyPerformedTranslation: CGSize = .zero
    var zoomCompensationTranslation: CGSize = .zero

    public init() {}

    public var totalTranslation: CGSize {
        translationBaseline + currentlyPerformedTranslation + zoomCompensationTranslation
    }

    public func setTranslation(_ translation: CGSize) {
        translationBaseline = translation
    }

    public func resetTranslation() {
        translationBaseline = .zero
        currentlyPerformedTranslation = .zero
    }

    // Zoom:
    var isZooming: Bool = false
    var scaleBaseline: CGFloat = 1.0
    var currentlyPerformedScale: CGFloat = 1.0

    public var totalScale: CGFloat {
        scaleBaseline * currentlyPerformedScale
    }

    public func resetScale() {
        scaleBaseline = 1.0
        currentlyPerformedScale = 1.0
        zoomCompensationTranslation = .zero
    }

    // Fit:
    public var visibleAreaSize: CGSize?
    public var contentSize: CGSize?
    public var contentFitOffset: CGSize?

    public func zoomToFit() {
        if let visibleAreaSize, let contentSize, let contentFitOffset {
            // TODO: ZoomPadding parameter
            let widthRatio = contentSize.width / visibleAreaSize.width
            let heightRatio = contentSize.height / visibleAreaSize.height
            let maxRatio = max(widthRatio, heightRatio)

            scaleBaseline = 1 / maxRatio
            currentlyPerformedScale = 1.0
            zoomCompensationTranslation = .zero

            translationBaseline = contentFitOffset * scaleBaseline
            currentlyPerformedTranslation = .zero
        }
    }

}
