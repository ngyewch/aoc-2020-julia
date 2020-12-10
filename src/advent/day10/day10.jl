using BenchmarkTools
using Printf
using Transducers

benchmark = true

readData(filename) = readlines(filename) |> Map(line -> parse(Int64, line)) |> collect

example1Data = readData("src/advent/day10/example1.txt")
example2Data = readData("src/advent/day10/example2.txt")
inputData = readData("src/advent/day10/input.txt")

#### part 1

function part1(data)
    differenceCounts = zeros(Int64, 3)
    data1 = sort(data)
    current = 0
    for value ∈ data1
        differenceCounts[value - current] += 1
        current = value
    end
    differenceCounts[3] += 1
    differenceCounts[1] * differenceCounts[3]
end

@assert part1(example1Data) == 35
@assert part1(example2Data) == 220

@show part1(inputData)
benchmark && @btime part1(inputData);

#### part 2

function part2(data)
    function collate(x, y)
        if isempty(x)
            push!(x, (y, 1))
        else
            r = last(x)
            if r[1] == y 
                x[length(x)] = (r[1], r[2] + 1)
            else
                push!(x, (y, 1))
            end
        end
        x
    end

    # magic numbers?
    multipliers = [1, 2, 4, 7]

    data1 = sort(data)
    pushfirst!(data1, 0)
    x = @view data1[1:length(data1)-1]
    y = @view data1[2:length(data1)]

    zip(x, y) |> 
    Map(r -> r[2] - r[1]) |> 
    foldxt(collate; init = Array{Tuple{eltype(data1), Int64}, 1}()) |> 
    Filter(r -> r[1] == 1 && r[2] > 1) |>
    Map(r -> multipliers[r[2]]) |>
    foldxt(*; init = 1)
end

@assert part2(example1Data) == 8
@assert part2(example2Data) == 19208

@show part2(inputData)
benchmark && @btime part2(inputData);
