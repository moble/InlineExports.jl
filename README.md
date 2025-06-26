# InlineExports.jl

[![Build Status](https://travis-ci.org/dalum/InlineExports.jl.svg?branch=master)](https://travis-ci.org/dalum/InlineExports.jl)
[![codecov](https://codecov.io/gh/dalum/InlineExports.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/dalum/InlineExports.jl)

Decentralizing exports in Julia

## Usage

`InlineExports` provides two convenience macros, `@export` and
`@public`.  The first exports names in a module at the location of
definition, as an alternative to the convention of exporting names at
the top of the module.  `@export` analyses an expression for
definitions of variables, functions or types, and inserts an
appropriate `export` statement above.  On Julia 1.11 and later,
`@public` does essentially the same thing, except that it inserts
`public` statements; on earlier versions, it does nothing.

This is illustrated by the following example:

```julia
module M

using InlineExports

@export struct T{...}
    ...
end

function f(x)
    ...
end

"""
    g(x)

...
"""
@export function g(x)
    ...
end

"""
    h(x)

...
"""
@public function h(x)
    ...
end

end
```

The module above will export the names `T` and `g`, but not `f` or `h`
— though `h` will be marked as `public` on Julia 1.11 and later.
Alternatively, definitions can be wrapped inside a block.  The example
below will export `a`, `b` and `c`, but only mark as `public` the
names `f`, `g` and `h`:

```julia
module M

using InlineExports

@export begin
    a = 1
    const b = 2
    c = 3
end

@public begin
    f = 4
    const g = 5
    h = 6
end

end
```

## Disabling inline exports

If you wish to disable all inline exports without removing all `@export` or `@public` macro calls, `InlineExports` provides a convenience submodule, `InlineExports.NoExport`.  This submodule exports a definition of the `@export` macro which returns the expression untouched.  As an example, this module does not export the function `f(x)`:
```julia
module M

using InlineExports.NoExport

# Export statements have been disabled.  This function will not be exported
@export function f(x)
    ...
end

# Public markings have been disabled.  This function will not be marked as public
@public function g(x)
    ...
end

```
