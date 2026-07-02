package SpriteManager

import "vendor:raylib"
import stbrp "vendor:stb/rect_pack"
import "core:os"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:encoding/json"

ATLAS_SIZE :: 1024

Sprite :: enum {
	UNKNOWN,
	GRASS,
	WALL,
	PLAYER,
}

// Resolved sprite location — store this on entities instead of the enum.
SpriteHandle :: struct {
	atlas_index: int,
	frames:       [dynamic]raylib.Rectangle,
}

SpriteManager :: struct {
	atlases:        [dynamic]raylib.Texture2D,
	spriteHandles: [Sprite]SpriteHandle,
}

_AsepriteFrameRect :: struct {
	x, y, w, h: int,
}

_AsepriteFrame :: struct {
	filename: string,
	frame:    _AsepriteFrameRect,
}

_AsepriteMeta :: struct {
	image: string,
}

_AsepriteJson :: struct {
	frames: []_AsepriteFrame,
	meta:   _AsepriteMeta,
}

_SpriteEntry :: struct {
	name:          string,
	png_path:      string,
	srcX, srcY:  int,
	w, h:          int,
}

init :: proc(manager: ^SpriteManager) -> bool {
	exe_dir, err := os.get_executable_directory(context.temp_allocator)
	if err != nil {
		log.error("Failed to get executable directory")
		return false
	}

	for sprite in Sprite {
		manager.spriteHandles[sprite].atlas_index = -1
	}

	_loadDirectory(manager, fmt.tprintf("%s/assets", exe_dir))
	return true
}

_loadDirectory :: proc(manager: ^SpriteManager, dir_path: string) {
	files, err := os.read_directory_by_path(dir_path, 0, context.temp_allocator)
	if err != nil {
		log.error("Failed to read directory:", dir_path)
		return
	}

	entries: [dynamic]_SpriteEntry
	defer delete(entries)

	for file in files {
		if file.type == .Regular && strings.has_suffix(file.name, ".json") {
			_parseJson(file.fullpath, dir_path, &entries)
		}
	}

	if len(entries) > 0 {
		_buildAtlas(manager, entries[:])
	}

	for file in files {
		if file.type == .Directory {
			_loadDirectory(manager, file.fullpath)
		}
	}
}

_parseJson :: proc(json_path: string, dir_path: string, entries: ^[dynamic]_SpriteEntry) {
	data, ok := os.read_entire_file(json_path, context.temp_allocator)
	if ok != nil {
		log.error("Failed to read:", json_path)
		return
	}

	parsed: _AsepriteJson
	if parse_err := json.unmarshal(data, &parsed, allocator = context.temp_allocator); parse_err != nil {
		log.error("Failed to parse JSON:", json_path)
		return
	}

	if len(parsed.frames) == 0 || parsed.meta.image == "" {
		return
	}

	name := strings.trim_suffix(parsed.meta.image, ".png")
	png_path := fmt.tprintf("%s/%s", dir_path, parsed.meta.image)

	for frame in parsed.frames {
		append(entries, _SpriteEntry{
			name     = name,
			png_path = png_path,
			srcX    = frame.frame.x,
			srcY    = frame.frame.y,
			w        = frame.frame.w,
			h        = frame.frame.h,
		})
	}
}

_buildAtlas :: proc(manager: ^SpriteManager, entries: []_SpriteEntry) {
	// stb rect_pack needs at least ATLAS_SIZE nodes for optimal results
	nodes := make([]stbrp.Node, ATLAS_SIZE, context.temp_allocator)
	rects := make([]stbrp.Rect, len(entries), context.temp_allocator)

	ctx: stbrp.Context
	stbrp.init_target(&ctx, ATLAS_SIZE, ATLAS_SIZE, raw_data(nodes), i32(len(nodes)))

	for e, i in entries {
		rects[i] = stbrp.Rect{
			id = i32(i),
			w  = stbrp.Coord(e.w),
			h  = stbrp.Coord(e.h),
		}
	}

	stbrp.pack_rects(&ctx, raw_data(rects), i32(len(rects)))

	atlas_img := raylib.GenImageColor(ATLAS_SIZE, ATLAS_SIZE, raylib.BLANK)
	defer raylib.UnloadImage(atlas_img)

	atlas_index := len(manager.atlases)

	loaded_images: map[string]raylib.Image
	defer {
		for _, img in loaded_images {
			raylib.UnloadImage(img)
		}
		delete(loaded_images)
	}

	for rect in rects {
		if !rect.was_packed {
			log.warn("Sprite did not fit in atlas:", entries[rect.id].name)
			continue
		}
		e := entries[rect.id]

		sprite_img, ok := loaded_images[e.png_path]
		if !ok {
			sprite_img = raylib.LoadImage(strings.clone_to_cstring(e.png_path, context.temp_allocator))
			loaded_images[e.png_path] = sprite_img
		}

		src_rect := raylib.Rectangle{f32(e.srcX), f32(e.srcY), f32(e.w), f32(e.h)}
		dst_rect := raylib.Rectangle{f32(rect.x), f32(rect.y), f32(e.w), f32(e.h)}
		raylib.ImageDraw(&atlas_img, sprite_img, src_rect, dst_rect, raylib.WHITE)
		_mapSprite(manager, e.name, atlas_index, dst_rect)
	}

	append(&manager.atlases, raylib.LoadTextureFromImage(atlas_img))
}

_mapSprite :: proc(manager: ^SpriteManager, name: string, atlas_index: int, rect: raylib.Rectangle) {
	for sprite in Sprite {
		if strings.equal_fold(fmt.tprintf("%v", sprite), name) {
			handle := &manager.spriteHandles[sprite]
			handle.atlas_index = atlas_index
			append(&handle.frames, rect)
			return
		}
	}
	log.warn("No Sprite enum value for:", name)
}

getHandle :: proc(manager: ^SpriteManager, sprite: Sprite) -> SpriteHandle {
	return manager.spriteHandles[sprite]
}

drawSprite :: proc(manager: ^SpriteManager, handle: SpriteHandle, x, y: f32, frame_index := 0) {
	if handle.atlas_index < 0 || handle.atlas_index >= len(manager.atlases) {
		return
	}
	if frame_index < 0 || frame_index >= len(handle.frames) {
		return
	}
	texture := manager.atlases[handle.atlas_index]
	source := handle.frames[frame_index]
	dest := raylib.Rectangle{x, y, source.width, source.height}
	raylib.DrawTexturePro(texture, source, dest, {0, 0}, 0, raylib.WHITE)
}

unload :: proc(manager: ^SpriteManager) {
	for texture in manager.atlases {
		raylib.UnloadTexture(texture)
	}
	delete(manager.atlases)
	for sprite in Sprite {
		delete(manager.spriteHandles[sprite].frames)
	}
}
