import sys

pg_file = sys.argv[1]
rs_file = sys.argv[2]


def parse_file(path):
    counts = {}

    with open(path, "r") as f:
        for line in f:

            line = line.strip()

            # Skip empty lines
            if not line:
                continue

            # Skip headers
            if line.lower().startswith("table"):
                continue

            # Skip footer
            if "rows" in line.lower():
                continue

            parts = line.split("|")

            if len(parts) < 2:
                continue

            table = parts[0].strip()

            try:
                count = int(parts[-1].strip())
            except ValueError:
                continue

            counts[table] = count

    return counts


pg = parse_file(pg_file)
rs = parse_file(rs_file)

print("")
print("========================================")
print("SOURCE VS TARGET COUNT VALIDATION")
print("========================================")
print("")

failed = False

for table in sorted(pg.keys()):

    pg_count = pg.get(table, 0)
    rs_count = rs.get(table, 0)

    status = "PASS"

    if pg_count != rs_count:
        status = "FAIL"
        failed = True

    print(
        f"{table:<20} "
        f"postgres={pg_count:<10} "
        f"redshift={rs_count:<10} "
        f"{status}"
    )

print("")

if failed:
    print("Validation FAILED")
    sys.exit(1)

print("Validation PASSED")