const c = @cImport({

	@cInclude("sqlite3.h");

});

pub fn main() !void {

	var db: ?*c.sqlite3 = undefined;
	var rc: i32 = undefined;

	rc = c.sqlite3_open("db/dat.db", &db);

	var select_sql: [*:0]const u8 = "SELECT * from COMPANY";

	exec(db, select_sql, cb) catch {
		std.debug.warn("Failed to select values.\n", .{});
	};

	_ = c.sqlite3_close(db);

}

fn cb(data: ?*c.c_void, argc: c.c_int, argv: [*c][*c]u8, azColName: [*c][*c]u8) callconv(.C) c.c_int {
	var i: usize = 0;

	while (i < argc) {
		if (argv[i] != null) {
			std.debug.warn("{s} = {s}\n", .{ azColName[i], argv[i] });
		} else {
			std.debug.warn("{s} = {}\n", .{ azColName[i], "NULL" });
		}
		i += 1;
	}
	std.debug.warn("\n", .{});
	return 0;
}

pub fn exec(db: *sqlite3, sql: [*:0]const u8, callback: fn(?*c_void, c_int, [*c][*c]u8, [*c][*c]u8) callconv(.C) c_int) !void {
	var errmsg: ?[*:0]u8 = undefined;
	var rc = sqlite3_exec(db, sql, callback, null, &errmsg);
	switch (rc) {
		SQLITE_OK => {
			return;
		},
		SQLITE_ERROR => {
			return Error.Error;
		},
		else => {
			std.debug.warn("{}: {s}\n", .{rc, errmsg});
			return Error.Unimplemented;
		},
	}
	if (rc != SQLITE_OK) {
		sqlite3_free(errmsg);
	}
}
