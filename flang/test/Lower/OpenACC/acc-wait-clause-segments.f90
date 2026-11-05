! This test checks lowering of OpenACC wait clauses to segmented wait operands.

! RUN: bbc -fopenacc -emit-hlfir %s -o - | FileCheck %s

subroutine wait_default_all()
  !$acc serial wait
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_default_all()
! CHECK: acc.serial wait {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_device_all()
  !$acc serial device_type(nvidia) wait
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_device_all()
! CHECK: acc.serial wait({} [#acc.device_type<nvidia>]) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_one_queue()
  !$acc serial wait(1)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_one_queue()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: acc.serial wait({%[[Q1]] : i32}) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_queue_list()
  !$acc serial wait(1, 2)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_queue_list()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: %[[Q2:.*]] = arith.constant 2 : i32
! CHECK: acc.serial wait({%[[Q1]] : i32, %[[Q2]] : i32}) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_repeated_queues()
  !$acc serial wait(1) wait(2)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_repeated_queues()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: %[[Q2:.*]] = arith.constant 2 : i32
! CHECK: acc.serial wait({%[[Q1]] : i32}, {%[[Q2]] : i32}) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_all_and_queue()
  !$acc serial wait wait(1)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_all_and_queue()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: acc.serial wait({}, {%[[Q1]] : i32}) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_common_and_device()
  !$acc serial wait device_type(nvidia) wait(1)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_common_and_device()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: acc.serial wait({}, {%[[Q1]] : i32} [#acc.device_type<nvidia>]) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_device_all_and_queue()
  !$acc serial device_type(nvidia) wait wait(1)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_device_all_and_queue()
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: acc.serial wait({} [#acc.device_type<nvidia>], {%[[Q1]] : i32} [#acc.device_type<nvidia>]) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }

subroutine wait_devnum_queues(d)
  integer :: d

  !$acc serial wait(devnum: d: queues: 1, 2)
  !$acc end serial
end subroutine

! CHECK-LABEL: func.func @_QPwait_devnum_queues(
! CHECK: %[[D:.*]] = fir.load
! CHECK: %[[Q1:.*]] = arith.constant 1 : i32
! CHECK: %[[Q2:.*]] = arith.constant 2 : i32
! CHECK: acc.serial wait({devnum: %[[D]] : i32, %[[Q1]] : i32, %[[Q2]] : i32}) {
! CHECK-NEXT: acc.yield
! CHECK-NEXT: }
