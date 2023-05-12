const std = @import("std");
const expect = @import("std").testing.expect;

const c = @cImport({

	@cInclude("SDL2/SDL.h");
	@cInclude("SDL2/SDL_ttf.h");
	@cInclude("SDL2/SDL_net.h");

});

const grid_cell = struct { c: u16, bg: *c.SDL_Color, fg: *c.SDL_Color, };

pub fn main() !void {

	const grid_w = 45;
	const grid_h = 20;
	const grid_size = grid_w * grid_h;

	const allocator = std.heap.page_allocator;
	const grid = try allocator.alloc(grid_cell, grid_size);
	defer allocator.free(grid);

	try expect(@TypeOf(grid) == []grid_cell);
	try expect(grid.len == grid_size);

	_ = c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO);
	_ = c.TTF_Init();

	const font = c.TTF_OpenFont("db/CascadiaMono.ttf", 25);

	var cell_w: i32 = undefined;
	var cell_h: i32 = undefined;

	_ = c.TTF_SizeUTF8(font, "@", &cell_w, &cell_h);

	const WIDTH = grid_w * cell_w;
	const HEIGHT = grid_h * cell_h;

	const window = c.SDL_CreateWindow("Parallax Engine", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, c.SDL_WINDOW_SHOWN);
	const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED | c.SDL_RENDERER_PRESENTVSYNC);

	c.TTF_SetFontStyle(font, c.TTF_STYLE_NORMAL); // STYLE_NORMAL | STYLE_BOLD | STYLE_ITALIC | STYLE_UNDERLINE | STYLE_STRIKETHROUGH
	c.TTF_SetFontOutline(font, 0); // 0, 1, 2, etc..
	c.TTF_SetFontKerning(font, 1); // 1, 0
	c.TTF_SetFontHinting(font, c.TTF_HINTING_NORMAL); // NORMAL, LIGHT, MONO, NONE, LIGHT_SUBPIXEL

	const glyph = 63;
	var bg = c.SDL_Color { .r = 0, .g = 0, .b = 0, .a = 255, };
	var fg = c.SDL_Color { .r = 200, .g = 200, .b = 200, .a = 255, };

	var z: u16 = 0;

	while (z < grid_size) {
		grid[z].c = glyph;

		z +=1;
	} 

	_ = c.SDL_SetRenderDrawColor(renderer, bg.r, bg.g, bg.b, bg.a);
	_ = c.SDL_RenderClear(renderer);

	z = 0;

	var x: i32 = 0;
	var y: i32 = 0;

	var dest = c.SDL_Rect { .x = 0, .y = 0, .w = cell_w, .h = cell_h, };

	while (x < grid_w) {
		while (y < grid_h) {
			dest.x = cell_w * x;
			dest.y = cell_h * y;

			const surface = c.TTF_RenderGlyph32_Shaded(font, grid[z].c, bg, fg);
			const texture = c.SDL_CreateTextureFromSurface(renderer, surface);

			_ = c.SDL_SetRenderDrawColor(renderer, bg.r, bg.g, bg.b, bg.a);

			_ = c.SDL_RenderFillRect(renderer, &dest);
			_ = c.SDL_RenderCopy(renderer, texture, null, &dest);

			c.SDL_DestroyTexture(texture);
			c.SDL_FreeSurface(surface);

			std.debug.print("grid={}\n", .{grid[z].c});

			y += 1;
			z += 1;
		}

		y = 0;
		x += 1;
	}

	c.SDL_RenderPresent(renderer);

	var done = c.SDL_FALSE;

	mainloop: while (done != 1) {
		var event: c.SDL_Event = undefined;
		while (c.SDL_PollEvent(&event) != 0) {
			switch (event.type) {
				c.SDL_QUIT => break :mainloop,
				else => {},

	}}}

	c.TTF_CloseFont(font);
	c.TTF_Quit();

	c.SDL_DestroyRenderer(renderer);
	c.SDL_DestroyWindow(window);

	c.SDL_Quit();

}
