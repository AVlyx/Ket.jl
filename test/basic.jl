@testset "Basic              " begin
    @testset "Kets" begin
        @test isa(ket(1, 3), Vector{Bool})
        @test isa(proj(1, 3), Hermitian{Bool})
        for R in [Int64, Float64, Double64, Float128, BigFloat]
            ψ = ket(R, 2, 3)
            P = proj(R, 2, 3)
            @test ψ == [0, 1, 0]
            @test isa(ψ, Vector{R})
            @test isa(P, Hermitian{R})
            @test P == ketbra(ψ)
            T = Complex{R}
            ψ = ket(T, 2, 3)
            P = proj(T, 2, 3)
            @test ψ == [0, 1, 0]
            @test isa(ψ, Vector{T})
            @test isa(P, Hermitian{T})
            @test P == ketbra(ψ)
        end
    end
    @testset "Shift and clock" begin
        @test isa(shift(4), Matrix{ComplexF64})
        @test clock(4) == Diagonal([1, im, -1, -im])
        @test isa(clock(4), Diagonal{ComplexF64})
        for R in [Float64, Double64, Float128, BigFloat]
            T = Complex{R}
            @test shift(T, 3) == [0 0 1; 1 0 0; 0 1 0]
            @test clock(T, 3) ≈ Diagonal([1, exp(2 * T(π) * im / 3), exp(-2 * T(π) * im / 3)])
            @test shift(T, 3, 2) == shift(T, 3)^2
            @test clock(T, 3, 2) ≈ clock(T, 3)^2
        end
    end
    @testset "Pauli" begin
        for R in [Int64, Float64, Double64, Float128, BigFloat]
            @test pauli(R, 0) == Matrix{R}(I, 2, 2)
            @test pauli(R, "x") == [0 1; 1 0]
            @test pauli(Complex{R}, 2) == [0 -im; im 0]
            @test pauli(R, 'Z') == [1 0; 0 -1]
            @test pauli(R, "II") == Matrix{R}(I, 4, 4)
            @test pauli(Complex{R}, [3, 3]) == Diagonal([1, -1, -1, 1])
        end
    end
    @testset "Gell-Mann" begin
        for R in [Int64, Float64, Double64, Float128, BigFloat]
            @test gellmann(R, 1, 1) == Matrix{R}(I, 3, 3)
            @test gellmann(R, 1, 2) == [0 1 0; 1 0 0; 0 0 0]
            @test gellmann(R, 1, 3) == [0 0 1; 0 0 0; 1 0 0]
            @test gellmann(Complex{R}, 2, 1) == [0 -im 0; im 0 0; 0 0 0]
            @test gellmann(R, 2, 2) == [1 0 0; 0 -1 0; 0 0 0]
            @test gellmann(R, 2, 3) == [0 0 0; 0 0 1; 0 1 0]
            @test gellmann(Complex{R}, 3, 1) == [0 0 -im; 0 0 0; im 0 0]
            @test gellmann(Complex{R}, 3, 2) == [0 0 0; 0 0 -im; 0 im 0]
        end
        @test gellmann(3, 3) == Diagonal([1, 1, -2] / sqrt(3))
        @test gellmann(1, 1, 4) == Matrix{Float64}(I, 4, 4)
    end
    @testset "Cleanup" begin
        for R in [Float64, Double64, Float128, BigFloat]
            a = zeros(R, 2, 2)
            a[1] = 0.5 * Ket._eps(R)
            a[4] = 1
            b = Hermitian(copy(a))
            c = UpperTriangular(copy(a))
            d = Diagonal(copy(a))
            cleanup!(a)
            cleanup!(b)
            cleanup!(c)
            cleanup!(d)
            @test a == [0 0; 0 1]
            @test b == [0 0; 0 1]
            @test c == [0 0; 0 1]
            @test d == [0 0; 0 1]
            T = Complex{R}
            a = zeros(T, 2, 2)
            a[1] = 0.5 * Ket._eps(T) + im
            a[3] = 1 + 0.5 * Ket._eps(T) * im
            a[4] = 1
            b = Hermitian(copy(a))
            c = UpperTriangular(copy(a))
            d = Diagonal(copy(a))
            cleanup!(a)
            cleanup!(b)
            cleanup!(c)
            cleanup!(d)
            @test a == [im 1; 0 1]
            @test b == [0 1; 1 1]
            @test c == [im 1; 0 1]
            @test d == [im 0; 0 1]
        end
    end
    @testset "Orthonormal range" begin
        for R in [Float64, Double64, Float128, BigFloat, ComplexF64]
            for _ in 1:10
                d1 = rand(5:20)
                d2 = rand(5:20)
                a = rand(R, d1, d2)
                s = orthonormal_range(a; mode = 1)
                @test size(s, 2) == rank(a)
                @test rank(hcat(s, a)) == size(s, 2)
                if R == Float64 || R == ComplexF64
                    q = orthonormal_range(SparseArrays.sparse(a); mode = 0)
                    @test size(s, 2) == size(q, 2)
                    @test rank(hcat(q, a)) == size(q, 2)
                end
            end
        end
    end
    @testset "N-body basis" begin
        @test collect(n_body_basis(0, 2)) == [I(4)]
        @test length(collect(n_body_basis(2, 3))) == 27
        sb = [I(2), I(2), I(2)]
        @test collect(n_body_basis(1, 3; eye = 2I(2), sb)) == [4I(8) for _ in 1:9]
    end
end
