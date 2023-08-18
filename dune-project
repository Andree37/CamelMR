(lang dune 3.10)

(name CamelMR)

(generate_opam_files true)

(source
 (github Andree37/CamelMR))

(authors "Andre Ribeiro")

(maintainers "Andre Ribeiro")

(license MIT)

(documentation https://url/to/documentation)

(package
 (name CamelMR)
 (synopsis "A versatile MapReduce engine implemented in OCaml")
 (description "This project uniquely allows users
               to define mapper and reducer functions in any programming language, providing a universal interface to harness the power
               of the MapReduce paradigm.")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
