
precompile(rotate, (Float64, Float64, Float64))
precompile(rotate, (Float32, Float32, Float32))
precompile(rotate, (Float64, Float64, Float64, Float64))
precompile(rotate, (Float32, Float32, Float32, Float32))

precompile(rotx, (Float32, ))
precompile(rotx, (Float64, ))

precompile(roty, (Float32, ))
precompile(roty, (Float64, ))

precompile(rotz, (Float32, ))
precompile(rotz, (Float64, ))

*(eye(StaticArrays.SMatrix{4, 4, Float32, 16}), eye(StaticArrays.SMatrix{4, 4, Float32, 16}))
