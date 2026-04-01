include("search3.jl")

for i in 15:26
	c = tsearchbt(i)
	println("Found $(length(c)) $(i)x$(i) arrays")
	cls = classes(c)
	println("Found $(length(cls)) $(i)x$(i) classes")
	savevar("classes_$(i)x$(i).dat", cls)
end
