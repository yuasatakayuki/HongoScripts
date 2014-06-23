project(HongoScripts)
cmake_minimum_required(VERSION 2.8)

file(GLOB scriptFiles "${CMAKE_CURRENT_SOURCE_DIR}/bin/*")
file(GLOB etcFiles "${CMAKE_CURRENT_SOURCE_DIR}/files/*")
install(FILES ${scriptFiles} DESTINATION bin)
install(FILES ${etcFiles} DESTINATION $ENV{HOME}/.hongoscripts/files/)