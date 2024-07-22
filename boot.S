.option norvc

.section .data

welcome: .ascii "Welcome to PseudOS!\n\0"
iamhart: .ascii "I am HART \0"
newline: .ascii "\n\0"
_scratchpad:
  .skip 1024


.section .text.init
.global _start

_start:
# Pause all harts except for 0
  csrr t0, mhartid
  bnez t0, _wait

# Print Welcome text
  call _setup_uart
  la a0, welcome
  call _write_uart

# fetch hart id
  csrr t0, mhartid
 # move value into ascii range
 # i.e. 0 -> ascii 0
  li t1, 0x30
  add t0, t1, t0
  la a0, _scratchpad
  sb t0, 0(a0)
  call _write_uart

  la a0, newline
  call _write_uart
  wfi


_setup_uart:
  # qemu uart addr
  # 0x10000000

# Disable interupts on teh UART
  li t1, 0x10000001
  sb x0, 0(t1)

# Write out to the UART Line Control register at UART +3
  li t1, 0x10000003
# Set output to 8 bits
  li t2, 0x03
  sb t2,0(t1)
  ret



_write_uart:
  li t1, 0x10000000
  lb t2, 0(a0)
  beqz t2, _write_uart_end
  sb t2, 0(t1)
  li t2, 1
  add a0, t2, a0
  j _write_uart

_write_uart_end:
  ret



_wait:
  wfi

