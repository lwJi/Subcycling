using Infino

function analytical_psi(t, x)
    return sin(2 * pi * (x - t))
end

function analytical_Pi(t, x)
    return -2 * pi * cos(2 * pi * (x - t))
end

@testset "Scalar Wave Evolution on Unit Grid" begin
    g = Infino.Basic.Grid(100, [[-0.5, 0.5 - 0.01]], 2, 2; cfl = 0.25, verbose = false)
    gfs = Infino.Basic.GridFunction(2, g)
    nxa = g.levs[1].nxa
    nbuf = g.levs[1].nbuf
    # initial data
    psi = gfs.levs[1].u[1]
    Pi = gfs.levs[1].u[2]
    x = gfs.levs[1].x
    @. psi = analytical_psi(0, x)
    @. Pi = analytical_Pi(0, x)
    Infino.Boundary.ApplyPeriodicBoundaryCondition!(gfs)
    # evolution
    for i = 1:4
        Infino.ODESolver.rk4!(Infino.Physical.WaveRHS!, gfs.levs[1])
        Infino.Boundary.ApplyPeriodicBoundaryCondition!(gfs)
    end
    t = g.levs[1].time
    @test isapprox(
        gfs.levs[1].u[1][1+nbuf:nxa-nbuf],
        analytical_psi.(t, x)[1+nbuf:nxa-nbuf];
        rtol = 1e-6,
    )
    @test isapprox(
        gfs.levs[1].u[2][1+nbuf:nxa-nbuf],
        analytical_Pi.(t, x)[1+nbuf:nxa-nbuf];
        rtol = 1e-5,
    )
end
