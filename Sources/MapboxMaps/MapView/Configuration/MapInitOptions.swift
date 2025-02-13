import Foundation

@objc public protocol MapInitOptionsProvider {
    func mapInitOptions() -> MapInitOptions
}

/// Options used when initializing `MapView`.
///
/// Contains the `ResourceOptions`, `MapOptions` (including `GlyphsRasterizationOptions`)
/// that are required to initialize a `MapView`.
public final class MapInitOptions: NSObject {

    /// Associated `ResourceOptions`
    public let resourceOptions: ResourceOptions

    /// Associated `MapOptions`
    public let mapOptions: MapOptions

    /// Default style URI for initializing the map
    public let styleURI: StyleURI?

    /// Default camera options for initializing the map
    public let cameraOptions: CameraOptions?

    /// Initializer. The default initializer, i.e. `MapInitOptions()` will use
    /// the default `CredentialsManager` to use the current shared access token.
    ///
    /// - Parameters:
    ///   - resourceOptions: `ResourceOptions`; default creates an instance
    ///         using `CredentialsManager.default`
    ///   - mapOptions: `MapOptions`; see `GlyphsRasterizationOptions` for the default
    ///         used for glyph rendering.
    ///   - cameraOptions: `CameraOptions` to be applied to the map, overriding
    ///         the default camera that has been specified in the style.
    ///   - styleURI: Style URI for the map to load. Defaults to `.streets`, but
    ///         can be `nil`.
    public init(resourceOptions: ResourceOptions = ResourceOptions(accessToken: CredentialsManager.default.accessToken ?? ""),
                mapOptions: MapOptions = MapOptions(constrainMode: .heightOnly),
                cameraOptions: CameraOptions? = nil,
                styleURI: StyleURI? = .streets) {
        self.resourceOptions = resourceOptions
        self.mapOptions      = mapOptions
        self.cameraOptions   = cameraOptions
        self.styleURI        = styleURI
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapInitOptions else {
            return false
        }

        return
            (resourceOptions == other.resourceOptions) &&
            (mapOptions == other.mapOptions) &&
            (cameraOptions == other.cameraOptions) &&
            (styleURI == other.styleURI)
    }

    /// :nodoc:
    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(resourceOptions)
        hasher.combine(mapOptions)
        hasher.combine(cameraOptions)
        hasher.combine(styleURI)
        return hasher.finalize()
    }
}
