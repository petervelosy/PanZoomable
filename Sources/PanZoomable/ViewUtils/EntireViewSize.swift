import Foundation

public struct EntireViewSize: Equatable {

    public let contentSize: CGSize
    public let contentFitOffset: CGSize

    public init(contentSize: CGSize, contentFitOffset: CGSize) {
        self.contentSize = contentSize
        self.contentFitOffset = contentFitOffset
    }
    
}
