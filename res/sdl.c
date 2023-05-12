#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

struct grid_cell {
	char c;
	SDL_Color* fg;
	SDL_Color* bg;
};

int main(int argc, char *argv[]) {// char **argv

	int grid_w = 83;
	int grid_h = 28;
	int grid_size = grid_w * grid_h;
	int cell_w = 0;
	int cell_h = 0;

	struct grid_cell* grid =
		calloc((size_t)grid_size, sizeof(struct grid_cell));

	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
	TTF_Init();

	TTF_Font* font = TTF_OpenFont("db/FiraMono-Regular.ttf", 20);
	TTF_SizeUTF8(font, "@", &cell_w, &cell_h);

	SDL_Cursor* cursor;
	cursor = SDL_CreateSystemCursor(SDL_SYSTEM_CURSOR_HAND);

	SDL_SetCursor(cursor);

	const int WIDTH = grid_w * cell_w;
	const int HEIGHT = grid_h * cell_h;

	SDL_Window* window = SDL_CreateWindow("Parallax Engine", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_SHOWN);
	SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

	//SDL_CreateWindowAndRenderer(WIDTH, HEIGHT, 0, &swindow, &srenderer);
	//SDL_SetWindowTitle(window, "Parallax Engine");

	TTF_SetFontStyle(font, TTF_STYLE_NORMAL);// STYLE_NORMAL | STYLE_BOLD | STYLE_ITALIC | STYLE_UNDERLINE | STYLE_STRIKETHROUGH
	TTF_SetFontOutline(font, 0);// 0, 1, 2, etc..
	TTF_SetFontKerning(font, 1);// 1, 0
	TTF_SetFontHinting(font, TTF_HINTING_NORMAL);// NORMAL, LIGHT, MONO, NONE, LIGHT_SUBPIXEL

	SDL_bool done = SDL_FALSE;

	char glyph = '?';

	//char waves[] = {'/', '\\'};
	//char* boat[] = {"   _   ", "  |o|  ", "\\_____/"};

	//SDL_Color bg = {255, 255, 255, 255};
	//SDL_Color waves[] = {{55, 55, 55, 255}, {22, 22, 22, 255}};
	//SDL_Color boat = {0, 0, 0, 255};

	//SDL_Color bg = {22, 22, 22, 255};
	//SDL_Color waves[] = {{200, 200, 200, 255}, {99, 99, 99, 255}};
	//SDL_Color  boat = {255, 255, 255, 255};

	SDL_Color bg = {22, 22, 22, 255};
	SDL_Color fg = {200, 200, 200, 255};

	while (!done)
	{
		SDL_Event event;

		while (SDL_PollEvent(&event))
		{
			switch (event.type) {
				case SDL_QUIT:
					done = SDL_TRUE;
					break;
			}
		}

		for (int x = 0; x < grid_w; x++) {
			for (int y = 0; y < grid_h; y++) {
				struct grid_cell* cell = &grid[x + grid_w * y];

				cell->bg = &bg;
				cell->fg = &fg;
				cell->c = glyph;
			}
		}

		SDL_SetRenderDrawColor(renderer, bg.r, bg.g, bg.b, bg.a);
		SDL_RenderClear(renderer);

		SDL_Rect dest = {
			.x = 0,
			.y = 0,
			.w = cell_w,
			.h = cell_h,
		};

		for (int x = 0; x < grid_w; x++) {
			for (int y = 0; y < grid_h; y++) {
				dest.x = cell_w * x;
				dest.y = cell_h * y;

				struct grid_cell* cell = &grid[x + grid_w * y];

				SDL_Surface* surface = TTF_RenderGlyph_Shaded(
					font, (Uint16)cell->c, *cell->fg, *cell->bg);

				SDL_Texture* texture =
					SDL_CreateTextureFromSurface(renderer, surface);

				 SDL_SetRenderDrawColor(renderer, cell->bg->r, cell->bg->g,
					cell->bg->b, cell->bg->a);

				 SDL_RenderFillRect(renderer, &dest);

				 SDL_RenderCopy(renderer, texture, NULL, &dest);

				 SDL_DestroyTexture(texture);
				 SDL_FreeSurface(surface);
			}
		}

		SDL_RenderPresent(renderer);

	}

	free(grid);

	TTF_CloseFont(font);
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);

	TTF_Quit();
	SDL_Quit();

	return 0;

}
