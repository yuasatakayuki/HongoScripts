project(HongoScripts)
cmake_minimum_required(VERSION 2.8)

file(GLOB scriptFiles "${CMAKE_CURRENT_SOURCE_DIR}/bin/*")
file(GLOB etcFiles "${CMAKE_CURRENT_SOURCE_DIR}/files/*")
file(GLOB rubyFiles "${CMAKE_CURRENT_SOURCE_DIR}/ruby/*")
install(FILES ${scriptFiles} DESTINATION bin)
install(FILES ${etcFiles} DESTINATION $ENV{HOME}/.hongoscripts/files/)
install(FILES ${rubyFiles} DESTINATION lib/ruby)