module TestInlineExports

using Test

module M1
using InlineExports
@export M1f() = nothing
end

using .M1

@testset "Simple function" begin
    @test M1f() === nothing
end

module M2
using InlineExports
@export begin
    M2f(a) = a^2
    M2a = 2
    "docstring M2b"
    const M2b = 3.0
    @doc raw"docstring M2c ``\alpha``"
    M2c = 7im
end

@export abstract type M2S{T} <: Number end
@export primitive type M2P <: Number 8 end
@export macro M2macro(expr)
    expr
end

@export struct M2TP{T} <: M2S{T}
    val::T
end

@export struct M2T <: M2S{Number}
    val::Number
end

@export @inline M2f(a::M2T) = M2f(a.val)

@export function M2g(a::M2TP{T}) where {T<:Number}
    return convert(T, M2f(a.val))
end

@export M2t = M2T(M2a)
@export M2tp = M2TP(M2c)

"""
    docstring
"""
@export function M2h end

@doc raw"""
    docstring ``\beta``
"""
@export function M2k end

end

using .M2

@testset "Advanced module" begin
    @test M2f(M2a) == 4
    @test M2f(M2b) == 9.0
    @test M2f(M2c) == -49
    @test M2f(M2t) == M2f(M2a)
    @test M2g(M2tp) == M2f(M2c)
    if VERSION >= v"1.11"
        @test Base.Docs.hasdoc(M2, :M2b)
        @test Base.Docs.hasdoc(M2, :M2c)
        @test Base.Docs.hasdoc(M2, :M2h)
        @test Base.Docs.hasdoc(M2, :M2k)
    end
end

module M3
using InlineExports.NoExport
@export M3f() = 42
@public M3g() = 27
end

using .M3

@testset "NoExport" begin
    @test_throws UndefVarError M3f()
    @test M3.M3f() === 42
    @test_throws UndefVarError M3g()
    @test M3.M3g() === 27
end

module M4
using InlineExports
@public begin
    M4f(a) = a^2
    M4a = 2
    "docstring M2b"
    const M4b = 3.0
    @doc raw"docstring M4c ``\alpha``"
    M4c = 7im
end

@public abstract type M4S{T} <: Number end
@public primitive type M4P <: Number 8 end
@public macro M4macro(expr)
    expr
end

@public struct M4TP{T} <: M4S{T}
    val::T
end

@public struct M4T <: M4S{Number}
    val::Number
end

@public @inline M4f(a::M4T) = M4f(a.val)

@public function M4g(a::M4TP{T}) where {T<:Number}
    return convert(T, M4f(a.val))
end

@public M4t = M4T(M4a)
@public M4tp = M4TP(M4c)

"""
    docstring
"""
@public function M4h end

@doc raw"""
    docstring ``\alpha``
"""
@public function M4k end

end

using .M4

@testset "Public" begin
    @test M4.M4f(M4.M4a) == 4
    @test M4.M4f(M4.M4b) == 9.0
    @test M4.M4f(M4.M4c) == -49
    @test M4.M4f(M4.M4t) == M4.M4f(M4.M4a)
    @test M4.M4g(M4.M4tp) == M4.M4f(M4.M4c)

    @test_throws UndefVarError M4a
    @test_throws UndefVarError M4b
    @test_throws UndefVarError M4c
    @test_throws UndefVarError M4f()
    @test_throws UndefVarError M4g()
    @test_throws UndefVarError M4h()
    @test_throws UndefVarError M4k()
    @test_throws UndefVarError M4t
    @test_throws UndefVarError M4tp
    @test_throws UndefVarError M4P
    @test_throws UndefVarError M4S
    @test_throws UndefVarError M4T
    @test_throws UndefVarError M4TP

    if VERSION >= v"1.11"
        @test Base.ispublic(M4, :M4a)
        @test Base.ispublic(M4, :M4b)
        @test Base.ispublic(M4, :M4c)
        @test Base.ispublic(M4, :M4f)
        @test Base.ispublic(M4, :M4g)
        @test Base.ispublic(M4, :M4h)
        @test Base.ispublic(M4, :M4k)
        @test Base.ispublic(M4, :M4t)
        @test Base.ispublic(M4, :M4tp)
        @test Base.ispublic(M4, :M4P)
        @test Base.ispublic(M4, :M4S)
        @test Base.ispublic(M4, :M4T)
        @test Base.ispublic(M4, :M4TP)
        @test Base.ispublic(M4, Symbol("@M4macro"))
        @test Base.Docs.hasdoc(M4, :M4b)
        @test Base.Docs.hasdoc(M4, :M4c)
        @test Base.Docs.hasdoc(M4, :M4h)
        @test Base.Docs.hasdoc(M4, :M4k)
    end
end

end #module
