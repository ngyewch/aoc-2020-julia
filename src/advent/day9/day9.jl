using BenchmarkTools
using Printf
using Transducers

benchmark = true

#### Record source (iterator)

struct RecordSource
    io::IOStream
end

function Base.iterate(iter::RecordSource, state = ())
    if eof(iter.io)
        close(iter.io)
        return nothing
    end
    (parse(Int64, readline(iter.io)), ())
end

Base.IteratorSize(::Type{RecordSource}) = Base.SizeUnknown()

Base.eltype(::Type{RecordSource}) = Int64

#### Factory methods

function recordSourceFactory(filename)
    factory() = RecordSource(open(filename))
    return factory
end

####

exampleRecordSource = recordSourceFactory("src/advent/day9/example.txt")
inputRecordSource = recordSourceFactory("src/advent/day9/input.txt")

####

function part1(recordSource, preambleLength)
    preamble = Array{Int64, 1}(undef, preambleLength)
    foreach(i -> preamble[i] = iterate(recordSource)[1], 1:preambleLength)
    for value ∈ recordSource
        !isvalid(value, preamble) && return value
        deleteat!(preamble, 1)
        push!(preamble, value)
    end
    nothing
end

exampleInvalidNumber = 127
@assert part1(exampleRecordSource(), 5) == exampleInvalidNumber

@show invalidNumber = part1(inputRecordSource(), 25)
benchmark && @btime part1(inputRecordSource(), 25);

####

function part2(recordSource, invalidNumber)
    window = Array{Int64, 1}()
    for value ∈ recordSource
        push!(window, value)
        while true
            total = sum(window)
            total == invalidNumber && return minimum(window) + maximum(window)
            total < invalidNumber && break
            deleteat!(window, 1)
        end
    end
    nothing
end

@assert part2(exampleRecordSource(), exampleInvalidNumber) == 62

@show part2(inputRecordSource(), invalidNumber)
benchmark && @btime part2(inputRecordSource(), invalidNumber);
