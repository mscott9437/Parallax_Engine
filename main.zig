const std = @import("std");

const c = @cImport({@cInclude("sqlite3.h");});

const input_length = 1;
const line_length = 16384;

pub fn main() !void {

	var raw_db: ?*c.sqlite3 = undefined;

	var rc: i32 = c.sqlite3_open("db/main.db", &raw_db);
	defer _ = c.sqlite3_close(raw_db);

	var db: *c.sqlite3 = @ptrCast(*c.sqlite3, raw_db);

	var my_file = try std.fs.cwd().openFile("ss/init.sql", .{},);
	defer my_file.close();

	var sql: [*c]const u8 = undefined;
	var f_buf: [line_length]u8 = undefined;

	while (try my_file.reader().readUntilDelimiterOrEof(&f_buf, '\n')) |line| {
		sql = @ptrCast([*c]const u8, line);
		rc = c.sqlite3_exec(db, sql, null, null, null);
	}

	const stdin = std.io.getStdIn();
	var in_buf: [input_length + 2]u8 = undefined;

	while (true) {
		var input = (try stdin.reader().readUntilDelimiterOrEof(&in_buf, '\n',)).?;
		std.debug.print("{s}\n", .{input},);
	}

}
