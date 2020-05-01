<div align="center">
    <br>
    <img src="https://github.com/questo-ai/kafka/raw/master/docs/Header.jpg" width="600"/>
    <hr/>
</div>
<p align="center">
    <a href="#">
        <img alt="License" src="https://github.com/questo-ai/kafka/workflows/CI/badge.svg">
    </a>
    <a href=#"">
        <img alt="License" src="https://img.shields.io/badge/platform-iOS-violet.svg">
    </a>
    <a href="#">
        <img alt="License" src="https://img.shields.io/badge/language-swift-orange.svg">
    </a>
    <a href="https://github.com/questo-ai/kafka/blob/master/LICENSE">
        <img alt="License" src="https://img.shields.io/badge/License-MIT-blue.svg">
    </a>
</p>

Kafka is an advanced Natural Language Processing library written in Swift. It's built for speed, simplicity, and easy integration into apps. Kafka currently provides linear **neural network models** for tagging and parsing, with pretrained models and word vectors. It's commercial open-source software, released under the MIT license.

💫 **Version 0.1 out now!**
[Check out the release notes here.](https://github.com/questo-ai/kafka/releases)

## Documentation

| Documentation      |                                                                |
| ------------------ | -------------------------------------------------------------- |
| [Data]             | Contains word embeddings, a list of POS tags, and a list of dependency tags
| [DependencyParser] | Dependency Parser parses Docs for dependency relations between word tokens
| [Doc]              | A container for accessing linguistic annotations.
| [Kafka]            | An interface for the library
| [Math]             | Math holds helper functions for common mathematical computations
| [PartialParse]     | A PartialParse is a snapshot of an arc-standard dependency parse
| [Transducer]       | Holds methods for conversions between data types

[Data]: https://github.com/questo-ai/kafka/docs/Data.md
[DependencyParser]: https://github.com/questo-ai/kafka/docs/DependencyParser.md
[Doc]: https://github.com/questo-ai/kafka/docs/Doc.md
[Kafka]: https://github.com/questo-ai/kafka/docs/Kafka.md
[Math]: https://github.com/questo-ai/kafka/docs/Math.md
[PartialParse]: https://github.com/questo-ai/kafka/docs/PartialParse.md
[Transducer]: https://github.com/questo-ai/kafka/docs/Transducer.md

## Features
- [x] Non-destructive tokenization
- [x] Named entity recognition
- [x] pretrained statistical models and word vectors
- [x] State-of-the-art speed
- [x] Easy deep learning integration
- [x] Part-of-speech tagging
- [x] Labelled dependency parsing
- [ ] Syntax-driven sentence segmentation
- [ ] Built in visualizers for syntax and NER
## Requirements
iOS 12.0+ | macOS 10.14+ | Mac Catalyst 13.0+ | tvOS 12.0+ | watchOS 5.0+
## Integration
#### CocoaPods

You can use [CocoaPods](http://cocoapods.org/) to install `Kafka` by adding it to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
    pod 'Kafka'
end
```

#### Carthage
You can use [Carthage](https://github.com/Carthage/Carthage) to install `Kafka` by adding it to your `Cartfile`:

```
github "questo-ai/kafka"
```

If you use Carthage to build your dependencies, make sure you have added `Kafka.framework` to the "Linked Frameworks and Libraries" section of your target, and have included them in your Carthage framework copying build phase.

## Usage
#### Initialization

```swift
import Kafka
```

```swift
// Initialise a dependency parser
let parser = DependencyParser()
```

#### Parsing

```swift
let doc = Doc(string: "Memories warm you up from the inside. But they also tear you apart.") // From Haruki Murakami, Kafka on the Shore
let result = parser.predict(text: doc)
```
#### Use dependency data
```swift
/// The dependency arcs is stored as a property of Doc, with type [[(Int, Int, String)]]
/// arcs is a list of triples (idx_head, idx_dep, deprel) signifying the
/// dependency relation `idx_head ->_deprel idx_dep`, where idx_head is
/// the index of the head word, idx_dep is the index of the dependant,
/// and deprel is a string representing the dependency relation label.
print(result.arcs)
```
