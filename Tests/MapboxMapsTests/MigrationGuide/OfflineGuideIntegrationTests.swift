import Foundation
import MapboxMaps
import XCTest

// These tests are used for documentation purposes
// Code between //--> and //<-- is used in the offline guide. Please do not modify
// without consultation.

//swiftlint:disable empty_enum_arguments
class OfflineGuideIntegrationTests: XCTestCase {
    let tokyoCoord = CLLocationCoordinate2D(latitude: 35.682027, longitude: 139.769305)

    // Test StylePackLoadOptions
    func testDefineAStylePackage() throws {
        //-->
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           acceptExpired: false)
        //<--

        XCTAssertNotNil(options, "Invalid configuration. Metadata?")
    }

    // Test TileRegionLoadOptions
    func testDefineATileRegion() throws {
        let accessToken = try mapboxAccessToken()

        //-->
        let offlineManager = OfflineManager(resourceOptions: ResourceOptions(accessToken: accessToken))

        // 1. Create the tile set descriptor
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 0...16)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)

        // 2. Create the TileRegionLoadOptions
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(coordinate: tokyoCoord),
            descriptors: [tilesetDescriptor],
            tileLoadOptions: tileLoadOptions)
        //<--

        XCTAssertNotNil(tileRegionLoadOptions, "Invalid configuration. Metadata?")
    }

    func testStylePackMetadata() throws {
        //-->
        let metadata = ["my-key": "my-style-pack-value"]
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           metadata: metadata)
        //<--

        XCTAssertNotNil(options, "Invalid configuration. Metadata?")
    }

    func testStylePackBadMetadata() throws {
        let options = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally,
                                           metadata: "Currently restricted to JSON dictionaries and arrays")
        XCTAssertNil(options)
    }

    func testTileRegionMetadata() throws {
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        //-->
        let metadata = [
            "name": "my-region",
            "my-other-key": "my-other-tile-region-value"]
        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(coordinate: tokyoCoord),
            descriptors: [],
            metadata: metadata,
            tileLoadOptions: tileLoadOptions)
        //<--

        XCTAssertNotNil(tileRegionLoadOptions, "Invalid configuration. Metadata?")
    }

    func testLoadAndCancelStylePack() throws {

        let expectation = self.expectation(description: "style pack should be canceled")
        var accessToken: String = ""
        do {
            accessToken = try mapboxAccessToken()
        } catch {
            _ = XCTSkip("Mapbox access token not found")
        }

        let offlineManager = OfflineManager(resourceOptions: ResourceOptions(accessToken: accessToken))
        let stylePackLoadOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally)!

        let handleCancelation = {
            expectation.fulfill()
        }

        let handleFailure = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        //-->
        // These closures do not get called from the main thread. Depending on
        // the use case, you may need to use `DispatchQueue.main.async`, for
        // example to update your UI.
        let stylePackCancelable = offlineManager.loadStylePack(for: .outdoors,
                                                               loadOptions: stylePackLoadOptions) { _ in
            //
            // Handle progress here
            //
        } completion: { result in
            //
            // Handle StylePack result
            //
            switch result {
            case let .success(stylePack):
                // Style pack download finishes successfully
                print("Process \(stylePack)")

            case let .failure(error):
                // Handle error occurred during the style pack download
                if case StylePackError.canceled(_) = error {
                    handleCancelation()
                } else {
                    handleFailure(error)
                }
            }
        }

        // Cancel the download if needed
        stylePackCancelable.cancel()
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testLoadAndCancelTileRegion() throws {
        let expectation = self.expectation(description: "Tile region download should be canceled")
        var accessToken: String = ""
        do {
            accessToken = try mapboxAccessToken()
        } catch {
            _ = XCTSkip("Mapbox access token not found")
        }

        let offlineManager = OfflineManager(resourceOptions: ResourceOptions(accessToken: accessToken))

        // Create the tile set descriptor
        let options = TilesetDescriptorOptions(styleURI: .outdoors, zoomRange: 0...16)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)

        let handleCancelation = {
            expectation.fulfill()
        }

        let handleFailure = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        //-->
        let tileRegionId = "my-tile-region-id"

        // Load the tile region
        let tileLoadOptions = TileLoadOptions(criticalPriority: false,
                                              acceptExpired: true,
                                              networkRestriction: .none)

        let tileRegionLoadOptions = TileRegionLoadOptions(
            geometry: MBXGeometry(coordinate: tokyoCoord),
            descriptors: [tilesetDescriptor],
            tileLoadOptions: tileLoadOptions)!

        let tileRegionCancelable = TileStore.getInstance().loadTileRegion(
            forId: tileRegionId,
            loadOptions: tileRegionLoadOptions) { _ in
            //
            // Handle progress here
            //
        } completion: { result in
            //
            // Handle TileRegion result
            //
            switch result {
            case let .success(tileRegion):
                // Tile region download finishes successfully
                print("Process \(tileRegion)")
            case let .failure(error):
                // Handle error occurred during the tile region download
                if case TileRegionError.canceled(_) = error {
                    handleCancelation()
                } else {
                    handleFailure(error)
                }
            }
        }

        // Cancel the download if needed
        tileRegionCancelable.cancel()
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchingAllStylePacks() throws {
        let expectation = self.expectation(description: "Style packs should be fetched without error")
        var accessToken: String = ""
        do {
            accessToken = try mapboxAccessToken()
        } catch {
            _ = XCTSkip("Mapbox access token not found")
        }

        let offlineManager = OfflineManager(resourceOptions: ResourceOptions(accessToken: accessToken))

        let handleStylePacks = { (stylePacks: [StylePack]) in
            // During testing there should be no style packs
            XCTAssert(stylePacks.isEmpty)
            expectation.fulfill()
        }

        let handleStylePackError = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        let handleFailure = {
            XCTFail("API Failure")
        }

        //-->
        // Get a list of style packs that are currently available.
        offlineManager.allStylePacks { result in
            switch result {
            case let .success(stylePacks):
                handleStylePacks(stylePacks)

            case let .failure(error) where error is StylePackError:
                handleStylePackError(error)

            case .failure(_):
                handleFailure()
            }
        }
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchingAllTileRegions() throws {
        throw XCTSkip("Test occasionally fails since tileRegions can be non-empty")

        let expectation = self.expectation(description: "Style packs should be fetched without error")

        let handleTileRegions = { (tileRegions: [TileRegion]) in
            // During testing there should be no tile regions
            for region in tileRegions {
                print("region = \(region.id)")
            }
            XCTAssert(tileRegions.isEmpty)
            expectation.fulfill()
        }

        let handleTileRegionError = { (error: Error) in
            XCTFail("Download failed with \(error)")
        }

        let handleFailure = {
            XCTFail("API Failure")
        }

        //-->
        // Get a list of tile regions that are currently available.
        TileStore.getInstance().allTileRegions { result in
            switch result {
            case let .success(tileRegions):
                handleTileRegions(tileRegions)

            case let .failure(error) where error is TileRegionError:
                handleTileRegionError(error)

            case .failure(_):
                handleFailure()
            }
        }
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testDeleteStylePack() throws {
        let accessToken = try mapboxAccessToken()
        let resourceOptions = ResourceOptions(accessToken: accessToken)
        let offlineManager = OfflineManager(resourceOptions: resourceOptions)

        //-->
        offlineManager.removeStylePack(for: .outdoors)
        //<--

        let expectation = self.expectation(description: "Ambient Cache should be cleared successfully")
        let handleExpected = { (expected: MBXExpected<AnyObject, AnyObject>?) in
            guard let expected = expected else {
                XCTFail("Invalid expected result")
                return
            }
            if expected.isValue() {
                expectation.fulfill()
            } else {
                XCTFail("Delete failed: \(String(describing: expected.value))")
            }
        }

        //-->
        // Remove the existing style resources from the ambient cache using
        // CacheManager
        let cacheManager = CacheManager(options: resourceOptions)
        cacheManager.clearAmbientCache { expected in
            handleExpected(expected)
        }
        //<--

        wait(for: [expectation], timeout: 5.0)
    }

    func testDeleteTileRegions() throws {
        //-->
        TileStore.getInstance().removeTileRegion(forId: "my-tile-region-id")
        //<--

        // Note this will not remove the downloaded tile packs, instead, it will
        // just mark the tileset as not being a part of a tile region. The tiles
        // will still exist in the TileStore.
        //
        // You can fully remove tiles that have been downloaded by setting the
        // disk quota to zero. This will ensure tile regions are fully evicted.

        //-->
        TileStore.getInstance().setOptionForKey(TileStoreOptions.diskQuota, value: 0)
        //<--

        // Wait *some time* before the test calls exit()
        let expectation = self.expectation(description: "Wait...")
        _ = XCTWaiter.wait(for: [expectation], timeout: 5.0)
    }
}
