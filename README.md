# OCaml MapReduce Framework

A versatile MapReduce engine implemented in OCaml, designed with flexibility in mind. This project uniquely allows users
to define mapper and reducer functions in any programming language, providing a universal interface to harness the power
of the MapReduce paradigm.

## Introduction

MapReduce is a popular programming model for processing and generating big data. This framework, though implemented in
OCaml, allows both mapper and reducer functions to be written in any language, making it versatile for various
applications.

## Features

- Implemented in OCaml: Benefit from the functional programming aspects and strong type system of OCaml, ensuring a
  robust and efficient engine.
- Language Agnostic Mappers and Reducers: Users are not restricted to a specific language for their Map and Reduce
  functions. This freedom allows for greater flexibility and lets developers use tools they are most familiar with.
- Single Node Operations: Currently designed for single-node, in-memory operations, making it perfect for educational
  purposes, testing, or lightweight data processing tasks.

## Getting Started

1. Setting Up:
    - Clone this repository: `git clone https://github.com/Andree37/CamelMR`
2. Writing Mappers and Reducers:
    - Ensure your mapper and reducer scripts/programs read input data from stdin and write results to stdout.
    - The scripts/programs can be written in any language, but they must be executable from the command line.
3. Running Your MapReduce Job:
    - Use the provided interface to specify your mapper and reducer executables and input data.
    - Execute the engine to see the results!

## Future Improvements

- Add distributed processing capabilities.
- Incorporate fault tolerance and recovery mechanisms.
- Enhance performance and optimize for larger datasets.

## Contribution

Contributions are always welcome! Please read the contribution guidelines first.

## License

This project is licensed under the MIT License. See the LICENSE file for details.