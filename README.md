# CamelMR: A MapReduce-style CSV Processor in OCaml

**CamelMR** is a simple MapReduce-style program written in OCaml, designed to process CSV files. It reads a given CSV file, sums up values based on a specified key (e.g., "Finding Type"), and then prints the results, sorted by the sum in descending order.

## Prerequisites
- OCaml
- Dune build system
- `csv` OCaml library
- `parmap` OCaml library
- `alcotest` OCaml library

## Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd <repository-dir>
```

2. Install the required libraries:

```bash
opam install csv parmap dune alcotest
```

3. Build the project:

```bash
dune build
```

## Usage

Run the program with the following command:

```bash
dune exec -- CamelMR <path_to_csv_file> <column_name_to_aggregate> (optional)<mode>
```

Replace `<path_to_csv_file>` with the path to your desired CSV file.

For example:

```bash
dune exec -- CamelMR data/sample.csv Name
```

You can also experiment with `simple`, `parallel` and `mapreduce`(default) runtimes that are provided.

**By default the runtime is `mapreduce`**

They ultimately do the same, but with different resource usages and can affect how long the script takes to run
```bash
dune exec -- CamelMR data/sample.csv Name simple
```

You can also run the tests in `src/test_camelmr.ml` with 

```bash
dune exec -- testCamelMR
```

## How it Works

1. **Map**: The program reads the CSV file line by line, extracts the key (based on the specified column name like "Finding Type"), and its associated value.
2. **Shuffle & Group**: It then groups the results by key.
3. **Reduce**: For each key, it sums up its values in parallel.
4. **Sort & Print**: Finally, it sorts the keys based on their summed values in descending order and prints the results.

## Customization

To focus on a different key or make other changes, modify the `main.ml` file in the `src` directory and recompile.