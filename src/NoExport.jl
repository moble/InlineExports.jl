module NoExport

import Base: @__doc__

export @export, @public

quote
    """
        @export

    No-op.  Used to disable inline exports.
    """
    macro $(Symbol("export"))(expr::Expr)
        return esc(expr)
    end
end |> eval

"""
    @public

No-op.  Used to disable inline public macro.
"""
macro public(expr::Expr)
    return esc(expr)
end

end # module
