# Plum

*Specification of the language*

Plum is a small esoteric language for Project-E, made just for fun.

A Plum program can use a maximum of 255 characters, as well as a stack of 256 bytes.

## Specification

`!` print the current memory until it finds a null character

`?` ask the user for an input. Maximum of 256 characters.

`b[x]` send the memory pointer back `x` times.

`B` is a short-hand for `b01`.

`f[x]` send the memory pointer foward `x` times.

`F` is a short-hand for `f01`.

`s[x]` store `x` in the memory and move the stack pointer forward.

`S[...]` store all the following characters as bytes in memory, until it finds a `$`.

`i[x]` if memory[ptr] != 0, set the code pointer to `x`.

`P` prints the current memory pointer.

`x` is a 2 hex digits number : `[0-9a-fA-F]{2}'`

## Examples

hello world

```
Shello world$b0b!
```

a=1, b=2, c=a+b, print(c)

```
s01s02+s48+!
```
