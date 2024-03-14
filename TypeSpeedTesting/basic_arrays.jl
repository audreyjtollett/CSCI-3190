using Dates

const SIZE = 10000
startTime = now()

intArray = rand(Int64, SIZE)

println("Create array Int64 $(now()-startTime)")
startTime = now()

for i in 1:SIZE
	for j in 1:SIZE-i
		if intArray[j] > intArray[j+1]
			tmp = intArray[j]
			intArray[j] = intArray[j+1]
			intArray[j+1] = tmp
		end
	end
end

println("Bubble sort Int64 $(now()-startTime)")
startTime = now()

floatArray = rand(Float64, SIZE)

println("Create array Int64 $(now()-startTime)")
startTime = now()

for i in 1:SIZE
	for j in 1:SIZE-i
		if floatArray[j] > floatArray[j+1]
			tmp = floatArray[j]
			floatArray[j] = floatArray[j+1]
			floatArray[j+1] = tmp
		end
	end
end

println("Bubble sort Float64 $(now()-startTime)")
startTime = now()

anyArray = []
for i in 1:SIZE
  push!(anyArray, rand())
end

println("Pushing any $(now()-startTime)")
startTime = now()

for i in 1:SIZE
	for j in 1:SIZE-i
		if anyArray[j] > anyArray[j+1]
			tmp = anyArray[j]
			anyArray[j] = anyArray[j+1]
			anyArray[j+1] = tmp
		end
	end
end

println("Bubble sort any $(now()-startTime)")
startTime = now()
