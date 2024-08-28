//
//  Untitled.swift
//  Elixirconf Voxels
//
//  Created by Carson.Katri on 8/28/24.
//

import LiveViewNative
import LiveViewNativeRealityKit
import RealityKit
import SwiftUI
import AudioToolbox

struct ElixirconfVoxelsRegistry: AggregateRegistry {
    #Registries<
        CustomizableRealityKitRegistry<EmptyEntityRegistry, OptimisticVoxelRegistry>.Registry<Self>,
        Addons.OptimisticVoxels<Self>
    >
}

extension Addons {
    @Addon
    struct OptimisticVoxels<Root: RootRegistry> {
        enum TagName: String {
            case optimisticVoxelContext = "OptimisticVoxelContext"
        }
        
        static func lookup(_ name: TagName, element: ElementNode) -> some View {
            OptimisticVoxelContext<Root>()
        }
    }
}

struct OptimisticVoxelRegistry: ComponentRegistry {
    enum TagName: String {
        case optimisticVoxel = "OptimisticVoxel"
    }
    
    static func lookup<R>(_ tag: TagName, element: ElementNode, context: Context<R>) -> Array<any Component> where R : RootRegistry {
        [
            InputTargetComponent(allowedInputTypes: .all),
            OptimisticVoxelComponent(
                event: element.attributeValue(for: "phx-click")!,
                x: try! element.attributeValue(Int.self, for: "phx-value-x"),
                y: try! element.attributeValue(Int.self, for: "phx-value-y"),
                z: try! element.attributeValue(Int.self, for: "phx-value-z"),
                rotation: try! element.attributeValue(Int.self, for: "phx-value-rotation")
            )
        ]
    }
    
    static func empty() -> Array<any Component> {
        []
    }
    
    static func reduce(accumulated: Array<any Component>, next: Array<any Component>) -> Array<any Component> {
        accumulated + next
    }
}

struct OptimisticVoxelComponent: RealityKit.Component {
    let event: String
    let x: Int
    let y: Int
    let z: Int
    let rotation: Int
}

private func playClickSound() {
    let clickSoundURL = URL(filePath: "/System/Library/Audio/UISounds/key_press_click_visionOS.caf")
    var clickSoundID: SystemSoundID = 0
    AudioServicesCreateSystemSoundID(clickSoundURL as CFURL, &clickSoundID)
    AudioServicesPlaySystemSound(clickSoundID)
}

@LiveElement
struct OptimisticVoxelContext<Root: RootRegistry>: View {
    @State private var color: SwiftUI.Color?
    
    var body: some View {
        $liveElement.children()
            .optimisticVoxelGesture(Root.self, color: color.flatMap(UIColor.init))
    }
}

extension View {
    func optimisticVoxelGesture<R: RootRegistry>(
        _: R.Type = R.self,
        color: UIColor?
    ) -> some View {
        modifier(OptimisticVoxelGestureModifier<R>(color: color))
    }
}

struct OptimisticVoxelGestureModifier<R: RootRegistry>: ViewModifier {
    @LiveContext<R> private var liveContext
    let color: UIColor?
    
    init(color: UIColor?) {
        OptimisticVoxelComponent.registerComponent()
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                SpatialTapGesture()
                    .targetedToEntity(where: .has(OptimisticVoxelComponent.self))
                    .onEnded { value in
                        print("OPTIMISTIC TAP")
                        let optimisticVoxel = value.entity.components[OptimisticVoxelComponent.self]!
                        let event = optimisticVoxel.event
                        
                        #if os(visionOS)
                        let tapLocation = value.convert(value.location3D, from: .local, to: .scene)
                        #else
                        let tapLocation = value.hitTest(point: value.location, in: .local).first?.position ?? value.entity.position
                        #endif
                        
                        let payload = [
                            "x": String(optimisticVoxel.x),
                            "y": String(optimisticVoxel.y),
                            "z": String(optimisticVoxel.z),
                            "_location": [tapLocation.x, tapLocation.y, tapLocation.z]
                        ]
                        
                        playClickSound()
                        
                        if let color {
                            createOptimisticEntity(
                                entity: value.entity,
                                optimisticVoxel: optimisticVoxel,
                                tapLocation: tapLocation,
                                color: color
                            )
                        }
                        
                        Task {
                            try await liveContext.coordinator.pushEvent(
                                type: "click",
                                event: event,
                                value: payload
                            )
                        }
                    }
            )
    }
    
    private func createOptimisticEntity(
        entity: Entity,
        optimisticVoxel: OptimisticVoxelComponent,
        tapLocation: SIMD3<Float>,
        color: UIColor
    ) {
        let scale: Float = 0.7
        let width: Float = 25
        let height: Float = 25
        let depth: Float = 25
        
        let optimisticModel = ModelEntity(
            mesh: .generateBox(size: scale / width),
            materials: [
                SimpleMaterial(color: color, roughness: .float(1), isMetallic: false)
            ]
        )
        var (tapX, tapY, tapZ) = switch Int(Double(optimisticVoxel.rotation).truncatingRemainder(dividingBy: 4)) {
        case 0:
            (tapLocation.x, tapLocation.y, tapLocation.z)
        case 1:
            (-tapLocation.z, tapLocation.y, tapLocation.x)
        case 2:
            (-tapLocation.x, tapLocation.y, -tapLocation.z)
        case 3:
            (tapLocation.z, tapLocation.y, -tapLocation.x)
        default:
            (tapLocation.x, tapLocation.y, tapLocation.z)
        }
        
        (tapX, tapY, tapZ) = (
            (tapX + (scale / 2) - (scale / width / 2)) * (width / scale),
            (tapY + (scale / 2) - (scale / height / 2)) * (height / scale),
            (tapZ + (scale / 2) - (scale / depth / 2)) * (depth / scale)
        )
        
        let offset = [
            0: tapX - Float(optimisticVoxel.x),
            1: tapY - Float(optimisticVoxel.y),
            2: tapZ - Float(optimisticVoxel.z),
        ]

        let (axis, direction) = offset.max(by: { abs($0.value) < abs($1.value) })!

        var pos = SIMD3<Float>(Float(optimisticVoxel.x), Float(optimisticVoxel.y), Float(optimisticVoxel.z))
        switch axis {
        case 0:
            pos.x = pos.x + (direction > 0 ? 1 : -1)
        case 1:
            pos.y = pos.y + (direction > 0 ? 1 : -1)
        case 2:
            pos.z = pos.z + (direction > 0 ? 1 : -1)
        default:
            fatalError()
        }
        
        optimisticModel.transform.translation = .init(
            (pos.x * (scale / width)) - (scale / 2) + (scale / width / 2),
            (pos.y * (scale / height)) - (scale / 2) + (scale / height / 2),
            (pos.z * (scale / depth)) - (scale / 2) + (scale / depth / 2)
        )
        entity.parent!.addChild(optimisticModel)
    }
}
