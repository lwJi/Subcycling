module Symb

using Symbolics

#===============================================================================
RK's interpolant, termed dense output
===============================================================================#
@variables theta, k[1:4], h, yn

b = [
    theta - 3 // 2 * theta^2 + 2 // 3 * theta^3,
    theta^2 - 2 // 3 * theta^3,
    theta^2 - 2 // 3 * theta^3,
    -1 // 2 * theta^2 + 2 // 3 * theta^3,
]

y = yn + sum([b[i] * k[i] for i = 1:length(b)])

dy_symb(ord) = expand_derivatives((Differential(theta)^ord)(y)) / h^ord

dy(ord) = build_function(dy_symb(ord), [theta, k, h], expression = Val{false})

end
