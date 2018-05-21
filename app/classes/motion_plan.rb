class MotionPlan
  module Solver
    extend FFI::Library
    ffi_lib FFI::Library::LIBC
    ffi_lib 'm'
    if OS.mac?
      ffi_lib 'c++'
      ffi_lib './lib/libmp.dylib'
    else
      ffi_lib 'libstdc++.so.6'
      ffi_lib 'libmp.so'
    end

    attach_function :self_collision_step, :backend_selfCollisionStep, [:float, :float, :float, :float, :float, :float], :int  # JOINTS

    attach_function :linear_cartesian_step, :backend_linearCartesianStep, [:float, :float, :float, :float, :float, :float, # JOINTS
                                                                           :float, :float, :float, :float, :float, :float, # JOINTS
                                                                           :float, :float], :pointer

    attach_function :cubic_cartesian_step, :backend_cubicCartesianStep, [:pointer, :pointer, :pointer, :float, :float, :float], :pointer

    attach_function :free_pointer, :backend_freePointer, [:pointer], :void

    attach_function :nudge_step, :backend_translateEndEffector, [:int, :float,
                                                :float, :float, :float, :float, :float, :float], :pointer # JOINTS

    attach_function :ik_step, :backend_ikStep, [:float, :float, :float, :float, :float, :float, # JOINTS
                                          :float, :float, :float,
                                          :float, :float, :float,
                                          :float, :float, :float], :pointer

    attach_function :fk_step, :backend_forwardKinematicsStep, [:float, :float, :float, :float, :float, :float, :float], :pointer # JOINTS
  end


  def self.self_collision_step(angles)
    MotionPlan::Solver.self_collision_step(*angles)
  end

  def self.linear_cartesian_step(angles1, angles2, segment_time, dt = 0.005)
    pointer = MotionPlan::Solver.linear_cartesian_step(*angles1, *angles2, segment_time, dt)
    result = pointer.null? ? [] : trajectory_array(pointer)
    MotionPlan::Solver.free_pointer(pointer)
    result
  end

  def self.cubic_cartesian_step(angles1, angles2, angles3, w1, segment_time, dt = 0.005)
    angles1_pointer = FFI::MemoryPointer.new :float, angles1.size
    angles2_pointer = FFI::MemoryPointer.new :float, angles2.size
    angles3_pointer = FFI::MemoryPointer.new :float, angles3.size

    angles1_pointer.put_array_of_float 0, angles1
    angles2_pointer.put_array_of_float 0, angles2
    angles3_pointer.put_array_of_float 0, angles3

    pointer = MotionPlan::Solver.cubic_cartesian_step(angles1_pointer, angles2_pointer, angles3_pointer, w1, segment_time, dt)
    result = pointer.null? ? [] : trajectory_array(pointer)
    MotionPlan::Solver.free_pointer(pointer)
    result
  end

  # Takes angles, direction and distance
  def self.nudge(direction, distance, angles)
    pointer = MotionPlan::Solver.nudge_step(direction, distance, *angles)
    result = pointer.null? ? [] : pointer.get_array_of_float(0, 7) # JOINTS
    trajectory_hash(result)
  end

  def self.ik_step(angles, geo_origin, geo_x, geo_y)
    pointer = MotionPlan::Solver.ik_step(*angles, *geo_origin, *geo_x, *geo_y)
    result = pointer.null? ? [] : pointer.get_array_of_float(0, 7) # JOINTS
    trajectory_hash(result)
  end

  def self.fk_step(*angles)
    pointer = MotionPlan::Solver.fk_step(*angles)
    result = pointer.null? ? [] : pointer.get_array_of_float(0, 12)
    if result.length < 1
      {}
    else
      {x: result[0], y: result[1], z: result[2]}
    end
  end


  private

  def self.trajectory_array(pointer)
    pointer_size = FFI::Pointer::SIZE
    ik_success = pointer.get_pointer(0 * pointer_size).to_i
    size = pointer.get_pointer(1 * pointer_size).to_i

    pointer.get_array_of_pointer(2 * pointer_size, size).map do |p|
      data = p.get_array_of_float(0, 11)

      {
        x: data[0], y: data[1], z: data[2],
        a0: data[3], a1: data[4], a2: data[5], a3: data[6], a4: data[7], a5: data[8], # JOINTS
        success: data[9] > 0.5
      }
    end
  end

  def self.trajectory_hash(result)
    unless result.empty?
      return { a0: result[0], a1: result[1], a2: result[2], a3: result[3], a4: result[4], a5: result[5], success: result[6].eql?(1.0) ? true : false } # JOINTS
    else
      []
    end
  end

end
