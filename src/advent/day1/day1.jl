using BenchmarkTools
using Printf
using Transducers

values = readlines("src/advent/day1/input.txt") |> Map(v -> parse(Int64, v)) |> collect

#########################################

function part1a(v)
    n = length(v)
    for i = 1:n-1, j=i+1:n
        v[i] + v[j] == 2020 && return (v[i] * v[j], v[i], v[j])
    end
    return Tuple{Int64}()
end

function part1b(v)
    n = length(v)
    Iterators.product(v[1:n-1], v[2:n]) |> Filter(x -> sum(x) == 2020) |> Take(1) |> Map(x -> reduce(*, x)) |> only
end

function part1c(v)
    n = length(v)
    Iterators.product(v[1:n-1], v[2:n]) |> Filter(x -> sum(x) == 2020) |> Map(x -> reduce(*, x)) |> first
end

@printf("part1a(values)=%s\n", part1a(values))
@printf("part1b(values)=%s\n", part1b(values))
@printf("part1c(values)=%s\n", part1c(values))

@assert part1a(values)[1] == 913824
@assert part1b(values) == 913824
@assert part1c(values) == 913824

#########################################

function part2a(v)
    n = length(v)
    for i = 1:n-2
        v[i] > 2020 && continue
        for j = i+1:n-1
            v[i] + v[j] > 2020 && continue
            for k = j+1:n
                v[i] + v[j] + v[k] == 2020 && return (v[i] * v[j] * v[k], v[i], v[j], v[k])
            end
        end
    end
    return Tuple{Int64}()
end

function part2b(v)
    n = length(v)
    Iterators.product(v[1:n-2], v[2:n-1], v[3:n]) |> Filter(x -> sum(x) == 2020) |> Take(1) |> Map(x -> reduce(*, x)) |> only
end

function part2c(v)
    n = length(v)
    Iterators.product(v[1:n-2], v[2:n-1], v[3:n]) |> Filter(x -> sum(x) == 2020) |> Map(x -> reduce(*, x)) |> first
end

@printf("part2a(values)=%s\n", part2a(values))
@printf("part2b(values)=%s\n", part2b(values))
@printf("part2c(values)=%s\n", part2c(values))

@assert part2a(values)[1] == 240889536
@assert part2b(values) == 240889536
@assert part2c(values) == 240889536

#########################################

@btime part1a(values);
@btime part1b(values);
@btime part1c(values);
@btime part2a(values);
@btime part2b(values);
@btime part2c(values);
