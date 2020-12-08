using BenchmarkTools
using Printf
using Transducers

const BoardingPass = NamedTuple{(:row, :column, :seatId), Tuple{Int64, Int64, Int64}}

function toInt(s::AbstractString, zeroChar::Char, oneChar::Char)::Int64
    value = 0
    for i = 1:length(s)
        value *= 2
        if s[i] == oneChar
            value += 1
        elseif s[i] != zeroChar
            throw(DomainError(s, "valid characters are $zeroChar and $oneChar"))
        end
    end
    value
end

function toBoardingPass(s::AbstractString)::BoardingPass
    row = toInt(s[1:7], 'F', 'B')
    column = toInt(s[8:10], 'L', 'R')
    (row = row, column = column, seatId = row*8+column)
end

function toBoardingPass(seatId::Int64)::BoardingPass
    (row = seatId ÷ 8, column = seatId % 8, seatId = seatId)
end

#### basic tests

@assert toBoardingPass("FBFBBFFRLR") == (row = 44, column = 5, seatId = 357)
@assert toBoardingPass("BFFFBBFRRR") == (row = 70, column = 7, seatId = 567)
@assert toBoardingPass("FFFBBBFRRR") == (row = 14, column = 7, seatId = 119)
@assert toBoardingPass("BBFFBBFRLL") == (row = 102, column = 4, seatId = 820)

@assert toBoardingPass(357) == (row = 44, column = 5, seatId = 357)
@assert toBoardingPass(567) == (row = 70, column = 7, seatId = 567)
@assert toBoardingPass(119) == (row = 14, column = 7, seatId = 119)
@assert toBoardingPass(820) == (row = 102, column = 4, seatId = 820)

#### read data

boardingPasses = readlines("src/advent/day5/input.txt") |> Map(line -> toBoardingPass(line)) |> collect

#### part 1

function highestSeatId(boardingPasses)
    boardingPasses |> Map(pass -> pass.seatId) |> maximum
end

@printf("highestSeatId = %d\n", highestSeatId(boardingPasses))
#@btime highestSeatId(boardingPasses);

#### part 2

function findMySeatId(boardingPasses)
    map = Dict{Int64, BoardingPass}()
    for pass in boardingPasses
        map[pass.seatId] = pass
    end
    for pass in boardingPasses
        if haskey(map, pass.seatId - 2) && !haskey(map, pass.seatId - 1)
            return toBoardingPass(pass.seatId - 1)
        elseif haskey(map, pass.seatId + 2) && !haskey(map, pass.seatId + 1)
            return toBoardingPass(pass.seatId + 1)
        end
    end
end

@printf("mySeatId = %d\n", findMySeatId(boardingPasses).seatId)
#@btime findMySeatId(boardingPasses);

#### part 2: pure MapReduce

function merge(a::UnitRange{Int64}, b::UnitRange{Int64})::Tuple{UnitRange{Int64}, Vararg{UnitRange{Int64}}}
    a.stop + 1 == b.start && return (a.start:b.stop, )
    b.stop + 1 == a.start && return (b.start:a.stop, )
    (a, b)
end

@assert merge(1:1, 2:2) == (1:2, )
@assert merge(2:2, 1:1) == (1:2, )
@assert merge(2:2, 4:4) == (2:2, 4:4)

function merge!(ranges, range1)
    modified = false
    for i ∈ 1:length(ranges)
        results = merge(ranges[i], range1)
        if length(results) == 1
            ranges[i] = results[1]
            modified = true
            break
        end
    end
    if !modified 
        push!(ranges, range1)
    end
    ranges
end

function merge!(ranges)
    modified = false
    while length(ranges) > 1
        changed = false
        i = 1
        while i < length(ranges)
            range = ranges[i]
            for j = i+1:length(ranges)
                results = merge(range, ranges[j])
                if length(results) == 1
                    ranges[i] = results[1]
                    deleteat!(ranges, j)
                    changed = true
                    modified = true
                    break
                end
            end
            i += 1
        end
        !changed && break
    end
    modified
end

function mergeRangeList(a, b)
    #before = (length(a), length(b))
    for range ∈ b
        merge!(a, range)
    end
    while merge!(a)
        # empty body
    end
    #after = length(a)
    #println("---- $before -> $after")
    a
end

function findMySeatId2(boardingPasses)
    ranges = foldxt(mergeRangeList, boardingPasses |> Map(pass -> [pass.seatId:pass.seatId])) |> collect
    sort!(ranges)
    1:length(ranges)-1 |> Map(i -> (ranges[i], ranges[i + 1])) |> Filter(ranges -> ranges[2].start - ranges[1].stop == 2) |> Map(ranges -> toBoardingPass(ranges[1].stop + 1)) |> first

    #for i = 1:length(ranges)-1
    #    range1 = ranges[i]
    #    range2 = ranges[i + 1]
    #    range2.start - range1.stop == 2 && return (seatId = range1.stop + 1, found = true)
    #end
    #(seatId = -1, found = false)
end

@printf("mySeatId2 = %d\n", findMySeatId2(boardingPasses).seatId)
#@btime findMySeatId2(boardingPasses);
