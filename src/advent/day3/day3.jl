using BenchmarkTools
using Printf
using Transducers

#### Parsing

function parseEntry(s::AbstractString)::Array{Bool,1}
    out = Array{Bool, 1}(undef, length(s))
    for i = 1:length(s)
        out[i] = (s[i] == '#')
    end
    out
end

#### Reading

function readMap(path)
    readlines(path) |> Map(line -> parseEntry(line)) |> collect
end

#### Logic

function countTrees(map, slope)
    slopeX, slopeY = slope
    count = 0; x = 1; y = 1
    while y <= length(map)
        row = map[y]
        if row[((x - 1) % length(row)) + 1]
            count += 1
        end
        x += slopeX; y += slopeY
    end
    count
end

function multiCountTrees(map, slopes)
    foldxt(*, slopes |> Map(slope -> countTrees(map, slope)))
end

#### Test

exampleMap = readMap("src/advent/day3/example.txt")
testMap = readMap("src/advent/day3/input.txt")

######### Part 1

testSlope = (3, 1)
@assert countTrees(exampleMap, testSlope) == 7

@printf("part1 = %d\n", countTrees(testMap, testSlope))
@btime countTrees(testMap, testSlope);

######### Part 2

testSlopes = ((1, 1), (3, 1), (5, 1), (7, 1), (1, 2))

@assert multiCountTrees(exampleMap, testSlopes) == 336

@printf("part2 = %d\n", multiCountTrees(testMap, testSlopes))
@btime multiCountTrees(testMap, testSlopes);
