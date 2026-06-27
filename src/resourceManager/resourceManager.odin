package ResourceManager

import "vendor:raylib"
import "core:os"
import "core:fmt"
import "core:io"
import "core:log"
import "core:strings"

TextureHandle :: distinct int

AsepriteDataeFrameCoordinates :: struct {
  x, y, w, h: int
}

AsepriteDataFrame :: struct {
  frame: AsepriteDataeFrameCoordinates
}

AsepriteData :: struct {
  frames: []AsepriteDataFrame
}

ResourceManager :: struct {
  textures: [dynamic]raylib.Texture,
  textureNameMap: map[string]TextureHandle 
}


//Loading Aseprite JSON file Data
loadDataFiles :: proc() -> (error: bool) {
  exePath, exePathError := os.get_executable_directory(context.temp_allocator)
  
  if exePathError != nil {
    log.error("Could not load executable directory")
    return true
  }

  assetPath := fmt.tprint(exePath, "/assets" , sep="")

  pathToDataMap : map[string]AsepriteData

  loadDataDirectory(&pathToDataMap, assetPath)

  return false
}

loadDataDirectory ::proc(pathToDataMap: ^map[string]AsepriteData, path: string) -> (error: bool) {
  files, readDirError := os.read_directory_by_path(path, 0, context.temp_allocator)

  if readDirError != nil {
    log.error("Could not read directory")
    return true
  }

  for file in files {
    if file.type == .Regular && strings.has_suffix(file.name, ".json") {
      log.debug("Loading File:", file.fullpath)
    }
  }

  for file in files {
    if file.type == os.File_Type.Directory {
      log.debug("Going into directory:", file.name)
      loadDataDirectory(pathToDataMap, file.fullpath)
    }
  }

  return false
}

loadDataFile :: proc()