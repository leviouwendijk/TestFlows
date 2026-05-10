### Background

Developed because I encountered problems with Command Line Tools when trying to use or import native testing targets (swift-testing, XCTests).

### Import

Add the dependency:

```swift
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),
    ],
```

Set the executable target:

```swift
    targets: [
        // …
        .executableTarget(
            name: "AgenticTestFlows",
            dependencies: [
                "Agentic",
                .product(name: "TestFlows", package: "TestFlows"),
            ]
        ),
    ]
```

Then it keeps this nicely organized:

```
Sources/
    ├── Agentic/…
    └── AgenticTestFlows/…
```

Configure the binary product how you like, then reference the target name:

```swift
    products: [
        // …
        .executable(
            name: "agtest",
            targets: ["AgenticTestFlows"]
        ),
    ],
```

Now you can do `swift run agtest` to execute it.

Note: ensure you add the platform requirement too:

```swift
    platforms: [
        .macOS(.v13)
    ],
```

Which as a result looks something like this:

```swift
// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Agentic",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Agentic",
            targets: ["Agentic"]
        ),
        .executable(
            name: "agtest",
            targets: ["AgenticTestFlows"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/TestFlows.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "Agentic",
            dependencies: [],
        ),
        .executableTarget(
            name: "AgenticTestFlows",
            dependencies: [
                "Agentic",
                .product(name: "TestFlows", package: "TestFlows"),
            ]
        ),
    ]
)
```

