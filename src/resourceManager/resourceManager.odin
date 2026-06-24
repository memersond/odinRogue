package ResourceManager

import "vendor:raylib"
import "core:os"
import "core:fmt"
import "core:io"
import "core:log"

TextureHandle :: distinct int

ResourceManager :: struct {
  textures: [dynamic]raylib.Texture,
  textureNameMap: map[string]TextureHandle 
}


//Loading Aseprite JSON file Data
loadDataFiles :: proc() -> (error: bool) {
  exeDir, exeDirError := os.get_executable_directory(context.temp_allocator)

  if exeDirError != nil {
    log.error("Could not read executable directory")
    return true
  }

  files, readDirError := os.read_directory_by_path(fmt.tprint(exeDir, "/assets", sep=""), 0, context.temp_allocator)

  if readDirError != nil {
    log.error("Could not read directory")
    return true
  }

  for file in files {
    
  }

  return false
}