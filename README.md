# Fennelate

Fennelate is a proof of concept for a macro processor based on
s-expressions.  I was motivated to write it as I was looking for a
light weight pre-processor for building static websites at the
command line, but there is no reason not to use it as a general
purpose macro processor.

As its name suggests, Fennelate utilises the [Fennel programming
language](https://fennel-lang.org) for its processing engine.
Fennnel was chosen for its light footprint and for its ability to
be embedded in Lua (and therefore C).

As a bonus for me, Fennel is also syntactically similar to the
Clojure programming language, which I often use for server-side web
development, but this was not a main motivator.

## Building

Build by running `make` at the root of the project directory.
This will produce the `fnlate` binary.

Fennelate requires `liblua` and `lua5.4` C headers to be pre-installed
on your system.  You may need to modify their paths for your system.

## Usage

Fennelate is run using the command `fnlate`.  It takes no arguements.
It just takes plaintext from `stdin` and puts to `stdout`. 

A typical usage pipeline might look something like the following:

```
cat src/index.html.fnlt | fnlate | tidy > build/index.html
```

Any text between the `<? ` and ` ?>` tags is evaluated as a Fennel
expression, the output of which replaces the expression, including
the tags themselves.

In its current implementation, the expression must be separated from
the tags by whitespace.

Examples of usage will follow.  For now, read the source code if you
want to know how the language works.
