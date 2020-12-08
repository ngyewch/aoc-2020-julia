import Base
using BenchmarkTools
using Printf
using Transducers

#### Record source (iterator)

struct RecordSource
    io::IOStream
end

function Base.iterate(iter::RecordSource, state = ())
    record = Dict{String, String}()
    while !eof(iter.io)
        line = readline(iter.io)
        line == "" && !isempty(record) && break
        if line != ""
            parts = split(line, " ")
            for part in parts
                subparts = split(part, ":"; limit=2)
                record[subparts[1]] = subparts[2]
            end
        end
    end
    !isempty(record) ? (record, ()) : nothing
end

Base.IteratorSize(::Type{RecordSource}) = Base.SizeUnknown()

Base.IteratorEltype(::Type{RecordSource}) = Base.HasEltype()

Base.eltype(::Type{RecordSource}) = Dict{String, String}

#### Factory methods

function recordSourceFactory(filename)
    factory() = RecordSource(open(filename))
    return factory
end

####

exampleRecordSource = recordSourceFactory("src/advent/day4/example.txt")
inputRecordSource = recordSourceFactory("src/advent/day4/input.txt")

function countValid(recordSource, isValid)
    length(recordSource |> Filter(record -> isValid(record)) |> collect)
end

####

function isValid1(record::Dict{String, String})::Bool
    haskey(record, "byr") && 
    haskey(record, "iyr") && 
    haskey(record, "eyr") && 
    haskey(record, "hgt") && 
    haskey(record, "hcl") && 
    haskey(record, "ecl") && 
    haskey(record, "pid")
end

@assert countValid(exampleRecordSource(), isValid1) == 2
@printf("[part1] countValid=%d\n", countValid(inputRecordSource(), isValid1))

records = collect(inputRecordSource())
@btime countValid(records, isValid1);

####

function isValid2(record::Dict{String, String})::Bool
    !isValid1(record) && return false

    byr = parse(Int64, record["byr"])
    (byr < 1920 || byr > 2002) && return false

    iyr = parse(Int64, record["iyr"])
    (iyr < 2010 || iyr > 2020) && return false

    eyr = parse(Int64, record["eyr"])
    (eyr < 2020 || eyr > 2030) && return false

    hgt = record["hgt"]
    if endswith(hgt, "cm")
        v = parse(Int64, hgt[1:length(hgt)-2])
        (v < 150 || v > 193) && return false
    elseif endswith(hgt, "in")
        v = parse(Int64, hgt[1:length(hgt)-2])
        (v < 59 || v > 76) && return false
    else
        return false
    end

    hcl = record["hcl"]
    isnothing(match(r"^#[a-f0-9]{6}$", hcl)) && return false

    ecl = record["ecl"]
    !(ecl in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]) && return false

    pid = record["pid"]
    isnothing(match(r"^[0-9]{9}$", pid)) && return false

    true
end

@assert countValid(RecordSource(open("src/advent/day4/invalid.txt")), isValid2) == 0
@assert countValid(RecordSource(open("src/advent/day4/valid.txt")), isValid2) == 4

@printf("[part2] countValid=%d\n", countValid(inputRecordSource(), isValid2))

#records = collect(inputRecordSource())
@btime countValid(records, isValid2);
