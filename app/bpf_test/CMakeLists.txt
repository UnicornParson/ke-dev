cmake_minimum_required(VERSION 3.15)
project(ebpf_trap_example CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

# Пути к BPF программе
set(BPF_SRC ${CMAKE_SOURCE_DIR}/src/bpf/bpf_trap.c)
set(BPF_SKEL_H ${CMAKE_SOURCE_DIR}/src/bpf/bpf_trap.skel.h)

# Поиск зависимостей
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBBPF REQUIRED libbpf)
pkg_check_modules(ELF REQUIRED libelf)

# Кастомный поиск libbpf
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
#find_package(LibBpf REQUIRED)
pkg_check_modules(LIBBPF REQUIRED libbpf)
include_directories(
    ${LIBBPF_INCLUDE_DIRS}
    ${ELF_INCLUDE_DIRS}
    ${CMAKE_SOURCE_DIR}/src/bpf
)

add_executable(ebpf_trap src/main.cpp)

target_link_libraries(ebpf_trap
    ${LIBBPF_LIBRARIES}
    ${ELF_LIBRARIES}
    pthread
)

# Правило для генерации .skel.h файла
add_custom_command(
    OUTPUT ${BPF_SKEL_H}
    COMMAND bpftool gen skeleton ${BPF_SRC} > ${BPF_SKEL_H}
    DEPENDS ${BPF_SRC}
    COMMENT "Generating BPF skeleton"
)

add_custom_target(bpf_skel DEPENDS ${BPF_SKEL_H})
add_dependencies(ebpf_trap bpf_skel)