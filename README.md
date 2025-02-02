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
    <a href="https://github.com/Carthage/Carthage">
        <img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
    </a> 
</p>

Kafka is an advanced Natural Language Processing library written in Swift. It's built for speed, simplicity, and easy integration into apps. Kafka currently provides linear **neural network models** for tagging and parsing, with pretrained models and word vectors. It's commercial open-source software, released under the MIT license.

💫 **Version 0.1 out now!**
[Check out the release notes here.](https://github.com/questo-ai/kafka/releases)

## Documentation

| Documentation      |                                                                |
| ------------------ | -------------------------------------------------------------- |
| [Data]             | Contains word embeddings, a list of POS tags, and a list of dependency tags.
| [DependencyParser] | Dependency Parser parses Docs for dependency relations between word tokens.
| [Doc]              | A container for accessing linguistic annotations.
| [Sentence]              | A class that holds relevant information for a single sentence.
| [Token]              | A class that holds relevant information for a single token.
| [Kafka]            | An interface for the library.
| [Math]             | Math holds helper functions for common mathematical computations.
| [PartialParse]     | A PartialParse is a snapshot of an arc-standard dependency parse.
| [Transducer]       | Holds methods for conversions between data types.
| [Internal Practices]       | Some documentation for our internal practises.


[Data]: docs/source/Data.md
[DependencyParser]: docs/source/DependencyParser.md
[Doc]: docs/source/Doc.md
[Sentence]: docs/source/Sentence.md
[Token]: docs/source/Token.md
[Kafka]: docs/source/Kafka.md
[Math]: docs/source/Math.md
[PartialParse]: docs/source/PartialParse.md
[Transducer]: docs/source/Transducer.md
[Internal Practices]: docs/source/Internal_Practices.md

## Features
- [x] Non-destructive tokenization
- [x] pretrained models and word vectors
- [x] State-of-the-art speed
- [x] Part-of-speech tagging
- [x] Dependency parsing
- [ ] Named entity recognition
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

#### Parsing
```swift
let doc = Doc(string: "Memories warm you up from the inside. But they also tear you apart.") // From Haruki Murakami, Kafka on the Shore
for sentence in doc.sentences {
    for token in sentence {
        /// The dependency arcs are stored as properties of the Tokens.
        /// Arcs are (headIndex: Int, index: Int, tag: String) signifying
        /// the dependency relation `headIndex ->tag index`, where headIndex
        /// is the index of the head word, index is the index of the dependant,
        /// and tag is a string representing the dependency relation label.
        print(token.text, token.tag, head.text)
    }
}
```
#### Accessing Token subtrees, lefts and rights
```swift
/// Kafka dependency graphs build a hierarchy of tokens in a sentence.
/// e.g Memories warm you up from the inside.
///          warm ___________
///         /    \     \     \
/// Memories     you   up    from
///                              \
///                            inside.
///                          /
///                        the

/// token.lefts is of type [Token]
for left in token.lefts {
    /// you can manually access the String representation 
    /// of a given token by using the token.text property
    print(left.text)
}

/// token.rights is of type [Token]
for right in token.rights {
    /// Kafka classes conform to the CustomStringConvertible
    /// protocol, so you can also just print them directly
    print(right)
}

/// token.subtree is of type [Token]
for node in token.subtree {
    print(node.text)
}
```
