#include <sqlite3.h>

int main(int argc, char *argv[]) {// char **argv

	sqlite3* db;
	int rc;

	rc = sqlite3_open("test.db", &db);

	sqlite3_close(db);

	return 0;

}
