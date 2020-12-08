using BenchmarkTools
using Printf
using Transducers

#### Types

struct Group
    records::Array{Set{Char}, 1}
end

function questionsWithYesAnswers(group::Group)
    reduce(union, group.records; init = Set{Char}())
end

function questionsEveryoneAnsweredYesTo(group::Group)
    reduce(intersect, group.records; init = Set{Char}(collect('a':'z')))
end

#### Record source (iterator)

struct RecordSource
    io::IOStream
end

function Base.iterate(iter::RecordSource, state = ())
    records = Array{Set{Char}, 1}()
    while !eof(iter.io)
        line = readline(iter.io)
        line == "" && !isempty(records) && break
        if line != ""
            push!(records, Set{Char}(collect(line)))
        end
    end
    !isempty(records) ? (Group(records), ()) : nothing
end

Base.IteratorSize(::Type{RecordSource}) = Base.SizeUnknown()

Base.IteratorEltype(::Type{RecordSource}) = Base.HasEltype()

Base.eltype(::Type{RecordSource}) = Group

#### Factory methods

function recordSourceFactory(filename)
    factory() = RecordSource(open(filename))
    return factory
end

####

exampleRecordSource = recordSourceFactory("src/advent/day6/example.txt")
inputRecordSource = recordSourceFactory("src/advent/day6/input.txt")

#### Part 1

function part1(recordSource)
    recordSource |> Map(group -> length(questionsWithYesAnswers(group))) |> sum
end

@assert part1(exampleRecordSource()) == 11

@printf("part1 = %d\n", part1(inputRecordSource()))

#collectedRecords = collect(inputRecordSource())
#@btime part1(collectedRecords);

#### Part 2

function part2(recordSource)
    recordSource |> Map(group -> length(questionsEveryoneAnsweredYesTo(group))) |> sum
end

@printf("part2 = %d\n", part2(inputRecordSource()))

#collectedRecords = collect(inputRecordSource())
#@btime part2(collectedRecords);
