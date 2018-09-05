using StaticArrays

export Vec, Mat, Vec2f, Vec3f, Vec4f, Vec2d, Vec3d, Vec4f, Vec2uc, Vec3uc, Vec4uc, Mat3f, Mat3d, Mat4f, Mat4d

typealias Vec StaticArrays.SVector
typealias Mat StaticArrays.SMatrix

typealias Vec2f Vec{2, Float32}
typealias Vec3f Vec{3, Float32}
typealias Vec4f Vec{4, Float32}

typealias Vec2d Vec{2, Float64}
typealias Vec3d Vec{3, Float64}
typealias Vec4d Vec{4, Float64}

typealias Vec2uc Vec{2, UInt8}
typealias Vec3uc Vec{3, UInt8}
typealias Vec4uc Vec{4, UInt8}

typealias Mat3f Mat{3, 3, Float32}
typealias Mat3d Mat{3, 3, Float64}

typealias Mat4f Mat{4, 4, Float32}
typealias Mat4d Mat{4, 4, Float64}

Vec3f(v::Vec4f) = Vec3f(v[1], v[2], v[3])
