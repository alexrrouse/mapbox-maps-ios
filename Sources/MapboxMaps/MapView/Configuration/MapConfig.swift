import Foundation

/// `MapConfig` is the structure used to configure the map with a set of capabilities
public struct MapConfig: Equatable {
    
    public var render: RenderOptions = RenderOptions()

    public var annotations: AnnotationOptions = AnnotationOptions()

    public init() {}
}
