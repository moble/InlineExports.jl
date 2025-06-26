module InlineExports

import Base: @__doc__

include("NoExport.jl")

export @export, @public

quote
    """
        @export

    Return the expression with all bindings exported.

    ```
    julia> module M
               using InlineExports
               @export begin
                   const a = 2
                   abstract type S <: Number end
                   struct T <: S
                       val
                   end
               end
               @export f(x::TT) where {TT<:S} = x.val^2
           end
    M

    julia> using .M

    julia> f(T(a))
    4
    ```
    """
    macro $(Symbol("export"))(expr::Expr)
        return handle(expr, :export)
    end
end |> eval

if VERSION < v"1.11"
    using .NoExport: @public
else
    """
        @public

    Return the expression with all bindings marked as public.

    ```
    julia> module M
               using InlineExports
               @public begin
                   const a = 2
                   abstract type S <: Number end
                   struct T <: S
                       val
                   end
               end
               @public f(x::TT) where {TT<:S} = x.val^2
           end
    M

    julia> using .M

    julia> M.f(M.T(M.a))
    4
    ```
    """
    macro public(expr::Expr)
        return handle(expr, :public)
    end
end

function handle(expr::Expr, export_or_public::Symbol)
    r = handle(expr)
    ep = if r isa Symbol
        Expr(export_or_public, r)
    else
        Expr(export_or_public, r...)
    end
    return esc(quote
        $ep
        Base.@__doc__ $expr
    end)
end

handle(::Any) = nothing
handle(x::Symbol) = x
handle(expr::Expr) = handle(Val(expr.head), expr)

handle(::Val{:block}, expr) = filter(x -> x !== nothing, map(handle, expr.args))
handle(::Val{:const}, expr) = handle(expr.args[1])
handle(::Val{:(::)}, expr) = handle(expr.args[1])
handle(::Val{:(=)}, expr) = handle(expr.args[1])
handle(::Val{:function}, expr) = handle(expr.args[1])
handle(::Val{:where}, expr) = handle(expr.args[1])
handle(::Val{:macro}, expr) = Symbol("@", handle(expr.args[1]))
handle(::Val{:struct}, expr) = handle(expr.args[2])
handle(::Union{Val{:abstract}, Val{:primitive}}, expr) = handle(expr.args[1])

handle(::Val{:<:}, expr) = handle(expr.args[1])
handle(::Val{:curly}, expr) = handle(expr.args[1])
handle(::Val{:call}, expr) = handle(expr.args[1])
function handle(::Val{:macrocall}, expr)
    if expr.args[1]==Symbol("@doc") || (expr.args[1] == Core.GlobalRef(Core, Symbol("@doc")))
        if length(expr.args) != 4
            error("@doc expression found with $(length(expr.args)) args:\n$expr")
        end
        handle(expr.args[4])
    else
        filter(x -> x !== nothing, map(handle, expr.args[3:end]))
    end
end

end # module
